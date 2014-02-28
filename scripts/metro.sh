#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare AUTHOR="Gary B. Genett <me@garybgenett.net>"
declare LOGIN="garybgenett"
declare TITLE="gary-os"

########################################

declare GITHUB="ssh://git@github.com/${LOGIN}/${TITLE}.git"
declare SFCODE="ssh://${LOGIN}@git.code.sf.net/p/${TITLE}/code"
declare SFFILE="${LOGIN}@web.sourceforge.net:/home/frs/project/${TITLE}"
declare SF_SSH="${LOGIN},${TITLE}@shell.sourceforge.net create"

declare -a RELEASE
declare -a CMT_HSH
RELEASE[0]="v0.1"; CMT_HSH[0]="4d1b46b02798a1d3d3421b1c8087d80a80012a53"
RELEASE[1]="v0.2"; CMT_HSH[1]="99c1bafbf1116c1400705803da45e1ac03f3d492"
RELEASE[2]="v0.3"; CMT_HSH[2]="6e968d212ea62a1054e3cafa2436b6a98cf8776b"

########################################

declare REL_DIR="/.g/_data/_builds/.${TITLE}"
declare DOC_DIR="/.g/_data/_builds/${TITLE}"

################################################################################

declare BITS="64"
if [[ ${1} == @(64|32) ]]; then
	BITS="${1}"
	shift
fi
declare REVN="0"
if [[ ${1} == [0-9] ]]; then
	REVN="${1}"
	shift
fi

########################################

declare CONFIG="${HOME}/setup/gentoo"
declare SET="${CONFIG}/sets/metro"
declare HASH="$(cat ${CONFIG}/.funtoo)"
declare DVER="${HASH}.${REVN}"
#>>>DVER="$(date --iso=d)"

declare BLD="/.g/_data/_build"
declare SAV="/.g/_data/_builds/_metro"
declare ISO="/.g/_data/_target/iso"

########################################

declare SMET="${BLD}/funtoo/metro"
declare SPRT="${BLD}/funtoo/portage"

declare TYPE="funtoo-stable"
declare PLAT="x86-${BITS}bit"
declare ARCH="generic_${BITS}"
declare SARC="core2_${BITS}"		; [[ ${BITS} == 32 ]] && SARC="i686"

declare DEST="${BLD}/_metro"
declare DFIL="${DEST}/.distfiles"
declare DMET="${DEST}/.metro"
declare DTMP="${DEST}/.temp"

declare DOUT="${DEST}/${TYPE}/${PLAT}/${ARCH}"
declare SOUT="${DEST}/${TYPE}/${PLAT}/${SARC}"

########################################

declare SAFE_ENV="prompt -z"
export CCACHE_DIR=

declare VERSION_REGEX="([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}-[0-9]{4})?|[a-z0-9]{40}[.][0-9])"
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
	target/version:	${DVER} \
"

########################################

declare COMMIT=
declare REPO
for REPO in \
	.setup	\
	.static	\
	metro	\
	portage
do
	COMMIT="${COMMIT}${REPO}: $(
		cat /.g/_data/zactive/${REPO}.git/refs/heads/master 2>/dev/null;
		cat ${BLD}/funtoo/${REPO}.git/refs/heads/{master,funtoo.org} 2>/dev/null;
	)\n"
done

########################################

declare REPO="$(cat ${SMET}/etc/builds/${TYPE}/build.conf 2>/dev/null |
	${SED} -n "s/^name[:][ ]//gp")"
declare SVER="$(ls -t {${SAV},${ISO},${SOUT}/*}/stage3-*${SARC}*${TYPE}*.tar.xz 2>/dev/null |
	${SED} "s/^.+${VERSION_REGEX}.+$/\1/g" |
	head -n1)"

{ [[ -z ${REPO} ]] || [[ -z ${SVER} ]]; } && exit 1

########################################

declare FILE=
declare NUM=

################################################################################

function checksum {
	for FILE in "${@}"; do
		declare CHECKDIR="$(dirname ${FILE})"
		declare CHECKFIL="$(basename ${FILE})"
		declare CHECKSUM="${FILE}.hash.txt"
		if [[ -f ${CHECKDIR}/${CHECKFIL} ]]; then
			(set -o pipefail; (cd ${CHECKDIR} &&
				sha256sum --tag ${CHECKFIL} &&
				md5sum --tag ${CHECKFIL}
			) | tee ${CHECKSUM}
			)						|| return 1
			touch -r ${CHECKDIR}/${CHECKFIL} ${CHECKSUM}	|| return 1
		fi
	done
	return 0
}

