#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################
# release checklist:
#	* build
#		* [complete all commits in ".setup", ".static" and "coding"]
#			* rm /.g/_data/_build/_metro/funtoo-*/*/*/*/stage3-*
#		* metro.sh -! && (echo | metro.sh 32 0) && (echo | metro.sh 64 0)
#			* qemu-minion.bsh /.g/_data/_builds/_metro/stage3-generic_32-*.kernel "" -append nomodeset
#			* qemu-minion.bsh /.g/_data/_builds/_metro/stage3-generic_64-*.kernel "" -append nomodeset
#		* cd /.g/_data/_builds/_metro && cat _commit
#			* [verify with "git-list" in each repository]
#		* cd /.g/_data/_builds/.gary-os/.gary-os ; vdiff -g v#.#
#			* [COMMIT] Added "v#.#" release to "Version History" in "README".
#			* [COMMIT] Tested/validated/updated "Use Cases" with "v#.#" version.
#	* commit
#		* cd /.g/_data/_builds/_metro && git-backup <version>
#		* [update "$RELEASE" and "$CMT_HSH" in "metro.sh"]
#		* metro.sh -! && (echo | metro.sh 32 0) && (echo | metro.sh 64 0)
#		* cd /.g/_data/_builds/_metro && git-commit --all --amend --no-edit
#			* [COMMIT] (RELEASE:########################################.#) (tag: v#.#)
#		* [update/commit "$RELEASE" and "$CMT_HSH" in "metro.sh"]
#			* [COMMIT] Added new release to version tags in "metro.sh".
#	* release
#		* ls /.g/_data/_builds/.gary-os/metro.gitlog/cur | tail -n1
#			* rm <result>
#		* cd /.g/_data/_builds/.gary-os/.gary-os && git-list
#			* git reset --hard HEAD^1
#		* metro.sh -! -!
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
RELEASE[3]="v1.0"; CMT_HSH[3]="f6885f3482b95fe15a688135c441f8f6391c9529"
RELEASE[4]="v1.1"; CMT_HSH[4]="9b653e64164e68873333043b41f8bbf23b0fbd55"
RELEASE[5]="v2.0"; CMT_HSH[5]="deda452a0aab311f243311b48a39b7ac60ab3fd8"

declare FUNTOO_STAGE="2015-01-27"
declare GRML_DATE="2014.11"

########################################

declare DOC_DIR="/.g/_data/zactive/coding/${TITLE}"
declare OUT_DIR="/.g/_data/_builds/.${TITLE}.release"
declare REL_DIR="/.g/_data/_builds/.${TITLE}"

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
declare HASH="$(cat ${CONFIG}/funtoo)"
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

declare EXTN=".tar.xz"

########################################

declare SAFE_ENV="prompt -z"
export CCACHE_DIR=


declare VERSION_REGEX="([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}-[0-9]{4})?|[a-z0-9]{40}[.][0-9])"
declare METRO_CMD="${DMET}/metro \
	--verbose \
	--debug \
	--debug-flexdata \
	multi:		yes \
	multi/mode:	full \
	path/mirror:	${DEST} \
	path/distfiles:	${DFIL} \
	path/install:	${DMET} \
	path/tmp:	${DTMP} \
	target/build:	${TYPE} \
	target/subarch:	${ARCH} \
	target/version:	${DVER} \
	${DMET}/metro.conf \
"

########################################

declare COMMIT=
declare REPO
for REPO in \
	${TITLE}	\
	.setup		\
	.static		\
	metro		\
	portage
do
	COMMIT="${COMMIT}${REPO}: $(
		cat /.g/_data/zactive{,/coding}/${REPO}.git/refs/heads/master 2>/dev/null;
		cat ${BLD}/funtoo/${REPO}.git/refs/heads/{master,funtoo.org} 2>/dev/null;
	)\n"
done

########################################

