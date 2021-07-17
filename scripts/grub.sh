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
declare SHMEM="3000m"

################################################################################

declare GDEST="$(realpath ${1} 2>/dev/null)"
if [[ ! -d ${GDEST} ]]; then
	GDEST="{directory}"
fi
shift

declare HEDEF="10"
declare GIDEF="${GDEST}/loopfile.img"
declare GIBAK="/dev/sdb"
declare GPDEF="1"

function print_usage {
	cat <<_EOF_
usage:
	${SCRIPT} {directory} [options]	= build / install
	${SCRIPT} {directory} {-m|-u}	= mount / unmount loopfile (for testing)

{directory}		target directory to use for building grub files (must already exist)
[-d || -d<0-9+>]	show debug information || number of objects to list (default: ${HEDEF})
[-f || -fx]		format the target block device || use ext4 instead of vfat/exfat
[block device]		use target device instead of the example loopfile
	(loopfile):	${GIDEF}
	grub<0-9+>	alternate partition number for example loopfile (default: ${GPDEF})
	${GIBAK}	use specified device with standard data partition (default: ${GPDEF})
	${GIBAK}<0-9+>	custom data partition number
[kernel options]	additional custom options to pass to the kernel at boot
[-m || -u]		mount/unmount the generated loopfile, for testing purposes

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
	print_usage
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

declare GROOT="hd0,${GPART}"
declare GEFIS="x86_64-efi" #>>> i386-efi"
declare GTYPE="i386-pc"
declare GPXE="efinet0"

declare GRUBD="/usr/lib/grub"
declare GMODS="${GRUBD}/${GTYPE}"
declare GFILE="/boot/grub/grub.cfg"

declare GCDEV="${GINST}${GPSEP}${GPART}"
if [[ ${GINST} == ${GIDEF} ]]; then
#>>>	GCDEV="${GIBAK}${GPSEP}${GPART}"
	GCDEV="${GIBAK}${GPART}"
fi

########################################

declare GMENU_KERNEL="/${_BASE}/${_BASE}.kernel"
declare GMENU_ROOTFS="/${_BASE}/${_BASE}.rootfs"
declare GMENU_OPTION="shmem_size=${SHMEM} groot_hint=\${garyos_rootfs} groot_file=${GMENU_ROOTFS} groot=${GCDEV}"
declare GMENU_OPTPXE="shmem_size=${SHMEM} groot_hint=${GPXE} groot_file=${GMENU_ROOTFS} groot=\${garyos_server}"

declare GMENU_CUSTOM="/${_BASE}/${_BASE}.grub.cfg"
declare GCUST_KERNEL="$(dirname ${GMENU_CUSTOM})/$(basename ${GMENU_KERNEL})"
declare GCUST_ROOTFS="$(dirname ${GMENU_CUSTOM})/$(basename ${GMENU_ROOTFS})"
declare GCUST_OPTION="shmem_size=${SHMEM} groot_hint=\${garyos_rootfs} groot_file=${GCUST_ROOTFS} groot=${GCDEV}"

declare GMENU_HEAD="\
################################################################################
# GaryOS Grub Configuration
################################################################################

set debug=linux
set default=0
set timeout=-1

########################################

insmod all_video

insmod part_gpt
insmod part_msdos

insmod fat
insmod exfat
insmod ext2
insmod net

insmod search
insmod configfile
insmod linux
insmod chain

########################################

serial --unit=0 --speed=9600 --word=8 --parity=no --stop=1
terminal_input console serial
terminal_output console serial

set menu_color_normal=white/black
set menu_color_highlight=black/red

################################################################################"
declare GMENU_FOOT="\
################################################################################
# end of file
################################################################################"

declare GMENU="\
${GMENU_HEAD}

menuentry \"${_NAME}\" {
	configfile (memdisk)${GFILE}
}
menuentry \"---\" {
	set pager=1
	set
	set pager=0
}

########################################

set garyos_custom=
set garyos_rescue=
set garyos_rootfs=
search --no-floppy --file --set garyos_custom ${GMENU_CUSTOM}
search --no-floppy --file --set garyos_rescue ${GMENU_KERNEL}
search --no-floppy --file --set garyos_rootfs ${GMENU_ROOTFS}

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
if [ -n \"\${garyos_rootfs}\" ]; then
	set default=4
	set timeout=${TIMEOUT}
else
	set garyos_rootfs=\"${GROOT}\"
fi

menuentry \"${_PROJ} Menu\" {
	configfile (\${garyos_custom})${GMENU_CUSTOM}
}
menuentry \"${_PROJ} Boot\" {
	linux (\${garyos_rescue})${GMENU_KERNEL}${GOPTS}
}
menuentry \"${_PROJ} Boot Rootfs\" {
	linux (\${garyos_rootfs})${GMENU_KERNEL}${GOPTS} ${GMENU_OPTION}
}

