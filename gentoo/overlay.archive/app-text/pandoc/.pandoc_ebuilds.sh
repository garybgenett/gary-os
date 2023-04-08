#!/usr/bin/env bash
source ${HOME}/.bashrc
umask 022
set -e
################################################################################
# ./.pandoc_ebuilds.sh =
# ./.pandoc_ebuilds.sh /
# ./.pandoc_ebuilds.sh -l
########################################
# ./.pandoc_ebuilds.sh [ - | + ]
# ./.pandoc_ebuilds.sh texlive [ = | module ]
# ./.pandoc_ebuilds.sh dev-texlive/texlive-basic	[ "" | - | version ]
# ./.pandoc_ebuilds.sh dev-lang/ghc			[ "" | - | version ]
########################################
# FILE="yaml"; (cd ./gentoo/overlay/app-text/pandoc; ./.pandoc_ebuilds.sh dev-haskell/${FILE} - && ./.pandoc_ebuilds.sh app-text/pandoc /)
# FILE="basic"; (cd ./gentoo/overlay/app-text/pandoc; ./.pandoc_ebuilds.sh dev-texlive/texlive-${FILE} - && ./.pandoc_ebuilds.sh app-text/pandoc /)
########################################
# git-commit -- $(./gentoo/overlay/app-text/pandoc/.pandoc_ebuilds.sh ^)
################################################################################

export TOOR="-x"

export PANPKG="app-text/pandoc"
export TEXPKG="app-text/texlive"
export TANURI="http://mirror.ctan.org/systems/texlive/tlnet/archive"

################################################################################

export PANDIR="$(dirname $(realpath ${_SELF}))"
export SETDIR="${PANDIR/%\/gentoo\/overlay\/app-text\/pandoc}"
source ${SETDIR}/gentoo/_system

########################################

export COMMIT="$(${SED} -n "s|^[^#].+id=||gp"			${PANDIR}/.rationale | tail -n1)"
export PANDOC="$(${SED} -n "s|^[=]${PANPKG}[-](.+)$|\1|gp"	${PANDIR}/.rationale | tail -n1)"
export TXLIVE="$(${SED} -n "s|^[=]${TEXPKG}[-](.+)$|\1|gp"	${PANDIR}/.rationale | tail -n1)"
export TLYEAR="${TXLIVE/%-r[0-9]*}"

########################################

declare FILE=

################################################################################

if [[ ${1} == -l ]]; then
	for FILE in $(${SED} -n "s|^[-+][ ]||gp" ${PANDIR}/.rationale); do
		echo -en "\n[${FILE}]\n"
		cat ${SETDIR}/gentoo/overlay/${FILE}/.rationale
		${GREP} "^#>>>" ${SETDIR}/gentoo/overlay/${FILE}/*.ebuild || true
	done
	exit 0
fi

########################################

if [[ ${1} == [-+] ]]; then
	for FILE in $(${SED} -n "s|^[${1}][ ]||gp" ${PANDIR}/.rationale); do
		${_SELF} ${FILE} -
	done
	exit 0
fi

########################################

if [[ ${1} == "^" ]]; then
	${SED} -n "s|^[=]([^/]+)[/](.+)[-]([0-9].+)$|\1/\2|gp" ${PANDIR}/.rationale |
		while read -r FILE; do
			echo "$(realpath --relative-to="${PWD}" ${SETDIR}/gentoo/overlay/${FILE})"
		done
#>>>		dev-tex \
	for FILE in \
		dev-haskell \
		dev-texlive \
	; do
		echo "$(realpath --relative-to="${PWD}" ${SETDIR}/gentoo/overlay/${FILE})"
	done
	exit 0
fi

################################################################################

if [[ -n ${1} ]]; then declare PKG="${1}" && shift && declare NAM="$(basename ${PKG})"; else exit 1; fi
if [[ -n ${1} ]]; then declare VER="${1}" && shift; fi

if [[ ${PKG} == "=" ]]; then
	PKG="${PANPKG}"
	VER="${PKG}"
fi
if [[ ${PKG} == "/" ]]; then
	PKG="${PANPKG}"
	VER="/"
fi

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
			${_SELF} ${PKG} ${FILE} || true
		done
	fi
	exit 0
fi

########################################

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
	echo "# pandoc version"	>${SETDIR}/gentoo/overlay/${PKG}/.rationale
fi

if [[ ${PKG} == ${PANPKG} ]]; then
	if [[ ${VER} == ${PKG} ]]; then
		${SED} -n "s|^[=](.+)[-]([0-9].+)$|\1 \2|gp" ${PANDIR}/.rationale |
			${GREP} -v "${PANPKG}" |
			while read -r FILE; do
				${_SELF} ${FILE}
			done
	fi
	${SETDIR}/gentoo/_system -q ${TOOR} -s -e $(${GREP} "^[=]" ${PANDIR}/.rationale) \
		=${TEXPKG}-${TXLIVE} \
		=${PANPKG}-${PANDOC} \
		|| exit 1
else
	${SETDIR}/gentoo/_system -q ${TOOR} -o ${NAM} ${NAM}-${VER}.ebuild ${COMMIT} \
		|| exit 1
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