declare REPO="$(
	cat ${SMET}/etc/builds/${TYPE}/build.conf 2>/dev/null |
	${SED} -n "s%^name[:][ ]%%gp"
)"
declare SVER="$(
	ls -t {${SAV},${ISO},${SOUT}/*}/stage3-${SARC}-${TYPE}-*${EXTN} 2>/dev/null |
	${SED} "s%^.+${VERSION_REGEX}.+$%\1%g" |
	head -n1
)"

{ [[ -z ${REPO} ]] || [[ -z ${SVER} ]]; } && exit 1

########################################

declare KERN="${ISO}/grml${BITS}-full_${GRML_DATE}.iso"
declare DWMC="${CONFIG}/savedconfig/x11-wm/dwm"
declare PACK=

if [[ -f ${KERN} ]]; then
	declare MNT="/mnt"				|| exit 1
	declare KRN="/boot/grml${BITS}full/vmlinuz"	|| exit 1
	mount -o loop ${KERN} ${MNT}			|| exit 1
	if [[ -f ${MNT}${KRN} ]]; then
		${MKDIR} ${SAV}				|| exit 1
		/usr/src/linux/scripts/extract-ikconfig \
			${MNT}${KRN} \
			>${SAV}/_config.${BITS}		|| exit 1
	fi
	umount ${KERN}					|| exit 1
fi
if [[ ! -f ${DWMC} ]]; then
	DWMC=						|| exit 1
fi

KERN="${SAV}/_config.${BITS}"
PACK="${SAV}/_packages.${BITS}"

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

if [[ ${1} == -! ]]; then
	function git-export-preprocess {
		${SED} -i "s%^(From[:][ ]).+%\1${AUTHOR}%g"							"${@}" || return 1
		${SED} -i "N;N;s%^(Subject[:][ ])[[]git-backup[^[]+[[](.+)[]]%\1(RELEASE:\2)%g"			"${@}" || return 1
		${SED} -i "N;N;s%^(From 444e47c253085ed084c4069e53505113b39619da.+Date[:][ ].+)-0800%\1+0000%g"	"${@}" || return 1
		return 0
	}
	function git-export-postprocess {
		declare NUM=0
		declare FILE=
		for FILE in $(
			git-list --reverse | ${GREP} "RELEASE" | ${GREP} -o "[a-z0-9]{40}[ ]"
		); do
			${GIT} tag --force ${RELEASE[${NUM}]} ${FILE}	|| return 1
			NUM="$((${NUM}+1))"				|| return 1
		done
		return 0
	}
	git-export ${TITLE} ${REL_DIR} ${GITHUB} \
		+git-export-preprocess +git-export-postprocess \
		metro:${SAV}:_commit^_config.\*^_packages.\* \
		setup:/.g/_data/zactive/.setup:gentoo \
		static:/.g/_data/zactive/.static:.bashrc^scripts/grub.sh^scripts/metro.sh \
		${TITLE}:${DOC_DIR}:				|| exit 1

	(cd ${REL_DIR}/.${TITLE} &&
		declare GIT_CFG="git --git-dir=/home/git/p/${TITLE}/code.git config" &&
		declare COMMAND= &&
		COMMAND+="${GIT_CFG} --unset receive.denynonfastforwards;" &&
		COMMAND+="${GIT_CFG} --list;" &&
		COMMAND+="exit 0;" &&
		echo -en "${COMMAND}\n" | ssh ${SF_SSH} &&
		${GIT} push --mirror ${SFCODE}
	)							|| exit 1

	if [[ ${2} == -! ]]; then
		${MKDIR} ${OUT_DIR}				|| exit 1
		${RM} ${OUT_DIR}.git				|| exit 1
		${LN} ${SAV}.git ${OUT_DIR}.git			|| exit 1
		for NUM in $(
			eval echo -en "{0..$((${#RELEASE[*]}-1))}"
		); do
			${MKDIR} ${OUT_DIR}/${RELEASE[${NUM}]}	|| exit 1
			(cd ${OUT_DIR} &&
				git-backup -r ${CMT_HSH[${NUM}]} portage-* stage3-* &&
				${GIT} reset &&
				checksum ${OUT_DIR}/{portage,stage3}-* &&
				${RSYNC_U} ${OUT_DIR}/{portage,stage3}-* ${OUT_DIR}/${RELEASE[${NUM}]}/ &&
				${RM} ${OUT_DIR}/{portage,stage3}-* &&
				touch -r $(
					ls -t ${OUT_DIR}/${RELEASE[${NUM}]}/*.kernel 2>/dev/null |
					head -n1
				) ${OUT_DIR}/${RELEASE[${NUM}]}
			)					|| exit 1
		done
		${RM} ${OUT_DIR}/+index*			|| exit 1
		${RM} ${OUT_DIR}.git				|| exit 1

		for NUM in ${RELEASE[*]}; do
			for FILE in $(
				ls ${OUT_DIR}/${NUM} |
				${GREP} "^stage3.+[.](kernel|initrd)$"
			); do
				declare OUTFILE="$(
					echo -en "${FILE}" |
					${SED} \
						-e "s%^stage3%${TITLE}%g" \
						-e "s%[a-z0-9]{40}[.][0-9]${EXTN//./[.]}%${NUM}%g"
				)"				|| exit 1
				${RSYNC_U} \
					${OUT_DIR}/${NUM}/${FILE} \
					${OUT_DIR}/${OUTFILE}	|| exit 1
				checksum ${OUT_DIR}/${OUTFILE}	|| exit 1
			done
		done

		FILE="${OUT_DIR}/${TITLE}.grub"			|| exit 1
		${RM} ${FILE}					|| exit 1
		${MKDIR} ${FILE}				|| exit 1
		(cd ${FILE} && ${HOME}/scripts/grub.sh)		|| exit 1
		(cd ${OUT_DIR} &&
			tar -cvvJ -f ${FILE}${EXTN} \
			${TITLE}.grub)				|| exit 1
	fi

	${RSYNC_C} ${DOC_DIR}/ ${OUT_DIR}/			|| exit 1
	${RSYNC_U} ${OUT_DIR}/ ${SFFILE}			|| exit 1
	${LL} -R ${OUT_DIR}

	exit 0
fi

################################################################################

echo -en "\n"
${SAFE_ENV} env
echo -en "\n"

echo -en "BITS: ${BITS}\n"
echo -en "REVN: ${REVN}\n"
echo -en "REPO: ${REPO}\n"
echo -en "HASH: ${HASH}\n"
echo -en "SVER: ${SVER}\n"
echo -en "DVER: ${DVER}\n"

if [[ ! -f ${KERN} ]]; then
	echo -en "\nWARNING: GRML ${GRML_DATE} not found!\n" >&2
fi
if [[ ${SVER} != ${FUNTOO_STAGE} ]]; then
	echo -en "\nWARNING: stage3 ${SVER} is not ${FUNTOO_STAGE}!\n" >&2
fi

read FILE

########################################

if [[ ${1} == -0 ]]; then
	vdiff -r ${SMET} ${DMET}
	exit 0
fi

########################################

if [[ ${1} == -1 ]]; then
	declare INIT_DIR="${PWD}"

	${CP} -L ${INIT_DIR}/boot/kernel ${INIT_DIR}.kernel	#>>> || exit 1
	eval find ./ \
		$(for FILE in ./usr/src/linux-*; do echo -en "\( -path ${FILE} -prune \) -o "; done) \
		\
		'\( -path ./usr/portage		-prune \)' -o \
		'\( -path ./usr/portage.git	-prune \)' -o \
		\
		'\( -path ./tmp/.ccache		-prune \)' -o \
		'\( -path ./usr/lib/debug	-prune \)' -o \
		'\( -path ./usr/lib32/debug	-prune \)' -o \
		'\( -path ./usr/lib64/debug	-prune \)' -o \
		'\( -path ./usr/src/debug	-prune \)' -o \
		-print |
	cpio -ovH newc >${INIT_DIR}.cpio			|| exit 1
	xz -cvC crc32 ${INIT_DIR}.cpio >${INIT_DIR}.initrd	|| exit 1

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
			ls -t ${INIT_DIR}/usr/src/linux/arch/*/boot/bzImage 2>/dev/null |
			head -n1
		) ${INIT_DIR}.kernel.initrd			|| exit 1
	fi
	if [[ -z ${METRO_DEBUG} ]]; then
		${RM} ${INIT_DIR}.cpio				|| exit 1
	fi

	exit 0
