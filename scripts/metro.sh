#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare BLD="/.g/_data/_build"
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
declare DTMP="${DEST}/.temp"
declare DOUT="${DEST}/${TYPE}/${PLAT}/${ARCH}"

########################################

declare SAFE_ENV="prompt -z"
export CCACHE_DIR=

declare METRO_CMD="${SMET}/metro \
	--libdir ${SMET} \
	--verbose \
	--debug \
	multi:		yes \
	multi/mode:	full \
	path/mirror:	${DEST} \
	path/distfiles:	${DFIL} \
	path/tmp:	${DTMP} \
	target/build:	${TYPE} \
	target/subarch:	${ARCH} \
	target/version:	$(date --iso=d) \
"

########################################

declare NAME="$(cat ${SMET}/etc/builds/${TYPE}/build.conf	2>/dev/null |
	${SED} -n "s/^name[:][ ]//gp")"
declare DATE="$(ls {${ISO},${DOUT}/*}/stage3-*${TYPE}*.tar.xz	2>/dev/null |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}).+$/\1/g" |
	sort -n |
	tail -n1)"

{ [[ -z ${NAME} ]] || [[ -z ${DATE} ]]; } && exit 1

################################################################################

${MKDIR} ${DEST}

########################################

#>>>${RM} /usr/bin/metro
#>>>${LN} ${SMET}/metro /usr/bin/metro
#>>>${RM} /usr/lib/metro
#>>>${LN} ${SMET} /usr/lib/metro
#>>>${RM} /var/tmp/metro
#>>>${LN} ${DTMP} /var/tmp/metro

${MKDIR} ${DOUT}/.control/{strategy,remote,version}
echo -en "remote\n"	>${DOUT}/.control/strategy/build
echo -en "stage3\n"	>${DOUT}/.control/strategy/seed
echo -en "${TYPE}\n"	>${DOUT}/.control/remote/build
echo -en "${SARC}\n"	>${DOUT}/.control/remote/subarch
echo -en "${DATE}\n"	>${DOUT}/.control/version/stage3

if [[ ! -d ${DTMP}/cache/cloned-repositories/${NAME} ]]; then
	${MKDIR}		${DTMP}/cache/cloned-repositories/${NAME}
	${RSYNC_U} ${SPRT}.git/	${DTMP}/cache/cloned-repositories/${NAME}.git
	${RM}			${DTMP}/cache/cloned-repositories/${NAME}/.git
	${LN} ../${NAME}.git	${DTMP}/cache/cloned-repositories/${NAME}/.git
fi
(cd ${DTMP}/cache/cloned-repositories/${NAME} &&
	${GIT} checkout --force funtoo.org)

declare FILE=
for FILE in $(ls ${ISO}/stage3-*${TYPE}*.tar.xz |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}).+$/\1/g" |
	sort -n)
do
	${MKDIR} ${DOUT}/${FILE}
	${RSYNC_U} ${ISO}/stage3-*${TYPE}*-${FILE}.tar.xz ${DOUT}/${FILE}/
done

########################################

echo -en "\n"
echo -en "NAME: ${NAME}\n"
echo -en "DATE: ${DATE}\n"

echo -en "\n"
${SAFE_ENV} env

########################################

echo -en "\n"
${SAFE_ENV} ${METRO_CMD} || exit 1

exit 0
################################################################################
# end of file
################################################################################
