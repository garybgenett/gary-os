#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare _PROJ="GaryOS"
declare _NAME="${_PROJ} Grub"

declare _BASE="gary-os"
declare _GRUB="${_BASE}.grub"

########################################

declare HEADER="$(printf "~%.0s" {1..80})"

declare _OPTS="${@}"
echo -en "${HEADER}\n"
echo -en "ARGUMENTS: ${_OPTS}\n"
echo -en "${HEADER}\n"

################################################################################

declare GDEST="$(realpath ${1} 2>/dev/null)"
if [[ ! -d ${GDEST} ]]; then
	GDEST="(null)"
fi
shift

declare HEDEF="10"
declare GIDEF="${GDEST}/disk_image.raw"
declare GPDEF="2"

if [[ ! -d ${GDEST} ]]; then
	exit 0
fi

########################################

declare DEBUG="false"
declare HEADS="${HEDEF}"
if [[ ${1} == -d*([0-9]) ]]; then
	HEADS="${1/#-d}"
	DEBUG="true"
	if [[ -z ${HEADS} ]]; then
		HEADS="${HEDEF}"
	fi
	shift
fi

########################################

declare GINST="${GIDEF}"
declare GPART="${GPDEF}"
declare GCUST=

if [[ -b ${1} ]] || [[ ${1} == grub+([0-9]) ]]; then
	GINST="$(echo ${1} | ${SED} "s|^(.+[^0-9])([0-9]+)$|\1|g")"
	GPART="$(echo ${1} | ${SED} "s|^(.+[^0-9])([0-9]+)$|\2|g")"
	shift
	if [[ ${GINST} == grub ]]; then
		GINST="${GIDEF}"
	fi
	if [[ ${GPART} != +([0-9]) ]]; then
		GPART="${GPDEF}"
	fi
fi

if [[ -f ${1} ]]; then
	GCUST="$(${SED} "s|[\"]|\\\\\"|g" ${1})"
	shift
fi

########################################

declare GOPTS=
if [[ -n ${1} ]]; then
	GOPTS="${1}"
	shift
fi

################################################################################

declare GBOOT="(hd0)"
declare GROOT="(hd0,${GPART})"
declare GFILE="(hd0,${GPART})/boot/grub/grub.cfg"

declare GTYPE="i386-pc"
declare GRUBD="/usr/lib/grub"
declare GMODS="${GRUBD}/${GTYPE}"

########################################

declare G_DBG="set debug=linux"

declare GLOAD="\
# load
${G_DBG}
echo \"Loading ${_NAME}...\"
insmod configfile
# end of file
"

declare GLOAD_FILE="\
# load file
${G_DBG}
echo \"Loading ${_NAME}...\"
insmod configfile
configfile ${GFILE}
# end of file
"

declare GMENU="\
# menu
${G_DBG}
insmod linux
menuentry \"${_PROJ}\" {
linux ${GROOT}/${_BASE}.null.kernel
linux ${GROOT}/${_BASE}.kernel ${GOPTS}
}
insmod chain
menuentry \"Back to OS\" { chainloader ${GBOOT}+1 }
# end of file
"

declare GRESC="\
# rescue
${G_DBG}
insmod read
menuentry \"${_NAME} Rescue Image\" { set; read rescue; }
${GCUST:-${GMENU}}
"

########################################

declare BCDEDIT="\
@echo off
set CURDIR=%~dp0
if not exist %CURDIR%\bcdedit.guid.txt (goto create) else (goto delete)
:create
	for /f \"usebackq tokens=3\" %%I in (\`bcdedit /create /d \"${_NAME}\" /application bootsector\`) do set GUID=%%I
	echo %GUID% >%CURDIR%\bcdedit.guid.txt
	echo %GUID%
	bcdedit /set %GUID% device partition=c:
	bcdedit /set %GUID% path \\${_GRUB}\\bootstrap.img
	bcdedit /displayorder %GUID% /addlast
	bcdedit /timeout 10
	goto end
:delete
	set /p GUID=<%CURDIR%\bcdedit.guid.txt
	del %CURDIR%\bcdedit.guid.txt
	echo %GUID%
	bcdedit /delete %GUID% /cleanup
	bcdedit /deletevalue {bootmgr} timeout
	goto end
:end
	bcdedit
	set /p EXIT=\"Hit enter to finish.\"
:: end of file
"

########################################

