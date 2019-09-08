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

function print_usage {
	cat <<_EOF_
usage: ${SCRIPT} ...

{directory}		target directory to use for building grub files (must already exist)
[-d || -d<0-9+>]	show debug information || number of objects to list (default: ${HEDEF})
[-f || -fv]		format the target block device || use vfat instead of ext4
[block device]		use target device instead of the example loopfile
	(loopfile):	${GIDEF}
	grub<0-9+>	alternate partition number for example loopfile (default: ${GPDEF})
	/dev/sda	use specified device with standard data partition (default: ${GPDEF})
	/dev/sda<0-9+>	custom data partition number
[menu file]		use target file as a custom grub.cfg instead of the default
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

declare GPEFI="99"; declare GNEFI="ef00"; declare GFEFI="-d"
declare GPMBR="98"; declare GNMBR="ef02"; #>>> declare GFMBR=""

########################################

declare GFDSK="false"
declare GFFMT=""
declare GFNUM="8300"
if [[ ${1} == -f*(v) ]]; then
	GFDSK="true"
	if [[ ${1/#-f} == v ]]; then
		GFFMT="-d"
		GFNUM="0700"
	fi
	shift
fi

########################################

declare GINST="${GIDEF}"
declare GPART="${GPDEF}"
declare GPSEP=
declare GPPRT=
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
GPSEP="$(echo "${GPART}" | ${SED} "s|^([p]?)([0-9]+)$|\1|g")"
GPPRT="$(echo "${GPART}" | ${SED} "s|^([p]?)([0-9]+)$|\2|g")"

if [[ ! -b ${GINST} ]]; then
	GPSEP="p"
fi

########################################

declare GCUST=
if [[ -f ${1} ]]; then
	GCUST="$(${SED} "s|[\"]|\\\\\"|g" ${1})"
	shift
fi

declare GOPTS=
if [[ -n ${1} ]]; then
	GOPTS="${1}"
	shift
fi

################################################################################

declare GBOOT="(hd0)"
declare GROOT="(hd0,${GPPRT})"
declare GFILE="(hd0,${GPPRT})/boot/grub/grub.cfg"

declare GEFIS="x86_64-efi" #>>> i386-efi"
declare GTYPE="i386-pc"
declare GRUBD="/usr/lib/grub"
declare GMODS="${GRUBD}/${GTYPE}"

########################################

declare G_SET="\
# settings
set debug=linux
"
declare G_MOD="\
# modules
insmod configfile
insmod linux
insmod chain
"
declare G_END="\n\
# end of file"
#>>> "

declare GLOAD="\
${G_MOD}
# load
echo \"Loading ${_NAME}...\"
${G_END}
"
declare GMENU="\n\
# menu
menuentry \"${_PROJ} Install Boot\" {
linux  ${GROOT}/boot/_null.kernel
linux  ${GROOT}/boot/kernel root=${GINST}${GPSEP}${GPART} ${GOPTS}
initrd ${GROOT}/boot/initrd
boot
}
menuentry \"${_PROJ} Install Menu\" {
configfile ${GFILE}
}
menuentry \"Default OS\" {
chainloader ${GBOOT}+1
}"
#>>> "
declare GRESC="\
${G_SET}
${G_MOD}
# rescue
menuentry \"${_NAME} Rescue\" {
set pager=1
set
set pager=0
}
menuentry \"${_PROJ} Rescue\" {
linux  ${GROOT}/${_BASE}.null.kernel
linux  ${GROOT}/${_BASE}.kernel ${GOPTS}
initrd ${GROOT}/${_BASE}.initrd
boot
}
${GMENU}
${G_END}
"

if [[ -n ${GCUST} ]]; then
	GRESC="${GCUST}"
fi

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

