# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic gnome.org meson xdg

DESCRIPTION="Image loading library for GTK+"
HOMEPAGE="https://git.gnome.org/browse/gdk-pixbuf"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"
IUSE="X docs +introspection jpeg jpeg2k tiff test"

RESTRICT="mirror"

COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2
	>=media-libs/libpng-1.4:0=
	>=dev-libs/gobject-introspection-1.62.0:=
	jpeg? ( virtual/jpeg:0= )
	jpeg2k? ( media-libs/jasper:= )
	tiff? ( >=media-libs/tiff-3.9.2:0= )
	X? ( x11-libs/libX11 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-doc-am-1.20
	>=sys-devel/gettext-0.19
	virtual/pkgconfig
"
# librsvg blocker is for the new pixbuf loader API, you lose icons otherwise
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gail-1000
	!<gnome-base/librsvg-2.31.0
	!<x11-libs/gtk+-2.21.3:2
	!<x11-libs/gtk+-2.90.4:3
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gdk-pixbuf-query-loaders$(get_exeext)
)

PATCHES=(
	# See https://bugzilla.gnome.org/show_bug.cgi?id=756590
	"${FILESDIR}"/${PN}-2.32.3-fix-lowmem-uclibc.patch
)

src_configure() {
	# png always on to display icons
	local emesonargs=(
		-Dpng=true
		-Dman=true
		-Dbuiltin_loaders=none
		-Dgir=true
		$(meson_use jpeg)
		$(meson_use jpeg2k jasper)
		$(meson_use tiff)
		$(meson_use X x11)
		$(meson_use docs)
		$(meson_use test installed_tests)
	)

	meson_src_configure
}

src_compile() { meson_src_compile; }

src_install() {
	# Parallel install fails when no gdk-pixbuf is already installed, bug #481372
	MAKEOPTS="${MAKEOPTS} -j1" meson_src_install
}

pkg_preinst() {
	xdg_pkg_preinst

    # Make sure loaders.cache belongs to gdk-pixbuf alone
    local cache="usr/$(get_libdir)/${PN}-2.0/2.10.0/loaders.cache"

    if [[ -e ${EROOT}${cache} ]]; then
        cp "${EROOT}"${cache} "${ED}"/${cache} || die
    else
        touch "${ED}"/${cache} || die
    fi
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER

	xdg_pkg_postinst
#>>>
	gdk-pixbuf-query-loaders >"${EROOT}"usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
#>>>

	# Migration snippet for when this was handled by gtk+
	if [ -e "${EROOT}"usr/lib/gtk-2.0/2.*/loaders ]; then
		elog "You need to rebuild ebuilds that installed into" "${EROOT}"usr/lib/gtk-2.0/2.*/loaders
		elog "to do that you can use qfile from portage-utils:"
		elog "emerge -va1 \$(qfile -qC ${EPREFIX}/usr/lib/gtk-2.0/2.*/loaders)"
	fi
}

pkg_postrm() {
	xdg_pkg_postrm

	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		rm -f "${EROOT}"usr/lib*/${PN}-2.0/2.10.0/loaders.cache
	fi
}
