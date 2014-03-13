#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare _PROJ="GaryOS"
declare _NAME="${_PROJ} Grub"

declare _BASE="gary-os"
declare _GRUB="${_BASE}.grub"

################################################################################

declare GDEST="${PWD}"

declare DEBUG="false"
if [[ ${1} == -d ]]; then
	DEBUG="true"
	shift
fi

declare GINST="${GDEST}/rescue_example.raw"
if [[ -b ${1} ]]; then
	GINST="${1}"
	shift
fi

########################################

declare GBOOT="(hd0)"
declare GROOT="(hd0,2)"

declare GTYPE="i386-pc"
declare GMODS="/usr/lib/grub/${GTYPE}"

################################################################################

declare GLOAD="\
# load
echo \"Loading ${_NAME}...\"
insmod configfile
# end of file
"

declare GMENU="\
# menu
set default=0
set timeout=10
insmod linux
menuentry \"${_PROJ} 64-bit\" { linux ${GROOT}/${_BASE}-64.kernel }
menuentry \"${_PROJ} 32-bit\" { linux ${GROOT}/${_BASE}-32.kernel }
insmod chain
menuentry \"Back to OS\" { chainloader ${GBOOT}+1 }
# end of file
"

declare GRESC="\
# rescue
insmod read
menuentry \"${_NAME} Rescue Image\" { set; read rescue; }
# end of file
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
		-e "[/]affs" \
		-e "[/]afs" \
		-e "[/]bfs" \
		-e "[/]btrfs" \
		-e "[/]jfs" \
		-e "[/]minix" \
		-e "[/]reiserfs" \
		-e "[/]sfs" \
		-e "[/]xfs" \
		\
		-e "[/]acpi" \
		-e "[/]efi" \
		-e "[/]plan9" \
		-e "[/]pxe" \
		\
		-e "[/]font" \
		-e "[/]gfx" \
		-e "[/]terminfo" \
		-e "[/]video" \
		\
		-e "[/]gcry" \
		-e "[/]gdb" \
		-e "[/]legacy" \
		-e "[/]regex" \
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

declare FILE=

################################################################################

function exit_summary {
	(cd $(dirname ${GINST}) &&
		fdisk -l $(basename ${GINST})
	)
	(cd ${GDEST} &&
		echo -en "\n" &&
		file *.img &&
		echo -en "\n" &&
		${LL}
	)

	if ${DEBUG}; then
		echo -en "\n"
		echo -en "# MAX BOOT: 512*103,  52736 (guess)\n"
		echo -en "# MAX CORE: 0x78000, 491520 (grub-mkimage)\n"

		FILE="${GDEST}/rescue.tar"
		echo -en "\n"
		echo -en "# objects for removal:\n"
		(cd ${FILE}/boot/grub/${GTYPE} &&
			du -bs * |
				sort -nr |
				head -n10
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
				head -n10
		)
	fi

	return 0
}

################################################################################

${RM} ${GDEST}/${GTYPE}					|| exit 1
${MKDIR} ${GDEST}/${GTYPE}				|| exit 1
${RSYNC_U} ${GMODS}/ ${GDEST}/${GTYPE}/			|| exit 1

echo -en "${GLOAD}"	>${GDEST}/bootstrap.cfg		|| exit 1
echo -en "${GMENU}"	>${GDEST}/grub.cfg		|| exit 1
echo -en "${GRESC}"	>${GDEST}/rescue.cfg		|| exit 1
echo -n "${BCDEDIT}"	>${GDEST}/bcdedit.bat		|| exit 1
unix2dos ${GDEST}/bcdedit.bat				|| exit 1

########################################

FILE="${GDEST}/rescue.tar"
${MKDIR} ${FILE}/boot/grub/${GTYPE}			|| exit 1
${RSYNC_U} ${MODULES} ${FILE}/boot/grub/${GTYPE}/	|| exit 1
echo -en "${GRESC}" >${FILE}/boot/grub/grub.cfg		|| exit 1
(cd ${FILE} && tar -cvv -f ${FILE}.tar *)		|| exit 1

grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/bootstrap.img \
	-c ${GDEST}/bootstrap.cfg \
	--prefix="${GROOT}/${_GRUB}" \
	${MODULES_BOOT}					|| exit 1

grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/rescue.img \
	-m ${GDEST}/rescue.tar.tar \
	${MODULES_CORE}					|| { exit_summary; exit 1; }

FILE="${GDEST}/bootstrap.img"
cat ${GMODS}/lnxboot.img ${FILE} >${FILE}.lnxboot	|| exit 1
${MV} ${FILE}{.lnxboot,}				|| exit 1

${RM} ${GDEST}/rescue.tar.tar				|| exit 1

########################################

if [[ ! -b ${GINST} ]]; then
	dcfldd \
		bs=${BLOCKS_SIZE} \
		count=$(( ${BLOCKS_BOOT} +${BLOCKS_DATA} +1 )) \
		if=/dev/zero \
		of=${GINST}				|| exit 1
	echo -en "${FDISK}" | fdisk ${GINST}		|| exit 1

	losetup -d ${LOOPDEV}				#>>> || exit 1
	losetup -v \
		-o $(( ${BLOCKS_SIZE}*${BLOCKS_BOOT} )) \
		--sizelimit $(( ${BLOCKS_SIZE}*${BLOCKS_DATA} )) \
		${LOOPDEV} ${GINST}			|| exit 1
	format ${LOOPDEV}				|| exit 1
	losetup -d ${LOOPDEV}				|| exit 1
fi

grub-bios-setup --verbose \
	--boot-image="${GTYPE}/boot.img" \
	--core-image="rescue.img" \
	--directory="${GDEST}" \
	--skip-fs-probe \
	${GINST}					|| exit 1

########################################

exit_summary

exit 0
################################################################################
# end of file
################################################################################
