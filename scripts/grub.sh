#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare GRUB_DIR="${GRUB_DIR:-/.g/_data/zactive/.setup/grub}"
if [[ ! -d ${GRUB_DIR} ]]; then
	GRUB_DIR="$(realpath $(dirname ${_SELF})/../grub)"
fi

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

################################################################################

declare GDEST="$(realpath ${1} 2>/dev/null)"
if [[ -z ${GDEST} ]]; then
	GDEST="{directory}"
fi
shift

declare HEDEF="10"
declare GIDEF="${GDEST}/loopfile.raw"
declare GIBAK="/dev/sda"
declare GPDEF="1"

function print_usage {
	if [[ -n "${@}" ]]; then
		echo -en "\n"
		echo -en "${@}\n"
		echo -en "\n"
	fi
	cat <<_EOF_
usage:
	${SCRIPT} {directory} [options]		= build / install
	${SCRIPT} {directory} [device] {-m|-u}	= mount / unmount

{directory}		target directory to use for building grub files (must already exist)
[-d || -d<0-9+>]	show debug information || number of objects to list (default: ${HEDEF})
[-f || -fx]		format the target block device || use ext4 instead of vfat/exfat
[block device]		use target device instead of the example loopfile
	(loopfile):	${GIDEF}
	grub<0-9+>	alternate partition number for example loopfile (default: ${GPDEF})
	${GIBAK}	use specified device with standard data partition (default: ${GPDEF})
	${GIBAK}<0-9+>	custom data partition number
[kernel options]	additional custom options to pass to the kernel at boot
[-m || -u]		mount/unmount the loopfile/device

All arguments must be used in the order specified.

(...)	informational notes
{...}	required
[...]	optional
||	select one option from the list
<0-9+>	any numerical value

The menu file directory is expected at "../grub" in relation to the script.
It can be specified manually using the "\$GRUB_DIR" environment variable.
_EOF_
	echo -en "${HEADER}\n"
}

if [[ ${GDEST} == '{directory}' ]]; then
	print_usage
	exit 1
elif [[ ! -d ${GDEST} ]]; then
	print_usage "THE TARGET DIRECTORY MUST ALREADY EXIST: ${GDEST}"
	exit 1
elif [[ ! -d ${GRUB_DIR} ]]; then
	print_usage "GRUB MENU FILE DIRECTORY DOES NOT EXIST: ${GRUB_DIR}"
	exit 1
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

declare GPMBR="4"; declare GNMBR="ef02"; declare GFMBR="-d"	# vfat
declare GPEFI="3"; declare GNEFI="ef00"; declare GFEFI="-d"	# vfat

########################################

declare GFDSK="false"
#>>>declare GFFMT="-d"			# vfat
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
if [[ -b $(		echo ${1} | ${SED} "s|[p]?[0-9]*$||g") ]] || [[ ${1} == grub+([0-9]) ]]; then
	GINST="$(	echo ${1} | ${SED} "s|[p]?[0-9]*$||g")"
	GPART="$(	echo ${1} | ${SED} "s|^${GINST}||g")"
	if [[ ${GINST} == grub ]]; then
		GINST="${GIDEF}"
	fi
	if [[ -z ${GPART} ]]; then
		GPART="${GPDEF}"
	fi
	if [[ ${GPART} == "p" ]]; then
		GPART="p${GPDEF}"
	fi
	shift
elif [[ -n $(		echo ${1} | ${GREP} "^[/]dev[/]") ]]; then
	print_usage "DEVICE DOES NOT EXIST: ${1}"
	exit 1
fi
declare GINST_DO="${GINST}"
GPSEP="$(echo "${GPART}" | ${SED} "s|^([p]?)([0-9]+)$|\1|g")"
GPART="$(echo "${GPART}" | ${SED} "s|^([p]?)([0-9]+)$|\2|g")"

if [[ ! -b ${GINST} ]]; then
	GPSEP="p"
fi

########################################