fi

########################################

if [[ ${1} == -/ ]]; then
	FILE="$(ls ${SAV}/stage3-${ARCH}-${TYPE}-${DVER}${EXTN} 2>/dev/null)"
	[[ -z ${FILE} ]] && exit 1

	declare INIT_SRC="${FILE}"
	declare INIT_DST="${FILE}.dir"

	${RM} ${INIT_DST}					|| exit 1
	${MKDIR} ${INIT_DST}					|| exit 1
	tar -pvvxJ -C ${INIT_DST} -f ${INIT_SRC}		|| exit 1

	${RSYNC_U} ${REL_DIR}/.${TITLE}/ \
		${INIT_DST}/.${TITLE}				|| exit 1
	${RSYNC_U} ${REL_DIR}/.${TITLE}.git/ \
		${INIT_DST}/.${TITLE}/.git			|| exit 1
	${SED} -i "s%^[[:space:]]+worktree.+$%%g" \
		${INIT_DST}/.${TITLE}/.git/config		|| exit 1

	${LN} sbin/init ${INIT_DST}/init			|| exit 1
	${SED} -i \
		-e "s%^([^#].+)$%#\1%g" \
		${INIT_DST}/etc/fstab				|| exit 1
	${SED} -i \
		-e "s%^(hostname=[\"]?)[^\"]+([\"]?)$%\1${TITLE}\2%g" \
		${INIT_DST}/etc/conf.d/hostname			|| exit 1
	echo -en "XSESSION=\"dwm\"\n" \
		>${INIT_DST}/etc/env.d/90xsession		|| exit 1
	chroot ${INIT_DST} /usr/sbin/env-update			|| exit 1
	chroot ${INIT_DST} rc-update delete lvm boot		|| exit 1
	chroot ${INIT_DST} rc-update delete postfix default	|| exit 1
	chroot ${INIT_DST} eselect vi set vim			|| exit 1
	echo -en "${TITLE}\n${TITLE}\n" |
		chroot ${INIT_DST} /usr/bin/passwd root		|| exit 1

	(cd ${INIT_DST}/var/db/pkg &&
		for FILE in $(
			find ./ -mindepth 2 -maxdepth 2 -type d |
				${SED} "s%^[.][/]%%g" |
				sort
		); do
			(cd ${DTMP}/cache/package-cache/${PLAT}/${TYPE}/${ARCH}/remote/stage3 &&
				du -ks ${FILE}.tbz2 |
				${SED} "s%^(.+${FILE}).+$%\1%g"
			)					#>>> || exit 1
		done
	) 2>&1 | tee ${PACK}					#>>> || exit 1

	(cd ${INIT_DST} && echo | ${_SELF} ${BITS} ${REVN} -1)	|| exit 1

	if [[ -f ${INIT_DST}.kernel.initrd ]]; then
		${MV} ${INIT_DST}.kernel.initrd \
			${INIT_SRC}.kernel			|| exit 1
		if [[ -z ${METRO_DEBUG} ]]; then
			${RM} ${INIT_DST}.kernel		|| exit 1
			${RM} ${INIT_DST}.initrd		|| exit 1
		fi
	else
		${MV} ${INIT_DST}.kernel ${INIT_SRC}.kernel	|| exit 1
		${MV} ${INIT_DST}.initrd ${INIT_SRC}.initrd	|| exit 1
	fi

	if [[ -z ${METRO_DEBUG} ]]; then
		${RM} ${INIT_DST}				|| exit 1
	fi

	exit 0
