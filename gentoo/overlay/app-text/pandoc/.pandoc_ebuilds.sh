#!/usr/bin/env bash
source ${HOME}/.bashrc
set -e
################################################################################
# ./.pandoc_ebuilds.sh -l
# ./.pandoc_ebuilds.sh [ - | + | / ]
# ./.pandoc_ebuilds.sh texlive [ = | module ]
# ./.pandoc_ebuilds.sh dev-texlive/texlive-basic	[ "" | - | version ]
# ./.pandoc_ebuilds.sh dev-lang/ghc			[ "" | - | version ]
# ./.pandoc_ebuilds.sh app-text/pandoc =
################################################################################

export TOOR="-x"
export TANURI="http://mirror.ctan.org/systems/texlive/tlnet/archive"

################################################################################

export PANDIR="$(dirname $(realpath ${0}))"
export SETDIR="${PANDIR/%\/gentoo\/overlay\/app-text\/pandoc}"
source ${SETDIR}/gentoo/_system

########################################

export COMMIT="$(${SED} -n "s|^[^#].+id=||gp"				${PANDIR}/.rationale | tail -n1)"
export PANDOC="$(${SED} -n "s|^[=]app-text/pandoc[-](.+)$|\1|gp"	${PANDIR}/.rationale | tail -n1)"
export TXLIVE="$(${SED} -n "s|^[=]app-text/texlive[-](.+)$|\1|gp"	${PANDIR}/.rationale | tail -n1)"
export TLYEAR="${TXLIVE/%-r[0-9]*}"

########################################

declare FILE=

################################################################################

if [[ ${1} == -l ]]; then
	for FILE in $(${SED} -n "s|^[-+][ ]||gp" ${PANDIR}/.rationale); do
		echo -en "\n[${FILE}]\n"
		cat ${SETDIR}/gentoo/overlay/${FILE}/.rationale
		${GREP} "#>>>." ${SETDIR}/gentoo/overlay/${FILE}/*.ebuild || true
	done
	exit 0
fi

########################################

if [[ ${1} == [-+/] ]]; then
	for FILE in $(${SED} -n "s|^[${1}][ ]||gp" ./.rationale); do
		${0} ${FILE} -
	done
	exit 0
fi

################################################################################

if [[ -n ${1} ]]; then declare PKG="${1}" && shift && declare NAM="$(basename ${PKG})"; else exit 1; fi
if [[ -n ${1} ]]; then declare VER="${1}" && shift; fi

########################################

if [[ ${PKG} == "texlive" ]]; then
	if [[ -n ${VER} ]] && [[ ${VER} != "=" ]]; then
		for FILE in "" .source .doc; do
			${WGET_C} -O ${TARGET}${DSTDIR}/texlive-module-${VER}${FILE}-${TLYEAR}.tar.xz \
				${TANURI}/${VER}${FILE}.tar.xz \
				|| [[ -n ${FILE} ]]
		done
	else
		for FILE in $(
			if [[ ${VER} == "=" ]]; then
				lftp ${TANURI} -e "dir ; quit" |
					${SED} "s|^.+[[:space:]]([^[:space:].]+)[.].+$|\1|g" |
					${GREP} -v "[.]r[0-9]{5}$"
			else
				${LS} ${TARGET}${DSTDIR} |
					${SED} -n "s|^texlive-module-(.+)-[0-9].+$|\1|gp"
			fi |
				${SED} "s/[.](source|doc)$//g" | sort -u
		); do
			${0} ${PKG} ${FILE} || true
		done
	fi
	exit 0
fi

if [[ ${VER} == "-" ]]; then VER="$(
	${WGET_C} -O - "https://gitweb.gentoo.org/repo/gentoo.git/tree/${PKG}?id=${COMMIT}" 2>/dev/null |
		w3m -T text/html -dump |
		${SED} -n "s|^[^[:space:]]+[[:space:]](.+)[-]([0-9].*)[.]ebuild.*$|\2|gp" |
		sort -V |
		tail -n1
)"; fi
if [[ -z ${VER} ]]; then
	${WGET_C} -O - "https://gitweb.gentoo.org/repo/gentoo.git/tree/${PKG}?id=${COMMIT}" |
		w3m -T text/html -dump
	exit 1
fi

########################################

if [[ ! -f			${SETDIR}/gentoo/overlay/${PKG}/.rationale ]]; then
	${MKDIR}		${SETDIR}/gentoo/overlay/${PKG}
	echo "pandoc version"	>${SETDIR}/gentoo/overlay/${PKG}/.rationale
fi

if [[ ${VER} != "=" ]]; then
	${SETDIR}/gentoo/_system ${TOOR} -o ${NAM} ${NAM}-${VER}.ebuild ${COMMIT}
fi
if [[ ${PKG} == app-text/pandoc ]]; then
	${SETDIR}/gentoo/_system ${TOOR} -s -e $(${GREP} "^[=]" ./.rationale) \
		=app-text/texlive-${TXLIVE} \
		=app-text/pandoc-${PANDOC}
else
	if [[ -f ${SETDIR}/gentoo/overlay/${PKG}/.source/.keep ]]; then
		echo "- ${PKG}"	>>${PANDIR}/.rationale
	else
		echo "+ ${PKG}"	>>${PANDIR}/.rationale
	fi
fi

exit 0
################################################################################
# end of file
################################################################################