########################################

function sort_by_date {
	for FILE in $(
		${GREP} --with-filename "^Date[:][ ]" "${@}" |
		${SED} "s|^(.+)[:]Date[:][ ](.+)$|\1::\2|g" |
		${SED} "s|[ ]|^|g"
	); do
		declare DATE="$(date --iso=s --date="$(
			echo "${FILE/#*::}" | tr '^' ' '
		)")"
		echo -en "${DATE} :: ${FILE/%::*}\n"
	done |
		sort -n |
		${SED} "s|^.+[ ]::[ ]||g"
	return 0
}

if [[ ${1} == -! ]]; then
	if [[ ! -d ${REL_DIR}/.${TITLE} ]]; then
		${MKDIR} ${REL_DIR}/.${TITLE}			|| exit 1
		(cd ${REL_DIR}/.${TITLE} && ${GIT} init)	|| exit 1
	fi

	for FILE in \
		metro:${SAV}:_commit \
		setup:/.g/_data/zactive/.setup:gentoo \
		static:/.g/_data/zactive/.static:.bashrc^scripts/metro.sh \
		${TITLE}:${DOC_DIR}:
	do
		declare NAM="$(echo "${FILE}" | cut -d: -f1)"
		declare DIR="$(echo "${FILE}" | cut -d: -f2)"
		declare FIL="$(echo "${FILE}" | cut -d: -f3 | tr '^' ' ')"
		${MKDIR} ${REL_DIR}/${NAM}			|| exit 1
		${RM} ${REL_DIR}/${NAM}.git			|| exit 1
		${LN} ${DIR}.git ${REL_DIR}/${NAM}.git		|| exit 1
		(cd ${REL_DIR}/${NAM} && git-logdir -- ${FIL})	|| exit 1
		${RM} ${REL_DIR}/${NAM}.git			|| exit 1
	done
	if [[ -n $(ls ${REL_DIR}/[a-z]*.gitlog/new/* 2>/dev/null) ]]; then
		${SED} -i \
			-e "s|^(From[:][ ]).+|\1${AUTHOR}|g" \
			${REL_DIR}/[a-z]*.gitlog/new/*		|| exit 1
		${SED} -i \
			-e "N;N;s|^(Subject[:][ ])[[]git-backup[^[]+[[](.+)[]]|\1(RELEASE:\2)|g" \
			${REL_DIR}/[a-z]*.gitlog/new/*		|| exit 1
		${SED} -i \
			-e "N;N;s|^(From 444e47c253085ed084c4069e53505113b39619da.+Date[:][ ].+)-0800|\1+0000|g" \
			${REL_DIR}/[a-z]*.gitlog/new/*		|| exit 1
	fi
	for FILE in $(
		sort_by_date ${REL_DIR}/[a-z]*.gitlog/new/*
	); do
		(cd ${REL_DIR}/.${TITLE} && ${GIT} am \
			--ignore-space-change \
			--ignore-whitespace \
			--whitespace=nowarn \
			${FILE}
		)						|| exit 1
		${MV} ${FILE} ${FILE//\/new\//\/cur\/}		|| exit 1
	done

	(cd ${REL_DIR}/.${TITLE} &&
		NUM=0 &&
		for FILE in $(
			git-list --reverse | ${GREP} "RELEASE" | ${GREP} -o "[a-z0-9]{40}[ ]"
		); do
			${GIT} tag --force \
				${RELEASE[${NUM}]} ${FILE}	|| exit 1
			NUM="$((${NUM}+1))"			|| exit 1
		done &&
		git-clean &&
		declare GIT_CFG="git --git-dir=/home/git/p/${TITLE}/code.git config" &&
		declare COMMAND= &&
		COMMAND+="${GIT_CFG} --unset receive.denynonfastforwards;" &&
		COMMAND+="${GIT_CFG} --list;" &&
		COMMAND+="exit 0;" &&
		echo "${COMMAND}" | ssh ${SF_SSH} &&
		${GIT} push --mirror ${GITHUB} &&
		${GIT} push --mirror ${SFCODE}
	)							|| exit 1

	exit 0
fi

################################################################################

echo -en "BITS: ${BITS}\n"
echo -en "REVN: ${REVN}\n"
echo -en "REPO: ${REPO}\n"
echo -en "HASH: ${HASH}\n"
echo -en "SVER: ${SVER}\n"
echo -en "DVER: ${DVER}\n"

echo -en "\n"
${SAFE_ENV} env
read FILE

########################################

if [[ ${1} == -0 ]]; then
	vdiff -r ${SMET} ${DMET}
	exit 0
fi

########################################

if [[ ${1} == -1 ]]; then
	declare INIT_DIR="${PWD}"

	${LN} sbin/init ${INIT_DIR}/init			|| exit 1
	${SED} -i \
		-e "s/^([^#].+)$/#\1/g" \
		${INIT_DIR}/etc/fstab				|| exit 1
	${SED} -i \
		-e "s/^(hostname=[\"]?)[^\"]+([\"]?)$/\1${TITLE}\2/g" \
		${INIT_DIR}/etc/conf.d/hostname			|| exit 1
	echo -en "${TITLE}\n${TITLE}\n" |
		chroot ${INIT_DIR} /usr/bin/passwd root		|| exit 1

	${CP} -L ${INIT_DIR}/boot/kernel ${INIT_DIR}.kernel	#>>> || exit 1
	eval find ./ \
		$(for FILE in ./usr/src/linux-*; do echo -en "\( -path ${FILE} -prune \) -o "; done) \
		\
		'\( -path ./usr/portage		-prune \)' -o \
		'\( -path ./usr/portage.git	-prune \)' -o \
		\
		'\( -path ./tmp/.ccache		-prune \)' -o \
		'\( -path ./usr/lib32/debug	-prune \)' -o \
		'\( -path ./usr/lib64/debug	-prune \)' -o \
		'\( -path ./usr/src/debug	-prune \)' -o \
		-print |
	cpio -ovH newc >${INIT_DIR}.cpio			|| exit 1
	gzip -c ${INIT_DIR}.cpio >${INIT_DIR}.initrd		|| exit 1

	if [[ -d ${INIT_DIR}/usr/src/linux ]]; then
		declare INITRAMFS_CONFIG="\n"
		INITRAMFS_CONFIG+="CONFIG_INITRAMFS_SOURCE=\"${INIT_DIR}.cpio\"\n"
		INITRAMFS_CONFIG+="CONFIG_INITRAMFS_ROOT_GID=0\n"
		INITRAMFS_CONFIG+="CONFIG_INITRAMFS_ROOT_UID=0\n"
		INITRAMFS_CONFIG+="CONFIG_INITRAMFS_COMPRESSION_XZ=y\n"
		INITRAMFS_CONFIG+="# CONFIG_INITRAMFS_COMPRESSION_BZIP2 is not set\n"
		INITRAMFS_CONFIG+="# CONFIG_INITRAMFS_COMPRESSION_GZIP is not set\n"
		INITRAMFS_CONFIG+="# CONFIG_INITRAMFS_COMPRESSION_LZMA is not set\n"
		INITRAMFS_CONFIG+="# CONFIG_INITRAMFS_COMPRESSION_LZO is not set\n"
		INITRAMFS_CONFIG+="# CONFIG_INITRAMFS_COMPRESSION_NONE is not set\n"
		${SED} -i \
			-e "s%^CONFIG_INITRAMFS_SOURCE=\"\"$%${INITRAMFS_CONFIG}%g" \
			${INIT_DIR}/usr/src/linux/.config	|| exit 1
		(cd ${INIT_DIR}/usr/src/linux && make bzImage)	|| exit 1
		${CP} -L $(
			ls -t ${INIT_DIR}/usr/src/linux/arch/*/boot/bzImage |
			head -n1
		) ${INIT_DIR}.kernel.initrd			|| exit 1
	fi
	${RM} ${INIT_DIR}.cpio					|| exit 1

	exit 0
fi

########################################

if [[ ${1} == -/ ]]; then
	FILE="$(ls ${SAV}/stage3-*${ARCH}*${TYPE}*${DVER}*.tar.xz 2>/dev/null)"
	[[ -z ${FILE} ]] && exit 1

	declare INIT_SRC="${FILE}"
	declare INIT_DST="${FILE}.dir"

	${RM} ${INIT_DST}					|| exit 1
	${MKDIR} ${INIT_DST}					|| exit 1
	tar -pvvxJ -C ${INIT_DST} -f ${INIT_SRC}		|| exit 1

	(cd ${INIT_DST} && echo | ${_SELF} ${BITS} ${REVN} -1)	|| exit 1
	if [[ -f ${INIT_DST}.kernel.initrd ]]; then
		${MV} ${INIT_DST}.kernel.initrd \
			${INIT_SRC}.kernel			|| exit 1
		${RM} ${INIT_DST}.kernel			|| exit 1
		${RM} ${INIT_DST}.initrd			|| exit 1
	else
		${MV} ${INIT_DST}.kernel ${INIT_SRC}.kernel	|| exit 1
		${MV} ${INIT_DST}.initrd ${INIT_SRC}.initrd	|| exit 1
	fi
	${RM} ${INIT_DST}					|| exit 1

	exit 0
fi

################################################################################

${MKDIR} ${DEST}
${RSYNC_U} ${SMET}/ ${DMET}

${SED} -i \
	-e "s%^(author:).*$%\1 ${AUTHOR}%g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

${SED} -i \
	-e "s%^(: ).*mirror.*$%\1${DEST}%g" \
	-e "s%^(distfiles: ).*$%\1${DFIL}%g" \
	-e "s%^(tmp: ).*$%\1${DTMP}%g" \
	${DMET}/etc/metro.conf || exit 1

########################################

function makeconf_var {
	source ${CONFIG}/make.conf
	eval echo -en "\${${1}}" |
		${SED} "s/[$]/\\\\\\\\$/g" |
		tr '\n' ' '
}

declare OPTS="	$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s/[-][-]ask[^[:space:]]*//g")"
OPTS+="		$(makeconf_var MAKEOPTS			| ${GREP} -o "[-]j[0-9]+")"
declare PKGS="$(cat ${SET}				| ${GREP} -v -e "^[#]" -e "^$" | sort | tr '\n' ' ')"

declare FEAT="$(makeconf_var FEATURES)"
declare MKOP="$(makeconf_var MAKEOPTS)"
declare USE_="$(makeconf_var USE)			$(makeconf_var METRO_USE)"

#>>>USE_+="\nACCEPT_KEYWORDS:		$(makeconf_var ACCEPT_KEYWORDS)"
USE_+="\nACCEPT_LICENSE:		$(makeconf_var ACCEPT_LICENSE)"
USE_+="\nEMERGE_DEFAULT_OPTS:		$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s/[-][-]ask[^[:space:]]*//g")"
USE_+="\nLANG:				$(makeconf_var LANG)"
USE_+="\nLC_ALL:			$(makeconf_var LC_ALL)"
USE_+="\nLDFLAGS:			$(makeconf_var LDFLAGS)"
USE_+="\nPORTAGE_IONICE_COMMAND:	$(makeconf_var PORTAGE_IONICE_COMMAND)"
USE_+="\nPORTAGE_NICENESS:		$(makeconf_var PORTAGE_NICENESS)"

${SED} -i \
	-e "s%^(options:).*jobs.*$%\1	${OPTS}%g" \
	-e "s%^(packages:.*)$%\1\n	${PKGS}%g" \
	\
	-e "s%^(FEATURES:.*)$%\1	${FEAT}%g" \
	-e "s%^(MAKEOPTS:).*$%\1	${MKOP}%g" \
	-e "s%^(USE:).*$%\1		${USE_}%g" \
	\
	-e "s%^(branch/tar:).*$%\1	${HASH}%g" \
	-e "s%^(options:).*pull.*$%\1	%g" \
	\
	-e "s%\t+% %g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

${SED} -i \
	-e "s%^git checkout (.+branch/tar.+)$%git reset --hard \1%g" \
	${DMET}/targets/gentoo/snapshot/source/git || exit 1

USE_=
for FILE in \
	ACCEPT_KEYWORDS		\
	ACCEPT_LICENSE		\
	CHOST			\
	EMERGE_DEFAULT_OPTS	\
	FEATURES		\
	LANG			\
	LC_ALL			\
	LDFLAGS			\
	MAKEOPTS		\
	PORTAGE_IONICE_COMMAND	\
	PORTAGE_NICENESS
do
	USE_+="\n${FILE}=\"\$[portage/${FILE}:zap]\""
	${SED} -i \
		-e "s%^(${FILE}=.+)$%%g" \
		${DMET}/targets/gentoo/target/files.spec || exit 1
done

${SED} -i \
	-e "s%^(USE=.+)$%\1${USE_}%g" \
	${DMET}/targets/gentoo/target/files.spec || exit 1

########################################

USE_=
for FILE in \
	keywords	\
	license		\
	mask		\
	unmask		\
	use
do
	USE_+="files/package.${FILE}: [\n$(
		${SED} -e "s|^[#][{]MET[}][ ](.+)$|\1|g" -e "s%$%\\\\n%g" ${CONFIG}/package.${FILE} 2>/dev/null |
		tr -d '\n'
	)]\n"