fi

################################################################################

${MKDIR} ${DEST}
${MKDIR} ${DEST}/${TYPE}/snapshots
${RSYNC_U} ${SMET}/ ${DMET}

${SED} -i \
	-e "s%^(author:).*$%\1 ${AUTHOR}%g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

${SED} -i \
	-e "s%^(: ).*mirror.*$%\1${DEST}%g" \
	-e "s%^(distfiles: ).*$%\1${DFIL}%g" \
	-e "s%^(install: ).*$%\1${DMET}%g" \
	-e "s%^(tmp: ).*$%\1${DTMP}%g" \
	${DMET}/metro.conf || exit 1

${SED} -i \
	-e "s%os.path.expanduser\(\"~/.metro\"\)%(\"${DMET}/metro.conf\")%g" \
	-e "s%libdir\+\"%\"${DMET}%g" \
	${DMET}/modules/metro_support.py || exit 1

########################################

function makeconf_var {
	source ${CONFIG}/make.conf
	eval echo -en "\${${1}}" |
		${SED} "s%[$]%\\\\\\\\$%g" |
		tr '\n' ' '
}

declare OPTS="	$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s%[-][-]ask[^[:space:]]*%%g")"
OPTS+="		$(makeconf_var MAKEOPTS			| ${GREP} -o "[-]j[0-9]+")"

