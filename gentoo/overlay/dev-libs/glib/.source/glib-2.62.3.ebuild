# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_5,3_6,3_7} )

#TODO most of those classes are not used
inherit meson bash-completion-r1 epunt-cxx flag-o-matic gnome.org gnome2-utils libtool linux-info \
	pax-utils python-any-r1 toolchain-funcs virtualx xdg

# Until bug #537330 glib is a reverse dependency of pkgconfig and, then
# adding new dependencies end up making stage3 to grow. Every addition needs
# then to be think very closely.

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="https://www.gtk.org/"
SRC_URI="${SRC_URI}
	https://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz" # pkg.m4 for eautoreconf

LICENSE="LGPL-2.1+"
SLOT="2"
IUSE="dbus fam gtk-doc kernel_linux +mime selinux static-libs systemtap test xattr"
KEYWORDS="*"

RDEPEND="
	!<dev-util/gdbus-codegen-${PV}
	>=dev-libs/libpcre-8.31:3[static-libs?]
	>=virtual/libiconv-0-r1
	>=virtual/libffi-3.0.13-r1:=
	>=virtual/libintl-0-r2
	>=sys-libs/zlib-1.2.8-r1
	kernel_linux? ( >=sys-apps/util-linux-2.23 )
	selinux? ( >=sys-libs/libselinux-2.2.2-r5 )
	xattr? ( >=sys-apps/attr-2.4.47-r1 )
	fam? ( >=virtual/fam-0-r1 )
	>=dev-util/gdbus-codegen-${PV}
	virtual/libelf:0=
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.1.2
	app-text/docbook-xsl-stylesheets
	>=dev-libs/libxslt-1.0
	>=sys-devel/gettext-0.11
	gtk-doc? ( >=dev-util/gtk-doc-1.20 )
	systemtap? ( >=dev-util/systemtap-1.3 )
	${PYTHON_DEPS}
	test? (
		sys-devel/gdb
		>=dev-util/gdbus-codegen-${PV}
		>=sys-apps/dbus-1.2.14 )
"

# Migration of glib-genmarshal, glib-mkenums and gtester-report to a separate
# python depending package, which can be buildtime depended in packages that
# need these tools, without pulling in python at runtime.
RDEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-util/glib-utils-${PV}"
PDEPEND="
	dbus? ( gnome-base/dconf )
	mime? ( x11-misc/shared-mime-info )
"
# shared-mime-info needed for gio/xdgmime, bug #409481
# dconf is needed to be able to save settings, bug #498436

pkg_setup() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY_USER"
		if use test ; then
			CONFIG_CHECK="~IPV6"
			WARNING_IPV6="Your kernel needs IPV6 support for running some tests, skipping them."
		fi
		linux-info_pkg_setup
	fi
	python-any-r1_pkg_setup
}

src_prepare() {
	default
	# Prevent build failure in stage3 where pkgconfig is not available, bug #481056
	mv -f "${WORKDIR}"/pkg-config-*/pkg.m4 "${S}"/m4macros/ || die

	if use test; then
		# Disable tests requiring dev-util/desktop-file-utils when not installed, bug #286629, upstream bug #629163
		if ! has_version dev-util/desktop-file-utils ; then
			ewarn "Some tests will be skipped due dev-util/desktop-file-utils not being present on your system,"
			ewarn "think on installing it to get these tests run."
			sed -i -e "/appinfo\/associations/d" gio/tests/appinfo.c || die
			sed -i -e "/g_test_add_func/d" gio/tests/desktop-app-info.c || die
		fi

		# gdesktopappinfo requires existing terminal (gnome-terminal or any
		# other), falling back to xterm if one doesn't exist
		#if ! has_version x11-terms/xterm && ! has_version x11-terms/gnome-terminal ; then
		#	ewarn "Some tests will be skipped due to missing terminal program"
		# These tests seem to sometimes fail even with a terminal; skip for now and reevulate with meson
		# Also try https://gitlab.gnome.org/GNOME/glib/issues/1601 once ready for backport (or in a bump) and file new issue if still fails
		sed -i -e "/appinfo\/launch/d" gio/tests/appinfo.c || die
		# desktop-app-info/launch* might fail similarly
		sed -i -e "/desktop-app-info\/launch-as-manager/d" gio/tests/desktop-app-info.c || die
		#fi

		# https://bugzilla.gnome.org/show_bug.cgi?id=722604
		sed -i -e "/timer\/stop/d" glib/tests/timer.c || die
		sed -i -e "/timer\/basic/d" glib/tests/timer.c || die

		ewarn "Tests for search-utils have been skipped"
		sed -i -e "/search-utils/d" glib/tests/meson.build || die
	else
		# Don't build tests, also prevents extra deps, bug #512022
		sed -i -e "/subdir('tests')/d" {.,gio,glib}/meson.build || die
	fi

	# gdbus-codegen is a separate package
	sed -i -e "s/install : true/install : false/" gio/gdbus-2.0/codegen/meson.build
	sed -i -e "s/install_dir : get_option('bindir')/install_dir : '' /" gio/gdbus-2.0/codegen/meson.build
	sed -i -e "s/[, ]*'gdbus-codegen.*'[,]*//" docs/reference/gio/meson.build

	sed -i -e "s/'python3'/'python'/" meson.build

	# Tarball doesn't come with gtk-doc.make and we can't unconditionally depend on dev-util/gtk-doc due
	# to circular deps during bootstramp. If actually not building gtk-doc, an almost empty file will do
	# fine as well - this is also what upstream autogen.sh does if gtkdocize is not found. If gtk-doc is
	# installed, eautoreconf will call gtkdocize, which overwrites the empty gtk-doc.make with a full copy.
	cat > gtk-doc.make << EOF
EXTRA_DIST =
CLEANFILES =
EOF
}