done

${SED} -i \
	-e "s%^(USE:.+)$%\1\n${USE_}%g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

USE_="\
if [ \"\$[portage/files/package.license?]\" = \"yes\" ]	\n\
then							\n\
cat > /etc/portage/package.license << \"EOF\"		\n\
\$[[portage/files/package.license:lax]]			\n\
EOF\nfi							\n\
"

${SED} -i \
	-e "s%^(if[ ].+portage/files/package.use.+)$%${USE_}\1%g" \
	${DMET}/targets/gentoo/steps/stage.spec || exit 1

########################################

FILE="$(${GREP} "^.+/gentoo-sources(:.+)?$" ${SET} |
	sort -n |
	tail -n1)"
USE_="\
emerge \$eopts ccache debugedit				|| exit 1\n\
\\1\n\
emerge \$eopts genkernel ${FILE}			|| exit 1\n\
genkernel --loglevel=5 --bootloader=grub --symlink all	|| exit 1\n\
emerge \$eopts grub					|| exit 1\n\
#>>>mkdir -p /boot/grub					|| exit 1\n\
#>>>grub-mkconfig -o /boot/grub/grub.cfg		|| exit 1\n\
"

${SED} -i \
	-e "s%^(emerge.+system.+)$%${USE_}%g" \
	${DMET}/targets/gentoo/stage3.spec || exit 1