declare PKGS="$(cat ${SET}				| ${GREP} -v \
								-e "^$" \
								-e "^[#]" \
								-e "[#][ ]${BITS}-bit[ ]build[ ]fail$" \
							| ${SED} "s/[#].+$//g" \
							| sort | tr '\n' ' ')"

declare FEAT="$(makeconf_var FEATURES)"
declare MKOP="$(makeconf_var MAKEOPTS)"
declare USE_="$(makeconf_var METRO_USE)"

#>>>USE_+="\nACCEPT_KEYWORDS:		$(makeconf_var ACCEPT_KEYWORDS)"
USE_+="\nACCEPT_LICENSE:		$(makeconf_var ACCEPT_LICENSE)"
USE_+="\nEMERGE_DEFAULT_OPTS:		$(makeconf_var EMERGE_DEFAULT_OPTS	| ${SED} "s%[-][-]ask[^[:space:]]*%%g")"
USE_+="\nLANG:				$(makeconf_var LANG)"
USE_+="\nLC_ALL:			$(makeconf_var LC_ALL)"
USE_+="\nPORTAGE_IONICE_COMMAND:	$(makeconf_var PORTAGE_IONICE_COMMAND)"
USE_+="\nPORTAGE_NICENESS:		$(makeconf_var PORTAGE_NICENESS)"

USE_+="\nINPUT_DEVICES:			$(makeconf_var METRO_INPUT_DEVICES)"
USE_+="\nVIDEO_CARDS:			$(makeconf_var METRO_VIDEO_CARDS)"

USE_+="\nPYTHON_ABIS:			$(makeconf_var METRO_PYTHON_ABIS)"
USE_+="\nPYTHON_TARGETS:		$(makeconf_var METRO_PYTHON_TARGETS)"
USE_+="\nRUBY_TARGETS:			$(makeconf_var METRO_RUBY_TARGETS)"

${SED} -i \
	-e "s%^MAKEOPTS:.*$%%g" \
	-e "s%^options:.*jobs.*$%%g" \
	${DMET}/metro.conf || exit 1

${SED} -i \
	-e "s%^(\[section emerge\])$%\1	\noptions: ${OPTS}\npackages: ${PKGS}%g" \
	\
	-e "s%^(FEATURES:.*)$%\1	${FEAT}\nMAKEOPTS: ${MKOP}%g" \
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
	INPUT_DEVICES		\
	LANG			\
	LC_ALL			\
	MAKEOPTS		\
	PORTAGE_IONICE_COMMAND	\
	PORTAGE_NICENESS	\
	PYTHON_ABIS		\
	PYTHON_TARGETS		\
	RUBY_TARGETS		\
	VIDEO_CARDS
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
		${SED} -e "s%^[#][{]MET[}][ ](.+)$%\1%g" -e "s%$%\\\\n%g" ${CONFIG}/package.${FILE} 2>/dev/null |
		tr -d '\n'
	)]\n"