declare DO_MOUNT=
if [[ ${1} == -m ]]; then
	DO_MOUNT="${1}"
	shift
elif [[ ${1} == -u ]]; then
	DO_MOUNT="${1}"
	shift
fi

########################################

declare GOPTS=
if [[ -n ${@} ]]; then
	GOPTS=" ${@}"
	shift
fi

################################################################################

declare GEFIS="x86_64-efi"
declare GTYPE="i386-pc"
declare GRUBD="/usr/lib/grub"
declare GMODS="${GRUBD}/${GTYPE}"

declare GCDEV="${GINST}${GPSEP}${GPART}"
if [[ ${GINST} == ${GIDEF} ]]; then
#>>>	GCDEV="${GIBAK}${GPSEP}${GPART}"
	GCDEV="${GIBAK}${GPART}"
fi

########################################

declare GMENU_NAME="${_BASE}.grub.cfg"
declare GMENU_FILE="/${_BASE}/${GMENU_NAME}"
declare GMENU_DATA="\
################################################################################
# GaryOS Grub Configuration
################################################################################

menuentry \"${_NAME}\" {
	configfile (memdisk)\${grub_menu}
}
menuentry \"---\" {
	serial_config
}

$(cat ${GRUB_DIR}/grub.defaults.cfg)
$(cat ${GRUB_DIR}/grub.menu.${_BASE}.cfg | ${SED} "s|${GIBAK}${GPART}|${GCDEV}|g")
$(cat ${GRUB_DIR}/grub.menu.windows.cfg)

options_root=\"\${options_root}${GOPTS}\"
options_boot=\"\${options_root} \${options_serial}\"

################################################################################
# GaryOS End Of File
################################################################################"

########################################

declare BCDEDIT="\
@echo off
set CURDIR=%~dp0
set BCDFILE=\"%CURDIR%bcdedit.guid.txt\"
if not exist %BCDFILE% (goto create) else (goto delete)
:create
::>>>	for /f \"usebackq tokens=2 delims={}\" %%G in (\`bcdedit.exe /create /d \"${_NAME}\" /inherit fwbootmgr\`) do (set GUID={%%G})
	for /f \"usebackq tokens=2 delims={}\" %%G in (\`bcdedit.exe /copy {bootmgr} /d \"${_NAME}\"\`) do (set GUID={%%G})
	echo %GUID% >%BCDFILE%
	bcdedit.exe /set %GUID% device partition=y:
	bcdedit.exe /set %GUID% path \\${_BASE}\\${_BASE}.efi
	bcdedit.exe /set {fwbootmgr} displayorder %GUID% /addfirst
	bcdedit.exe /set {fwbootmgr} displayorder {bootmgr} /addfirst
	bcdedit.exe /displayorder %GUID% /addlast
	bcdedit.exe /timeout ${TIMEOUT}
	bcdedit.exe /enum %GUID%
	mountvol y: /s
	mkdir y:\\${_BASE}
	copy /y /v %CURDIR%\\${GMENU_NAME} y:\\${_BASE}\\${GMENU_NAME}
	copy /y /v %CURDIR%\\x86_64.efi y:\\${_BASE}\\${_BASE}.efi
	goto end
:delete
	set /p GUID=<%BCDFILE%
	del /q /f %BCDFILE%
	bcdedit.exe /enum %GUID%
	bcdedit.exe /delete %GUID% /cleanup
	bcdedit.exe /set {bootmgr} timeout 0
	mountvol y: /s
	rmdir /q /s y:\\${_BASE}
	goto end
:end
	bcdedit.exe /enum firmware
	bcdedit.exe
	dir y: y:\\${_BASE}
	set /p EXIT=\"Hit enter to finish.\"
:: end of file
"

########################################

#>>> https://www.linux.org/threads/understanding-the-various-grub-modules.11142

