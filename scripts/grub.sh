#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare _PROJ="GaryOS"
declare _NAME="${_PROJ} Grub"

declare _BASE="gary-os"

########################################

declare HEADER="$(printf "~%.0s" {1..80})"

declare _OPTS="${@}"
echo -en "${HEADER}\n"
echo -en "ARGUMENTS: ${_OPTS}\n"
echo -en "${HEADER}\n"

########################################

declare TIMEOUT="5"

################################################################################

declare GDEST="$(realpath ${1} 2>/dev/null)"
if [[ ! -d ${GDEST} ]]; then
	GDEST="[...]"
fi
shift

declare HEDEF="10"
declare GIDEF="${GDEST}/loopfile.img"
declare GIBAK="/dev/sda"
declare GPDEF="1"

function print_usage {
	cat <<_EOF_
usage: ${SCRIPT} {directory} [options]

{directory}		target directory to use for building grub files (must already exist)
[-d || -d<0-9+>]	show debug information || number of objects to list (default: ${HEDEF})
[-f || -fx]		format the target block device || use ext4 instead of vfat/exfat
[block device]		use target device instead of the example loopfile
	(loopfile):	${GIDEF}
	grub<0-9+>	alternate partition number for example loopfile (default: ${GPDEF})
	${GIBAK}	use specified device with standard data partition (default: ${GPDEF})
	${GIBAK}<0-9+>	custom data partition number
[kernel options]	additional custom options to pass to the kernel at boot

All arguments must be used in the order specified.

(...)	informational notes
{...}	required
[...]	optional
||	select one option from the list
<0-9+>	any numerical value
_EOF_
	echo -en "${HEADER}\n"
}

if [[ ! -d ${GDEST} ]]; then
	print_usage
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

declare GPMBR="99"; declare GNMBR="ef02"; declare GFMBR="-d"	# vfat
declare GPEFI="98"; declare GNEFI="ef00"; declare GFEFI="-d"	# vfat

########################################

