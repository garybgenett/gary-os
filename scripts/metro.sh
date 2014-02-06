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
	target/version:	$(date --iso=d) \
"
#>>>	target/version:	$(date --iso=h) \

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

declare NAME="$(cat ${SMET}/etc/builds/${TYPE}/build.conf 2>/dev/null |
	${SED} -n "s/^name[:][ ]//gp")"
declare DATE="$(ls {${SAV},${ISO},${SOUT}/*}/stage3-*${SARC}*${TYPE}*.tar.xz 2>/dev/null |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}-[0-9]{4})?).+$/\1/g" |
	sort -n |
	tail -n1)"

{ [[ -z ${NAME} ]] || [[ -z ${DATE} ]]; } && exit 1

########################################

declare FILE=

################################################################################

if [[ ${1} == -/ ]]; then
	FILE="$(ls ${SAV}/stage3-*${ARCH}*${TYPE}*${DATE}*.tar.xz 2>/dev/null)"
	[[ -z ${FILE} ]] && exit 1

	declare INIT_SRC="${FILE}"
	declare INIT_DST="${FILE}.dir"
	declare INIT_NAM="rescue"

	${RM} ${INIT_DST}						|| exit 1
	${MKDIR} ${INIT_DST}						|| exit 1
	tar -pvvxJ -C ${INIT_DST} -f ${INIT_SRC}			|| exit 1

	${LN} sbin/init ${INIT_DST}/init				|| exit 1
	${SED} -i \
		-e "s/^([^#].+)$/#\1/g" \
		${INIT_DST}/etc/fstab					|| exit 1
	${SED} -i \
		-e "s/^(hostname=[\"]?)[^\"]+([\"]?)$/\1${INIT_NAM}\2/g" \
		${INIT_DST}/etc/conf.d/hostname				|| exit 1
	echo -en "${INIT_NAM}\n${INIT_NAM}\n" |
		chroot ${INIT_DST} /usr/bin/passwd root			|| exit 1

	${CP} -L ${INIT_DST}/boot/kernel ${INIT_SRC}.kernel		|| exit 1
	(cd ${INIT_DST} &&
		find . | cpio -ovH newc | gzip >${INIT_SRC}.initrd)	|| exit 1
	${RM} ${INIT_DST}						|| exit 1

	exit 0
fi

################################################################################

${MKDIR} ${DEST}
${RSYNC_U} ${SMET}/ ${DMET}

########################################

function makeconf_var {
	source ${HOME}/setup/gentoo/make.conf
	eval echo -en "\${${1}}" |
		${SED} "s/[$]/\\\\\\\\$/g" |
		tr '\n' ' '
}

declare OPTS="	$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s/[-][-]ask[^[:space:]]*//g")"
OPTS+="		$(makeconf_var MAKEOPTS			| ${GREP} -o "[-]j[0-9]+")"
declare PKGS="$(cat ${HOME}/setup/gentoo/sets/metro	| ${GREP} -v -e "^[#]" -e "^$" | sort | tr '\n' ' ')"

declare FEAT="$(makeconf_var FEATURES)"
declare MKOP="$(makeconf_var MAKEOPTS)"
declare USE_="$(makeconf_var USE			| ${SED} "s/[ ][-]?(X|gdbm|gtk|imlib|introspection|java|tk|udev|wxwidgets)[ ]/ -\1 /g")"

#>>>USE_+="\nACCEPT_KEYWORDS:		$(makeconf_var ACCEPT_KEYWORDS)"
USE_+="\nACCEPT_LICENSE:		$(makeconf_var ACCEPT_LICENSE)"
USE_+="\nEMERGE_DEFAULT_OPTS:		$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s/[-][-]ask[^[:space:]]*//g")"
USE_+="\nGRUB_PLATFORMS:		$(makeconf_var GRUB_PLATFORMS)"
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
	-e "s%^(branch/tar:).*$%\1	$(cat ${HOME}/setup/gentoo/.funtoo)%g" \
	-e "s%^(options:).*pull.*$%\1	%g" \
	\
	-e "s%^(options:).*clean.*$%\1	%g" \
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
	GRUB_PLATFORMS		\
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
USE_+="files/package.keywords: [			\n\
# required						\n\
app-crypt/efitools		~\$[target/arch]	\n\
net-analyzer/tcptrace		~\$[target/arch]	\n\
sys-fs/ext3grep			~\$[target/arch]	\n\
sys-fs/zfs			~\$[target/arch]	\n\
sys-fs/zfs-kmod			~\$[target/arch]	\n\
sys-kernel/spl			~\$[target/arch]	\n\
# fail							\n\
net-analyzer/ssldump		~\$[target/arch]	\n\
sys-boot/gnu-efi		~\$[target/arch]	\n\
]\n"
USE_+="files/package.license: [				\n\
app-arch/rar			RAR			\n\
app-arch/unrar			unRAR			\n\
sys-kernel/gentoo-sources	freedist		\n\
sys-kernel/linux-firmware	freedist		\n\
]\n"
USE_+="files/package.mask: [				\n\
]\n"
USE_+="files/package.unmask: [				\n\
]\n"
USE_+="files/package.use: [				\n\
]\n"

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

