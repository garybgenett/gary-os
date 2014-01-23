#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare BLD="/.g/_data/_build"
declare ISO="/.g/_data/_target/iso"

########################################

declare SRC="${BLD}/funtoo/metro"
declare DST="${BLD}/_metro"

declare PORT="${BLD}/funtoo/portage"
declare DIST="${DST}/.distfiles"
declare TEMP="${DST}/.temp"

declare TYPE="funtoo-stable"
declare PLAT="x86-64bit"
declare ARCH="core2_64"
declare DOUT="${DST}/${TYPE}/${PLAT}/${ARCH}"

########################################

declare NAME="$(cat ${SRC}/etc/builds/${TYPE}/build.conf	2>/dev/null |
	${SED} -n "s/^name[:][ ]//gp")"
declare DATE="$(ls {${ISO},${DOUT}/*}/stage3-*${TYPE}*.tar.xz	2>/dev/null |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}).+$/\1/g" |
	sort -n |
	tail -n1)"

{ [[ -z ${NAME} ]] || [[ -z ${DATE} ]]; } && exit 1

########################################

declare SAFE_ENV="prompt -z"
export CCACHE_DIR=

declare METRO_CMD="${SRC}/metro \
	--libdir ${SRC} \
	--verbose \
	--debug"

################################################################################

${MKDIR} ${DST}
#>>>${RM} /usr/bin/metro
#>>>${LN} ${SRC}/metro /usr/bin/metro
#>>>${RM} /usr/lib/metro
#>>>${LN} ${SRC} /usr/lib/metro
#>>>${RM} /var/tmp/metro
#>>>${LN} ${TEMP} /var/tmp/metro

${MKDIR} ${DOUT}/.control/{strategy,version}
echo -en "local\n"	>${DOUT}/.control/strategy/build
echo -en "stage3\n"	>${DOUT}/.control/strategy/seed
echo -en "${DATE}\n"	>${DOUT}/.control/version/stage3

declare FILE=
for FILE in $(ls ${ISO}/stage3-*${TYPE}*.tar.xz |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}).+$/\1/g" |
	sort -n)
do
	${MKDIR} ${DOUT}/${FILE}
	${RSYNC_C} ${ISO}/stage3-*${TYPE}*-${FILE}.tar.xz ${DOUT}/${FILE}/
done

if [[ ! -d ${TEMP}/cache/cloned-repositories/${NAME} ]]; then
	${MKDIR}		${TEMP}/cache/cloned-repositories/${NAME}
	${RSYNC_U} ${PORT}.git/	${TEMP}/cache/cloned-repositories/${NAME}.git
	${RM}			${TEMP}/cache/cloned-repositories/${NAME}/.git
	${LN} ../${NAME}.git	${TEMP}/cache/cloned-repositories/${NAME}/.git
fi
(cd ${TEMP}/cache/cloned-repositories/${NAME} &&
	${GIT} checkout --force funtoo.org)

########################################

echo -en "\n"
echo -en "NAME: ${NAME}\n"
echo -en "DATE: ${DATE}\n"

echo -en "\n"
${SAFE_ENV} env

echo -en "\n"
${SAFE_ENV} ${METRO_CMD} \
	multi: yes \
	multi/mode: full \
	path/mirror: ${DST} \
	path/distfiles: ${DIST} \
	path/tmp: ${TEMP} \
	target/build: ${TYPE} \
	target/subarch: ${ARCH} \
	target/version: $(date --iso=d) || exit 1

exit 0
################################################################################
# end of file
################################################################################
