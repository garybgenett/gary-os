# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit epatch

DESCRIPTION="A *nix firendly FitzQuake with new features"
HOMEPAGE="http://quakespasm.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cdinstall debug demo mp3 ogg sdl2 opus flac mikmod"

DEPEND="
	mp3? ( media-libs/libmad )
	ogg? ( media-libs/libvorbis )
	opus? (
		media-libs/opus
		media-libs/opusfile
	)
	flac? ( media-libs/flac )
	mikmod? ( media-libs/libmikmod )
	sdl2? ( media-libs/libsdl2[opengl] )
	!sdl2? ( media-libs/libsdl[opengl] )
	"
RDEPEND="${DEPEND}
	cdinstall? ( games-fps/quake1-data )
	demo? ( games-fps/quake1-demodata )"


S=${WORKDIR}/${P}/Quake

src_prepare() {

	epatch "${FILESDIR}/0.93.1-makefile.patch"

	sed -i -e \
		"s!parms.basedir = \".\"!parms.basedir = \"/usr/share/games/quake1\"!" \
		main_sdl.c || die "sed failed"

	default
}

src_compile() {
	local opts=""
	use debug && opts="DEBUG=1"
	use mp3 && opts="${opts} USE_CODEC_MP3=1"
	use ogg && opts="${opts} USE_CODEC_VORBIS=1"
	use sdl2 && opts="${opts} USE_SDL2=1"
	use flac && opts="${opts} USE_CODEC_FLAC=1"
	use opus && opts="${opts} USE_CODEC_OPUS=1"
	use mikmod && opts="${opts} USE_CODEC_MIKMOD=1"

	emake ${opts} || die "emake failed"
}

src_install() {
	dobin "${PN}"
	dodoc ../Quakespasm.txt ../Quakespasm-Music.txt ../Quakespasm.html ../LICENSE.txt
	insinto "/usr/share/games/quake1"
	doins quakespasm.pak
}