declare MODULES_CORE="\
	biosdisk
	memdisk
	tar
	\
	configfile
	echo
	reboot
	\
	part_gpt
	part_msdos
	\
	ext2
	fat
	exfat
	ntfs
	net
	\
	search
	linux
	chain
"
declare MODULES_UEFI="$(
	echo -en "${MODULES_CORE}" |
	${GREP} -v \
		-e "biosdisk" \
)"

declare MODULES_BIOS="
$(
	for FILE in \
		part_gpt \
		part_msdos \
		vga \
	; do
		echo "${GMODS}/${FILE}.mod"
		echo "${GMODS}/${FILE}.module"
	done
) $(
	ls ${GMODS}/*.{lst,mod} |
	${GREP} -v \
		-e "[/]regex" \
		-e "[/]vbe" \
		\
		-e "[/][^/]*audio[^/]*" \
		-e "[/][^/]*modem[^/]*" \
		-e "[/][^/]*test[^/]*" \
		-e "[/]efi[^/]*" \
		-e "[/]video[^/]*" \
		\
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
		-e "[/]f2fs" \
		-e "[/]font" \
		-e "[/]freedos" \
		-e "[/]gcry" \
		-e "[/]gdb" \
		-e "[/]geli" \
		-e "[/]gettext" \
		-e "[/]gfx" \
		-e "[/]gzio" \
		-e "[/]hfs" \
		-e "[/]http" \
		-e "[/]jfs" \
		-e "[/]jpeg" \
		-e "[/]ldm" \
		-e "[/]legacy" \
		-e "[/]linux16" \
		-e "[/]lsacpi" \
		-e "[/]lsapm" \
		-e "[/]lzopio" \
		-e "[/]macho" \
		-e "[/]mda" \
		-e "[/]minix" \
		-e "[/]morse" \
		-e "[/]mpi" \
		-e "[/]multiboot" \
		-e "[/]multiboot2" \
		-e "[/]nativedisk" \
		-e "[/]nilfs2" \
		-e "[/]odc" \
		-e "[/]part[_]" \
		-e "[/]parttool" \
		-e "[/]pata" \
		-e "[/]pbkdf2" \
		-e "[/]pgp" \
		-e "[/]plan9" \
		-e "[/]play" \
		-e "[/]png" \
		-e "[/]random" \
		-e "[/]reiserfs" \
		-e "[/]romfs" \
		-e "[/]sendkey" \
		-e "[/]sfs" \
		-e "[/]spkmodem" \
		-e "[/]squash" \
		-e "[/]syslinux" \
		-e "[/]terminfo" \
		-e "[/]tga" \
		-e "[/]trig" \
		-e "[/]udf" \
		-e "[/]ufs" \
		-e "[/]usbms" \
		-e "[/]xfs" \
		-e "[/]xnu" \
		-e "[/]zstd" \
)"

########################################

declare BLOCKS_SIZE="512"

declare BCALC_SCALE="9"
declare GB_BIT_SIZE="$(( ( (10**3)**3 ) ))"
declare GB_BYTESIZE="$(( ( (2**10)**3 ) ))"
declare GB_ISACTUAL="$(echo "scale=${BCALC_SCALE} ; ( ${GB_BIT_SIZE} / ${GB_BYTESIZE} ) * ${GB_BIT_SIZE}" | bc | ${SED} "s|[.].*$||g")"
declare GB_DISKSIZE="$(( ${GB_ISACTUAL} * 4 ))"

declare BLOCKS_ROOM="$(( ( (2**10)*4		) ))"
declare BLOCKS_GMBR="$(( ( ${GB_BYTESIZE}/8	) / ${BLOCKS_SIZE} ))"
declare BLOCKS_GEFI="$(( ( ${GB_BYTESIZE}	) / ${BLOCKS_SIZE} ))"

declare BLOCKS_NULL="$(( ( ${GB_BYTESIZE}/16	) / ${BLOCKS_SIZE} ))"
	BLOCKS_NULL="0"

declare LOOP_DEVICE="/dev/loop9"
declare LOOP_BLOCKS="$(( ${GB_DISKSIZE} / ${BLOCKS_SIZE} ))"

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
NEWBLOCK="${BLOCKS_ROOM}"				; GDISK+="${NEWBLOCK}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_GMBR} -1 ))"	; GDISK+="${NEWBLOCK}\n"
GDISK+="${GNMBR}\n"
GDISK+="p\n"
# efi partition
GDISK+="n\n"
GDISK+="${GPEFI}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_NULL} +1 ))"	; GDISK+="${NEWBLOCK}\n"
NEWBLOCK="$(( ${NEWBLOCK} + ${BLOCKS_GEFI} -1 ))"	; GDISK+="${NEWBLOCK}\n"
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
#>>>		echo -en "${GDHYB_READ}q\n" | gdisk $(basename ${GINST}) &&
		gdisk -l $(basename ${GINST})
	)
	(cd ${GDEST} &&
		echo -en "\n" &&
		file *.efi *.img &&
		echo -en "\n" &&
		${LL}
	)

	if ${DEBUG}; then
		FILE="${GDEST}/${GTYPE/%-pc}.tar/boot/grub/${GTYPE}"
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

########################################

if [[ -n ${DO_MOUNT} ]]; then
	if {
		[[ -b ${GINST} ]] ||
		[[ -f ${GINST} ]];
	}; then
		FILE="${GDEST}/.mount"
		if [[ -f ${GINST} ]]; then
			GINST_DO="${LOOP_DEVICE}"
		fi
		if {
			[[ ${DO_MOUNT} == -m ]] ||
			[[ ${DO_MOUNT} == -u ]];
		}; then
			if [[ -b ${GINST_DO}${GPSEP}${GPEFI} ]]; then
				mount-robust -u ${GINST_DO}${GPSEP}${GPEFI}	|| exit 1
			fi
			if [[ -b ${GINST_DO}${GPSEP}${GPART} ]]; then
				mount-robust -u ${GINST_DO}${GPSEP}${GPART}	|| exit 1
			fi
			if [[ -f ${GINST} ]]; then
				losetup -d ${LOOP_DEVICE}			#>>> || exit 1
			fi
			${RM} ${FILE}{-mbr,-efi}				|| exit 1
		fi
		if [[ ${DO_MOUNT} == -m ]]; then
			if [[ -f ${GINST} ]]; then
				losetup -d ${LOOP_DEVICE}			#>>> || exit 1
				losetup -v -P ${LOOP_DEVICE} ${GINST}		|| exit 1
				partx -t gpt -a ${LOOP_DEVICE}			#>>> || exit 1
			fi
			${MKDIR} ${FILE}{-mbr,-efi}				|| exit 1
			mount-robust ${GINST_DO}${GPSEP}${GPART} ${FILE}-mbr	|| exit 1
			mount-robust ${GINST_DO}${GPSEP}${GPEFI} ${FILE}-efi	|| exit 1
			echo -en "\n"; ${LL} -R ${FILE}{-mbr,-efi}
		fi
	else
		print_usage "COULD NOT FIND FOR MOUNTING: ${GINST}"
		exit 1
	fi
	exit 0
fi

################################################################################

${MKDIR} ${GDEST}/_${GTYPE}				|| exit 1
${RSYNC_U} ${GMODS}/ ${GDEST}/_${GTYPE}/		|| exit 1
for TYPE in ${GEFIS}; do
	${MKDIR} ${GDEST}/_${TYPE}			|| exit 1
	${RSYNC_U} ${GRUBD}/${TYPE}/ ${GDEST}/_${TYPE}	|| exit 1
done

########################################

echo -en "${GMENU_DATA}"	>${GDEST}/${GMENU_NAME}	|| exit 1
echo -n "${BCDEDIT}"		>${GDEST}/bcdedit.bat	|| exit 1
unix2dos			${GDEST}/bcdedit.bat	|| exit 1

########################################

function partition_disk {
	declare DEV="${1}"
	shift
	echo -en "${GDISK}" | gdisk ${DEV}			|| return 1
#>>>	echo -en "${GDHYB}" | gdisk ${DEV}			|| return 1
#>>>	yes | format ${GFMBR} ${DEV}${GPSEP}${GPMBR}		|| return 1
	yes | format ${GFEFI} ${DEV}${GPSEP}${GPEFI}		|| return 1
	yes | format ${GFFMT} ${DEV}${GPSEP}${GPART}		|| return 1
	return 0
}

function custom_menu {
	declare DEV="${1}"
	DO_MOUNT="${GDEST}/.mount-menu"
	${MKDIR} ${DO_MOUNT}					|| return 1
	if [[ -b ${DEV}${GPSEP}${GPART} ]]; then
		mount-robust -u ${DEV}${GPSEP}${GPART}		#>>> || return 1
	fi
	mount-robust ${DEV}${GPSEP}${GPART} ${DO_MOUNT}		|| return 1
	if [[ ! -f ${DO_MOUNT}${GMENU_FILE} ]]; then
		${MKDIR} ${DO_MOUNT}$(dirname ${GMENU_FILE})	|| return 1
		echo -en "${GMENU_DATA}" >${DO_MOUNT}${GMENU_FILE}	|| return 1
	fi
	mount-robust -u ${DEV}${GPSEP}${GPART}			#>>> || return 1
	${RM} ${DO_MOUNT}					|| return 1
	return 0
}

if [[ -b ${GINST_DO} ]]; then
	if ${GFDSK}; then
		partition_disk ${GINST_DO}			|| exit 1
	fi
	custom_menu ${GINST_DO}					|| exit 1
else
	declare PART_DO="false"
	if [[ ! -f ${GINST} ]]; then
		PART_DO="true"
		$(which dd) \
			status=progress \
			bs=${BLOCKS_SIZE} \
			count=${LOOP_BLOCKS} \
			conv=sparse \
			if=/dev/zero \
			of=${GINST}				|| exit 1
	fi
	losetup -d ${LOOP_DEVICE}				#>>> || exit 1
	losetup -v -P ${LOOP_DEVICE} ${GINST}			|| exit 1
	GINST_DO="${LOOP_DEVICE}"
	if ${PART_DO}; then
		partition_disk ${GINST_DO}			|| exit 1
	fi
	custom_menu ${GINST_DO}					|| exit 1
fi

########################################

FILE="${GDEST}/${GTYPE/%-pc}.tar/boot/grub"
${RM} ${FILE}/${GTYPE}						|| exit 1
${MKDIR} ${FILE}/${GTYPE}					|| exit 1
${RSYNC_U} ${MODULES_BIOS} ${FILE}/${GTYPE}/			|| exit 1
${RSYNC_U} ${GDEST}/${GMENU_NAME} ${FILE}/grub.cfg		|| exit 1
FILE="${GDEST}/${GTYPE/%-pc}.tar"
(cd ${FILE} && tar -cvv -f ${FILE}.tar *)			|| exit 1
grub-mkimage -v \
	-C xz \
	-O ${GTYPE} \
	-d ${GMODS} \
	-o ${GDEST}/${GTYPE/%-pc}.img \
	-m ${GDEST}/${GTYPE/%-pc}.tar.tar \
	${MODULES_CORE}						|| exit_summary 1

for TYPE in ${GEFIS}; do
	FILE="${GDEST}/${TYPE/%-efi}.tar/boot/grub"
	${MKDIR} ${FILE}/${TYPE}				|| exit 1
	${RSYNC_U} ${GRUBD}/${TYPE}/ ${FILE}/${TYPE}		|| exit 1
	${RSYNC_U} ${GDEST}/${GMENU_NAME} ${FILE}/grub.cfg	|| exit 1
	FILE="${GDEST}/${TYPE/%-efi}.tar"
	(cd ${FILE} && tar -cvv -f ${FILE}.tar *)		|| exit 1
	FILE="${GDEST}/${TYPE/%-efi}"
	grub-mkimage -v \
		-C xz \
		-O ${TYPE} \
		-d ${GRUBD}/${TYPE} \
		-o ${FILE}.efi \
		-m ${FILE}.tar.tar \
		${MODULES_UEFI}					|| exit_summary 1
done

${RM} ${GDEST}/*.tar.tar					|| exit 1

########################################

DO_MOUNT="${GDEST}/.mount-mbr"
${MKDIR} ${DO_MOUNT}								|| exit 1
if [[ -b ${GINST_DO}${GPSEP}${GPART} ]]; then
	mount-robust -u ${GINST_DO}${GPSEP}${GPART}				#>>> || exit 1
fi
mount-robust ${GINST_DO}${GPSEP}${GPART} ${DO_MOUNT}				|| exit 1
${RSYNC_U} ${GDEST}/${GTYPE/%-pc}.img ${GDEST}/_${GTYPE}/core.img		|| exit 1
grub-install \
	--verbose \
	--removable \
	--skip-fs-probe \
	--target="${GTYPE}" \
	--directory="${GDEST}/_${GTYPE}" \
	--boot-directory="${GDEST}/_${GTYPE}.boot" \
	${GINST_DO}								|| exit_summary 1
${RSYNC_U} ${GDEST}/${GTYPE/%-pc}.img ${GDEST}/_${GTYPE}.boot/grub/${GTYPE}/	|| exit 1
grub-bios-setup \
	--verbose \
	--skip-fs-probe \
	--directory="${GDEST}/_${GTYPE}.boot/grub/${GTYPE}" \
	--core-image="${GTYPE/%-pc}.img" \
	${GINST_DO}								|| exit_summary 1
mount-robust -u ${GINST_DO}${GPSEP}${GPART}					#>>> || exit 1
${RM} ${DO_MOUNT}								|| exit 1

if [[ -b ${GINST_DO}${GPSEP}${GPEFI} ]]; then
	function efi_cp {
		declare SRC="${1}"; shift
		declare DST="${1}"; shift
		if [[ ${SRC} == ${GDEST}/x86_64.efi ]]; then
			${RSYNC_C} ${SRC} ${DST}/BOOTX64.EFI			|| exit 1
		fi
		return 0
	}
	DO_MOUNT="${GDEST}/.mount-efi"
	${MKDIR} ${DO_MOUNT}							|| exit 1
	if [[ -b ${GINST_DO}${GPSEP}${GPEFI} ]]; then
		mount-robust -u ${GINST_DO}${GPSEP}${GPEFI}			|| exit 1
	fi
	mount-robust ${GINST_DO}${GPSEP}${GPEFI} ${DO_MOUNT}			|| exit 1
	${MKDIR} ${DO_MOUNT}							|| exit 1
	for TYPE in ${GEFIS}; do
		FILE="${GDEST}/${TYPE/%-efi}.efi"
		${RSYNC_U} ${FILE} ${GDEST}/_${TYPE}/core.efi			|| exit 1
		grub-install \
			--verbose \
			--removable \
			--skip-fs-probe \
			--target="${TYPE}" \
			--directory="${GDEST}/_${TYPE}" \
			--boot-directory="${GDEST}/_${TYPE}.boot" \
			--efi-directory="${DO_MOUNT}" \
			${GINST_DO}						|| exit_summary 1
		${MKDIR} ${DO_MOUNT}/EFI/BOOT					|| exit 1
		efi_cp ${FILE} ${DO_MOUNT}/EFI/BOOT				|| exit 1
		mount-robust -u ${GINST_DO}${GPSEP}${GPEFI}			|| exit 1
	done
	${RM} ${DO_MOUNT}							|| exit 1
fi

########################################

losetup -d ${LOOP_DEVICE} #>>> || exit 1

exit_summary 0

exit 0
################################################################################
# end of file
################################################################################
