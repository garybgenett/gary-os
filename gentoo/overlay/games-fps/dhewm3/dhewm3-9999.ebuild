EAPI=7
inherit git-r3

DESCRIPTION="Source port of the original Doom3"
HOMEPAGE="https://dhewm3.org/"
# 2022-06-13 03:36:23 +0200 2e71b99ee05ea65caa0fdafb0bbeeb9ddb997ced dhewm3 1.5.2  (tag: 1.5.2)
EGIT_REPO_URI="https://github.com/dhewm/dhewm3"
EGIT_COMMIT="1.5.2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	media-libs/libjpeg-turbo
	media-libs/libogg
	media-libs/libvorbis
	media-libs/openal
	media-libs/libsdl
	net-misc/curl
"

src_configure() {
	install -d ${S}/build
	cd ${S}/build
	cmake ${S}/neo
}

src_compile() {
	sed -ri.BAK \
		-e "s|/(usr)/local|${D}\1|g" \
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
