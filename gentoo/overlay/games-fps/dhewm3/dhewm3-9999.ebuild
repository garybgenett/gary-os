EAPI=7
inherit git-r3

DESCRIPTION="Source port of the original Doom3"
HOMEPAGE="https://dhewm3.org/"
# 2024-03-29 01:55:34 +0100 9892438a9bf57aa388cd7f1bcbdf9b9c1d5682e6 Update changelog for 1.5.3  (tag: 1.5.3)
EGIT_REPO_URI="https://github.com/dhewm/dhewm3"
EGIT_COMMIT="1.5.3"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	media-libs/libsdl
	media-libs/openal
	net-misc/curl
	sys-libs/zlib

	media-libs/libjpeg-turbo
	media-libs/libogg
	media-libs/libvorbis
"

src_configure() {
	install -d ${S}/build
	cd ${S}/build
	cmake ${S}/neo
}

src_compile() {
	sed -ri.BAK \
		-e "s|(/usr)/local|${D}\1|g" \
		${S}/build/{config.h,cmake_install.cmake}
	cd ${S}/build
	make
}

src_install() {
	cd ${S}/build
	make install
	cd ${S}
	dodoc README.md
}
