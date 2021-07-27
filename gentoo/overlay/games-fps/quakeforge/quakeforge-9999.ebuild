# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
#>>>inherit eutils flag-o-matic autotools
inherit eutils flag-o-matic autotools git-r3
#>>>

DESCRIPTION="New 3d engine based off of id Softwares's Quake and QuakeWorld game engine"
HOMEPAGE="http://www.quakeforge.net/"
#>>>SRC_URI="mirror://sourceforge/quake/${P}.tar.bz2"
# 2020-08-17 13:08:49 +0900 09384eb70388b1113417d2df01f6e2b73ab644df [netchan] Optionally dump the contents of packets
EGIT_REPO_URI="https://git.code.sf.net/p/quake/quakeforge"
EGIT_COMMIT="09384eb70388b1113417d2df01f6e2b73ab644df"
#>>>

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa cdinstall debug dga fbcon flac ipv6 ncurses oss png sdl vorbis wildmidi X xdg xv zlib"
RESTRICT="userpriv"

RDEPEND="
	media-libs/libsamplerate
	net-misc/curl
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	dga? ( x11-libs/libXxf86dga )
	flac? ( media-libs/flac )
	ncurses? ( sys-libs/ncurses:0 )
	png? ( media-libs/libpng:0 )
	sdl? ( media-libs/libsdl[video] )
	vorbis? (
		media-libs/libogg
		media-libs/libvorbis
	)
	wildmidi? ( media-sound/wildmidi )
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXxf86vm
	)
	xv? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXxf86vm
	)
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	cdinstall? ( games-fps/quake1-data )
	>=sys-devel/bison-2.6
	sys-devel/flex
	virtual/pkgconfig"

#>>>PATCHES=(
#>>>	"${FILESDIR}"/${P}-gentoo.patch
#>>>)

src_prepare() {
	default
	eautoreconf
#>>>	append-cflags -std=gnu89 # build with gcc5 (bug #570392)
#>>>
	# https://stackoverflow.com/questions/36685457/build-error-using-flex-lexer-and-cmake
	# libs/video/targets/fbset_modes_l.l:162:66: error: 'yyunput' undeclared here (not in a function); did you mean 'unput'?
	# 162 | static __attribute__ ((used)) void (*yyunput_hack)(int, char*) = yyunput;
	#>>> append-cflags -Wno-error=implicit-function-declaration -Wno-error=unused-function
	sed -ri.BAK \
		-e "s|^(static __attribute__ .+ )yy(unput;)$|// \1\2;|g" \
		${S}/libs/video/targets/fbset_modes_l.l
#>>>
	# https://stackoverflow.com/questions/9541679/undefined-reference-to-stdscr-while-using-ncurses
	# /usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../x86_64-pc-linux-gnu/bin/ld: ruamoko/qwaq/builtins/curses.o: undefined reference to symbol 'stdscr'
	# /usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../x86_64-pc-linux-gnu/bin/ld: /lib/libtinfo.so.6: error adding symbols: DSO missing from command line
	sed -ri.BAK \
		-e "s|^([[:space:]]+CURSES_LIBS=-lncurses),$|\1 -ltinfo,|g" \
		${S}/config.d/curses.m4
#>>>
}

src_configure() {
	local debugopts
	use debug \
		&& debugopts="--enable-debug --disable-optimize --enable-profile" \
		|| debugopts="--disable-debug --disable-profile"

	local clients=${QF_CLIENTS}
	use fbcon && clients="${clients},fbdev"
	use sdl && clients="${clients},sdl"
	use X && clients="${clients},x11"
	[ "${clients:0:1}" == "," ] && clients=${clients:1}

	local servers=${QF_SERVERS:-master,nq,qw,qtv}

	local tools=${QF_TOOLS:-all}

	econf \
		--enable-dependency-tracking \
		$(use_enable ncurses curses) \
		$(use_enable vorbis) \
		$(use_enable png) \
		$(use_enable zlib) \
		$(use_with ipv6) \
		$(use_with fbcon fbdev) \
		$(use_with X x) \
		$(use_enable xv vidmode) \
		$(use_enable dga) \
		$(use_enable sdl) \
		--disable-xmms \
		$(use_enable alsa) \
		$(use_enable flac) \
		$(use_enable oss) \
		$(use_enable xdg) \
		$(use_enable wildmidi) \
		--enable-sound \
		--disable-optimize \
		--disable-Werror \
		--without-svga \
		${debugopts} \
		--with-global-cfg=/etc/quakeforge.conf \
		--with-sharepath=/usr/share/quake1 \
		--with-clients=${clients} \
		--with-servers=${servers} \
		--with-tools=${tools}
}

src_install() {
	emake -j1 DESTDIR="${D}" install
#>>>	dodoc ChangeLog NEWS TODO
	dodoc NEWS TODO
#>>>
}

pkg_postinst() {
	# same warning used in quake1 / quakeforge / nprquake-sdl
	echo
	elog "Before you can play, you must make sure"
	elog "${PN} can find your Quake .pak files"
	elog
	elog "You have 2 choices to do this"
	elog "1 Copy pak*.pak files to /usr/share/quake1/id1"
	elog "2 Symlink pak*.pak files in /usr/share/quake1/id1"
	elog
	elog "Example:"
	elog "my pak*.pak files are in /mnt/secondary/Games/Quake/Id1/"
	elog "ln -s /mnt/secondary/Games/Quake/Id1/pak0.pak /usr/share/quake1/id1/pak0.pak"
	elog
	elog "You only need pak0.pak to play the demo version,"
	elog "the others are needed for registered version"
}
