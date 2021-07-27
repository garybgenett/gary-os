# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
#>>>inherit games
inherit games git-r3
#>>>

MY_FULL_PV=1.9.3
MY_PN="${PN/-bin/}"
DESCRIPTION="Quakeworld client with mqwcl functionality and many more features"
HOMEPAGE="http://ezquake.sf.net/"
#>>>
#SRC_URI="
#	amd64? ( mirror://sourceforge/${MY_PN}/${MY_PN}_linux-x86_64.${MY_FULL_PV}.tar.gz
#		mirror://sourceforge/${MY_PN}/${MY_PN}_linux64_${PV}.tar.gz )
#	x86? ( mirror://sourceforge/${MY_PN}/${MY_PN}_linux-x86_${MY_FULL_PV}.tar.gz
#		mirror://sourceforge/${MY_PN}/${MY_PN}_linux32_${PV}.tar.gz )"
#>>>
# 2020-10-26 18:39:16 +0000 37a3611697f9307f0d092759c171f9b71b3d2da6 FLASHBLEND: Fix when non-square sprite dimensions
EGIT_REPO_URI="https://github.com/ezQuake/ezquake-source"
EGIT_COMMIT="37a3611697f9307f0d092759c171f9b71b3d2da6"
#>>>

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip mirror"
IUSE="cdinstall"

#>>>DEPEND="cdinstall? ( games-fps/quake1-data )"
# https://github.com/ezQuake/ezquake-source = apt-get [...]
DEPEND="cdinstall? ( games-fps/quake1-data )
	media-libs/libsdl
	dev-libs/jansson
	dev-libs/expat
	net-misc/curl
	dev-libs/openssl
	media-libs/libpng
	media-libs/libjpeg-turbo
	media-libs/speex
"
#>>>
RDEPEND="${DEPEND}
		virtual/opengl
		x11-libs/libXxf86dga
		x11-libs/libXxf86vm"

#>>>S=${WORKDIR}/${MY_PN}

dir=${GAMES_PREFIX_OPT}/${PN}

QA_PREBUILT="${dir:1}/ezquake*"

#>>>
#src_unpack() {
#	unpack ${A}
#	if use amd64; then
#		mv ${MY_PN}_linux-x86_64.${MY_FULL_PV} "${MY_PN}"
#		mv ezquake-gl_linux-x64.glx "${MY_PN}"/ezquake-gl.glx
#	else
#		mv ${MY_PN}_linux-x86.${MY_FULL_PV} "${MY_PN}"
#		mv ezquake-gl_linux-x86.glx "${MY_PN}"/ezquake-gl.glx
#	fi
#}
#>>>

#>>>
src_compile() {
	# https://github.com/open-eid/libdigidocpp/issues/3
	# In file included from minizip/unzip.h:55,
	# from fs.h:26,
	# from common.h:43,
	# from cmodel.c:23:
	# minizip/ioapi.h:135:51: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'OF'
	# 135 | typedef voidpf (ZCALLBACK *open_file_func) OF((voidpf opaque, const char* filename, int mode));
	#>>> sed -ri.BAK \
	#>>>	-e "s|^([[:space:]]+CFLAGS_c [+]= -I)minizip$|\1/usr/include/minizip|g" \
	#>>>	${S}/Makefile
	sed -ri.BAK \
		-e "s|^([[:space:]]+MINIZIP_LIBS [?]= ).+$|\1\$(MINIZIP_CFLAGS) -L/usr/lib -lminizip|g" \
		${S}/Makefile
	emake USE_SYSTEM_MINIZIP=1
}
#>>>

src_install() {
#>>>
#	exeinto "${dir}"
#	insinto "${dir}"
#
#	doexe ezquake-gl.glx
#	doins -r ezquake qw
#	dosym "${GAMES_DATADIR}"/quake1/id1 "${dir}"/id1
#	games_make_wrapper ezquake-gl.glx ./ezquake-gl.glx "${dir}" "${dir}"
#
#	prepgamesdirs
#>>>
	mkdir -pv ${D}usr/bin
	install ${S}/ezquake-linux-x86_64 ${D}usr/bin
	ln -sv ezquake-linux-x86_64 ${D}usr/bin/ezquake
	dodoc CHANGELOG README.md
#>>>
}

#>>>
#pkg_postinst() {
#	games_pkg_postinst
#
#	if ! use cdinstall; then
#		elog "NOTE that this client doesn't include .pak files. You *should*"
#		elog "enable \"cdinstall\" flag or install quake1-demodata with the symlink use flag."
#		elog "You can also copy the files from your Quake1 CD to"
#		elog "  ${dir}/quake1/id1 (all names lowercase)"
#		elog ""
#		elog "You may also want to check:"
#		elog " http://fuhquake.quakeworld.nu - complete howto on commands and variables"
#		elog " http://equake.quakeworld.nu - free package containing various files"
#	fi
#}
#>>>
