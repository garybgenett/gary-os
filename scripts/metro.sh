#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare BLD="/.g/_data/_build"
declare SAV="/.g/_data/_builds/_metro"
declare ISO="/.g/_data/_target/iso"

########################################

declare SMET="${BLD}/funtoo/metro"
declare SPRT="${BLD}/funtoo/portage"

declare TYPE="funtoo-stable"
declare PLAT="x86-64bit"
declare ARCH="core2_64"
declare SARC="${ARCH}"

declare DEST="${BLD}/_metro"
declare DFIL="${DEST}/.distfiles"
declare DMET="${DEST}/.metro"
declare DTMP="${DEST}/.temp"

declare DOUT="${DEST}/${TYPE}/${PLAT}/${ARCH}"
declare SOUT="${DEST}/${TYPE}/${PLAT}/${SARC}"

########################################

declare SAFE_ENV="prompt -z"
export CCACHE_DIR=

declare METRO_CMD="${DMET}/metro \
	--libdir ${DMET} \
	--verbose \
	--debug \
	multi:		yes \
	multi/mode:	full \
	path/mirror:	${DEST} \
	path/distfiles:	${DFIL} \
	path/tmp:	${DTMP} \
	target/build:	${TYPE} \
	target/subarch:	${ARCH} \
	target/version:	$(date --iso=m) \
"
#>>>	target/version:	$(date --iso=h) \

########################################

declare NAME="$(cat ${SMET}/etc/builds/${TYPE}/build.conf 2>/dev/null |
	${SED} -n "s/^name[:][ ]//gp")"
declare DATE="$(ls {${SAV}/*/*/*/*,${ISO},${SOUT}/*}/stage3-*${SARC}*${TYPE}*.tar.xz 2>/dev/null |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}-[0-9]{4})?).+$/\1/g" |
	sort -n |
	tail -n1)"

{ [[ -z ${NAME} ]] || [[ -z ${DATE} ]]; } && exit 1

################################################################################

${MKDIR} ${DEST}
${RSYNC_U} ${SMET}/ ${DMET}

########################################

function makeconf_var {
	source ${HOME}/setup/gentoo/make.conf
	eval echo -en "\${${1}}" | tr '\n' ' '
}

declare OPTS="	$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s/[-][-]ask[^[:space:]]*//g")"
OPTS+="		$(makeconf_var MAKEOPTS			| ${GREP} -o "[-]j[0-9]+")"
declare PKGS="$(cat ${HOME}/setup/gentoo/sets/metro	| ${GREP} -v -e "^[#]" -e "^$" | sort | tr '\n' ' ')"

declare FEAT="$(makeconf_var FEATURES)"
declare MKOP="$(makeconf_var MAKEOPTS)"

########################################

${SED} -i \
	-e "s%^(options:).*jobs.*$%\1	${OPTS}%g" \
	-e "s%^(packages:.*)$%\1\n	${PKGS}%g" \
	\
	-e "s%^(FEATURES:.*)$%\1	${FEAT}%g" \
	-e "s%^(MAKEOPTS:).*$%\1	${MKOP}%g" \
	\
	-e "s%^(branch/tar:).*$%\1	./%g" \
	-e "s%^(options:).*pull.*$%\1	%g" \
	\
	-e "s%\t+% %g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

################################################################################

#>>>${RM} /usr/bin/metro
#>>>${LN} ${DMET}/metro /usr/bin/metro
#>>>${RM} /usr/lib/metro
#>>>${LN} ${DMET} /usr/lib/metro
#>>>${RM} /var/tmp/metro
#>>>${LN} ${DTMP} /var/tmp/metro

${MKDIR} ${DOUT}/.control/{strategy,remote}
echo -en "remote\n"	>${DOUT}/.control/strategy/build
echo -en "stage3\n"	>${DOUT}/.control/strategy/seed
echo -en "${TYPE}\n"	>${DOUT}/.control/remote/build
echo -en "${SARC}\n"	>${DOUT}/.control/remote/subarch
${MKDIR} ${SOUT}/.control/version
echo -en "${DATE}\n"	>${SOUT}/.control/version/stage3

${MKDIR}		${DTMP}/cache/cloned-repositories/${NAME}
${RSYNC_U} ${SPRT}.git/	${DTMP}/cache/cloned-repositories/${NAME}/.git
${RM}			${DTMP}/cache/cloned-repositories/${NAME}.git
${LN} ../${NAME}/.git	${DTMP}/cache/cloned-repositories/${NAME}.git

declare FILE=
for FILE in $(ls {${SAV}/*/*/*/*,${ISO}}/stage3-*${SARC}*${TYPE}*.tar.xz |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}).+$/\1/g" |
	sort -n)
do
	${MKDIR} ${SOUT}/${FILE}
	${RSYNC_U} {${SAV}/*/*/*/*,${ISO}}/stage3-*${SARC}*${TYPE}*-${FILE}.tar.xz ${SOUT}/${FILE}/
done

########################################

echo -en "\n"
diff	${SMET}/etc/builds/${TYPE}/build.conf \
	${DMET}/etc/builds/${TYPE}/build.conf

echo -en "\n"
echo -en "NAME: ${NAME}\n"
echo -en "DATE: ${DATE}\n"

echo -en "\n"
${SAFE_ENV} env

########################################

echo -en "\n"
${SAFE_ENV} ${METRO_CMD} || exit 1

${MKDIR} ${SAV}
${RSYNC_C} ${DEST}/ ${SAV}

exit 0
################################################################################
# end of file
################################################################################