done
USE_+="files/linux.config: [\n]\n"
USE_+="files/dwm.config: [\n]\n"

${SED} -i \
	-e "s%^(USE:.+)$%\1\n${USE_}%g" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1
${SED} -i \
	-e "/files[\/]linux[.]config[:]/r ${KERN}" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1
${SED} -i \
	-e "/files[\/]dwm[.]config[:]/r ${DWMC}" \
	${DMET}/etc/builds/${TYPE}/build.conf || exit 1

USE_="\
if [ \"\$[portage/files/package.license?]\" = \"yes\" ]	\n\
then							\n\
cat > /etc/portage/package.license << \"EOF\"		\n\
\$[[portage/files/package.license:lax]]			\n\
EOF\nfi							\n\
\
if [ \"\$[portage/files/linux.config?]\" = \"yes\" ]	\n\
then							\n\
mkdir /etc/kernels					\n\
cat > /etc/kernels/.config << \"EOF\"			\n\
\$[[portage/files/linux.config:lax]]			\n\
EOF\nfi							\n\
\
if [ \"\$[portage/files/dwm.config?]\" = \"yes\" ]	\n\
then							\n\
mkdir -p /etc/portage/savedconfig/x11-wm		\n\
cat > /etc/portage/savedconfig/x11-wm/dwm << \"EOF\"	\n\
\$[[portage/files/dwm.config:lax]]			\n\
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
GK_OPTS=\"--loglevel=5 --bootloader=grub --symlink\"	|| exit 1\n\
if [ -f \"/etc/kernels/.config\" ]			\n\
then							\n\
GK_OPTS+=\" --kernel-config=/etc/kernels/.config\"	|| exit 1\n\
fi							\n\
genkernel \${GK_OPTS} all				|| exit 1\n\
emerge \$eopts grub					|| exit 1\n\
#>>>mkdir -p /boot/grub					|| exit 1\n\
#>>>grub-mkconfig -o /boot/grub/grub.cfg		|| exit 1\n\
#>>>boot-update						|| exit 1\n\
"

${SED} -i \
	-e "s%^export USE=.+$%%g" \
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
echo -en "${PLAT}\n"	>${DOUT}/.control/remote/arch_desc
echo -en "${SARC}\n"	>${DOUT}/.control/remote/subarch
${MKDIR} ${SOUT}/.control/version
echo -en "${SVER}\n"	>${SOUT}/.control/version/stage3

${MKDIR}		${DTMP}/cache/cloned-repositories/${REPO}
${RSYNC_U} ${SPRT}.git/	${DTMP}/cache/cloned-repositories/${REPO}/.git
${RM}			${DTMP}/cache/cloned-repositories/${REPO}.git
${LN} ${REPO}/.git	${DTMP}/cache/cloned-repositories/${REPO}.git

for FILE in $(
	ls -t {${SAV},${ISO}}/stage3-${SARC}-${TYPE}-*${EXTN} 2>/dev/null |
	${SED} "s%^.+${VERSION_REGEX}.+$%\1%g"
); do
	${MKDIR} ${SOUT}/${FILE}
	${RSYNC_U} {${SAV},${ISO}}/stage3-${SARC}-${TYPE}-${FILE}${EXTN} ${SOUT}/${FILE}/
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

FILE="${DTMP}/cache/package-cache/${PLAT}/${TYPE}/${ARCH}/remote/stage3"
${RSYNC_U} ${FILE}/	${SAV}/.packages.${ARCH}	|| exit 1

FILE="$(find ${DEST}/${TYPE} -type f 2>/dev/null |
	${GREP} "(${SVER}|${DVER})${EXTN//./[.]}$")"
${RSYNC_U} ${FILE}	${SAV}/				|| exit 1

########################################

echo | ${_SELF} ${BITS} ${REVN} -/ || exit 1

exit 0
################################################################################
# end of file
################################################################################