declare MODULES="$(
	ls ${GMODS}/*.{lst,mod} |
	${GREP} -v \
		-e "[/]functional_test" \
		-e "[/]testspeed" \
		\
		-e "[/]acpi" \
		-e "[/]efi" \
		-e "[/]mpi" \
		-e "[/]multiboot" \
		-e "[/]net" \
		-e "[/]plan9" \
		-e "[/]pxe" \
		\
		-e "[/]part_acorn" \
		-e "[/]part_amiga" \
		-e "[/]part_dvh" \
		-e "[/]part_plan" \
		-e "[/]part_sun" \
		\
		-e "[/]affs" \
		-e "[/]afs" \
		-e "[/]bfs" \
		-e "[/]btrfs" \
		-e "[/]hfs" \
		-e "[/]jfs" \
		-e "[/]minix" \
		-e "[/]nilfs2" \
		-e "[/]reiserfs" \
		-e "[/]sfs" \
		-e "[/]ufs" \
		-e "[/]xfs" \
		-e "[/]zfs" \
		\
		-e "[/]font" \
		-e "[/]gfx" \
		-e "[/]png" \
		-e "[/]progress" \
		-e "[/]terminfo" \
		-e "[/]vbe" \
		-e "[/]video" \
		\
		-e "[/]play" \
		-e "[/]spkmodem" \
		-e "[/]usbms" \
		\
		-e "[/]crypt" \
		-e "[/]gcry" \
		-e "[/]truecrypt" \
		-e "[/]zfscrypt" \
		\
		-e "[/]gdb" \
		-e "[/]legacy" \
		-e "[/]regex" \
		-e "[/]trig" \
)"

#>>> 52768 (FAIL) :: MODULES_BOOT="biosdisk memdisk tar      ntfs          part_msdos       echo        affs btrfs gcry_md5"
#>>> 52706 (PASS) :: MODULES_BOOT="biosdisk memdisk tar ext2 ntfs part_gpt part_msdos chain echo reboot"
declare MODULES_BOOT="\
	biosdisk
	memdisk
	tar
	\
	ext2
	ntfs
	part_gpt
	part_msdos
	\
	chain
	echo
	reboot
"

declare MODULES_CORE="\
	${MODULES_BOOT}
	configfile
	linux
"

#>>> http://blog.fpmurphy.com/2010/03/grub2-efi-support.html
declare MODULES_UEFI="\
	$(echo -en "${MODULES_CORE}" | ${SED} "s/biosdisk//g")
"

########################################

declare BLOCKS_SIZE="512"		# default
declare BLOCKS_BOOT="$(( (2**10)*2 ))"	# minimum mbr
declare BLOCKS_DATA="$(( (2**10)*14 ))"	# minimum ext

declare LOOPDEV="/dev/loop9"
declare FDISK=
FDISK+="n\n"
FDISK+="p\n"
FDISK+="1\n"
FDISK+="$(( ${BLOCKS_BOOT} ))\n"
FDISK+="$(( ${BLOCKS_BOOT} +${BLOCKS_DATA} ))\n"
FDISK+="\n"
FDISK+="t\n"
FDISK+="83\n"
FDISK+="a\n"
FDISK+="w\n"

########################################

declare TYPE=
declare FILE=

################################################################################

function exit_summary {
	EXIT="0"
	if [[ ${1} == +([0-9]) ]]; then
		EXIT="${1}"
		shift
	fi

	echo -en "${HEADER}\n"
	echo -en "EXIT OUTPUT\n"
	echo -en "${HEADER}\n"

	(cd $(dirname ${GINST}) &&
		fdisk -l $(basename ${GINST})
	)
	(cd ${GDEST} &&
		echo -en "\n" &&
		file *.efi *.img &&
		echo -en "\n" &&
		${LL}
	)

	if ${DEBUG}; then
		FILE="${GDEST}/rescue.tar"
		echo -en "\n"
		echo -en "# objects for removal:\n"
		(cd ${FILE}/boot/grub/${GTYPE} &&
			du -bs * |
				sort -nr |
				head -n${HEADS}
		)
		echo -en "\n"
		echo -en "# objects for inclusion:\n"
		(cd ${GDEST}/${GTYPE} &&
			du -bs $(
				diff -qr ${GDEST}/${GTYPE} ${FILE}/boot/grub/${GTYPE} |
				${SED} -n "s%^Only in ${GDEST}/${GTYPE}[:][[:space:]]*%%gp" |
				${GREP} "[.](lst|mod)$"
			) |
				sort -n |
				head -n${HEADS}
		)
	fi

	echo -en "${HEADER}\n"
	if [[ ${EXIT} == 0 ]]; then
		echo -en "SUCCESS!\n"
	else
		echo -en "FAILED!\n"
	fi
	echo -en "${HEADER}\n"

	exit ${EXIT}
}

################################################################################

${RSYNC_U} -L ${_SELF} ${GDEST}/$(basename ${_SELF})		|| exit 1

########################################

${RM} ${GDEST}/${GTYPE}						|| exit 1
${MKDIR} ${GDEST}/${GTYPE}					|| exit 1
${RSYNC_U} ${GMODS}/ ${GDEST}/${GTYPE}/				|| exit 1

echo -en "${GLOAD}"	>${GDEST}/bootstrap.cfg			|| exit 1
echo -en "${GMENU}"	>${GDEST}/grub.cfg			|| exit 1
echo -en "${GRESC}"	>${GDEST}/rescue.cfg			|| exit 1
echo -n "${BCDEDIT}"	>${GDEST}/bcdedit.bat			|| exit 1
unix2dos ${GDEST}/bcdedit.bat					|| exit 1

########################################

FILE="${GDEST}/rescue.tar"
${MKDIR} ${FILE}/boot/grub/${GTYPE}				|| exit 1
${RSYNC_U} ${MODULES} ${FILE}/boot/grub/${GTYPE}/		|| exit 1
${RSYNC_U} ${GDEST}/rescue.cfg ${FILE}/boot/grub/grub.cfg	|| exit 1
(cd ${FILE} && tar -cvv -f ${FILE}.tar *)			|| exit 1

grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/bootstrap.img \
	-c ${GDEST}/bootstrap.cfg \
	--prefix="${GROOT}/${_GRUB}" \
	${MODULES_BOOT}						|| exit_summary 1

grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/rescue.img \
	-m ${GDEST}/rescue.tar.tar \
	${MODULES_CORE}						|| exit_summary 1

for TYPE in x86_64-efi i386-efi; do
	FILE="${GDEST}/grub.${TYPE/%-efi}.tar/boot/grub"
	${MKDIR} ${FILE}/${TYPE}				|| exit 1
	${RSYNC_U} ${GRUBD}/${TYPE}/ ${FILE}/${TYPE}		|| exit 1
	echo -en "${GLOAD_FILE}" >${FILE}/grub.cfg		|| exit 1

	FILE="${GDEST}/grub.${TYPE/%-efi}.tar"
	(cd ${FILE} && tar -cvv -f ${FILE}.tar *)		|| exit 1

	FILE="${GDEST}/grub.${TYPE/%-efi}"
	grub-mkimage -v \
		-C xz \
		-O ${TYPE} \
		-d ${GRUBD}/${TYPE} \
		-o ${FILE}.efi \
		-m ${FILE}.tar.tar \
		${MODULES_UEFI}					|| exit_summary 1
done

FILE="${GDEST}/bootstrap.img"
cat ${GMODS}/lnxboot.img ${FILE} >${FILE}.lnxboot		|| exit 1
${MV} ${FILE}{.lnxboot,}					|| exit 1

${RM} ${GDEST}/*.tar.tar					|| exit 1

########################################

if [[ ! -b ${GINST} ]]; then
	dcfldd \
		bs=${BLOCKS_SIZE} \
		count=$(( ${BLOCKS_BOOT} +${BLOCKS_DATA} +1 )) \
		if=/dev/zero \
		of=${GINST}					|| exit 1
	echo -en "${FDISK}" | fdisk ${GINST}			|| exit 1

	losetup -d ${LOOPDEV}				#>>> || exit 1
	losetup -v \
		-o $(( ${BLOCKS_SIZE}*${BLOCKS_BOOT} )) \
		--sizelimit $(( ${BLOCKS_SIZE}*${BLOCKS_DATA} )) \
		${LOOPDEV} ${GINST}				|| exit 1
	format ${LOOPDEV}					|| exit 1
	losetup -d ${LOOPDEV}					|| exit 1
fi

grub-bios-setup \
	--verbose \
	--skip-fs-probe \
	--directory="${GDEST}" \
	--core-image="rescue.img" \
	${GINST}						|| exit_summary 1

########################################

exit_summary 0

exit 0
################################################################################
# end of file
################################################################################
