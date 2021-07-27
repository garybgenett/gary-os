EAPI=5
inherit git-r3

DESCRIPTION="QuakeWorld setup for competitive online gaming"
HOMEPAGE="https://www.nquake.com/"
# 2020-04-26 09:37:53 +0200 b74eb61fd046bb52be76374bb0b9756295a9448b Merge pull request #9 from hemostx/fix-gpl_maps-path
EGIT_REPO_URI="https://github.com/nQuake/client-linux"
EGIT_COMMIT="b74eb61fd046bb52be76374bb0b9756295a9448b"
SRC_URI="
https://raw.githubusercontent.com/nQuake/client-win32/master/etc/nquake.ini
https://nquake.fnu.nu/qsw106.zip
https://nquake.fnu.nu/gpl.zip
https://nquake.fnu.nu/non-gpl.zip
https://nquake.fnu.nu/linux.zip
https://nquake.fnu.nu/addon-clanarena.zip
https://nquake.fnu.nu/addon-fortress.zip
https://nquake.fnu.nu/addon-textures.zip
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	games-fps/quake1-data
	games-fps/ezquake
	net-misc/wget
"

DDIR="${D}opt/${PN}"

src_compile() {
	sed -ri.BAK \
		-e "s|^(.*wget.*)$|#\1|g" \
			-e "s|-q (-O)|\1|g" \
			-e "s|(-O )([$]2)|\1${DISTDIR}/\2|g" \
			-e "s|(-qqo )([^/])|\1${DISTDIR}/\2|g" \
		-e "s|^(.*read -p.*)$|#\1|g" \
			-e "s|^(defaultdir=).+$|\1${DDIR}|g" \
			-e "s|^(defaultsearchdir=).+$|\1/usr/share/games/quake1/id1|g" \
			-e "s|[$]clanarena|y|g" \
			-e "s|[$]fortress|y|g" \
			-e "s|[$]textures|y|g" \
			-e "s|[$]search|y|g" \
		-e "s|([\" ])(nquake.ini)|\1${DISTDIR}/\2|g" \
		-e "s|([\" ])(nquake.ini)|\1${S}/\2|g" \
			-e "s|([\^])[$]mirror(=)|\12\2|g" \
			-e "s|^(.*distdl [$]mirror.*)$|echo \1|g" \
		-e "s|^(.*rm -rf.*)$|#\1|g" \
		${S}/src/install_nquake.sh
}

src_install() {
	install -d ${DDIR}
	cd ${DDIR}
	bash ${S}/src/install_nquake.sh
	rm -rf ${DDIR}/ID1
}