declare GFDSK="false"
#>>> declare GFFMT="-d"			# vfat
declare GFFMT="-f"			# exfat
declare GFNUM="0700"
if [[ ${1} == -f*(x) ]]; then
	GFDSK="true"
	if [[ ${1/#-f} == x ]]; then
		GFFMT=""		# ext4
		GFNUM="8300"
	fi
	shift
fi

########################################

declare GINST="${GIDEF}"
declare GPART="${GPDEF}"
declare GPSEP=
if [[ -b $(		echo ${1} | ${SED} "s|[p]?[0-9]+$||g") ]] || [[ ${1} == grub+([0-9]) ]]; then
	GINST="$(	echo ${1} | ${SED} "s|[p]?[0-9]+$||g")"
	GPART="$(	echo ${1} | ${SED} "s|^${GINST}||g")"
	if [[ ${GINST} == grub ]]; then
		GINST="${GIDEF}"
	fi
	if [[ -z ${GPART} ]]; then
		GPART="${GPDEF}"
	fi
	shift
fi
declare GINST_DO="${GINST}"
GPSEP="$(echo "${GPART}" | ${SED} "s|^([p]?)([0-9]+)$|\1|g")"
GPART="$(echo "${GPART}" | ${SED} "s|^([p]?)([0-9]+)$|\2|g")"

if [[ ! -b ${GINST} ]]; then
	GPSEP="p"
fi

########################################

declare GOPTS=
if [[ -n ${1} ]]; then
	GOPTS="${1}"
	shift
fi

################################################################################

declare GROOT="hd0,${GPART}"
declare GEFIS="x86_64-efi" #>>> i386-efi"
declare GTYPE="i386-pc"

declare GRUBD="/usr/lib/grub"
declare GMODS="${GRUBD}/${GTYPE}"
declare GFILE="/boot/grub/grub.cfg"

declare GCUST="${_BASE}.grub.cfg"

########################################

declare GMENU="\
# settings

set debug=linux
set default=0
set timeout=-1

# modules

insmod fat
insmod exfat
insmod ext2

insmod search
insmod configfile
insmod linux
insmod chain

# titles

menuentry \"${_NAME}\" {
	set pager=1
	set
	set pager=0
}
menuentry \"---\" {
	set pager=1
	set
	set pager=0
}

# kernel

set garyos_custom=
set garyos_rescue=
search --file --set garyos_custom /${_BASE}/${GCUST}
search --file --set garyos_rescue /${_BASE}/${_BASE}.kernel

if [ -n \"\${garyos_custom}\" ]; then
	set default=2
	set timeout=${TIMEOUT}
else
	set garyos_custom=\"${GROOT}\"
fi
if [ -n \"\${garyos_rescue}\" ]; then
	set default=3
	set timeout=${TIMEOUT}
else
	set garyos_rescue=\"${GROOT}\"
fi

menuentry \"${_PROJ} Menu\" {
	configfile (\${garyos_custom})/${_BASE}/${GCUST}
}
menuentry \"${_PROJ} Boot\" {
	linux  (\${garyos_rescue})/${_BASE}/${_BASE}.null.kernel
	linux  (\${garyos_rescue})/${_BASE}/${_BASE}.kernel${GOPTS:+ ${GOPTS}}
	initrd (\${garyos_rescue})/${_BASE}/${_BASE}.initrd
	boot
}

# install

set garyos_menu=
set garyos_install=
search --file --set garyos_menu ${GFILE}
search --file --set garyos_install /boot/kernel

if [ -n \"\${garyos_menu}\" \"\${garyos_menu}\" != \"memdisk\" ]; then
	set default=4
	set timeout=${TIMEOUT}
else
	set garyos_menu=\"${GROOT}\"
fi
if [ -n \"\${garyos_install}\" ]; then
#>>>	set default=5
	set default=4
	set timeout=${TIMEOUT}
else
	set garyos_install=\"${GROOT}\"
fi

menuentry \"${_PROJ} Install Menu\" {
#>>>	configfile (\${garyos_menu})${GFILE}
	configfile (\${garyos_install})${GFILE}
}
menuentry \"${_PROJ} Install Boot\" {
	linux  (\${garyos_install})/boot/_null.kernel
	linux  (\${garyos_install})/boot/kernel root=$(
		if [[ ${GINST} == ${GIDEF} ]]; then
#>>>			echo -en "${GIBAK}${GPSEP}${GPART}"
			echo -en "${GIBAK}${GPART}"
		else
			echo -en "${GINST}${GPSEP}${GPART}"
		fi
	)${GOPTS:+ ${GOPTS}}
	initrd (\${garyos_install})/boot/initrd
	boot
}

# chainload

menuentry \"Boot Primary\" {
	chainloader (hd0)+1
}
menuentry \"Boot Secondary\" {
	chainloader (hd1)+1
}

# end of file
"

declare GCONF="\
# custom
menuentry \"${_NAME} (Custom)\" {
	set pager=1
	set
	set pager=0
}
# end of file
"

########################################

declare _GRUB="${_BASE}.grub"

declare BCDEDIT="\
@echo off
set CURDIR=%~dp0
set BCDFILE=\"%CURDIR%bcdedit.guid.txt\"
if not exist %BCDFILE% (goto create) else (goto delete)
:create
	for /f \"usebackq tokens=3\" %%I in (\`bcdedit.exe /create /d \"${_NAME}\" /application bootsector\`) do (set GUID=%%I)
::>>>	for /f \"usebackq tokens=3\" %%I in (\`bcdedit.exe /create /d \"${_NAME}\" /inherit fwbootmgr\`) do (set GUID=%%I)
	echo %GUID% >%BCDFILE%
	echo %GUID%
	bcdedit.exe /set %GUID% device partition=c:
	bcdedit.exe /set %GUID% path \\${_GRUB}\\bootstrap.img