########################################

${SED} -i \
	-e "s%^(options:.*)clean/auto(.*)$%\1\2%g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

${SED} -i \
	-e "s%^([[:space:]]*emerge -C .*(ccache|genkernel).*)$%echo \"\1\"%g" \
	-e "s%^([[:space:]]*rm -rf .*linux.*)$%echo \"\1\"%g" \
	${DMET}/targets/gentoo/steps/kernel.spec \
	${DMET}/targets/gentoo/steps/stage.spec || exit 1

########################################

${SED} -i \
	-e "s%[-]fomit[-]frame[-]pointer%%g" \
	${DMET}/subarch/${ARCH}.spec || exit 1

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
echo -en "${SVER}\n"	>${SOUT}/.control/version/stage3

${MKDIR}		${DTMP}/cache/cloned-repositories/${REPO}
${RSYNC_U} ${SPRT}.git/	${DTMP}/cache/cloned-repositories/${REPO}/.git
${RM}			${DTMP}/cache/cloned-repositories/${REPO}.git
${LN} ${REPO}/.git	${DTMP}/cache/cloned-repositories/${REPO}.git

for FILE in $(
	ls -t {${SAV},${ISO}}/stage3-*${SARC}*${TYPE}*.tar.xz |
	${SED} "s/^.+${VERSION_REGEX}.+$/\1/g"
); do
	${MKDIR} ${SOUT}/${FILE}
	${RSYNC_U} {${SAV},${ISO}}/stage3-*${SARC}*${TYPE}*-${FILE}.tar.xz ${SOUT}/${FILE}/
done

########################################

echo -en "\n"
${SAFE_ENV} ${METRO_CMD} || exit 1

########################################

${MKDIR}		${SAV}				|| exit 1
echo -en "${COMMIT}"	>${SAV}/_commit			|| exit 1
${RSYNC_U} ${CONFIG}/	${SAV}/_config			|| exit 1
${RSYNC_U} ${_SELF}	${SAV}/_${SCRIPT}		|| exit 1
${RSYNC_U} ${DFIL}/	${SAV}/.distfiles		|| exit 1

FILE="${DTMP}/cache/build/${TYPE}/stage3-${ARCH}-${TYPE}-${DVER}/package"
${RSYNC_U} ${FILE}/	${SAV}/.packages.${ARCH}	|| exit 1

FILE="$(find ${DEST}/${TYPE} -type f 2>/dev/null |
	${GREP} "(${SVER}|${DVER})[.]tar[.]xz$")"
${RSYNC_U} ${FILE}	${SAV}/				|| exit 1

########################################

echo | ${_SELF} ${BITS} ${REVN} -/ || exit 1

exit 0
################################################################################
# end of file
################################################################################