########################################

set garyos_install=
search --no-floppy --file --set garyos_install /boot/kernel

if [ -n \"\${garyos_install}\" ]; then
	if [ -f \"(\${garyos_install})${GFILE}\" ]; then
		set default=5
	else
		set default=6
	fi
	set timeout=${TIMEOUT}
else
	set garyos_install=\"${GROOT}\"
fi

menuentry \"${_PROJ} Install Menu\" {
	configfile (\${garyos_install})${GFILE}
}
menuentry \"${_PROJ} Install Boot\" {
	linux (\${garyos_install})/boot/kernel${GOPTS} root=${GCDEV}
	initrd (\${garyos_install})/boot/initrd
}

########################################

set garyos_server=\"\${net_${GPXE}_next_server}\"
set garyos_source=\"\${net_${GPXE}_rootpath}\"
set garyos_params=\"\${net_${GPXE}_extensionspath}\"
if [ -z \"\${garyos_server}\" ]; then set garyos_server=\"\${net_${GPXE}_dhcp_next_server}\"; fi
if [ -z \"\${garyos_source}\" ]; then set garyos_source=\"\${net_${GPXE}_dhcp_rootpath}\"; fi
if [ -z \"\${garyos_params}\" ]; then set garyos_params=\"\${net_${GPXE}_dhcp_extensionspath}\"; fi

if [ -z \"\${garyos_source}\" ]; then
	set garyos_source=\"${GMENU_KERNEL}\"
fi

if [ -n \"\${garyos_server}\" ]; then
	set default=7
	set timeout=${TIMEOUT}
fi

menuentry \"${_PROJ} PXE\" {
	echo cmd: net_dhcp
	echo cmd: configfile (memdisk)${GFILE}
	echo var: set garyos_server=\"\${garyos_server}\"
	echo var: set garyos_source=\"${GMENU_KERNEL}\"
	echo var: set garyos_params=\"${GMENU_OPTPXE}\"
	echo garyos_server: \${garyos_server}
	echo garyos_source: \${garyos_source}
	echo garyos_params: \${garyos_params}
	linux (tftp,\${garyos_server})\${garyos_source}${GOPTS} \${garyos_params}
}

${GMENU_FOOT}
"

declare GCUST="\
${GMENU_HEAD}

menuentry \"${_NAME} (Custom)\" {
	configfile (memdisk)${GFILE}
}
menuentry \"---\" {
	set pager=1
	set
	set pager=0
}

########################################

set garyos_rescue=
set garyos_rootfs=
search --no-floppy --file --set garyos_rescue ${GCUST_KERNEL}
search --no-floppy --file --set garyos_rootfs ${GCUST_ROOTFS}

if [ -n \"\${garyos_rescue}\" ]; then
	set default=2
	set timeout=${TIMEOUT}
else
	set garyos_rescue=\"${GROOT}\"
fi
if [ -n \"\${garyos_rootfs}\" ]; then
	set default=3
	set timeout=${TIMEOUT}
else
	set garyos_rootfs=\"${GROOT}\"
fi

menuentry \"${_PROJ} Boot\" {
	linux (\${garyos_rescue})${GCUST_KERNEL}${GOPTS}
}
menuentry \"${_PROJ} Boot Rootfs\" {
	linux (\${garyos_rootfs})${GCUST_KERNEL}${GOPTS} ${GCUST_OPTION}
}

${GMENU_FOOT}
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
		-e "[/]efiemu" \
		-e "[/]freedos" \
		-e "[/]functional_test" \
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
		-e "[/]legacy" \
		-e "[/]linux16" \
		-e "[/]lsacpi" \
		-e "[/]lsapm" \
		-e "[/]mda" \
		-e "[/]minix" \
		-e "[/]morse" \
		-e "[/]mpi" \
		-e "[/]multiboot" \
		-e "[/]multiboot2" \
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
		-e "[/]syslinuxcfg" \
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

########################################

if [[ -f ${GIDEF} ]]; then
	FILE="${GDEST}/.mount-loop"
	if {
		[[ ${DO_MOUNT} == -m ]] ||
		[[ ${DO_MOUNT} == -u ]];
	}; then
		if [[ -b ${LOOP_DEVICE}p${GPDEF} ]]; then
			mount-robust -u ${LOOP_DEVICE}p${GPDEF}		|| exit 1
		fi
		if [[ -b ${LOOP_DEVICE}p${GPEFI} ]]; then
			mount-robust -u ${LOOP_DEVICE}p${GPEFI}		|| exit 1
		fi
		if [[ -b ${LOOP_DEVICE} ]]; then
			losetup -d ${LOOP_DEVICE}			#>>> || exit 1
		fi
		${RM} ${FILE}{,-efi}					|| exit 1
		if [[ ${DO_MOUNT} == -u ]]; then
			exit 0
		fi
	fi
	if [[ ${DO_MOUNT} == -m ]]; then
		losetup -v -P ${LOOP_DEVICE} ${GINST}			|| exit 1
		partx -t gpt -a ${LOOP_DEVICE}				#>>> || exit 1
		${MKDIR} ${FILE}{,-efi}					|| exit 1
		mount-robust ${LOOP_DEVICE}p${GPDEF} ${FILE}		|| exit 1
		mount-robust ${LOOP_DEVICE}p${GPEFI} ${FILE}-efi	|| exit 1
		echo -en "\n"; ${LL} -R ${FILE}*
		exit 0
	fi
fi

################################################################################

#>>>${RM} ${GDEST}/*					|| exit 1

${MKDIR} ${GDEST}/_${GTYPE}				|| exit 1
${RSYNC_U} ${GMODS}/ ${GDEST}/_${GTYPE}/		|| exit 1
for TYPE in ${GEFIS}; do
	${MKDIR} ${GDEST}/_${TYPE}			|| exit 1
	${RSYNC_U} ${GRUBD}/${TYPE}/ ${GDEST}/_${TYPE}	|| exit 1
done

${RSYNC_U} -L ${_SELF} ${GDEST}/$(basename ${_SELF})	|| exit 1

########################################

#>>> echo -en "${GMENU}"	>${GDEST}/grub.cfg			|| exit 1
echo -en "${GMENU}"		>${GDEST}/rescue.cfg			|| exit 1
echo -en "${GCUST}"		>${GDEST}/$(basename ${GMENU_CUSTOM})	|| exit 1

#>>> echo -en "${GMENU}"	>${GDEST}/bootstrap.cfg			|| exit 1
#>>> echo -n "${BCDEDIT}"	>${GDEST}/bcdedit.bat			|| exit 1
#>>> unix2dos ${GDEST}/bcdedit.bat					|| exit 1

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
	FILE="${GDEST}/.mount-menu"
	${MKDIR} ${FILE}					|| return 1
	if [[ -b ${DEV}${GPSEP}${GPART} ]]; then
		mount-robust -u ${DEV}${GPSEP}${GPART}		|| return 1
	fi
	mount-robust ${DEV}${GPSEP}${GPART} ${FILE}		|| return 1
	if [[ ! -f ${FILE}${GMENU_CUSTOM} ]]; then
		${MKDIR} ${FILE}$(dirname ${GMENU_CUSTOM})	|| return 1
		echo -en "${GCUST}" >${FILE}${GMENU_CUSTOM}	|| return 1
	fi
	mount-robust -u ${DEV}${GPSEP}${GPART}			|| return 1
	${RM} ${FILE}						|| return 1
	return 0
}

if [[ -b ${GINST_DO} ]]; then
	if ${GFDSK}; then
		partition_disk ${GINST_DO}			|| exit 1
	fi
	custom_menu ${GINST_DO}					|| exit 1
else
	$(which dd) \
		status=progress \
		bs=${BLOCKS_SIZE} \
		count=${LOOP_BLOCKS} \
		conv=sparse \
		if=/dev/zero \
		of=${GINST}					|| exit 1
	losetup -d ${LOOP_DEVICE}				#>>> || exit 1
	losetup -v -P ${LOOP_DEVICE} ${GINST}			|| exit 1
	GINST_DO="${LOOP_DEVICE}"
	partition_disk ${GINST_DO}				|| exit 1
	custom_menu ${GINST_DO}					|| exit 1
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

FILE="${GDEST}/.mount-mbr"
${MKDIR} ${FILE}								|| exit 1
if [[ -b ${GINST_DO}${GPSEP}${GPART} ]]; then
	mount-robust -u ${GINST_DO}${GPSEP}${GPART}				|| exit 1
fi
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
${RM} ${GDEST}/.mount-mbr							|| exit 1

if [[ -b ${GINST_DO}${GPSEP}${GPEFI} ]]; then
	function efi_cp {
		declare SRC="${1}"; shift
		declare DST="${1}"; shift
		if [[ ${SRC} == ${GDEST}/x86_64.efi ]]; then
			${RSYNC_C} ${SRC} ${DST}/BOOTX64.EFI			|| exit 1
		fi
		if [[ ${SRC} == ${GDEST}/i386.efi ]]; then
			${RSYNC_C} ${SRC} ${DST}/BOOTIA32.EFI			|| exit 1
		fi
		return 0
	}
	${MKDIR} ${GDEST}/.mount-efi						|| exit 1
	if [[ -b ${GINST_DO}${GPSEP}${GPEFI} ]]; then
		mount-robust -u ${GINST_DO}${GPSEP}${GPEFI}			|| exit 1
	fi
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
