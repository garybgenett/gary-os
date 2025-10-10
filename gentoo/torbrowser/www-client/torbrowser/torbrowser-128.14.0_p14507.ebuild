# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FIREFOX_PATCHSET="firefox-128esr-patches-12.tar.xz"

LLVM_COMPAT=( 17 18 19 )

PYTHON_COMPAT=( python3_{11..13} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

# This will also filter rust versions that don't match LLVM_COMPAT in the non-clang path; this is fine.
RUST_NEEDS_LLVM=1
# If not building with clang we need at least rust 1.76
RUST_MIN_VER=1.77.1

WANT_AUTOCONF="2.1"

# Convert the ebuild version to the upstream Mozilla version
MOZ_PV="${PV/_p*}esr"

# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-14.5/projects/firefox/config?ref_type=heads#L17
# and https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-14.5/projects/browser/config?ref_type=heads#L114
# and https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tags
TOR_PV="14.5.7"
TOR_TAG="${TOR_PV%.*}-1-build5"
NOSCRIPT_VERSION="13.0.9"
NOSCRIPT_ID="4551629"
CHANGELOG_TAG="${TOR_PV}-build1"

inherit autotools check-reqs desktop flag-o-matic linux-info llvm-r1 multiprocessing \
	pax-utils python-any-r1 rust toolchain-funcs xdg

TOR_SRC_BASE_URI="https://dist.torproject.org/torbrowser/${TOR_PV}"
TOR_SRC_ARCHIVE_URI="https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}"

PATCH_URIS=(
	https://dev.gentoo.org/~juippis/mozilla/patchsets/${FIREFOX_PATCHSET}
)

DESCRIPTION="Private browsing without tracking, surveillance, or censorship"
HOMEPAGE="https://www.torproject.org/ https://gitlab.torproject.org/tpo/applications/tor-browser/"
SRC_URI="
	${TOR_SRC_BASE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_BASE_URI}/tor-browser-linux-x86_64-${TOR_PV}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/tor-browser-linux-x86_64-${TOR_PV}.tar.xz
	https://addons.mozilla.org/firefox/downloads/file/${NOSCRIPT_ID}/noscript-${NOSCRIPT_VERSION}.xpi
	https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/raw/tbb-${CHANGELOG_TAG}/projects/browser/Bundle-Data/Docs-TBB/ChangeLog.txt -> ${P}-ChangeLog.txt
	${PATCH_URIS[@]}"

S="${WORKDIR}/firefox-tor-browser-${MOZ_PV}-${TOR_TAG}"
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+clang dbus hardened pulseaudio"
IUSE+=" +system-av1 +system-harfbuzz +system-icu +system-jpeg +system-libevent +system-libvpx"
IUSE+=" system-png +system-webp wayland +X"

REQUIRED_USE="|| ( X wayland )
	wayland? ( dbus )"

BDEPEND="${PYTHON_DEPS}
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}
		clang? (
			llvm-core/lld:${LLVM_SLOT}
		)
	')
	app-alternatives/awk
	app-arch/unzip
	app-arch/zip
	>=dev-util/cbindgen-0.26.0
	net-libs/nodejs
	virtual/pkgconfig
	amd64? ( >=dev-lang/nasm-2.14 )
	x86? ( >=dev-lang/nasm-2.14 )"

COMMON_DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libffi:=
	>=dev-libs/nss-3.101
	>=dev-libs/nspr-4.35
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa
	media-video/ffmpeg
	sys-libs/zlib
	virtual/freedesktop-icon-theme
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/pango
	x11-libs/pixman
	dbus? (
		sys-apps/dbus
	)
	pulseaudio? (
		|| (
			media-libs/libpulse
			>=media-sound/apulse-0.1.12-r4[sdk]
		)
	)
	system-av1? (
		>=media-libs/dav1d-1.0.0:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-libs/harfbuzz-2.8.1:0=
	)
	system-icu? ( >=dev-libs/icu-73.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1:= )
	system-libevent? ( >=dev-libs/libevent-2.1.12:0=[threads(+)] )
	system-libvpx? ( >=media-libs/libvpx-1.8.2:0=[postproc] )
	system-png? ( >=media-libs/libpng-1.6.35:0=[apng] )
	system-webp? ( >=media-libs/libwebp-1.1.0:0= )
	wayland? (
		>=media-libs/libepoxy-1.5.10-r1
		x11-libs/gtk+:3[wayland]
	)
	X? (
		virtual/opengl
		x11-libs/cairo[X]
		x11-libs/gtk+:3[X]
		x11-libs/libX11
		x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXrandr
		x11-libs/libxcb:=
	)"