::>>>	bcdedit.exe /set %GUID% path \\${_GRUB}\\x86_64.efi
	bcdedit.exe /displayorder %GUID% /addlast
	bcdedit.exe /timeout ${TIMEOUT}
	goto end
:delete
	set /p GUID=<%BCDFILE%
	del %BCDFILE%
	echo %GUID%
	bcdedit.exe /delete %GUID% /cleanup
	bcdedit.exe /deletevalue {bootmgr} timeout
	goto end
:end
	bcdedit.exe
	set /p EXIT=\"Hit enter to finish.\"
:: end of file
"

########################################

declare MODULES_LIST="$(
	ls ${GMODS}/*.{lst,mod} |
	${GREP} -v \
		-e "[/]915resolution" \
		-e "[/]acpi" \
		-e "[/]adler" \
		-e "[/]affs" \
		-e "[/]afs" \
		-e "[/]ahci" \
		-e "[/]backtrace" \
		-e "[/]bfs" \
		-e "[/]bsd" \
		-e "[/]btrfs" \
		-e "[/]cbfs" \
		-e "[/]freedos" \
		-e "[/]gcry" \
		-e "[/]geli" \
		-e "[/]gettext" \
		-e "[/]gfx" \
		-e "[/]gzio" \
		-e "[/]hfs" \
		-e "[/]http" \
		-e "[/]jfs" \
		-e "[/]jpeg" \
		-e "[/]legacy" \
		-e "[/]linux16" \
		-e "[/]lsacpi" \
		-e "[/]lsapm" \
		-e "[/]mda" \
		-e "[/]minix" \
		-e "[/]morse" \
		-e "[/]named-colors" \
		-e "[/]net" \
		-e "[/]nilfs2" \
		-e "[/]odc" \
		-e "[/]part_acorn" \
		-e "[/]part_amiga" \
		-e "[/]part_apple" \
		-e "[/]part_bsd" \
		-e "[/]part_dfly" \
		-e "[/]part_dvh" \
		-e "[/]part_plan" \
		-e "[/]part_sun" \
		-e "[/]part_sunpc" \
		-e "[/]pata" \
		-e "[/]pbkdf2" \
		-e "[/]plan9" \
		-e "[/]play" \
		-e "[/]png" \
		-e "[/]random" \
		-e "[/]reiserfs" \
		-e "[/]romfs" \
		-e "[/]serial" \
		-e "[/]sfs" \
		-e "[/]spkmodem" \
		-e "[/]squash" \
		-e "[/]terminfo" \
		-e "[/]testspeed" \
		-e "[/]tga" \
		-e "[/]trig" \
		-e "[/]truecrypt" \
		-e "[/]udf" \
		-e "[/]ufs" \
		-e "[/]usbserial" \
		-e "[/]video" \
		-e "[/]xfs" \
		-e "[/]xnu" \
		-e "[/]zfs" \
)"

declare MODULES_CORE="\
	biosdisk
	memdisk
	tar
	\
	configfile
	echo
	\
	fat
	exfat
	ext2
	ntfs
	part_gpt
	part_msdos
	\
	chain
	linux
	reboot
"

declare MODULES_UEFI="$(
	echo -en "${MODULES_CORE}" |
	${GREP} -v \
		-e "biosdisk" \
)"

########################################

declare BLOCKS_SIZE="512"
declare BLOCKS_BOOT="$(( (2**10)*4 ))"
declare BLOCKS_DATA="$(( (2**10)*(2**6) *2))"
if ! ${DEBUG}; then
	BLOCKS_DATA="$(( (2**10)*(2**10) *2))"
fi
#>>> declare BLOCKS_NULL="${BLOCKS_DATA}"
declare BLOCKS_NULL="0"

declare LOOP_DEVICE="/dev/loop9"
declare LOOP_BLOCKS="$(( ${BLOCKS_BOOT} + (${BLOCKS_NULL}*2) + (${BLOCKS_DATA}*2) + (${BLOCKS_DATA}*1) ))"
if ! ${DEBUG}; then
#>>>	LOOP_BLOCKS="$(( ${BLOCKS_BOOT} + (${BLOCKS_NULL}*2) + (${BLOCKS_DATA}*2) + (${BLOCKS_DATA}*4) ))"
	LOOP_BLOCKS="$(( ${BLOCKS_BOOT} + (${BLOCKS_NULL}*2) + (${BLOCKS_DATA}*2) + (${BLOCKS_DATA}*2) ))"
fi

declare NEWBLOCK=
declare GDISK=
declare GDHYB_READ=
declare GDHYB=
# reset table
GDISK+="p\n"
GDISK+="o\n"
GDISK+="y\n"
GDISK+="p\n"
# bios partition
GDISK+="n\n"
GDISK+="${GPMBR}\n"
NEWBLOCK="${BLOCKS_BOOT}"				; GDISK+="${NEWBLOCK}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_DATA} -1 ))"	; GDISK+="${NEWBLOCK}\n"
GDISK+="${GNMBR}\n"
GDISK+="p\n"
# efi partition
GDISK+="n\n"
GDISK+="${GPEFI}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_NULL} +1 ))"	; GDISK+="${NEWBLOCK}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_DATA} -1 ))"	; GDISK+="${NEWBLOCK}\n"
GDISK+="${GNEFI}\n"
GDISK+="p\n"
# data partition
GDISK+="n\n"
GDISK+="${GPART}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_NULL} +1 ))"	; GDISK+="${NEWBLOCK}\n"
NEWBLOCK=""						; GDISK+="${NEWBLOCK}\n"
GDISK+="${GFNUM}\n"
GDISK+="p\n"
# write partition table
GDISK+="w\n"
GDISK+="y\n"
# hybrid mbr
GDHYB_READ+="r\n"
GDHYB_READ+="o\n"
GDHYB+="${GDHYB_READ}"
GDHYB+="h\n"
GDHYB+="${GPMBR} ${GPEFI} ${GPART}\n"
GDHYB+="n\n"
GDHYB+="${GNMBR}/%[0-9][0-9]}\n"
GDHYB+="y\n"
GDHYB+="${GNEFI}/%[0-9][0-9]}\n"
GDHYB+="n\n"
GDHYB+="${GFNUM}/%[0-9][0-9]}\n"
GDHYB+="n\n"
GDHYB+="o\n"
GDHYB+="w\n"
GDHYB+="y\n"

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
		echo -en "${GDHYB_READ}q\n" | gdisk $(basename ${GINST}) &&
		gdisk -l $(basename ${GINST})
	)
	(cd ${GDEST} &&
		echo -en "\n" &&
		file *.efi *.img &&
		echo -en "\n" &&
		${LL}
	)

	if ${DEBUG}; then
		FILE="${GDEST}/rescue.tar/boot/grub/${GTYPE}"
		echo -en "\n"
		echo -en "# objects for removal:\n"
		(cd ${FILE} &&
			du -bs * |
				sort -nr |
				head -n${HEADS}
		)
		echo -en "\n"
		echo -en "# objects for inclusion:\n"
		(cd ${GMODS} &&
			du -bs $(
				diff -qr ${GMODS} ${FILE} |
				${SED} -n "s|^Only in ${GMODS}[:][[:space:]]*||gp" |
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

${RM} ${GDEST}/*					|| exit 1

${MKDIR} ${GDEST}/_${GTYPE}				|| exit 1
${RSYNC_U} ${GMODS}/ ${GDEST}/_${GTYPE}/		|| exit 1
for TYPE in ${GEFIS}; do
	${MKDIR} ${GDEST}/_${TYPE}			|| exit 1
	${RSYNC_U} ${GRUBD}/${TYPE}/ ${GDEST}/_${TYPE}	|| exit 1
done

${RSYNC_U} -L ${_SELF} ${GDEST}/$(basename ${_SELF})	|| exit 1

########################################

#>>> echo -en "${GMENU}"	>${GDEST}/grub.cfg	|| exit 1
echo -en "${GMENU}"		>${GDEST}/rescue.cfg	|| exit 1

#>>> echo -en "${GMENU}"	>${GDEST}/bootstrap.cfg	|| exit 1
#>>> echo -n "${BCDEDIT}"	>${GDEST}/bcdedit.bat	|| exit 1
#>>> unix2dos ${GDEST}/bcdedit.bat			|| exit 1

########################################

function partition_disk {
	declare DEV="${1}"
	shift
	echo -en "${GDISK}" | gdisk ${DEV}		|| return 1
#>>>	echo -en "${GDHYB}" | gdisk ${DEV}		|| return 1
#>>>	yes | format ${GFMBR} ${DEV}${GPSEP}${GPMBR}	|| return 1
	yes | format ${GFEFI} ${DEV}${GPSEP}${GPEFI}	|| return 1
	yes | format ${GFFMT} ${DEV}${GPSEP}${GPART}	|| return 1
	return 0
}

function custom_menu {
	declare DEV="${1}"
	FILE="${GDEST}/.mount-menu"
	${MKDIR} ${FILE}				|| return 1
	mount-robust ${DEV}${GPSEP}${GPART} ${FILE}	|| return 1
	${MKDIR} ${FILE}/${_BASE}			|| return 1
	echo -en "${GCONF}" >${FILE}/${_BASE}/${GCUST}	|| return 1
	mount-robust -u ${DEV}${GPSEP}${GPART}		|| return 1
	${RM} ${FILE}					|| return 1
	return 0
}

if [[ -b ${GINST_DO} ]]; then
	if ${GFDSK}; then
		partition_disk ${GINST_DO}		|| exit 1
	fi
	custom_menu ${GINST_DO}				|| exit 1
else
	dd \
		status=progress \
		bs=${BLOCKS_SIZE} \
		count=${LOOP_BLOCKS} \
		conv=sparse \
		if=/dev/zero \
		of=${GINST}				|| exit 1
	losetup -d ${LOOP_DEVICE}			#>>> || exit 1
	losetup -v -P ${LOOP_DEVICE} ${GINST}		|| exit 1
	GINST_DO="${LOOP_DEVICE}"
	partition_disk ${GINST_DO}			|| exit 1
	custom_menu ${GINST_DO}				|| exit 1
fi

########################################

#>>> grub-mkimage -v \
#>>> 	-C xz \
#>>> 	-O ${GTYPE} \
#>>> 	-d ${GMODS} \
#>>> 	-o ${GDEST}/bootstrap.img \
#>>> 	-c ${GDEST}/bootstrap.cfg \
#>>> 	--prefix="${GROOT}/${_GRUB}" \
#>>> 	${MODULES_CORE}					|| exit_summary 1
#>>> FILE="${GDEST}/bootstrap.img"
#>>> cat ${GMODS}/lnxboot.img ${FILE} >${FILE}.lnxboot	|| exit 1
#>>> ${MV} ${FILE}{.lnxboot,}				|| exit 1

FILE="${GDEST}/rescue.tar/boot/grub"
${MKDIR} ${FILE}/${GTYPE}				|| exit 1
${RSYNC_U} ${MODULES_LIST} ${FILE}/${GTYPE}/		|| exit 1
${RSYNC_U} ${GDEST}/rescue.cfg ${FILE}/grub.cfg		|| exit 1
FILE="${GDEST}/rescue.tar"
(cd ${FILE} && tar -cvv -f ${FILE}.tar *)		|| exit 1
grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/rescue.img \
	-m ${GDEST}/rescue.tar.tar \
	${MODULES_CORE}					|| exit_summary 1

for TYPE in ${GEFIS}; do
	FILE="${GDEST}/${TYPE/%-efi}.tar/boot/grub"
	${MKDIR} ${FILE}/${TYPE}			|| exit 1
	${RSYNC_U} ${GRUBD}/${TYPE}/ ${FILE}/${TYPE}	|| exit 1
	${RSYNC_U} ${GDEST}/rescue.cfg ${FILE}/grub.cfg	|| exit 1
	FILE="${GDEST}/${TYPE/%-efi}.tar"
	(cd ${FILE} && tar -cvv -f ${FILE}.tar *)	|| exit 1
	FILE="${GDEST}/${TYPE/%-efi}"
	grub-mkimage -v \
		-C xz \
		-O ${TYPE} \
		-d ${GRUBD}/${TYPE} \
		-o ${FILE}.efi \
		-m ${FILE}.tar.tar \
		${MODULES_UEFI}				|| exit_summary 1
done

${RM} ${GDEST}/*.tar.tar				|| exit 1

########################################

FILE="${GDEST}/.mount"
${MKDIR} ${FILE}								|| exit 1
mount-robust ${GINST_DO}${GPSEP}${GPART} ${FILE}				|| exit 1
${RSYNC_U} ${GDEST}/rescue.img ${GDEST}/_${GTYPE}/core.img			|| exit 1
grub-install \
	--verbose \
	--removable \
	--skip-fs-probe \
	--target="${GTYPE}" \
	--directory="${GDEST}/_${GTYPE}" \
	--boot-directory="${FILE}/${SCRIPT}" \
	${GINST_DO}								|| exit_summary 1
${RSYNC_U} ${GDEST}/rescue.img ${FILE}/${SCRIPT}/grub/${GTYPE}/			|| exit 1
grub-bios-setup \
	--verbose \
	--skip-fs-probe \
	--directory="${FILE}/${SCRIPT}/grub/${GTYPE}" \
	--core-image="rescue.img" \
	${GINST_DO}								|| exit_summary 1
${MV} ${FILE}/${SCRIPT} ${GDEST}/_${GTYPE}.boot					|| exit 1
mount-robust -u ${GINST_DO}${GPSEP}${GPART}					|| exit 1
${RM} ${GDEST}/.mount								|| exit 1

if [[ -b ${GINST_DO}${GPSEP}${GPEFI} ]]; then
	function efi_cp {
		declare SRC="${1}"; shift
		declare DST="${1}"; shift
		if [[ ${SRC} == ${GDEST}/x86_64.efi ]]; then
			${RSYNC_C} ${SRC} ${DST}/BOOTX64.EFI			|| return 1
		fi
		if [[ ${SRC} == ${GDEST}/i386.efi ]]; then
			${RSYNC_C} ${SRC} ${DST}/BOOTIA32.EFI			|| return 1
		fi
		return 0
	}
	${MKDIR} ${GDEST}/.mount-efi						|| exit 1
	mount-robust ${GINST_DO}${GPSEP}${GPEFI} ${GDEST}/.mount-efi		|| exit 1
	FILE="${GDEST}/.mount-efi/EFI/BOOT"					|| exit 1
	${MKDIR} ${FILE}							|| exit 1
	for TYPE in ${GEFIS}; do
		FILE="${GDEST}/${TYPE/%-efi}.efi"
		${RSYNC_U} ${FILE} ${GDEST}/_${TYPE}/core.efi			|| exit 1
		grub-install \
			--verbose \
			--removable \
			--skip-fs-probe \
			--target="${TYPE}" \
			--directory="${GDEST}/_${TYPE}" \
			--boot-directory="${GDEST}/.mount-efi/${SCRIPT}" \
			--efi-directory="${GDEST}/.mount-efi" \
			${GINST_DO}						|| exit_summary 1
		efi_cp ${FILE} ${GDEST}/.mount-efi/EFI/BOOT			|| exit 1
		${MV} ${GDEST}/.mount-efi/${SCRIPT} ${GDEST}/_${TYPE}.boot	|| exit 1
		mount-robust -u ${GINST_DO}${GPSEP}${GPEFI}			|| exit 1
	done
	${RM} ${GDEST}/.mount-efi						|| exit 1
fi

########################################

losetup -d ${LOOP_DEVICE} #>>> || exit 1

exit_summary 0

exit 0
################################################################################
# end of file
################################################################################
