EAPI=7
inherit git-r3

DESCRIPTION="Source port of the original Doom3"
HOMEPAGE="https://dhewm3.org/"
# 2024-08-02 22:17:52 -0500 be2b788c6719dff953ce816a1246c49bd5cd30a5 Lower macOS requirement  (tag: 1.5.4)
EGIT_REPO_URI="https://github.com/dhewm/dhewm3"
EGIT_COMMIT="1.5.4"

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