src_configure() {
	# Avoid circular depend with dev-util/pkgconfig and
	# native builds (cross-compiles won't need pkg-config
	# in the target ROOT to work here)
	if ! tc-is-cross-compiler && ! $(tc-getPKG_CONFIG) --version >& /dev/null; then
		if has_version sys-apps/dbus; then
			export DBUS1_CFLAGS="-I/usr/include/dbus-1.0 -I/usr/$(get_libdir)/dbus-1.0/include"
			export DBUS1_LIBS="-ldbus-1"
		fi
		export LIBFFI_CFLAGS="-I$(echo /usr/$(get_libdir)/libffi-*/include)"
		export LIBFFI_LIBS="-lffi"
		export PCRE_CFLAGS=" " # test -n "$PCRE_CFLAGS" needs to pass
		export PCRE_LIBS="-lpcre"
	fi

	# These configure tests don't work when cross-compiling.
	if tc-is-cross-compiler ; then
		# https://bugzilla.gnome.org/show_bug.cgi?id=756473
		case ${CHOST} in
		hppa*|metag*) export glib_cv_stack_grows=yes ;;
		*)            export glib_cv_stack_grows=no ;;
		esac
		# https://bugzilla.gnome.org/show_bug.cgi?id=756474
		export glib_cv_uscore=no
		# https://bugzilla.gnome.org/show_bug.cgi?id=756475
		export ac_cv_func_posix_get{pwuid,grgid}_r=yes
	fi

	local emesonargs=(
                -Dc_args="${CFLAGS}"
		-Dman=true
		-Dinternal_pcre=false
		-Ddefault_library=$(usex static-libs both shared)
		$(meson_use xattr)
		$(meson_use fam)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use kernel_linux libmount)
		-Dselinux=$(usex selinux enabled disabled)
		$(meson_use systemtap dtrace)
		$(meson_use systemtap)
	)

	meson_src_configure
}

src_test() {
	export XDG_CONFIG_DIRS=/etc/xdg
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
	export G_DBUS_COOKIE_SHA1_KEYRING_DIR="${T}/temp"
	export LC_TIME=C # bug #411967
	unset GSETTINGS_BACKEND # bug #596380
	python_setup

	# Related test is a bit nitpicking
	mkdir "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"
	chmod 0700 "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"

	# Hardened: gdb needs this, bug #338891
	if host-is-pax ; then
		pax-mark -mr "${BUILD_DIR}"/tests/.libs/assert-msg-test \
			|| die "Hardened adjustment failed"
	fi

	# Need X for dbus-launch session X11 initialization
	virtx emake check
}

src_install() {
	meson_src_install completiondir="$(get_bashcompdir)"
	keepdir /usr/$(get_libdir)/gio/modules
	einstalldocs

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/$(get_libdir)/charset.alias"

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"

	# Completely useless with or without USE static-libs, people need to use pkg-config
	find "${ED}" -name '*.la' -delete || die
}

pkg_preinst() {
	xdg_pkg_preinst

	# Make gschemas.compiled belong to glib alone
	local cache="usr/share/glib-2.0/schemas/gschemas.compiled"

	if [[ -e ${EROOT}${cache} ]]; then
		cp "${EROOT}"${cache} "${ED}"/${cache} || die
	else
		touch "${ED}"/${cache} || die
	fi

	if ! tc-is-cross-compiler ; then
		# Make giomodule.cache belong to glib alone
		local cache="usr/$(get_libdir)/gio/modules/giomodule.cache"

		if [[ -e ${EROOT}${cache} ]]; then
			cp "${EROOT}"${cache} "${ED}"/${cache} || die
		else
			touch "${ED}"/${cache} || die
		fi
	fi
}

pkg_postinst() {
	# force (re)generation of gschemas.compiled
	GNOME2_ECLASS_GLIB_SCHEMAS="force"

	xdg_pkg_postinst

	if ! tc-is-cross-compiler ; then
		gnome2_giomodule_cache_update || die "Update GIO modules cache failed"
	else
		ewarn "Updating of GIO modules cache skipped due to cross-compilation."
		ewarn "You might want to run gio-querymodules manually on the target for"
		ewarn "your final image for performance reasons and re-run it when packages"
		ewarn "installing GIO modules get upgraded or added to the image."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm

	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		rm -f "${EROOT}"usr/$(get_libdir)/gio/modules/giomodule.cache
		rm -f "${EROOT}"usr/share/glib-2.0/schemas/gschemas.compiled
	fi
}