RDEPEND="${COMMON_DEPEND}
	!www-client/torbrowser-launcher"

DEPEND="${COMMON_DEPEND}
	X? (
		x11-base/xorg-proto
		x11-libs/libICE
		x11-libs/libSM
	)"

llvm_check_deps() {
	if ! has_version -b "llvm-core/clang:${LLVM_SLOT}" ; then
		einfo "llvm-core/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang && ! tc-ld-is-mold ; then
		if ! has_version -b "llvm-core/lld:${LLVM_SLOT}" ; then
			einfo "llvm-core/lld:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

moz_clear_vendor_checksums() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -ne 1 ]] ; then
		die "${FUNCNAME} requires exact one argument"
	fi

	einfo "Clearing cargo checksums for ${1} ..."

	sed -i \
		-e 's/\("files":{\)[^}]*/\1/' \
		"${S}"/third_party/rust/${1}/.cargo-checksum.json || die
}

mozconfig_add_options_ac() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "ac_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_add_options_mk() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "mk_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_use_enable() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_enable "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

mozconfig_use_with() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_with "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="6600M"

	check-reqs_pkg_pretend
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]] ; then

		# Ensure we have enough disk space to compile
		CHECKREQS_DISK_BUILD="6400M"

		check-reqs_pkg_setup
		llvm-r1_pkg_setup
		rust_pkg_setup
		python-any-r1_pkg_setup

		# These should *always* be cleaned up anyway
		unset \
			DBUS_SESSION_BUS_ADDRESS \
			DISPLAY \
			ORBIT_SOCKETDIR \
			SESSION_MANAGER \
			XAUTHORITY \
			XDG_CACHE_HOME \
			XDG_SESSION_COOKIE

		# Build system is using /proc/self/oom_score_adj, bug #604394
		addpredict /proc/self/oom_score_adj

		if ! mountpoint -q /dev/shm ; then
			# If /dev/shm is not available, configure is known to fail with
			# a traceback report referencing /usr/lib/pythonN.N/multiprocessing/synchronize.py
			ewarn "/dev/shm is not mounted -- expect build failures!"
		fi

		# Ensure we use C locale when building, bug #746215
		export LC_ALL=C
	fi

	CONFIG_CHECK="~SECCOMP"
	WARNING_SECCOMP="CONFIG_SECCOMP not set! This system will be unable to play DRM-protected content."
	linux-info_pkg_setup
}

