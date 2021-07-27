EAPI=5
inherit git-r3

DESCRIPTION="Source port of the original Doom3"
HOMEPAGE="https://dhewm3.org/"
# 2020-08-02 04:48:11 +0200 c4c72363523fc65e635c7ad7ae86247b4f082340 Fix "t->c->value.argSize == func->parmTotal" Assertion in Scripts, #303
EGIT_REPO_URI="https://github.com/dhewm/dhewm3"
EGIT_COMMIT="c4c72363523fc65e635c7ad7ae86247b4f082340"

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