FILE="$(${GREP} "^.+/gentoo-sources(:.+)?$" ${HOME}/setup/gentoo/sets/metro |
	sort -n |
	tail -n1)"
USE_="\
genkernel --loglevel=5 --symlink all || exit 1		\n\
#>>>mkdir -p /boot/grub || exit 1			\n\
#>>>grub-mkconfig -o /boot/grub/grub.cfg || exit 1	\n\
"

${SED} -i \
	-e "s%^(emerge.+system)(.+)$%\1 ${FILE} genkernel grub\2\n${USE_}%g" \
	${DMET}/targets/gentoo/stage3.spec || exit 1

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
${LN} ${NAME}/.git	${DTMP}/cache/cloned-repositories/${NAME}.git

for FILE in $(ls {${SAV},${ISO}}/stage3-*${SARC}*${TYPE}*.tar.xz |
	${SED} "s/^.+([0-9]{4}-[0-9]{2}-[0-9]{2}).+$/\1/g" |
	sort -n)
do
	${MKDIR} ${SOUT}/${FILE}
	${RSYNC_U} {${SAV},${ISO}}/stage3-*${SARC}*${TYPE}*-${FILE}.tar.xz ${SOUT}/${FILE}/
done

########################################

for FILE in \
	targets/gentoo/snapshot/source/git	\
	targets/gentoo/stage3.spec		\
	targets/gentoo/steps/stage.spec		\
	targets/gentoo/target/files.spec	\
	etc/builds/${TYPE}/build.conf
do
	echo -en "\n[${FILE}]\n"
	diff ${SMET}/${FILE} ${DMET}/${FILE}
done

echo -en "\n"
echo -en "NAME: ${NAME}\n"
echo -en "DATE: ${DATE}\n"

echo -en "\n"
${SAFE_ENV} env

########################################

echo -en "\n"
${SAFE_ENV} ${METRO_CMD} || exit 1

########################################

FILE="$(find ${DEST}/funtoo-* -type f 2>/dev/null |
	${GREP} "[.]tar[.]xz$")"

${MKDIR}				${SAV}				|| exit 1
echo -en "${COMMIT}"			>${SAV}/_commit			|| exit 1
${RSYNC_U} ${HOME}/setup/gentoo/	${SAV}/_config			|| exit 1
${RSYNC_U} ${HOME}/scripts/metro.sh	${SAV}/_metro.sh		|| exit 1
${RSYNC_U} ${DFIL}/			${SAV}/$(basename ${DFIL})	|| exit 1
${RSYNC_U} ${FILE}			${SAV}/				|| exit 1

${_SELF} -/ || exit 1

exit 0
################################################################################
# end of file
################################################################################