src_prepare() {
	# Workaround for bgo#917599
	if has_version ">=dev-libs/icu-74.1" && use system-icu ; then
		eapply "${WORKDIR}"/firefox-patches/*-bmo-1862601-system-icu-74.patch
	fi
	rm -v "${WORKDIR}"/firefox-patches/*-bmo-1862601-system-icu-74.patch || die

	# Workaround for bgo#915651 on musl
	if use elibc_glibc ; then
		rm -v "${WORKDIR}"/firefox-patches/*bgo-748849-RUST_TARGET_override.patch || die
	fi

	eapply "${WORKDIR}/firefox-patches"

	# https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/20497#note_2873088
	sed -i \
		-e "s/MOZ_APP_VENDOR=\"Tor Project\"/MOZ_APP_VENDOR=\"TorProject\"/" \
		"${S}"/browser/confvars.sh || die

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Make cargo respect MAKEOPTS
	export CARGO_BUILD_JOBS="$(makeopts_jobs)"

	# Workaround for bgo#915651
	if ! use elibc_glibc ; then
		if use amd64 ; then
			export RUST_TARGET="x86_64-unknown-linux-musl"
		else
			die "Unsupported architecture ${CHOST}"
		fi
	fi

	# Make LTO respect MAKEOPTS
	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/lto-pgo.configure || die "Failed sedding multiprocessing.cpu_count"

	# Make ICU respect MAKEOPTS
	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/intl/icu_sources_data.py || die "Failed sedding multiprocessing.cpu_count"

	# Respect MAKEOPTS all around (maybe some find+sed is better)
	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/python/mozbuild/mozbuild/base.py || die "Failed sedding multiprocessing.cpu_count"

	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/third_party/libwebrtc/build/toolchain/get_cpu_count.py || die "Failed sedding multiprocessing.cpu_count"

	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/third_party/libwebrtc/build/toolchain/get_concurrent_links.py ||
			die "Failed sedding multiprocessing.cpu_count"

	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/third_party/python/gyp/pylib/gyp/input.py || die "Failed sedding multiprocessing.cpu_count"

	sed -i -e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/python/mozbuild/mozbuild/code_analysis/mach_commands.py || die "Failed sedding multiprocessing.cpu_count"

	# sed-in toolchain prefix
	sed -i \
		-e "s/objdump/${CHOST}-objdump/" \
		"${S}"/python/mozbuild/mozbuild/configure/check_debug_ranges.py || die "sed failed to set toolchain prefix"

	sed -i \
		-e 's/ccache_stats = None/return None/' \
		"${S}"/python/mozbuild/mozbuild/controller/building.py || die "sed failed to disable ccache stats call"

	einfo "Removing pre-built binaries ..."

	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

	# Clear checksums from cargo crates we've manually patched.
	# moz_clear_vendor_checksums xyz

	# Changing the value for FILES_PER_UNIFIED_FILE may not work, see #905431
	if [[ -n ${FILES_PER_UNIFIED_FILE} ]]; then
		local my_files_per_unified_file=${FILES_PER_UNIFIED_FILE:=16}
		elog ""
		elog "build defaults modified to ${my_files_per_unified_file}."
		elog "if you get a build failure, try undefining FILES_PER_UNIFIED_FILE,"
		elog ""

		sed -i -e "s/\"FILES_PER_UNIFIED_FILE\", 16/\"FILES_PER_UNIFIED_FILE\", "${my_files_per_unified_file}"/" \
			python/mozbuild/mozbuild/frontend/data.py ||
				die "Failed to adjust FILES_PER_UNIFIED_FILE in python/mozbuild/mozbuild/frontend/data.py"
		sed -i -e "s/FILES_PER_UNIFIED_FILE = 6/FILES_PER_UNIFIED_FILE = "${my_files_per_unified_file}"/" \
			js/src/moz.build ||
				die "Failed to adjust FILES_PER_UNIFIED_FILE in js/src/moz.build"
	fi

	# Create build dir
	BUILD_DIR="${WORKDIR}/${PN}_build"
	mkdir -p "${BUILD_DIR}" || die

	xdg_environment_reset
}

src_configure() {
	# Show flags set at the beginning
	einfo "Current BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Current CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Current CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Current LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Current RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	local have_switched_compiler=
	if use clang; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."

		local version_clang=$(clang --version 2>/dev/null | grep -F -- 'clang version' | awk '{ print $3 }')
		[[ -n ${version_clang} ]] && version_clang=$(ver_cut 1 "${version_clang}")
		[[ -z ${version_clang} ]] && die "Failed to read clang version!"

		if tc-is-gcc; then
			have_switched_compiler=yes
		fi

		AR=llvm-ar
		CC=${CHOST}-clang-${version_clang}
		CXX=${CHOST}-clang++-${version_clang}
		NM=llvm-nm
		RANLIB=llvm-ranlib
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		have_switched_compiler=yes
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	if [[ -n "${have_switched_compiler}" ]] ; then
		# Because we switched active compiler we have to ensure
		# that no unsupported flags are set
		strip-unsupported-flags
	fi

	# Ensure we use correct toolchain,
	# AS is used in a non-standard way by upstream, #bmo1654031
	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	export AS="$(tc-getCC) -c"

	# Configuration tests expect llvm-readelf output, bug 913130
	READELF="llvm-readelf"

	tc-export CC CXX LD AR AS NM OBJDUMP RANLIB READELF PKG_CONFIG

	# Pass the correct toolchain paths through cbindgen
	if tc-is-cross-compiler ; then
		export BINDGEN_CFLAGS="${SYSROOT:+--sysroot=${ESYSROOT}} --target=${CHOST} ${BINDGEN_CFLAGS-}"
	fi

	# Set MOZILLA_FIVE_HOME
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set state path
	export MOZBUILD_STATE_PATH="${BUILD_DIR}"

	# Set MOZCONFIG
	export MOZCONFIG="${S}/.mozconfig"

	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application=browser
	mozconfig_add_options_ac '' --enable-project=browser

	# Set Gentoo defaults
	mozconfig_add_options_ac 'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-disk-remnant-avoidance \
		--disable-geckodriver \
		--disable-gpsd \
		--disable-install-strip \
		--disable-legacy-profile-creation \
		--disable-parental-controls \
		--disable-strip \
		--disable-tests \
		--disable-updater \
		--disable-valgrind \
		--disable-wmf \
		--enable-negotiateauth \
		--enable-new-pass-manager \
		--enable-official-branding \
		--enable-release \
		--enable-system-pixman \
		--enable-system-policies \
		--host="${CBUILD:-${CHOST}}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--without-wasm-sandboxed-libraries \
		--with-intl-api \
		--with-libclang-path="$(llvm-config --libdir)" \
		--with-system-ffi \
		--with-system-nspr \
		--with-system-nss \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes=app,system \
		--x-includes="${ESYSROOT}/usr/include" \
		--x-libraries="${ESYSROOT}/usr/$(get_libdir)"

	einfo "Building without Mozilla API key ..."

	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libevent
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-png
	mozconfig_use_with system-webp

	mozconfig_use_enable dbus
	mozconfig_add_options_ac ''  --disable-libproxy

	mozconfig_add_options_ac '' --disable-eme

	if use hardened ; then
		mozconfig_add_options_ac "+hardened" --enable-hardening
		append-ldflags "-Wl,-z,relro -Wl,-z,now"

		# Increase the FORTIFY_SOURCE value, #910071.
		sed -i -e '/-D_FORTIFY_SOURCE=/s:2:3:' "${S}"/build/moz.configure/toolchain.configure || die
	fi

	local myaudiobackends=""
	use pulseaudio && myaudiobackends+="pulseaudio,"
	! use pulseaudio && myaudiobackends+="alsa,"

	mozconfig_add_options_ac '--enable-audio-backends' --enable-audio-backends="${myaudiobackends::-1}"

	mozconfig_add_options_ac '' --disable-necko-wifi

	if use X && use wayland ; then
		mozconfig_add_options_ac '+x11+wayland' --enable-default-toolkit=cairo-gtk3-x11-wayland
	elif ! use X && use wayland ; then
		mozconfig_add_options_ac '+wayland' --enable-default-toolkit=cairo-gtk3-wayland-only
	else
		mozconfig_add_options_ac '+x11' --enable-default-toolkit=cairo-gtk3-x11-only
	fi

	# LTO is handled via configure.
	# -Werror=lto-type-mismatch -Werror=odr are going to fail with GCC,
	# bmo#1516758, bgo#942288
	filter-lto
	filter-flags -Werror=lto-type-mismatch -Werror=odr

	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40745
	export MOZ_APP_BASENAME="TorBrowser"

	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-14.5/projects/firefox/build#L112
	mozconfig_add_options_ac 'torbrowser' \
		--with-base-browser-version=${TOR_PV} \
		--enable-update-channel=release \
		--with-branding=browser/branding/tb-release \
		--without-wasm-sandboxed-libraries

	# see https://gitlab.torproject.org/tpo/applications/tor-browser/-/blob/tor-browser-128.9.0esr-14.5-1/browser/config/mozconfigs/tor-browser
	mozconfig_add_options_mk 'torbrowser' "MOZ_APP_DISPLAYNAME=\"Tor Browser\""
	mozconfig_add_options_ac 'torbrowser' \
		--without-relative-data-dir \
		--with-user-appdir=.torproject \
		--with-distribution-id=org.torproject

	# see https://gitlab.torproject.org/tpo/applications/tor-browser/-/blob/tor-browser-128.9.0esr-14.5-1/browser/config/mozconfigs/base-browser
	export MOZILLA_OFFICIAL=1
	mozconfig_add_options_ac 'torbrowser' \
		--enable-official-branding \
		--enable-optimize \
		--enable-rust-simd \
		--disable-unverified-updates \
		--disable-base-browser-update \
		--enable-bundled-fonts \
		--disable-tests \
		--disable-debug \
		--disable-crashreporter \
		--disable-webrtc \
		--disable-parental-controls \
		--enable-proxy-bypass-protection \
		--disable-system-policies \
		--disable-backgroundtasks \
		MOZ_TELEMETRY_REPORTING= \
		--disable-legacy-profile-creation \
		--enable-geckodriver

	# Avoid auto-magic on linker
	if use clang ; then
		# lld is upstream's default
		if tc-ld-is-mold ; then
			mozconfig_add_options_ac "using ld=mold due to system selection" --enable-linker=mold
		else
			mozconfig_add_options_ac "forcing ld=lld due to USE=clang" --enable-linker=lld
		fi
	else
		if tc-ld-is-mold ; then
			mozconfig_add_options_ac "using ld=mold due to system selection" --enable-linker=mold
		else
			mozconfig_add_options_ac "linker is set to bfd due to USE=-clang" --enable-linker=bfd
		fi
	fi

	mozconfig_add_options_ac 'Gentoo default' --disable-debug-symbols
	mozconfig_add_options_ac 'Gentoo defaults' --disable-real-time-tracing

	if is-flag '-O0' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O0
	elif is-flag '-O4' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O4
	elif is-flag '-O3' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O3
	elif is-flag '-O1' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O1
	elif is-flag '-Os' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-Os
	else
		mozconfig_add_options_ac "Gentoo default" --enable-optimize=-O2
	fi

	# Debug flag was handled via configure
	filter-flags '-g*'

	# Optimization flag was handled via configure
	filter-flags '-O*'

	# elf-hack
	# Filter "-z,pack-relative-relocs" and let the build system handle it instead.
	filter-flags "-z,pack-relative-relocs"

	if tc-ld-is-mold ; then
		# relr-elf-hack is currently broken with mold, bgo#916259
		mozconfig_add_options_ac 'disable elf-hack with mold linker' --disable-elf-hack
	else
		mozconfig_add_options_ac 'relr elf-hack' --enable-elf-hack=relr
	fi

	if ! use elibc_glibc; then
		mozconfig_add_options_ac '!elibc_glibc' --disable-jemalloc
	fi

	# System-av1 fix
	use system-av1 && append-ldflags "-Wl,--undefined-version"

	# Make revdep-rebuild.sh happy; Also required for musl
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}",--enable-new-dtags

	# Pass $MAKEOPTS to build system
	export MOZ_MAKE_FLAGS="${MAKEOPTS}"

	# Use system's Python environment
	export PIP_NETWORK_INSTALL_RESTRICTED_VIRTUALENVS=mach

	export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="none"

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Portage sets XARGS environment variable to "xargs -r" by default which
	# breaks build system's check_prog() function which doesn't support arguments
	mozconfig_add_options_ac 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_DIR}"

	# Show flags we will use
	einfo "Build BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Build CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Build CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Build LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Build RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	# Handle EXTRA_CONF and show summary
	local ac opt hash reason

	# Apply EXTRA_ECONF entries to $MOZCONFIG
	if [[ -n ${EXTRA_ECONF} ]] ; then
		IFS=\! read -a ac <<<${EXTRA_ECONF// --/\!}
		for opt in "${ac[@]}"; do
			mozconfig_add_options_ac "EXTRA_ECONF" --${opt#--}
		done
	fi

	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	grep ^ac_add_options "${MOZCONFIG}" | while read ac opt hash reason; do
		[[ -z ${hash} || ${hash} == \# ]] \
			|| die "error reading mozconfig: ${ac} ${opt} ${hash} ${reason}"
		printf "    %-30s  %s\n" "${opt}" "${reason:-mozilla.org default}"
	done
	echo "=========================================================="
	echo

	./mach configure || die
}

src_compile() {
	./mach build --verbose || die

	# FIXME: add locale support
	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-13.5/projects/firefox/build?ref_type=heads#L173
	./mach build stage-package || die
}

src_install() {
	# xpcshell is getting called during install
	pax-mark m \
		"${BUILD_DIR}"/dist/bin/xpcshell \
		"${BUILD_DIR}"/dist/bin/${PN} \
		"${BUILD_DIR}"/dist/bin/plugin-container

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym ${PN} ${MOZILLA_FIVE_HOME}/${PN}-bin

	# Don't install llvm-symbolizer from llvm-core/llvm package
	if [[ -f "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] ; then
		rm -v "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" || die
	fi

	# Install system-wide preferences
	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"

	local GENTOO_PREFS="${ED}${PREFS_DIR}/gentoo-prefs.js"

	# Set dictionary path to use system hunspell
	cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set spellchecker.dictionary_path pref"
	pref("spellchecker.dictionary_path", "${EPREFIX}/usr/share/myspell");
	EOF

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install icons
	local icon_srcdir="${S}/browser/branding/tb-release"

	local icon size
	for icon in "${icon_srcdir}"/default*.png ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" ${PN}.png
		fi

		newicon -s ${size} "${icon}" ${PN}.png
	done

	# Install menu
	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-14.5/projects/browser/RelativeLink/start-browser.desktop
	domenu "${FILESDIR}"/torbrowser.desktop

	# Install wrapper
	# see: https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/browser/RelativeLink/start-browser
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/libexec/anon-ws-disable-stacked-tor/torbrowser.sh
	rm "${ED}"/usr/bin/torbrowser || die # symlink to /usr/lib64/torbrowser/torbrowser

	newbin - torbrowser <<-EOF
		#!/bin/bash

		unset SESSION_MANAGER
		export GSETTINGS_BACKEND=memory
		export __GL_SHADER_DISK_CACHE=0

		export TOR_SKIP_LAUNCH=1
		export TOR_SKIP_CONTROLPORTTEST=1

		if @DEFAULT_WAYLAND@ && [[ -z \${MOZ_DISABLE_WAYLAND} ]]; then
			if [[ -n "\${WAYLAND_DISPLAY}" ]]; then
				export MOZ_ENABLE_WAYLAND=1
			fi
		fi

		exec /usr/$(get_libdir)/torbrowser/torbrowser "\${@}"
	EOF

	# Update wrapper
	local use_wayland="false"
	if use wayland ; then
		use_wayland="true"
	fi
	sed -i -e "s:@DEFAULT_WAYLAND@:${use_wayland}:" "${ED}/usr/bin/${PN}" || die

	# torbrowser and torbrowser-bin are identical
	rm "${ED}"${MOZILLA_FIVE_HOME}/torbrowser-bin || die
	dosym torbrowser ${MOZILLA_FIVE_HOME}/torbrowser-bin

	# https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-14.5/projects/browser/build#L71
	insinto ${MOZILLA_FIVE_HOME}/browser/extensions
	newins "${DISTDIR}/noscript-${NOSCRIPT_VERSION}.xpi" {73a6fe31-595d-460b-a920-fcc0f8843232}.xpi

	# https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tree/main/projects/fonts
	insinto /usr/$(get_libdir)/torbrowser/
	doins -r "${WORKDIR}/tor-browser/Browser/fonts"

	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/browser/Bundle-Data/Docs/ChangeLog.txt
	newdoc "${DISTDIR}/${P}-ChangeLog.txt" ChangeLog.txt

	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/libexec/anon-ws-disable-stacked-tor/torbrowser.sh
	dodoc "${FILESDIR}/99torbrowser.example"
	dodoc "${FILESDIR}/torrc.example"
}

pkg_postinst() {
	xdg_pkg_postinst

	if [[ -z "${REPLACING_VERSIONS}" ]] ; then
		ewarn "This Tor Browser build is _NOT_ recommended by Tor upstream but uses"
		ewarn "the exact same sources. Use this only if you know what you are doing!"
		elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
		elog "in /etc/env.d/99torbrowser to match your setup."
		elog "An example file is available at /usr/share/doc/${P}/99torbrowser.example.bz2"
		elog ""
		elog "To get the advanced functionality (network information,"
		elog "new identity), Torbrowser needs to access a control port."
		elog "Set the Variables in /etc/env.d/99torbrowser accordingly."
	fi
}
