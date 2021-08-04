EAPI=7
inherit git-r3

DESCRIPTION="Source port of the original Doom3"
HOMEPAGE="https://dhewm3.org/"
# 2021-07-19 17:09:36 +0200 981863788f6d9cfb0ce4bb628c2df40306ba459a Update Changelog
EGIT_REPO_URI="https://github.com/dhewm/dhewm3"
EGIT_COMMIT="981863788f6d9cfb0ce4bb628c2df40306ba459a"

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
