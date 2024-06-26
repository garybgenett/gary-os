# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO: if installing off of the 1.01 cd, need to fetch the
#       quake shareware and use that pak0
# http://linux.omnipotent.net/article.php?article_id=11287
# ftp://ftp.cdrom.com/pub/idgames/idstuff/quake/quake106.zip

EAPI=7

inherit cdrom

DESCRIPTION="iD Software's Quake 1 ... the data files"
HOMEPAGE="https://www.idsoftware.com/games/quake/quake/"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="bindist"

RDEPEND="!games-fps/quake1-demodata[symlink]"
BDEPEND="app-arch/lha"

src_unpack() {
#>>>
	if [ -d /tmp/quake ]; then export CD_ROOT="/tmp/quake"; fi
#>>>
	export CDROM_NAME_SET=("Existing Install" "Quake CD (1.01)" "Ultimate Quake Collection" "Quake CD (newer)")
	cdrom_get_cds id1:q101_int.1:Setup/ID1:resource.1

	if [[ ${CDROM_SET} == "1" ]] ; then
		elog "Unpacking q101_int.lha to ${PWD}"
		cat "${CDROM_ROOT}"/q101_int.1 "${CDROM_ROOT}"/q101_int.2 > \
			"${S}"/q101_int.exe

		lha xqf "${S}"/q101_int.exe || die
		rm -f q101_int.exe || die
	elif [[ ${CDROM_SET} == "3" ]] ; then
		elog "Unpacking resource.1 to ${PWD}"
#>>>		lha xqf "${CDROM_ROOT}"/resource.1 || die
		cp "${CDROM_ROOT}"/resource.1 resource.x || die "failure copying resource.1"
		lha -x -q -f resource.x || die "failure unpacking resource.x"
#>>>
	fi
}

src_install() {
	insinto /usr/share/quake1/id1
	case ${CDROM_SET} in
		0)
			doins "${CDROM_ROOT}"/id1/*
		    dodoc "${CDROM_ROOT}"/*.txt
		    ;;
		1|3)
#>>>			doins id1/*
#>>>		    dodoc *.txt
			doins ID1/*
		    dodoc *.TXT
#>>>
		    ;;
		2)
			newins "${CDROM_ROOT}"/Setup/ID1/PAK0.PAK pak0.pak
		    newins "${CDROM_ROOT}"/Setup/ID1/PAK1.PAK pak1.pak
		    dodoc "${CDROM_ROOT}"/Docs/*
		    ;;
	esac
}