declare MODULES_LIST="$(
	ls ${GMODS}/*.{lst,mod} |
	${GREP} -v \
		-e "[/]915resolution" \
		-e "[/]acpi" \
		-e "[/]adler" \
		-e "[/]affs" \
		-e "[/]afs" \
		-e "[/]ahci" \
		-e "[/]all_video" \
		-e "[/]backtrace" \
		-e "[/]bfs" \
		-e "[/]bsd" \
		-e "[/]btrfs" \
		-e "[/]cbfs" \
		-e "[/]font" \
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
#>>> declare BLOCKS_DATA="$(( (2**20)*2 ))"
declare BLOCKS_DATA="$(( (2**10)*(2**7) ))"
#>>> declare BLOCKS_NULL="${BLOCKS_DATA}"
declare BLOCKS_NULL="0"

declare LOOP_DEVICE="/dev/loop9"
#>>> declare LOOP_BLOCKS="$(( ${BLOCKS_BOOT} + (${BLOCKS_NULL}*2) + (${BLOCKS_DATA}*6) ))"
declare LOOP_BLOCKS="$(( ${BLOCKS_BOOT} + (${BLOCKS_NULL}*2) + (${BLOCKS_DATA}*3) ))"

declare NEWBLOCK=
declare GDISK=
declare GDHYB=
# reset table
GDISK+="\n"
GDISK+="p\n"
GDISK+="o\n"
GDISK+="Y\n"
GDISK+="p\n"
# efi partition
GDISK+="n\n"
GDISK+="${GPEFI}\n"
NEWBLOCK="${BLOCKS_BOOT}"				; GDISK+="${NEWBLOCK}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_DATA} -1 ))"	; GDISK+="${NEWBLOCK}\n"
GDISK+="${GNEFI}\n"
GDISK+="p\n"
# bios partition
GDISK+="n\n"
GDISK+="${GPMBR}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_NULL} +1 ))"	; GDISK+="${NEWBLOCK}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_DATA} -1 ))"	; GDISK+="${NEWBLOCK}\n"
GDISK+="${GNMBR}\n"
GDISK+="p\n"
# data partition
GDISK+="n\n"
GDISK+="${GPPRT}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_NULL} +1 ))"	; GDISK+="${NEWBLOCK}\n"
NEWBLOCK=""						; GDISK+="${NEWBLOCK}\n"
GDISK+="${GFNUM}\n"
GDISK+="p\n"
# write partition table
GDISK+="w\n"
GDISK+="Y\n"
# hybrid mbr
GDHYB+="r\n"
GDHYB+="h\n"
GDHYB+="${GPMBR} ${GPPRT}\n"
GDHYB+="n\n"
GDHYB+="\n"
GDHYB+="n\n"
GDHYB+="\n"
GDHYB+="y\n"
GDHYB+="n\n"
GDHYB+="o\n"
GDHYB+="w\n"
GDHYB+="Y\n"

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
				${SED} -n "s%^Only in ${GMODS}[:][[:space:]]*%%gp" |
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

echo -en "${GLOAD}"	>${GDEST}/bootstrap.cfg	|| exit 1
echo -en "${GRESC}"	>${GDEST}/grub.cfg	|| exit 1
echo -en "${GRESC}"	>${GDEST}/rescue.cfg	|| exit 1
echo -n "${BCDEDIT}"	>${GDEST}/bcdedit.bat	|| exit 1
unix2dos ${GDEST}/bcdedit.bat			|| exit 1

########################################

function partition_disk {
	declare DEV="${1}"
	shift
	echo -en "${GDISK}" | gdisk ${DEV}		|| return 1
	echo -en "${GDHYB}" | gdisk ${DEV}		|| return 1
	yes | format ${GFFMT} ${DEV}${GPSEP}${GPART}	|| return 1
	yes | format ${GFEFI} ${DEV}${GPSEP}${GPEFI}	|| return 1
	return 0
}

if [[ -b ${GINST} ]]; then
	if ${GFDSK}; then
		partition_disk ${GINST}			|| exit 1
	fi
else
	dd \
		status=progress \
		bs=${BLOCKS_SIZE} \
		count=${LOOP_BLOCKS} \
		conv=notrunc \
		if=/dev/zero \
		of=${GINST}				|| exit 1
	losetup -d ${LOOP_DEVICE}			#>>> || exit 1
	losetup -v -P ${LOOP_DEVICE} ${GINST}		|| exit 1
	partition_disk ${LOOP_DEVICE}			|| exit 1
	GINST="${LOOP_DEVICE}"
fi

########################################

grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/bootstrap.img \
	-c ${GDEST}/bootstrap.cfg \
	--prefix="${GROOT}/${_GRUB}" \
	${MODULES_CORE}					|| exit_summary 1
FILE="${GDEST}/bootstrap.img"
cat ${GMODS}/lnxboot.img ${FILE} >${FILE}.lnxboot	|| exit 1
${MV} ${FILE}{.lnxboot,}				|| exit 1

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
mount-robust ${GINST}${GPSEP}${GPART} ${FILE}					|| exit 1
${RSYNC_U} ${GDEST}/rescue.img ${GDEST}/_${GTYPE}/core.img			|| exit 1
grub-install \
	--verbose \
	--removable \
	--skip-fs-probe \
	--target="${GTYPE}" \
	--directory="${GDEST}/_${GTYPE}" \
	--boot-directory="${FILE}/${SCRIPT}" \
	${GINST}								|| exit_summary 1
${RSYNC_U} ${GDEST}/rescue.img ${FILE}/${SCRIPT}/grub/${GTYPE}/			|| exit 1
grub-bios-setup \
	--verbose \
	--skip-fs-probe \
	--directory="${FILE}/${SCRIPT}/grub/${GTYPE}" \
	--core-image="rescue.img" \
	${GINST}								|| exit_summary 1
${MV} ${FILE}/${SCRIPT} ${GDEST}/_${GTYPE}.boot					|| exit 1
mount-robust -u ${GINST}${GPSEP}${GPART}					|| exit 1
${RM} ${GDEST}/.mount								|| exit 1

if [[ -b ${GINST}${GPSEP}${GPEFI} ]]; then
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
	mount-robust ${GINST}${GPSEP}${GPEFI} ${GDEST}/.mount-efi		|| exit 1
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
			${GINST}						|| exit_summary 1
		efi_cp ${FILE} ${GDEST}/.mount-efi/EFI/BOOT			|| exit 1
		${MV} ${GDEST}/.mount-efi/${SCRIPT} ${GDEST}/_${TYPE}.boot	|| exit 1
		mount-robust -u ${GINST}${GPSEP}${GPEFI}			|| exit 1
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
