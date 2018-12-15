#!/usr/bin/env bash
################################################################################
# bash configuration file
################################################################################

umask 022
unalias -a

set -o vi

shopt -s cdspell
shopt -s cmdhist
shopt -s extglob
shopt -s histappend
shopt -s histreedit
shopt -s histverify
shopt -s lithist

eval $(dircolors	2>/dev/null)
if [[ "${-}" == *(*)i*(*) ]]; then
	setterm -blank 10	2>/dev/null
	setterm -blength 0	2>/dev/null
fi

if [[ -f /etc/profile.d/bash-completion.sh ]]; then
	source /etc/profile.d/bash-completion.sh
fi
complete -d -o dirnames cd

########################################

if [[ "${-/i}" != "${-}" ]] &&
   [[ -x /usr/bin/fortune ]]; then
	echo -en "\n"
	fortune -ac all
fi

########################################

mkdir -p ${HOME}/.history/screen	2>/dev/null
mkdir -p ${HOME}/.history/shell		2>/dev/null

export SCREENDIR="${HOME}/.screen"
mkdir -p ${SCREENDIR}			2>/dev/null
chown -R root:root ${SCREENDIR}		2>/dev/null
chmod -R 700 ${SCREENDIR}		2>/dev/null

################################################################################
# variables
################################################################################

export _SELF="$(realpath -- "${0}")"
export SCRIPT="$(basename -- "${0}")"
export UNAME="$(uname -s)"

export COMPOSER="/.g/_data/zactive/coding/composer/Makefile"
export PIMDIR="/.g/_data/zactive/_pim"
export MAILDIR="${HOME}/Maildir"
export MAILCAPS="${HOME}/.mailcap"

export GDRIVE_REMOTE="gdrive"
export NOTES_MD="/.g/_data/zactive/_pim/tasks.notes.md";	export NOTES_MD_ID="1asjTujzIRYBiqvXdBG34RD_fCN7GQN5e"
export IDEAS_MD="/.g/_data/zactive/writing/_imagination.md";	export IDEAS_MD_ID="1_p06qeX31eFRTUJ2VKWhdfGUhaQBqF5k"
export SALES_MD="/.g/_data/zactive/_pim/zoho.today.md";		#>>>export SALES_MD_ID="1wQrnTw0I5pDfzlqeuKdBNCNvFH9Ifulz"

export ACRO_ALLOW_SUDO="set"

########################################

export LANG="en_US.UTF-8"
export LC_ALL="${LANG}"
export LC_COLLATE="C"
#>>>export LC_TIME="en_DK.UTF-8"
export LC_ALL=

export HISTFILE="${HOSTNAME}.${USER}.$(basename ${SHELL}).$(date +%Y-%m)"
export HISTFILE="${HOME}/.history/shell/${HISTFILE}"
export HISTSIZE="$(( (2**31)-1 ))"
export HISTFILESIZE="${HISTSIZE}"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S "
export HISTCONTROL=
export HISTIGNORE=

########################################

unset EMERGE_DEFAULT_OPTS

#>>>export CARCH="i686"
#>>>export CHOST="i686-pc-linux-gnu"
export CARCH="x86_64"
export CHOST="x86_64-pc-linux-gnu"

#>>>export CFLAGS="-march=i686 -mtune=i686 -m32 -O2 -ggdb -pipe"
#>>>export CFLAGS="-march=core2 -mtune=core2 -m64 -O2 -ggdb -pipe"
export CFLAGS="-march=core2 -mtune=core2 -O2 -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,--hash-style=gnu -Wl,--as-needed"
export MAKEFLAGS="-j9"

export CCACHE_DIR="/tmp/.ccache"
export CCACHE_LOGFILE="" #>>>"/tmp/.ccache.log"

########################################

export CDPATH=".:${HOME}"
export CDPATH="${CDPATH}:/.g"
export CDPATH="${CDPATH}:/.g/_data"
export CDPATH="${CDPATH}:/.g/_data/media"
export CDPATH="${CDPATH}:/.g/_data/zactive"

export PATH="${HOME}"
export PATH="${PATH}:${HOME}/commands"
export PATH="${PATH}:${HOME}/scripts"
if [[ "${UNAME}" == "Darwin" ]]; then
	export PATH="${PATH}:/_ports/bin"
	export PATH="${PATH}:/_ports/libexec/gnubin"
fi
export PATH="${PATH}:/usr/local/bin"
export PATH="${PATH}:/usr/local/sbin"
export PATH="${PATH}:/usr/bin"
export PATH="${PATH}:/usr/sbin"
export PATH="${PATH}:/bin"
export PATH="${PATH}:/sbin"
export PATH="${PATH}:/usr/games/bin"
export PATH="${PATH}:/usr/lib/perl5/core_perl/bin"
if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	export PATH="${PATH}:/c/WINDOWS"
	export PATH="${PATH}:/c/WINDOWS/system32"
fi

if [[ "${UNAME}" == "Darwin" ]]; then
	export MANPATH="/_ports/share/man:${MANPATH}"
fi

########################################

# title escapes
#	screen	ESC k ${TITLE} ESC \
#	xterm	ESC ]0; ${TITLE} BEL
# color escapes
#	ansi	ESC [ ${0=normal,1=bold,7=reverse} ; ${30-37=color} m
# escape codes
#	ESC	\e
#	BEL	\a

export PROMPT_DIRTRIM=
declare PROMPT_SCR_COLOR="r"
declare PROMPT_TOKEN_CLR="\[\e[7;31m\]"
declare PROMPT_TOKEN_DFL="\[\e[0m\]"	# reset color
declare PROMPT_TOKEN_PWD="\w"

if [[ ${HOSTNAME} == spider ]]; then
	PROMPT_TOKEN_CLR="\[\e[7;32m\]"
	PROMPT_SCR_COLOR="g"
elif [[ ${HOSTNAME} == shadow ]] ||
     [[ ${HOSTNAME} == bastion ]]; then
	PROMPT_TOKEN_CLR="\[\e[7;33m\]"
	PROMPT_SCR_COLOR="y"
elif [[ ${HOSTNAME} == tarantula ]] ||
     [[ ${HOSTNAME} == phantom ]]; then
	PROMPT_TOKEN_CLR="\[\e[7;36m\]"
	PROMPT_SCR_COLOR="c"
elif [[ ${HOSTNAME} == Arachnid ]]; then
	PROMPT_TOKEN_CLR="\[\e[7;35m\]"
	PROMPT_SCR_COLOR="m"
fi

declare PRE_PROMPT='\
\e]0;\
${PROMPT_KEY}[ ${TERM} | ${USER}@${HOSTNAME/%.*} | ${PWD/#$HOME/~} ]\
\a'

if { [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; } &&
   { [[ -z ${PROMPT} ]] || [[ ${PROMPT} == \$P\$G ]]; }; then
	export PROMPT="cygwin"
fi

if [[ ${PROMPT} == simple ]]; then
	export PROMPT=
	PROMPT_TOKEN_PWD="<\W>"
fi
if [[ -z ${PROMPT} ]]; then
	export PROMPT=
	export PROMPT_KEY=
else
	export PROMPT="${PROMPT}"
	export PROMPT_KEY="( ${PROMPT} )"
fi
if [[ "${SCRIPT}" != ".bashrc" ]]; then
	export PROMPT_COMMAND="IMPERSONATE_MODE=\"true\"; echo -en \"${PRE_PROMPT}\";"
fi
if [[ -n ${PROMPT_KEY} ]] &&
   [[ "${SCRIPT}" != ".bashrc" ]] &&
   [[ ${BASH_EXECUTION_STRING/%\ *} != rsync  ]] &&
   [[ ${BASH_EXECUTION_STRING/%\ *} != scp    ]] &&
   [[ ${BASH_EXECUTION_STRING/%\ *} != unison ]]; then
	eval "echo -en \"${PRE_PROMPT}\""
fi

# http://superuser.com/questions/175799/does-bash-have-a-hook-that-is-run-before-executing-a-command
# http://hints.macworld.com/dlfiles/preexec.bash.txt
export IMPERSONATE_NAME
export IMPERSONATE_MODE="false"
export IMPERSONATE_QUIT="shopt -u extdebug; trap - DEBUG;"
export IMPERSONATE_TRAP="shopt -s extdebug; trap impersonate_shell DEBUG;"
eval ${IMPERSONATE_QUIT}
if [[ ${PROMPT} == [+]*(*) ]]; then
	export IMPERSONATE_NAME="${PROMPT/#+}"
	PROMPT_TOKEN_PWD="\[\e[7;37m\](${IMPERSONATE_NAME}:\W)${PROMPT_TOKEN_DFL}"
	history -a
	HISTFILE="${HOSTNAME}.${USER}.${IMPERSONATE_NAME}.$(date +%Y-%m)"
	HISTFILE="${HOME}/.history/shell/${HISTFILE}"
	history -r
	function impersonate_command { return 0; }
	function impersonate_shell {
		if [[ -n ${COMP_LINE} ]] ||
		   (( ${BASH_SUBSHELL} > 0 )) ||
		   [[ ${BASH_COMMAND} == IMPERSONATE_MODE[=]\"true\" ]] ||
		   [[ ${BASH_COMMAND} == echo*(*){PROMPT_KEY}*(*) ]] ||
		   [[ ${BASH_COMMAND} == shopt*(*) ]] ||
		   [[ ${BASH_COMMAND} == trap*(*) ]] ||
		   ! ${IMPERSONATE_MODE}
		then
			return 0
		else
			IMPERSONATE_MODE="false"
		fi
		if [[ ${BASH_COMMAND} == [:]*(*) ]]; then
			${BASH_COMMAND/#:}
		elif [[ ${BASH_COMMAND} == [.]*(*) ]]; then
			impersonate_command ${BASH_COMMAND/#.}
		else
			${IMPERSONATE_NAME} ${BASH_COMMAND}
		fi
		return 1
	}
	alias quit="${IMPERSONATE_QUIT} history -a; prompt; history -r;"
	eval ${IMPERSONATE_TRAP}
fi

export PS1="\u@\h:\w\\$ "
export PS1="\
\n\
${PROMPT_TOKEN_CLR}\
[\u@\h]:[\D{%a/%j_%FT%T%z}]\
\n\
[\#/\!]\
${PROMPT_TOKEN_DFL}\
\[\ek\e\\\\\]:${PROMPT_TOKEN_PWD}\\$"

################################################################################
# commands
################################################################################

export NICELY="sudo -E nice -n 19 ionice --class 2 --classdata 7"	; alias nicely="${NICELY}"
export NICELY="sudo -E nice -n 19 ionice -c 2 -n 7"			; alias nicely="${NICELY}"
export REALTIME="sudo -E nice -n -20 ionice --class 1 --classdata 0"	; alias realtime="${REALTIME}"
export REALTIME="sudo -E nice -n -20 ionice -c 1 -n 0"			; alias realtime="${REALTIME}"

if { [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; } ||
   [[ "${UNAME}" == "Darwin" ]]; then
	export NICELY=
	export REALTIME=
fi

########################################

export MORE="less -rX"						; alias more="${MORE}"
export VI="${REALTIME} vim -u ${HOME}/.vimrc -i NONE -p"	; alias vi="${VI}"
export VIEW="eval ${VI} -nR -c \"set nowrap\""			; alias view="${VIEW/#eval\ /}"

export PAGER="${MORE}"
export EDITOR="${VI}"

unset VISUAL

########################################

export CP="cp -pvR"			; alias cp="${CP}"
export GREP="grep --color=auto -E"	; alias grep="${GREP}"
export LN="ln -fsv"			; alias ln="${LN}"
export MKDIR="mkdir -pv"		; alias mkdir="${MKDIR}"
export MV="mv -v"			; alias mv="${MV}"
export PS="ps aux -ww"			; alias psl="${PS}"
export RM="rm -frv"			; alias rm="${RM}"
export RMDIR="rmdir -v"			; alias rmdir="${RMDIR}"
export SED="sed -r"			; alias sed="${SED}"

if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	unalias sed
fi

########################################

export LS="ls --color=auto --time-style=long-iso"		; alias ls="${LS}"
export LL="${LS} -asF -l"					; alias ll="${LL}"
export LX="${LS} -asF -kC"					; alias lx="${LX}"
export LF="eval ${LL} -d \`find . -maxdepth 1 ! -type l\`"	; alias lf="${LF}"

export LI="find . | sort | indexer | indexer -p"		; alias li="${LI}"
export LT="tree -asF -hD --du"					; alias lt="${LT}"

export DU="du -b --time --time-style=long-iso"			; alias du="${DU}"
export LU="${DU} -ak --max-depth 1"				; alias lu="${LU}"

########################################

export EMERGE_CMD="prompt -z emerge"		; alias emerge="${EMERGE_CMD}"

export CVS="reporter cvs"			; alias cvs="${CVS}"
export SVN="reporter svn"			; alias svn="${SVN}"
export SVNSYNC="reporter svnsync"		; alias svnsync="${SVNSYNC}"

export GIT_CMD="git"
export GIT="reporter ${GIT_CMD}"		; alias git="${GIT}"
export GIT_ADD="${GIT} add --verbose --all"	; alias git-add="${GIT_ADD}"
export GIT_CMT="${GIT} commit --verbose"	; alias git-commit="${GIT_CMT}"
export GIT_STS="${GIT} status"			; alias git-status="${GIT_STS}"
export GIT_SVN="${GIT} svn"			; alias git-svn="${GIT_SVN}"

export DIFF_OPTS="-u -U10"
export GIT_DIF="--find-renames --full-index --summary --stat=128,128"
export GIT_FMT="${GIT_DIF} --pretty=fuller --date=iso --decorate"
export GIT_PAT="${GIT_DIF} --attach --binary --keep-subject"

########################################

export LAST="last --system --fullnames --fulltimes --hostlast --ip"		; alias last="${LAST}"

export PV="pv --cursor --bytes --timer --rate --average-rate"			; alias pv="${PV}"
export XARGS="xargs --max-procs=2 --max-args=10"				; alias xargs="${XARGS}"

export XPDF="sudo -H -u plastic DISPLAY=:0 firefox"				; alias xpdf="${XPDF}"
export XPDF_READ="qpdfview"							; alias xpdf-read="${XPDF_READ}"

export RDP="rdesktop -z -n NULL -g 1024x768 -a 24 -r sound:remote"		; alias rdp="${RDP}"
export VNC="vncviewer -Shared -FullColor"					; alias vnc="${VNC}"
export X2VNC="x2vnc -west -tunnel -shared -noblank -lockdelay 60 -timeout 60"	; alias x2vnc="${X2VNC}"

########################################

export UNISON="/.g/_data/+unison"
export UNISON_LOG="_log"

export UNISON_W="reporter unison \
	-ui text \
	-log \
	-logfile ${UNISON}/${UNISON_LOG} \
	-times \
	-perms 0"
export UNISON_U="${UNISON_W} \
	-perms -1 \
	-numericids \
	-owner \
	-group"
export UNISON_F="${UNISON_U} \
	-fastcheck=false"

alias unison="${UNISON_U}"

########################################

export RSYNC_C="reporter rsync \
	-vv \
	--rsh=ssh \
	--recursive \
	--one-file-system \
	--itemize-changes \
	--progress \
	--compress \
	--fuzzy \
	--times"
export RSYNC_W="${RSYNC_C} \
	--force \
	--delete \
	--delete-during"
export RSYNC_U="${RSYNC_W} \
	--sparse \
	--devices \
	--specials \
	--hard-links \
	--links \
	--perms \
	--numeric-ids \
	--owner \
	--group"
export RSYNC_F="${RSYNC_U} \
	--checksum"
export RSYNC_W="${RSYNC_W} \
	--modify-window=10"

alias rsync="${RSYNC_U}"

########################################

export RCLONE_C="reporter rclone"
export RCLONE_U="${RCLONE_C} sync \
	-vv \
	--one-file-system \
	--stats=0 \
	--stats-file-name-length=0 \
	--delete-during \
	--track-renames \
	--copy-links"

alias rclone="${RCLONE_U}"

########################################

export WGET_C="wget \
	--verbose \
	--progress=bar \
	--execute robots=off \
	--user-agent=Mozilla/5.0 \
	--restrict-file-names=windows \
	--no-check-certificate \
	--server-response \
	--adjust-extension \
	--timestamping \
	--timeout=3 \
	--tries=3 \
	--waitretry=3"
export WGET_S="${WGET_C} \
	--force-directories \
	--no-host-directories \
	--no-parent \
	--page-requisites \
	--convert-links \
	--backup-converted"
export WGET_R="${WGET_S} \
	--recursive \
	--level=inf \
	--random-wait \
	--wait=3"

alias wget="${WGET_C}"

################################################################################
# aliases
################################################################################

alias halt="sudo runit-init 0"
alias reboot="sudo runit-init 6"

########################################

alias a="alias"
alias c="clear"
alias h="history"
alias hg="history | ${GREP}"

########################################

alias cl="clear ; ${LL}"
alias ztmp="cd /tmp ; clear ; ${LL}"
alias zpim="cd ${PIMDIR} ; clear ; ${LL}"
alias zcode="cd /.g/_data/zactive/coding/composer ; clear ; ${LL}"
alias zwrite="cd /.g/_data/zactive/writing/tresobis ; clear ; ${LL}"
alias zplan="IMPERSONATE_NAME=task ${HOME}/.bashrc impersonate_command %"

alias s="run-mailcap"
alias x="cd / ; clear"
alias zdesk="cd /.g/_data/zactive/_zcache ; clear ; ${LL}"
if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	alias s="cygstart"
	alias x="cd / ; clear"
#>>>	alias zdesk="cd \"${USERPROFILE}/Desktop\" ; clear ; ${LL}"
	alias zdesk="cd \"/h/My Drive\" ; clear ; ${LL}"
fi
if [[ "${UNAME}" == "Darwin" ]]; then
	alias s="open"
	alias x="cd / ; clear"
#>>>	alias zdesk="cd \"/Users/plastic/Desktop\" ; clear ; ${LL}"
	alias zdesk="cd \"/Volumes/GoogleDrive/My\ Drive\" ; clear ; ${LL}"
fi

########################################

alias rsynclook="${GREP} -v '^[.<>][fdDLS][ ]'"

alias dmesgtail="dmesg --kernel --human --decode --ctime --follow"
alias logtail="tail --follow /.runit/log/syslogd"
alias synctail="${GREP} '^ERROR[:][ ]' /.g/_data/+sync/_sync.log ; echo ; tail --follow /.g/_data/+sync/_sync.log"

########################################

alias cal="cal --monday --three"
alias clean="_sync clean"
alias clock="clockywock"
alias dd="dcfldd conv=noerror,notrunc"
alias dict="sdcv"
alias diskio="iostat -cdmtN -p sda,sdb,sdc,sdd 1"
alias ftp="lftp"
alias htop="${CP} -L ${HOME}/.htoprc.bak ${HOME}/.htoprc ; htop"
alias loopfile="dcfldd if=/dev/zero of=/tmp/loopfile bs=1k count=98288"
alias man="PAGER='less' man"
alias mixer="aumix -C ansi"
alias mozall="_sync _moz _save"
alias mozfox="_sync _moz _firefox"
alias mozfox-reset="_sync _moz _firefox _reset"
alias mplayer="mplayer -fs"
alias pics="feh -. -Sname"
alias pics-s="feh -F -rz -D5"
alias pics-x="feh -F -rz -D5 /.g/_data/personal/pictures/*/[0-9][0-9][0-9][0-9]"
alias pim-mount="umount -f -l ${PIMDIR} ; mount -t cifs -o ro,soft,username=plastic //10.255.255.254/plastic/_pim ${PIMDIR}"
alias ports="netstat -an | ${MORE}"
alias pstree="pstree -clnpuA"
alias publish="_sync publish"
alias remind="remind -v -uplastic"
alias schedule="remind -v -uplastic -g -m -b1 -cc+2 -w90 ${HOME}/.reminders"
alias sheep="electricsheep --debug 1 --mplayer 1 --server d2v6.sheepserver.net"
alias sknow="_sync backup know"
alias smount="_sync mount"
alias tasker="prompt -x +task"
alias torrent="rtorrent -n -s ."
alias trust="_sync archive"
alias vlc-c="vlc --intf ncurses --no-color" #>>> --fullscreen
alias vlc-help="vlc-c --help --full-help --longhelp --advanced 2>&1 | ${MORE}"
alias vlc-play="vlc-c ${HOME}/setup/_misc/playlist.m3u"
alias web="w3m https://www.google.com"
alias workspace="_sync workspace"
alias wpa="ip-setup wpa"
if [[ "${UNAME}" == "Darwin" ]]; then
	alias trust="/_install/_mac_osx.txt -r ; /_install/_mac_osx.txt -x ; /_install/_mac_osx.txt -s"
	alias workspace="/_install/_mac_osx.txt -w"
fi

################################################################################
# basic functions
################################################################################

function adb {
	(cd /.g/_data/_builds/_android && ADB_TRACE=1 ./_adb.sh ${@})
}

########################################

function adb-backup {
	adb backup -all -apk -obb -noshared -nosystem -f ${@}
}

########################################

function adb-vpn {
	adb forward tcp:8080 tcp:8080 ${@}
	adb forward --list
}

########################################

function burn {
	if [[ ${1} == -l ]]; then
		shift
		cdrecord -v dev=ATAPI -scanbus "${@}"
	elif [[ ${1} == -i ]]; then
		shift
		cdrecord -v dev=ATAPI -data "${@}"
	elif [[ ${1} == -e ]]; then
		shift
		cdrecord -v dev=ATAPI -eject "${@}"
	elif [[ ${1} == -a ]]; then
		shift
		cdparanoia -vwB "${@}"
	fi
}

########################################

function filter {
	declare TABLE=
	for TABLE in \
		filter \
		nat \
		mangle \
		raw \
		security \
	; do
		echo -en "\n----------[ ${TABLE} ]----------\n"
		iptables -L -nvx --line-numbers -t ${TABLE}
	done
}

########################################

function format {
	if [[ ${1} == -z ]]; then
		shift
		shred -vzn 7 "${@}"
	elif [[ ${1} == -i ]]; then
		shift
		mkisofs -iso-level 4 -o "${@}"
	elif [[ ${1} == -d ]]; then
		shift
		mkfs.vfat -vF 32 "${@}"
	elif [[ ${1} == -n ]]; then
		shift
		mkntfs -vI "${@}"
	elif [[ ${1} == -l ]]; then
		shift
		cryptsetup --hash sha256 --cipher aes-cbc-essiv:sha256 --key-size 256 luksFormat "${@}"
	else
		mke2fs -t ext4 -jvm 0 "${@}"
	fi
}

########################################

function git {
	declare DIR="$(realpath "${PWD}")"
	${NICELY} $(which git) --git-dir="${DIR}.git" --work-tree="${DIR}" "${@}"
}

########################################

function git-clone {
	if [[ ${1} == svn ]]; then
		shift
		reporter $(which git) svn clone "${@}"
	else
		reporter $(which git) clone --verbose "${@}"
	fi
	${MV} "${!#}/.git" "${!#}.git"
}

########################################

function git-list {
	if [[ ${1} == -l ]]; then
		shift
		${FUNCNAME} -r "${@}" |
			awk '{print $5;}' |
			sort |
			uniq
	elif [[ ${1} == -r ]]; then
		shift
		declare HASH
		for HASH in $(${FUNCNAME} | cut -d' ' -f4); do
			${FUNCNAME} ${HASH} "${@}"
		done
	elif [[ -n "$(echo "${1}" | ${GREP} "^[a-z0-9]{40}$")" ]]; then
		${GIT} ls-tree -lrt "${@}"
	else
		${GIT_CMD} log --pretty=format:"%ai %H %s %d" "${@}"
	fi
}

########################################

function git-patch {
	${GIT} format-patch ${GIT_PAT} ${DIFF_OPTS} "${@}"
}

########################################

function git-perms {
	${GIT_CMD} diff ${GIT_DIF} ${DIFF_OPTS} -R "${@}" |
		${GREP} "^(diff|(old|new) mode)" |
		${GIT_CMD} apply
	${GIT_STS}
}

########################################

function git-remove {
	declare FILTER="git rm -fr --cached --ignore-unmatch ${@}"
	${GIT} filter-branch --index-filter "${FILTER}" HEAD
}

########################################

function hist-grep {
	${GREP} "${@}" ${HOME}/.history/shell/${HOSTNAME}.${USER}.$(basename ${SHELL}).* |
		cut -d: -f2- |
		sort |
		uniq --count |
		sort --numeric-sort |
		${GREP} "${@}"
}

########################################

function ldir {
	${LL} -R "${@}" | more
}

########################################

function letmeknow {
	screen -X wall "$(
		echo -en "[${?}] ["
		history |
			tail -n1 |
			tr -d '\n' |
			${SED} \
				-e "s/^[[:space:]]*[0-9]+[[:space:]]+[0-9T:-]+[[:space:]]+//g" \
				-e "s/[[:space:]]*;[[:space:]]*letmeknow[[:space:]]*$//g"
		echo -en "]"
	)"
}

########################################

function pages {
	calc "$(lynx -dump "${@}" | wc -l) / 60"
}

########################################

function psg {
	declare PSLIST="$(pgrep -d, -f "${@}" | ${SED} "s/[,]$//g")"
	if [[ -n "${PSLIST}" ]]; then
		$(which ps) u -ww -p ${PSLIST}
	fi
}

########################################

function psk {
	declare PSNAME="${1}" && shift
	declare PSLIST="$(pgrep -f "${PSNAME}")"
	psg ${PSNAME}
	if [[ -n "${PSLIST}" ]]; then
		kill "${@}" ${PSLIST}
		sleep 1
	fi
	psg ${PSNAME}
}

########################################

function mirror {
	declare PREFIX="$(echo "${!#}" | ${SED} "s|^(http\|ftp)[s]?://||g" | ${SED} "s|^([^/]+).*$|\1|g")-$(date --iso)"
	${WGET_R} --directory-prefix "${PREFIX}" "${@}" 2>&1 | tee -a ${PREFIX}.log
}

########################################

function swint {
	declare INT="${1}" && shift
	declare WID="${1}" && shift
	declare WPW="${1}" && shift
	${SED} -i "s/eth0/${INT}/g" \
		${HOME}/scripts/fw.${HOSTNAME} \
		${HOME}/scripts/ip.${HOSTNAME} \
		/.runit/_config/dhclient \
		/.runit/_config/tcpdump
	if [[ -n ${WID} ]] && [[ -n ${WPW} ]]; then
		${SED} -i \
			-e "s/(\tssid=).+$/\1\"${WID}\"/g" \
			-e "s/(\tpsk=).+$/\1\"${WPW}\"/g" \
			/.runit/_config/wpa_supplicant
	fi
	ip-setup
}

########################################

function vlc-rc {
	if [[ -n ${@} ]]; then
		echo "${@}" | nc -q 1 127.0.0.1 4212
	else
		nc 127.0.0.1 4212
	fi
}

########################################

function zpim-shortcuts {
	${SED} -n \
		-e "s/^.*HREF[=][\"]([^\"]+)[\"].*SHORTCUTURL[=][\"]([^\"]+)[\"].*[>]([^>]+)[<].*$/\2\t\3\t\1/gp" \
		${PIMDIR}/bookmarks.html
}

################################################################################
# advanced functions
################################################################################

function calendar {
	cd ${PIMDIR}
	prompt -x ${FUNCNAME}
	sudo -H -u \#1000 wyrd \
		calendar.rem \
		"${@}"
	prompt
	cd - >/dev/null
	return 0
}

########################################

function contacts {
	declare CONTACTS="contacts"
	if [[ ${1} == -b ]]; then
		shift
		CONTACTS="contacts-business"
	elif [[ ${1} == -k ]]; then
		shift
		CONTACTS="contacts-keep"
	elif [[ ${1} == -l ]]; then
		shift
		CONTACTS="contacts-ldap"
	elif [[ ${1} == -p ]]; then
		shift
		CONTACTS="contacts-pathfinder"
	elif [[ ${1} == -z ]]; then
		shift
		CONTACTS="contacts-zoho"
		perl -e '
			use strict;
			use warnings;
			use JSON::XS;
			open(JSON, "<", "./zoho-export.leads.json")	|| die();
			open(ADB, ">", "./contacts-zoho.adb")		|| die();
			my $contacts = do { local $/; <JSON> };
			$contacts = decode_json(${contacts});
			foreach my $key (sort(keys(%{$contacts}))) {
				my $item = $contacts->{$key};
				print ADB "[0]\n";
				print ADB "name="	. $item->{"Company"}	. " :: " . $item->{"First Name"} . "\n";
				print ADB "email="	. ($item->{"Email"}	|| "") . "\n";
				print ADB "info="	. ${key}		. "\n";
				print ADB "mobile="	. ($item->{"Mobile"}	|| "") . "\n";
				print ADB "workphone="	. ($item->{"Phone"}	|| "") . "\n";
				print ADB "address="	. ($item->{"Street"}	|| "") . "\n";
				print ADB "city="	. ($item->{"City"}	|| "") . "\n";
				print ADB "state="	. ($item->{"State"}	|| "") . "\n";
				print ADB "zip="	. ($item->{"Zip Code"}	|| "") . "\n";
				print ADB "country=USA\n";
			};
			close(JSON)	|| die();
			close(ADB)	|| die();
		' -- "${@}" || return 1
	elif [[ ${1} == -c ]]; then
		shift
		declare EXP_DIR="contacts.export"
		${RM} ./${EXP_DIR}/*
		declare FILE
		for FILE in *.adb; do
			sudo -H -u \#1000 abook \
				--convert \
				--infile ./${FILE} \
				--informat abook \
				--outfile ./${EXP_DIR}/${FILE/%\.adb}.ldif \
				--outformat ldif
			${SED} -i \
				-e "s/^cn[:][ ](([^ ]+)[ ]?(.*))$/cn: \1\ngivenName: \2\nsn: \3/g" \
				-e "s/^xmozillaanyphone[:]/telephoneNumber:/g" \
				./${EXP_DIR}/${FILE/%\.adb}.ldif
			sudo -H -u \#1000 abook \
				--convert \
				--infile ./${FILE} \
				--informat abook \
				--outfile ./${EXP_DIR}/${FILE/%\.adb}.vcf \
				--outformat vcard
		done
		sudo -H -u \#1000 dos2unix ./${EXP_DIR}/*.{ldif,vcf}
		cat $(${LS} ./${EXP_DIR}/*.vcf | ${GREP} -v "[-]keep") >./${EXP_DIR}.vcf
		chmod -R 750 ./${EXP_DIR}*
		return 0
	fi
	cd ${PIMDIR}
	prompt -x ${FUNCNAME}
	sudo -H -u \#1000 abook \
		--config ${HOME}/.abookrc \
		--datafile ./${CONTACTS}.adb \
		"${@}"
	${FUNCNAME} -c
	chmod 750 ./${CONTACTS}.adb
	prompt
	cd - >/dev/null
	return 0
}

########################################

function edit {
	declare DIFF="diff"
	declare EDIT="${EDITOR}"
	declare FILES
	declare FILE
	if [[ ${1} == -c ]]; then
		shift
		EDIT="cat"
	fi
	if [[ ${1} == -d ]] ||
	   [[ ${1} == -v ]]; then
		[[ ${1} == -v ]] && DIFF="vdiff"
		shift
		for FILE in "${@}"; do
			if [[ -d ${FILE} ]] ||
			   [[ -f ${FILE} ]]; then
				FILE="$(readlink -f ${FILE} 2>/dev/null)"
			else
				FILE="$(which ${FILE} 2>/dev/null)"
			fi
			echo -en "\n----------[ ${FILE} ]----------\n"
			${DIFF} -r ${FILE/zactive/zbackup} ${FILE}
		done
	elif [[ ${1} == -g ]]; then
		shift
		${GREP} -r "${@}" \
			/.g/_data/zactive/.setup \
			/.g/_data/zactive/.static |
			${GREP} -v "[+.]git" |
			${GREP} "${@}"
	elif [[ ${1} == -r ]]; then
		shift
		env ${EDIT} $(
			bash -c "source ${HOME}/.bashrc ; ${FUNCNAME} -g ${@}" |
			${GREP} -v "^Binary" |
			cut -d: -f1 |
			sort |
			uniq
		)
	elif [[ ${1} == -e ]]; then
		shift
		for FILE in "${@}"; do
			set 2>&1 | ${MORE} +/^${FILE}
		done
	else
		for FILE in "${@}"; do
			FILES="${FILES} $(which ${FILE} 2>/dev/null)"
		done
		${EDIT} ${FILES}
	fi
	return 0
}

########################################

function email {
	declare TMPDIR="${HOME}/Desktop"
	declare MUTTRC="${HOME}/.muttrc"
	declare MUTT_X="/tmp/_mutt_mail"
	if [[ ${1} == -a ]]; then
		shift
		MUTTRC="${MUTTRC}.all"
	fi
	if [[ ${1} == -p ]]; then
		shift
		MUTTRC="${HOME}/.procmail.mutt"
	fi
	sudo -H -u \#1000 \
		${MKDIR} ${TMPDIR}
	cd ${TMPDIR}
	prompt -x ${FUNCNAME}
	if [[ ${1} == -x ]]
	then
		shift
		EMAIL_MAIL="${EMAIL_MAIL:-root@garybgenett.net}"
		EMAIL_NAME="${EMAIL_NAME:-GaryBGenett.net Automation}"
		declare LINE
		declare VAR
		declare VAL
		echo "source ${MUTTRC}"								>${MUTT_X}
		${SED} -n "/^alternates.+${EMAIL_MAIL}$/,/^$/p" ${MUTTRC} |
			${SED} -n "s/^<enter-command>(.+)<return>.+$/\1/gp" |
			while read LINE; do
				VAR="$(echo "${LINE}" | ${SED} -n "s/^.+[$](my[_].+)$/\1/gp")"
				if [[ -n ${VAR} ]]; then
					VAL="$(${SED} -n "s/^set[ ]${VAR}.+[=](.+)$/\1/gp" ${MUTTRC})"
					echo "${LINE}" | ${SED} "s|[$]my[_].+$|${VAL}|g"
				else
					echo "${LINE}"
				fi
			done									>>${MUTT_X}
		if [[ -n ${EMAIL_MAIL} ]]; then echo "set from = '${EMAIL_MAIL}'"; fi		>>${MUTT_X}
		if [[ -n ${EMAIL_NAME} ]]; then echo "set realname = '${EMAIL_NAME}'"; fi	>>${MUTT_X}
		echo "set copy = no"								>>${MUTT_X}
		${REALTIME} \
		sudo -H -u \#1000 \
				TMPDIR="${TMPDIR}" \
			mutt \
			-d 2 \
			-nxF ${MUTT_X} \
			"${@}"
		cat ${HOME}/.muttdebug0
		${RM} ${HOME}/.muttdebug0
	else
		if [[ -d "${MAILDIR}" ]]; then
			declare CRUFT="$(cd ${MAILDIR}; find $(find . -type d | ${GREP} "[/]tmp$") ! -empty	| sort)"
			declare EMPTY="$(cd ${MAILDIR}; find . -type f -empty | ${GREP} -v "[./]lock$"		| sort)"
			if [[ -n ${CRUFT} ]] || [[ -n ${EMPTY} ]]; then
				echo -en "[CRUFT]\n${CRUFT}\n"
				echo -en "[EMPTY]\n${EMPTY}\n"
				cd - >/dev/null
				return 1
			fi
		fi
		${REALTIME} \
		sudo -H -u \#1000 \
				MAILDIR="${MAILDIR}" \
				TMPDIR="${TMPDIR}" \
				EDITOR="${VI} +/^$" \
				DISPLAY=":0" \
			mutt \
			-nF ${MUTTRC} \
			"${@}"
	fi
	prompt
	cd - >/dev/null
	return 0
}

########################################

function email-copy {
	declare TMPFILE="/tmp/_mutt_copy"
	declare SRC="${1}"
	declare DST="${2}"
	if [[ -d ${SRC} ]] && [[ -d ${DST} ]]; then
		echo -en "set mbox_type = maildir\n" >${TMPFILE}
		echo -en "folder-hook . \"push " >>${TMPFILE}
			echo -en "<tag-pattern>~A<return>" >>${TMPFILE}
			echo -en "<tag-prefix><copy-message><kill-line>${DST}<return>y" >>${TMPFILE}
			echo -en "<quit>y" >>${TMPFILE}
		echo -en "\"\n" >>${TMPFILE}
		sudo -H -u \#1000 mutt \
			-nF ${TMPFILE} \
			-zRf ${SRC}
		${RM} ${TMPFILE}
	fi
	return 0
}

########################################

function git-backup {
	declare DIR="$(realpath "${PWD}")"
	declare FAIL=
	if [[ "${1}" == -r ]]; then
		shift
		declare COMMIT="HEAD"
		declare ENTIRE="+index"
		[[ -n "$(echo "${1}" | ${GREP} "^[a-z0-9]{40}$")" ]] && COMMIT="${1}" && shift
		[[ -z "${@}" ]] && ENTIRE="./ ${ENTIRE}"
		${GIT} checkout ${COMMIT} ${ENTIRE} "${@}" &&
		index-dir ${DIR} -r "${@}"
		return 0
	fi
	echo -en "* -delta\n" >${DIR}/.gitattributes
	if [[ "${1}" == -! ]]; then
		shift
	else
		index-dir ${DIR} -0 $(
			${GREP} "^/" .gitignore 2>/dev/null |
			${SED} -e "s|^/|./|g" -e "s|/$||g"
			)
	fi
	declare COUNT=
	declare AMEND=
	if [[ "${1}" == *([0-9]) ]]; then
		COUNT="${1}"
		shift
	fi
	if [[ -n "${1}" ]]; then
		AMEND="${1}"
		shift
	fi
	git-save "${FUNCNAME}" "${AMEND}"	|| return 1
	if [[ -n "${COUNT}" ]]; then
		{ git-purge "${COUNT}" &&
			${RM} ${DIR}.gitlog; }	|| FAIL="1"
	fi
#>>>	git-logdir				|| FAIL="1"
	if [[ -n "${FAIL}" ]]; then
		return 1
	fi
	return 0
}

########################################

function git-check {
	declare NEW=".${FUNCNAME}-new"
	declare OLD=".${FUNCNAME}-old"
	declare LST=
	function git-check-out {
		declare FILE="${1}" && shift
		touch --reference ${FILE} ${FILE}${NEW}		|| return 1
		${GIT} checkout ${FILE}				|| return 1
		chown --reference ${FILE}${NEW} ${FILE}		|| return 1
		chmod --reference ${FILE}${NEW} ${FILE}		|| return 1
		${CP} ${FILE} ${FILE}${OLD}			|| return 1
		return 0
	}
	function git-check-new {
		declare FILE="${1}" && shift
		if [[ -n $(diff ${FILE} ${FILE}${NEW} 2>/dev/null) ]]; then
			vdiff ${FILE} ${FILE}${NEW}		|| return 1
		fi
		return 0
	}
	function git-check-old {
		declare FILE="${1}" && shift
		if [[ -z $(diff ${FILE} ${FILE}${OLD} 2>/dev/null) ]]; then
			return 1
		fi
		return 0
	}
	function git-check-end {
		declare FILE="${1}" && shift
		if {
			[[ -f ${FILE}${NEW} ]] &&
			[[ -z $(diff ${FILE} ${FILE}${NEW} 2>/dev/null) ]];
		} || {
			[[ -f ${FILE}${OLD} ]] &&
			[[ -z $(diff ${FILE} ${FILE}${OLD} 2>/dev/null) ]];
		} then
			${MV} ${FILE}${NEW} ${FILE}		|| return 1
			${RM} ${FILE}${OLD}			|| return 1
		fi
		${GIT_STS}					|| return 1
		return 0
	}
	if [[ ${1} == -r ]]; then
		shift
		for FILE in "${@}"; do
			if [[ -f ${FILE}${NEW} ]]; then
				${MV} -i ${FILE}${NEW} ${FILE}
			fi
		done
	fi
	for FILE in "${@}"; do
		LST="${LST} ${FILE} ${FILE}${NEW}"
		if [[ ! -f ${FILE}${NEW} ]]; then
			${CP} ${FILE} ${FILE}${NEW}		|| return 1
			${FUNCNAME}-out ${FILE}			|| return 1
			${FUNCNAME}-new ${FILE}			|| return 1
		fi
	done
	${VI} ${LST}						|| return 1
	for FILE in "${@}"; do
		if ${FUNCNAME}-old ${FILE}; then
			${FUNCNAME}-new ${FILE}			|| return 1
		fi
	done
	${GIT_CMT} "${@}"					|| {
		for FILE in "${@}"; do
			${FUNCNAME}-end ${FILE}
		done
		return 1
	}
	for FILE in "${@}"; do
		${FUNCNAME}-out ${FILE}				|| return 1
		${FUNCNAME}-end ${FILE}				|| return 1
	done
	return 0
}

########################################

function git-clean {
	${GIT} reset --soft								|| return 1
	declare REF
	for REF in $(
		${GIT_CMD} for-each-ref --format="%(refname)" refs/original		2>/dev/null
	); do
		${GIT} update-ref -d ${REF}						|| return 1
	done
	${GIT} reflog expire --verbose --all --expire=all --expire-unreachable=all	|| return 1
	${GIT} gc --prune=all								|| return 1
	${GIT} fsck --verbose --full --no-reflogs --strict				|| return 1
	return 0
}

########################################

function git-export {
	declare EXP_NAM="${1}" && shift
	declare EXP_DIR="${1}" && shift
	declare EXP_GIT="${1}" && shift

	{ [[ -z ${EXP_NAM} ]] || [[ -z ${EXP_DIR} ]]; } && return 1

	declare EXP_PRE_PROC=""; [[ "${1}" == +*(*) ]] && EXP_PRE_PROC="${1/#+}" && shift
	declare EXP_PST_PROC=""; [[ "${1}" == +*(*) ]] && EXP_PST_PROC="${1/#+}" && shift
	[[ -z "${EXP_PRE_PROC}" ]] && EXP_PRE_PROC="echo [NO PRE-PROCESSING]"
	[[ -z "${EXP_PST_PROC}" ]] && EXP_PST_PROC="echo [NO POST-PROCESSING]"

	declare FILE=

	function sort_by_date {
		for FILE in $(
			${GREP} --with-filename "^Date[:][ ]" "${@}" 2>/dev/null |
			${SED} "s%^(.+)[:]Date[:][ ](.+)$%\1::\2%g" |
			${SED} "s%[ ]%^%g"
		); do
			declare DATE="$(date --iso=s --date="$(
				echo "${FILE/#*::}" | tr '^' ' '
			)")"
			echo -en "${DATE} :: ${FILE/%::*}\n"
		done |
			sort -n |
			${SED} "s%^.+[ ]::[ ]%%g"
		return 0
	}

	if [[ ! -d ${EXP_DIR}/.${EXP_NAM} ]]; then
		${MKDIR} ${EXP_DIR}/.${EXP_NAM}			|| return 1
		(cd ${EXP_DIR}/.${EXP_NAM} && ${GIT} init)	|| return 1
	fi
	for FILE in "${@}"; do
		declare NAM="$(echo "${FILE}" | cut -d: -f1)"
		declare DIR="$(echo "${FILE}" | cut -d: -f2)"
		declare FIL="$(echo "${FILE}" | cut -d: -f3 | tr '^' ' ')"
		${MKDIR} ${EXP_DIR}/${NAM}			|| return 1
		${RM} ${EXP_DIR}/${NAM}.git			|| return 1
		${LN} ${DIR}.git ${EXP_DIR}/${NAM}.git		|| return 1
		(cd ${EXP_DIR}/${NAM} && git-logdir -- ${FIL})	|| return 1
		${RM} ${EXP_DIR}/${NAM}.git			|| return 1
	done

	if [[ -n $(ls ${EXP_DIR}/[a-z]*.gitlog/new/* 2>/dev/null) ]]; then
		(cd ${EXP_DIR} &&
			${EXP_PRE_PROC} ${EXP_DIR}/[a-z]*.gitlog/new/*
		)						|| return 1
	fi
	for FILE in $(
		sort_by_date ${EXP_DIR}/[a-z]*.gitlog/new/*
	); do
		(cd ${EXP_DIR}/.${EXP_NAM} && ${GIT} am \
			--ignore-space-change \
			--ignore-whitespace \
			--whitespace=nowarn \
			${FILE}
		)						|| return 1
		${MV} ${FILE} ${FILE//\/new\//\/cur\/}		|| return 1
	done

	(cd ${EXP_DIR}/.${EXP_NAM} &&
		${EXP_PST_PROC}
	)							|| return 1
	if [[ -n ${EXP_GIT} ]]; then
		(cd ${EXP_DIR}/.${EXP_NAM} &&
			git-clean &&
			${GIT} push --mirror ${EXP_GIT}
		)						|| return 1
	fi

	return 0
}

########################################

function git-logdir {
	declare DIR="$(realpath "${PWD}")"
	declare GITDIR="${DIR}.gitlog"
	declare LAST_P="$(ls ${GITDIR}/{cur,new} 2>/dev/null |
		sort -n |
		tail -n1)"
	declare FROM_C="--root"
	declare FROM_N="1"
	if [[ ! -d ${GITDIR} ]]; then
		maildirmake ${GITDIR}
	fi
	if [[ -n "${LAST_P}" ]]; then
		FROM_C="$(${GREP} "^From[ ]" ${GITDIR}/{cur,new}/${LAST_P} 2>/dev/null |
			head -n1 |
			cut -d' ' -f2)"
		FROM_N="$(( $(echo "${LAST_P}" |
			${SED} "s/^0*//" |
			${SED} "s/-.+$//g") +1 ))"
	fi
	git-patch \
		--start-number ${FROM_N} \
		--output-directory ${GITDIR}/new \
		${FROM_C} \
		"${@}" || return 1
	return 0
}

########################################

function git-purge {
	declare DIR="$(realpath "${PWD}")"
	declare MEM_DIR="/dev/shm"
	declare PURGE="$(${GIT_CMD} rev-parse "HEAD~$((${1}-1))")" && shift
	declare _HEAD="$(${GIT_CMD} rev-parse "HEAD")"
	if [[ -z ${PURGE} ]] ||
	   [[ -z ${_HEAD} ]] ||
	   [[ ${PURGE} == ${_HEAD} ]]; then
		echo -en "\n !!! ERROR IN PURGE REQUEST !!!\n\n" >&2
		return 1
	fi
	${GIT} filter-branch \
		-d ${MEM_DIR}/${FUNCNAME} \
		--original "refs/${FUNCNAME}" \
		--parent-filter "[ ${PURGE} = \$GIT_COMMIT ] || cat" \
		HEAD							|| return 1
	${GIT} update-ref -d refs/${FUNCNAME}/refs/heads/master		|| return 1
#>>>	${RM} ${DIR}.git/refs/${FUNCNAME}				|| return 1
	git-clean							|| return 1
	return 0
}

########################################

function git-save {
	declare MESSAGE="${FUNCNAME}"
	declare AMEND=
	if [[ -n ${1} ]]; then
		MESSAGE="${1}"
		shift
	fi
	if [[ -n ${1} ]]; then
		AMEND="[${1}]"
		shift
	fi
	${GIT_ADD} ./									|| return 1
	${GIT_CMT} --all --message="[${MESSAGE} :: $(date --iso=seconds)]${AMEND}"	|| return 1
	return 0
}

########################################

function gtasks {
	cd ${PIMDIR}
	if [[ "${1}" == -a ]]; then
		shift
		${FUNCNAME} -z
		echo -en "\n"
		${FUNCNAME} -c
		echo -en "\n"
		${FUNCNAME} -l
		echo -en "\n"
		${FUNCNAME}
		${GIT_STS}
	elif [[ "${1}" == -c ]]; then
		shift
		declare FILE
		for FILE in ${PIMDIR}/.tasks.*; do
			echo -en ">>> ${FILE}\n"
			cat ${FILE}
			echo -en "\n"
			${RM} ${FILE} >/dev/null
		done
		gtasks_export.pl cruft "${@}"
	elif [[ "${1}" == -l ]]; then
		shift
		${FUNCNAME} -s -r
		echo -en "\n"
		gtasks_export.pl links "${@}"
	elif [[ "${1}" == -s ]]; then
		shift
		if [[ "${1}" == -r ]]; then
			shift
			declare DUE_DATE="[0-9]{4}[-][0-9]{2}[-][0-9]{2}[T][0-9]{2}[:][0-9]{2}[:][0-9]{2}[.][0-9]{3}[Z]"
			declare SOFT_LINK="[[].+[:].+[]]"
			declare HTTP_LINK="http[s]?[:][/][/]"
			declare BASH_LINK="[#$][ ]"
			gtasks_export.pl search "(${DUE_DATE}|${SOFT_LINK}|${HTTP_LINK}|${BASH_LINK})"
		else
			gtasks_export.pl search "${@}"
		fi
	elif [[ "${1}" == -x ]]; then
		shift
		gtasks_export.pl "0.GTD" "[weekly review]"
	elif [[ "${1}" == -z ]]; then
		shift
		gtasks_export.pl "0.GTD" "[today]"
	elif [[ -n "${@}" ]]; then
		gtasks_export.pl "${@}"
	else
		gtasks_export.pl "${@}"	&&
			read		&&
			zpim-commit tasks
	fi
	return 0
}

########################################

function index-dir {
	declare INDEX_D="${PWD}"
	declare INDEX_N="$((12+4))"
	declare OPTION=
	declare SINGLE="false"
	[[ -d "${1}" ]]			&& INDEX_D="${1}"		&& shift
	[[ "${1}" == +([0-9]) ]]	&& INDEX_N="$((${1}+4))"	&& shift
	[[ "${1}" == -[a-z] ]]		&& OPTION="${1}"		&& shift
	[[ "${1}" == -0 ]]		&& SINGLE="true"		&& shift
	declare EXCL_PATHS=
	declare EXCL_PATH=
	for EXCL_PATH in "${@}"; do
		EXCL_PATHS="${EXCL_PATHS} \( -path \"${EXCL_PATH}\" -prune \) -o"
	done
	declare INDEX_I="${INDEX_D}/+index"
	declare CUR_IDX="${INDEX_I}/$(date --iso=seconds | ${SED} "s/[:]/-/g")"
	declare CUR_LNK="${INDEX_I}/_current.txt"
	declare I_ERROR="${INDEX_I}/_error.log"
	declare I_USAGE="${INDEX_I}/_usage.txt"
	if [[ -n "${OPTION}" ]]; then
		if [[ -f ${INDEX_I} ]]; then
			cat ${INDEX_I}
		else
			cat ${CUR_LNK}
		fi |
		${PV} | indexer "${OPTION}" "${@}"
		return 0
	fi
	echo -en "\n ${FUNCNAME}: ${INDEX_D}\n"
	echo -en "\n"
	if ${SINGLE}; then
		(cd ${INDEX_D} && \
			(	eval find . ${EXCL_PATHS} -print	2>&3; [[ -n "${@}" ]] &&
				eval find "${@}" -type d -print		2>&3) | ${PV} -N find |
			sort						2>&3 | ${PV} -N sort |
			indexer -0					2>&3 | ${PV} -N indx |
			cat				>${INDEX_I}	) 3>&2
	else
		${MKDIR} ${INDEX_I}
		cat /dev/null						>${I_ERROR}
		(cd ${INDEX_I} && \
			${RM} $(ls -A | sort -r | tail -n+${INDEX_N})	) 2>>${I_ERROR}
		(cd ${INDEX_D} && \
			(	eval find . ${EXCL_PATHS} -print	2>&3; [[ -n "${@}" ]] &&
				eval find "${@}" -type d -print		2>&3) | ${PV} -N find |
			sort						2>&3  | ${PV} -N sort |
			indexer						2>&3  | ${PV} -N indx |
			cat				>${CUR_IDX}	) 3>>${I_ERROR}
		(cd ${INDEX_D} && \
			cat ${CUR_IDX} | indexer -s	>${I_USAGE}	) 2>>${I_ERROR}
		(cd ${INDEX_I} && \
			${LN} $(basename ${CUR_IDX}) ${CUR_LNK}		) 2>>${I_ERROR}
	fi
	return 0
}

########################################

function indexer {
####################
#  0	type,target_type
#  1	inode
#  2	hard_links
#  3	char_mode,octal_mode
#  4	user:group,uid:gid
#  5	mod_time_iso,mod_time_epoch
#  6	blocks,size_in_b
#  7	size_in_b	[*,!,x]		(directories only)
#  8	md5_hash	[*,!,x]		(files only)
#  9	@d,@f		[*,!,-]		(directories and files only, denotes empty)
# 10	name
# 11	(target)
####################
	declare SED_DATE="[0-9]{4}[-][0-9]{2}[-][0-9]{2}"
	declare SED_TIME="[0-9]{2}[:][0-9]{2}[:][0-9]{2}([.][0-9]{10})?"
	declare SED_ZONE="[A-Z]{3}"
	declare FILE=
	declare DEBUG="false"
	[[ "${1}" == -d ]] && DEBUG="true" && shift
	if [[ "${1}" == -[a-z] ]] &&
	   [[ "${1}" != -m ]] &&
	   (( "${#}" >= 2 )); then
		declare OPTION="${1}" && shift
		${FUNCNAME} -m "${@}" | ${FUNCNAME} $(${DEBUG} && echo "-d") "${OPTION}"
		return 0
	elif [[ "${1}" == -p ]]; then
		shift
		DEBUG="${DEBUG}" perl -e '
			use strict;
			use warnings;
			while(<>){
				chomp();
				my $a = [split(/\0/)];
				print "@{$a}\n";
			};
		' -- "${@}" || return 1
	elif [[ "${1}" == -m ]]; then
		shift
		DEBUG="${DEBUG}" perl -e '
			use strict;
			use warnings;
			my $matches = [@ARGV];
			undef(@ARGV);
			if(!@{$matches}){
				$matches = [".*",];
			};
			while(<>){
				chomp();
				my $a = [split(/\0/)];
				foreach my $match (@{$matches}){
					if($a->[10] =~ m|${match}|){
						print "${_}\n";
					};
				};
			};
		' -- "${@}" || return 1
	elif [[ "${1}" == -l ]]; then
		shift
		DEBUG="${DEBUG}" perl -e '
			use strict;
			use warnings;
			my $emp_dir = [];
			my $emp_fil = [];
			my $brk_sym = [];
			my $symlink = [];
			my $failure = [];
			while(<>){
				chomp();
				my $a = [split(/\0/)];
				if($a->[9] eq "\@d"){ push(@{$emp_dir}, $a); };
				if($a->[9] eq "\@f"){ push(@{$emp_fil}, $a); };
				if($a->[0] eq "l,l"){ push(@{$brk_sym}, $a); };
				if($a->[0] =~ /l,/ ){ push(@{$symlink}, $a); };
				if($a->[7] eq "!"  ||
				   $a->[8] eq "!"  ||
				   $a->[9] eq "!"  ){ push(@{$failure}, $a); };
			};
			print ">>> Empty directories: "	. ($#{$emp_dir} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$emp_dir}) { print "@{$out}\n"; }; };
			print ">>> Empty files: "	. ($#{$emp_fil} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$emp_fil}) { print "@{$out}\n"; }; };
			print ">>> Broken symlinks: "	. ($#{$brk_sym} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$brk_sym}) { print "@{$out}\n"; }; };
			print ">>> Symlinks: "		. ($#{$symlink} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$symlink}) { print "@{$out}\n"; }; };
			print ">>> Failures: "		. ($#{$failure} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$failure}) { print "@{$out}\n"; }; };
		' -- "${@}" || return 1
	elif [[ "${1}" == -s ]]; then
		shift
		DEBUG="${DEBUG}" perl -e '
			use strict;
			use warnings;
			my $tlds = [];
			my $subs = {};
			while(<>){
				chomp();
				my $a = [split(/\0/)];
				if($a->[0] eq "d,d"){
					if($a->[10] =~ m|^[.](/[^/]+)?$|){
						push(@{$tlds}, [$a->[7], $a->[10],]);
					}else{
						my $cur = $a->[10];
						$cur =~ s|^([.]/[^/]+)/.+$|$1|g;
						push(@{$subs->{$cur}}, [$a->[7], $a->[10],]);
						my $added = 0;
						foreach my $tld (@{$tlds}){
							if($cur eq $tld->[1]){
								$added = 1;
							};
						};
						if(!${added}){
							push(@{$tlds}, [0, $cur,]);
						};
					};
				};
			};
			@{$tlds} = (sort({$b->[0] <=> $a->[0] || $a->[1] cmp $b->[1]} @{$tlds}));
			while(my($tld, $obj) = each(%{$subs})){
				@{$subs->{$tld}} = (sort({$b->[0] <=> $a->[0] || $a->[1] cmp $b->[1]} @{$subs->{$tld}}));
			};
			sub format_output {
				my($head, $size, $file) = (shift, shift, shift);
				$size = reverse($size);
				$size =~ s/([0-9]{3})/$1\ /g;
				$size = reverse($size);
				if($head){
					print "-"x7 .">";
					printf("%21s", $size);
				}else{
					printf("%29s", $size);
				};
				print "\t${file}\n";
			};
			foreach my $tld (@{$tlds}){
				format_output(1, $tld->[0], $tld->[1]);
				foreach my $sub (@{$subs->{$tld->[1]}}){
					format_output(0, $sub->[0], $sub->[1]);
				};
			};
		' -- "${@}" || return 1
	elif [[ "${1}" == -v ]]; then
		shift
		tr '\0' '\t' | while read -r FILE; do
			declare MD5="$(echo -en "${FILE}" | cut -d$'\t' -f9)"
			declare FIL="$(echo -en "${FILE}" | cut -d$'\t' -f11)"
			if [[ "${MD5}" != "*" ]] &&
			   [[ "${MD5}" != "!" ]] &&
			   [[ "${MD5}" != "x" ]]; then
				echo "${MD5}  ${FIL}"
			fi
		done | ${NICELY} md5sum -c -
	elif [[ "${1}" == -r ]]; then
		shift
		if ! ${DEBUG}; then
			for FILE in errors missing; do
				if [[ -f +${FUNCNAME}.${FILE} ]]; then
					${RM} +${FUNCNAME}.${FILE}
				fi
			done
		fi
		function do_file {
			{ [[ "${IDX_EMPTY}" != "@d" ]] || ${MKDIR} "${TARGET}"; }			&&
			{ [[ "${IDX__TYPE}" == "l"  ]] || chmod -v "${IDX_CHMOD}" "${TARGET}"; }	&&
			chown -hv "${IDX_CHOWN}" "${TARGET}"						&&
			touch -hd "${IDX_TOUCH}" "${TARGET}"						&&
			return 0
			return 1
		}
		tr '\0' '\t' | while read -r FILE; do
			declare    TARGET="$(echo -en "${FILE}" | cut -d$'\t' -f11)"
			declare IDX_EMPTY="$(echo -en "${FILE}" | cut -d$'\t' -f10)"
			if [[ -e "${TARGET}" ]] ||
			   [[ "${IDX_EMPTY}" == "@d" ]]; then
				declare IDX__TYPE="$(echo -en "${FILE}" | cut -d$'\t' -f1 | cut -d, -f1)"
				declare IDX_CHMOD="$(echo -en "${FILE}" | cut -d$'\t' -f4 | cut -d, -f2)"
				declare IDX_CHOWN="$(echo -en "${FILE}" | cut -d$'\t' -f5 | cut -d, -f2)"
				declare IDX_TOUCH="$(echo -en "${FILE}" | cut -d$'\t' -f6 | cut -d, -f1 | ${SED} "s/(${SED_DATE})[T+](${SED_TIME}${SED_ZONE})/\1 \2/g")"
				if ${DEBUG}; then
					echo -en "RESTORE: ${TARGET}\n"
					do_file
				else
					if do_file >/dev/null 2>&1; then
						echo -en "."
					else
						echo -en "!"
						echo "${FILE}" | tr '\t' '\0' >>+${FUNCNAME}.errors
					fi
				fi
			else
				if ${DEBUG}; then
					echo -en "MISSING: ${TARGET}\n" 1>&2
				else
					echo -en "*"
					echo "${FILE}" | tr '\t' '\0' >>+${FUNCNAME}.missing
				fi
			fi
		done
		if ! ${DEBUG}; then
			echo -en "\n"
			for FILE in errors missing; do
				if [[ -f +${FUNCNAME}.${FILE} ]]; then
					echo -en "\n"
					cat +${FUNCNAME}.${FILE} | ${FUNCNAME} -d -r
				fi
			done
		fi
	elif [[ "${1}" == -du ]]; then
		shift
		DEBUG="${DEBUG}" perl -e '
			use strict;
			use warnings;
			use File::Find;
			while(<>){
				chomp();
				my $size = 0;
				my $size_of = sub {
					if(-L){
						$size += (lstat)[7];
					}else{
						$size += (stat)[7];
					};
				};
				if(-d){
					find($size_of, ${_});
				}else{
					&{$size_of};
				};
				print "${size}\t${_}\n";
			};
		' -- "${@}" || return 1
	elif [[ "${1}" == -! ]]; then
		shift
		DEBUG="${DEBUG}" perl -e '
			while(<>){
				chomp();
				# \000 = null character
				# \042 = double quote
				# \047 = single quote
				if($_ =~ m|([^A-Za-z0-9 \000\042\047 \(\)\[\]\{\} \!\#\$\%\&\*\+\,\/\:\;\=\?\@\^\~ _.-])|){
					print "[$1]: $_\n";
				};
			};
		' -- "${@}" || return 1
	else
		declare FORKS="true"
		if [[ "${1}" == -0 ]]; then
			FORKS="false"
		fi
		function get_output {
			if ${FORKS}; then
				${NICELY} "${@}" "${FILE}" 2>/dev/null | ${SED} "s/[[:space:]].+$//g"
			else
				echo -en "x"
			fi
		}
		function get_null {
			declare TYPE="${1}" && shift
			if [[ -n "$(find "${FILE}" -maxdepth 0 -empty 2>/dev/null)" ]]; then
				echo -en "@${TYPE}"
			else
				echo -en "-"
			fi
		}
		while read -r FILE; do
			declare SIZE="*"
			declare HASH="*"
			declare NULL="*"
			test -d "${FILE}" -a ! -L "${FILE}"	&& SIZE="$(get_output du -bs)" && NULL="$(get_null d)"
			test -f "${FILE}" -a ! -L "${FILE}"	&& HASH="$(get_output md5sum)" && NULL="$(get_null f)"
			test -z "${SIZE}"			&& SIZE="!"
			test -z "${HASH}"			&& HASH="!"
			test -z "${NULL}"			&& NULL="!"
			${NICELY} find "${FILE}" \
				-maxdepth 0 \
				-printf "%y,%Y\t%i\t%n\t%M,%m\t%u:%g,%U:%G\t%T+%TZ,%T@\t%k,%s\t${SIZE}\t${HASH}\t${NULL}\t%p\t(%l)\n" |
					${SED} -e "s/[.][0]{10}//g" -e "s/(${SED_DATE})[T+](${SED_TIME}${SED_ZONE})/\1T\2/g" |
					tr '\t' '\0'
		done
	fi
	return 0
}

########################################

function journal {
	declare JOURNAL_DIR="/.g/_data/zactive/writing/tresobis/_staging"
	if [[ -d "${1}" ]]; then
		JOURNAL_DIR="${1}"
		shift
	fi
	cd "${JOURNAL_DIR}"
	prompt -x ${FUNCNAME}
	${VI} \
		"${@}" \
		$(date --iso=seconds | ${SED} "s/[:]/-/g").txt
	prompt
	cd - >/dev/null
	return 0
}

########################################

function maildirmake {
	declare MAILDIR
	declare DIR
	for MAILDIR in "${@}"; do
		for DIR in cur new tmp; do
			${MKDIR} ${MAILDIR}/${DIR}
		done
	done
	return 0
}

########################################

function mount-robust {
	declare RO=
	declare UN="false"
	if [[ ${1} == -0 ]]; then
		RO="ro,"
		shift
	fi
	if [[ ${1} == -u ]]; then
		UN="true"
		shift
	fi
	declare CHK_EXT="fsck -t ext4		-V -pC"
	declare CHK_NTF="fsck -t ntfs-3g	-V"
	declare CHK_FAT="fsck -t vfat		-V"
	declare MNT_EXT="mount -v -t ext4	-o ${RO}relatime,errors=remount-ro"
	declare MNT_NTF="mount -v -t ntfs-3g	-o ${RO}relatime,errors=remount-ro,shortname=mixed"
	declare MNT_FAT="mount -v -t vfat	-o ${RO}relatime,errors=remount-ro,shortname=mixed"
	declare MNT_BND="mount -v --bind"
	declare UNMOUNT="umount -drv"
	declare DEV="${1}"
	declare DIR="${2}"
	declare LUK="/dev/mapper/$(basename ${DEV})_crypt"
	declare PNT="$(df ${DEV} 2>&1 | ${GREP} "^${DEV}" | ${SED} "s/^.+[[:space:]]//g")"
	if ${UN}; then
		if cryptsetup isLuks ${DEV}; then
			DEV="${LUK}"
		fi
		${UNMOUNT} ${DEV}
		if [[ -n "$(df ${DEV} 2>/dev/null | ${GREP} "${DEV}")" ]]; then
			return 1
		fi
		if [[ -b ${LUK} ]]; then
			cryptsetup luksClose ${LUK} || return 1
		fi
		return 0
	fi
	if [[ -n ${PNT} ]]; then
		if [[ ${PNT} == "/" ]]; then
			echo "Root Filesystem: ${DEV}"
		fi
		if [[ ${PNT} == ${DIR} ]] ||
		   [[ -n $(mount 2>&1 | ${GREP} "^${PNT} on ${DIR}.+bind[)]$") ]]; then
			echo "Already Mounted: ${DEV}"
			return 0
		fi
		${MNT_BND}	${PNT}	${DIR}	|| return 1
	else
		if cryptsetup isLuks ${DEV}; then
			if [[ ! -b ${LUK} ]]; then
				cryptsetup luksOpen ${DEV} $(basename ${LUK}) || return 1
				cryptsetup luksDump ${DEV}
			fi
			DEV="${LUK}"
		fi
		${CHK_EXT}	${DEV}		||
		${CHK_NTF}	${DEV}		||
		${CHK_FAT}	${DEV}		|| return 1
		${MNT_EXT}	${DEV}	${DIR}	||
		${MNT_NTF}	${DEV}	${DIR}	||
		${MNT_FAT}	${DEV}	${DIR}	|| return 1
	fi
	return 0
}

########################################

function organize {
	declare SEARCH="\*"
	declare ORGANIZE="_mission"
	if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
		ORGANIZE="${USERPROFILE}/Desktop/${ORGANIZE}"
	else
		ORGANIZE="${PIMDIR}/${ORGANIZE}"
	fi
	cd $(dirname ${ORGANIZE})
	prompt -x ${FUNCNAME}
	if [[ ${1} == -a ]]; then
		shift
		if [[ -n ${1} ]]; then
			SEARCH="${1}"
		fi
		${SED} "s/^[[:space:]]+//g" "${ORGANIZE}.txt" |
			eval ${GREP} "${SEARCH}" |
			${GREP} "[ ]~[ ]" |
			${GREP} -v "^[*]" |
			sort |
			awk '{printf("%2d %s\n",NR,$0);}' |
			${GREP} "[ ]~[ ]"
	elif [[ ${1} == -l ]]; then
		shift
		if [[ -n ${1} ]]; then
			SEARCH="${1}"
		fi
		${SED} "s/^[[:space:]]+//g" "${ORGANIZE}.txt" |
			eval ${GREP} "${SEARCH}" |
			${GREP} "[ ]~[ ]" |
			${GREP} -v "^[*]" |
			${GREP} -v "^[0-9]" |
			${GREP} -v "[ ]jxt[ ]" |
			sort |
			awk '{printf("%2d %s\n",NR,$0);}' |
			${GREP} "[ ]~[ ]"
	elif [[ ${1} == -z ]]; then
		shift
		${FUNCNAME} -l "${@}" |
			awk -F'~' '{
				z=$2"~"$3;
				n=split($1,d," ");
				n=d[3]" "d[4]" "d[5]
				printf("%-42.42s ~ %s\n",z,n);
			}' |
			${SED} "s/^[[:space:]]+//g" |
			awk '{printf("%2d %s\n",NR,$0);}' |
			${GREP} "[ ]~[ ]"
	else
		${REALTIME} \
		${VI} "${@}" "${ORGANIZE}"{.txt,-*.txt}
	fi
	prompt
	cd - >/dev/null
	return 0
}

########################################

function prompt {
	if [[ ${1} == -z ]]; then
		shift
		declare CMD="bash --login --noprofile --norc -o vi"
		if [[ -n "${@}" ]]; then
			CMD=
		fi
		/usr/bin/env -i \
			PROMPT_DIRTRIM="1" \
			PS1="------------------------------\nENV(\u@\h \w)\\$ " \
			${USER+USER="${USER}"} \
			${HOME+HOME="${HOME}"} \
			${TERM+TERM="${TERM}"} \
			${LANG+LANG="${LANG}"} \
			${LC_ALL+LC_ALL="${LANG}"} \
			${HISTFILE+HISTFILE="${HISTFILE}"} \
			${HISTSIZE+HISTSIZE="${HISTSIZE}"} \
			${HISTFILESIZE+HISTFILESIZE="${HISTFILESIZE}"} \
			${HISTTIMEFORMAT+HISTTIMEFORMAT="${HISTTIMEFORMAT}"} \
			${EMERGE_DEFAULT_OPTS+EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS}"} \
			${CARCH+CARCH="${CARCH}"} \
			${CHOST+CHOST="${CHOST}"} \
			${CFLAGS+CFLAGS="${CFLAGS}"} \
			${CXXFLAGS+CXXFLAGS="${CXXFLAGS}"} \
			${LDFLAGS+LDFLAGS="${LDFLAGS}"} \
			${MAKEFLAGS+MAKEFLAGS="${MAKEFLAGS}"} \
			${CCACHE_DIR+CCACHE_DIR="${CCACHE_DIR}"} \
			${CCACHE_LOGFILE+CCACHE_LOGFILE="${CCACHE_LOGFILE}"} \
			${PATH+PATH="${PATH}"} \
			${CYGWIN+CYGWIN="${CYGWIN}"} \
			${CYGWIN_ROOT+CYGWIN_ROOT="${CYGWIN_ROOT}"} \
			${CMD} "${@}"
		return ${?}
	fi
	if [[ ${1} == -c ]]; then
		shift
		perl -p -e '
			my $DEF_COLOR	= "\e[0;37m";	# light gray
			my $MSG_COLOR	= "\e[0;36m";	# cyan
			my $MARK_COLOR	= "\e[0;35m";	# magenta
			my $TERM_COLOR	= "\e[1;34m";	# dark blue
			my $DARK_COLOR	= "\e[1;30m";	# dark gray
			my $GOOD_COLOR	= "\e[1;32m";	# light green
			my $WARN_COLOR	= "\e[1;33m";	# yellow
			my $FAIL_COLOR	= "\e[1;31m";	# red
		      s/(\s)(no|false|failed)(\s)/\1${FAIL_COLOR}\2${DEF_COLOR}\3/gi;
		s/(\s)(yes|true|ok|succeeded)(\s)/\1${GOOD_COLOR}\2${DEF_COLOR}\3/gi;
		                 s/(\.\.\.)(\s.+)/\1${MSG_COLOR}\2/gi;
		                    s/(.*error.*)/${FAIL_COLOR}\1/gi;
		                  s/(.*warning.*)/${WARN_COLOR}\1/gi;
		         s/^(making [^\s]+ in .+)/${MARK_COLOR}\1/gi;
		                      s/^(\*\*.+)/${MARK_COLOR}\1/gi;
		                        s/^(--.+)/${MARK_COLOR}\1/gi;
		           s/^(patching file)(.+)/${TERM_COLOR}\1${DARK_COLOR}\2/gi;
		       s/^(generating .+ for)(.+)/${TERM_COLOR}\1${DARK_COLOR}\2/gi;
		       s/^(created directory)(.+)/${TERM_COLOR}\1${DARK_COLOR}\2/gi;
		              s/^(installing)(.+)/${TERM_COLOR}\1${DARK_COLOR}\2/gi;
		              s/^(.+[^\s]:)(\s.+)/${TERM_COLOR}\1${DARK_COLOR}\2/gi;
		              s/([\$]?\([^\)]+\))/${MARK_COLOR}\1${DEF_COLOR}/gi;
		           s/.{7}(\(cached\)).{7}/${WARN_COLOR}\1${MSG_COLOR}/gi;
		                    s/(-o [^\s]+)/${MSG_COLOR}\1${DEF_COLOR}/gi;
		                              s/$/${DEF_COLOR}/gi;
		' -- "${@}" || return 1
		return ${?}
	fi
	if [[ ${1} == -d ]]; then
		export DISPLAY=
		if [[ ${2} == [0-9] ]]; then
			export DISPLAY=":${2}"
		elif [[ ${2} == -x ]]; then
			export DISPLAY=":0"
		fi
		if [[ ${2} == -x ]] || [[ ${3} == -x ]]; then
			declare XAUTH="/var/lib/xdm/{,authdir/}authfiles/*"
			export XAUTHORITY="$(eval "ls ${XAUTH}" 2>/dev/null | head -n1)"
			if [[ -z "${XAUTHORITY}" ]]; then
				export XAUTHORITY=$(${PS} 2>/dev/null | ${GREP} "xinit" | ${GREP} "${DISPLAY} -auth" | ${SED} "s/^.+-auth //g")
			fi
		fi
	elif [[ ${1} == -s ]]; then
		export PROMPT="simple"
	elif [[ ${1} == -x ]]; then
		export PROMPT="${2}"
	else
		export PROMPT=
	fi
	source ${HOME}/.bashrc >/dev/null
	return 0
}

########################################

function rater {
	declare DEV
	declare DEVS="bond0.91 bond0.92 bond0.251 bond0.252 bond0.253 bond0.255"
	if [[ ${1} == -n ]]; then
		DEVS="eth0.91 eth0.92 eth1.251 eth1.252 eth1.253 eth1.255"
	fi
	for DEV in ${DEVS}; do
		echo -en "\n ${DEV}:\n"
		tc -d -s filter show dev ${DEV}
		echo -en "\n"
		tc -d -s qdisc show dev ${DEV}
		echo -en "\n"
		tc -d -s class show dev ${DEV}
	done 2>&1 | ${MORE}
	return 0
}

########################################

function reporter {
	declare MARKER="($(date --iso=s) ${HOSTNAME}:${PWD}) ${@}"
	declare CMD="$(basename ${1})"
	declare SRC="$((${#}-1))"	; SRC="${!SRC}"
	declare DST="${#}"		; DST="${!DST}"
	echo -en "\n reporting [${CMD}]: '${SRC}' -> '${DST}'\n"
	echo -en "${MARKER}\n"
	if [[ ${1} != git ]]; then
		time ${NICELY} "${@}" || {
			echo -en "ERROR: ${MARKER}\n"
			return 1;
		};
	else
		time "${@}" || {
			echo -en "ERROR: ${MARKER}\n"
			return 1;
		};
	fi
	return 0
}

########################################

function session {
	declare NAME="_${FUNCNAME}"
	if [[ ${1} == --*(*) ]] && [[ ${1} != --all ]]; then
		NAME="${1/#--}"
		shift
	fi
	if [[ ${1} == --all ]]; then
		shift
		declare RETURN=false
		declare SESSION
		for SESSION in $(screen -list | ${SED} -n "s/^[[:space:]]+[0-9]+[.](.+)[[:space:]]+[(](Attached|Detached)[)]$/\1/gp" | sort); do
			RETURN=true
			${FUNCNAME} --${SESSION} "${@}"
		done
		if ${RETURN}; then
			return 0
		fi
	fi
	if [[ ${1} == -c ]]; then
		declare COLOR="${2}"
		eval screen -X "$(
			${GREP} "^caption[[:space:]]+string[[:space:]]+" ${HOME}/.screenrc |
			${SED} -e "s/= dr/= d${COLOR}/g" -e "s/\"/\'/g"
		)"
	elif [[ ${1} == -l ]]; then
		screen -list
		psg screen
	elif [[ ${1} == -x ]]; then
		killall -9 -v screen
		screen -wipe
	else
		if (( $(id -u) != 0 )) &&
		   { [[ -z ${CYGWIN} ]] && [[ -z ${CYGWIN_ROOT} ]]; }; then
			su - root
		else
			exec screen -xAR -S "${NAME}" "${@}" || return 1
		fi
	fi
	return 0
}

if [[ "${-/i}" != "${-}" ]] &&
   [[ -n "${STY}" ]]; then
	session -c "${PROMPT_SCR_COLOR}"
fi

########################################

function setconf {
	declare SRC="${1}"
	declare DST="${2}"
	if [[ -d ${SRC} ]] && [[ -d ${DST} ]]; then
		(cd ${SRC} ; tar --no-recursion -cf - \
			$(find . ! -type d | ${GREP} -v "[+]" | sort) \
			$(find . ! -type d | ${GREP} "[+]${HOSTNAME}" | sort)) |
			(cd ${DST} ; tar --transform "s/[+]${HOSTNAME}$//g" -svvxf -)
	fi
	return 0
}

########################################

function shell {
	[[ -z ${1} ]] && return 0
	declare DEST="${1}" && shift
	declare PROMPT_NAME="${FUNCNAME}_${DEST}"
	declare SHELL_TERM="${TERM}"
	[[ -n ${1} ]] && [[ ${1} != -*(*) ]] && PROMPT_NAME="${1}" && SHELL_TERM="ansi" && shift
	declare SSH="sudo -H ssh -2"
	declare LOG="root"
	declare OPTS
	if { [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; } ||
	   (( $(id -u) == 0 )); then
		SSH="${SSH/#sudo -H /}"
	fi
	if [[ ${DEST} == -m[0-9] ]]; then
		DEST="${DEST/#-m/}"
		cd
		prompt -x "minicom_${DEST}"
		minicom ${DEST}
		prompt
		cd - >/dev/null
		return 0
	fi
	if [[ ${DEST} == -i ]]; then
		rsync root@me.garybgenett.net:/.g/_data/zactive/.static/.ssh/id_* ${HOME}/.ssh/
		return 0
	fi
	case ${DEST} in
		(me)	DEST="me.garybgenett.net"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5900[:]") ]] && OPTS="${OPTS} -L 5900:127.0.0.1:5900"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5901[:]") ]] && OPTS="${OPTS} -L 5901:127.0.0.1:5901"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5902[:]") ]] && OPTS="${OPTS} -L 5902:127.0.0.1:5902"
			if [[ ${HOSTNAME} != spider ]]; then
				[[ -z $(${PS} 2>/dev/null | ${GREP} "5909[:]") ]] && OPTS="${OPTS} -L 5909:127.0.0.1:5900"
				[[ -z $(${PS} 2>/dev/null | ${GREP} "6606[:]") ]] && OPTS="${OPTS} -L 6606:127.0.0.1:6666"
				[[ -z $(${PS} 2>/dev/null | ${GREP} "6608[:]") ]] && OPTS="${OPTS} -L 6608:127.0.0.1:6668"
			fi
			;;
		(you)	DEST="vpn-client.vpn.example.net"
			if [[ ${HOSTNAME} != bastion ]]; then
				[[ -z $(${PS} 2>/dev/null | ${GREP} "5909[:]") ]] && OPTS="${OPTS} -L 5909:127.0.0.1:5900"
			fi
			;;
		(net:*)	DEST="${DEST/#net:}"
			if [[ ${HOSTNAME} != phantom ]]; then
				[[ -z $(${PS} 2>/dev/null | ${GREP} "5910[:]") ]] && OPTS="${OPTS} -L 5910:127.0.0.1:5900"
			fi
			LOG="plastic"
			OPTS="${OPTS} -t \"/_ports/bin/screen -xAR\""
			;;
		(0)	DEST="localhost -p6553${DEST}"
			LOG="root"
			;;
		([1-4])	DEST="localhost -p6553${DEST}"
			;;
		(5)	DEST="localhost -p6553${DEST}"
			OPTS="${OPTS} -o \"BatchMode yes\""
			OPTS="${OPTS} -o \"CheckHostIP no\""
			OPTS="${OPTS} -o \"StrictHostKeyChecking no\""
			OPTS="${OPTS} -o \"UserKnownHostsFile /dev/null\""
			;;
	esac
	if [[ ${1} == -v[0-9] ]]; then
		OPTS="${OPTS} -L 590${1/#-v/}:127.0.0.1:590${1/#-v}"
		shift
	fi
	if [[ ${1} == -s[=0-9] ]]; then
		if [[ ${2} == --*(*) ]]; then
			OPTS="${OPTS} -t \"bash -c 'source ~/.bashrc ; session ${2} -p${1/#-s/}'\""
			shift
		else
			OPTS="${OPTS} -t \"bash -c 'source ~/.bashrc ; session -p${1/#-s/}'\""
		fi
		shift
	fi
	cd
	prompt -x "${PROMPT_NAME}"
	eval TERM="${SHELL_TERM}" ${SSH} ${LOG}@${DEST} ${OPTS} "${@}"
	prompt
	cd - >/dev/null
	return 0
}

########################################

function sync-dir {
	declare BAS_DIR="${PWD}"
	declare REP_TYP="${1}" && shift
	declare REP_SRC="${1}" && shift
	declare REP_DST="${1}" && shift
	declare REP_FUL="${1}" && shift
	${MKDIR} $(dirname ${BAS_DIR}/${REP_DST})
	if [[ ${REP_TYP} == repo ]]; then
		export PATH="${BAS_DIR}/${REP_DST}:${PATH}"
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			${MKDIR} ${BAS_DIR}/${REP_DST}
			${LN} /usr/bin/python2.7 ${BAS_DIR}/${REP_DST}/python
			(cd ${BAS_DIR}/${REP_DST} &&
				reporter ${BAS_DIR}/.repo/repo init -u ${REP_SRC//\/=\// })
		fi
		${RM} ${BAS_DIR}/${REP_DST}/python
		${LN} /usr/bin/python2.7 ${BAS_DIR}/${REP_DST}/python
		(cd ${BAS_DIR}/${REP_DST} &&
			reporter ${BAS_DIR}/.repo/repo sync)
	elif [[ ${REP_TYP} == git ]]; then
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			git-clone ${REP_SRC} ${BAS_DIR}/${REP_DST}
		fi
		(cd ${BAS_DIR}/${REP_DST} &&
			${GIT} checkout --force &&
			${GIT} pull)
		if [[ -f ${BAS_DIR}/${REP_DST}/.gitmodules ]]; then
			(cd ${BAS_DIR}/${REP_DST} &&
				${GIT} submodule update --force --init --recursive --remote --rebase)
		fi
		if [[ $(basename ${REP_DST}) == meta-repo ]]; then
			${HOME}/setup/gentoo/funtoo.kits ${BAS_DIR}/${REP_DST}
		fi
	elif [[ ${REP_TYP} == hg ]]; then
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			reporter $(which hg) clone --verbose ${REP_SRC} ${BAS_DIR}/${REP_DST}
#>>>			${MV} ${BAS_DIR}/${REP_DST}/.hg ${BAS_DIR}/${REP_DST}.hg
		fi
#>>>			--repository	${BAS_DIR}/${REP_DST}.hg \
		declare HG_CMD="reporter $(which hg) \
			--repository	${BAS_DIR}/${REP_DST} \
			--cwd		${BAS_DIR}/${REP_DST} \
			--verbose"
		(cd ${BAS_DIR}/${REP_DST} &&
			${HG_CMD} pull &&
			${HG_CMD} update --clean)
	elif [[ ${REP_TYP} == svn ]]; then
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			# http://cournape.wordpress.com/2007/12/18/making-a-local-mirror-of-a-subversion-repository-using-svnsync
			(reporter svnadmin create ${BAS_DIR}/${REP_DST}.svn &&
				${MKDIR} ${BAS_DIR}/${REP_DST}.svn/hooks &&
				echo -en "#!/bin/bash\nexit 0\n" >${BAS_DIR}/${REP_DST}.svn/hooks/pre-revprop-change &&
				chmod 755 ${BAS_DIR}/${REP_DST}.svn/hooks/pre-revprop-change &&
				${SVNSYNC} init file://${BAS_DIR}/${REP_DST}.svn ${REP_SRC} &&
				${SVNSYNC} sync file://${BAS_DIR}/${REP_DST}.svn &&
				git-clone svn file://${BAS_DIR}/${REP_DST}.svn ${BAS_DIR}/${REP_DST})
		fi
		(cd ${BAS_DIR}/${REP_DST} &&
			${SVNSYNC} sync file://${BAS_DIR}/${REP_DST}.svn &&
			${GIT_SVN} fetch &&
			${GIT_SVN} rebase &&
			${GIT} checkout --force)
	elif [[ ${REP_TYP} == cvs ]]; then
		declare CVSROOT=":pserver:anonymous@${REP_SRC/%\/=\/*}"
		declare CVS_MOD="${REP_SRC/#*\/=\/}"
		(cd ${BAS_DIR} &&
			${CVS} -d ${CVSROOT} checkout -d ${REP_DST} ${CVS_MOD})
#>>>		if [[ -n ${REP_FUL} ]]; then
			(cd ${BAS_DIR}/${REP_DST} &&
				${GIT} -c i18n.commitencoding=ascii cvsimport -akmR)
#>>>		fi
	elif [[ ${REP_TYP} == rsync ]]; then
		${RSYNC_U/--rsh=ssh } ${REP_SRC}/ ${BAS_DIR}/${REP_DST}
		if [[ -n $(echo "${REP_DST}" | ${GREP} "CVSROOT$") ]]; then
			declare NEW_DST="${BAS_DIR}/${REP_DST/%\/CVSROOT}"
			(cd ${BAS_DIR} &&
				${CVS} -d ${NEW_DST} checkout -d ${NEW_DST}.dir CVSROOT)
			if [[ -n ${REP_FUL} ]]; then
				${MKDIR} ${NEW_DST}.git
				(cd ${NEW_DST}.git &&
					reporter cvs2git \
						--encoding		ascii \
						--fallback-encoding	ascii \
						--username		cvs2git \
						--tmpdir		cvs2git.tmp \
						--blobfile		cvs2git.blob \
						--dumpfile		cvs2git.dump \
						${NEW_DST} &&
					${GIT} init &&
					cat cvs2git.blob cvs2git.dump | ${GIT} fast-import &&
					${GIT} checkout --force)
			fi
		fi
	fi
	return 0
}

########################################

function vdiff {
	declare VDIFF="$(mktemp /tmp/vdiff.XXX 2>/dev/null)"
	declare SEARCH=
	if [[ ${1} == -g ]]; then
		shift
		SEARCH="+/^diff"
		declare TREE=
		[[ -z ${1} ]]		&& TREE="HEAD"			&& shift
		[[ ${1} == -c ]]	&& TREE="--cached HEAD"		&& shift
		[[ ${1} == -i ]]	&& TREE=""			&& shift
		echo "diff" >${VDIFF}
		${GIT_CMD} diff ${GIT_DIF} ${DIFF_OPTS} ${TREE} "${@}" >>${VDIFF} 2>&1
	elif [[ ${1} == -l ]] ||
	     [[ ${1} == -s ]]; then
		declare DIFF="${DIFF_OPTS}"
		[[ ${1} == -s ]] && DIFF=
		shift
		SEARCH="+/^commit"
		declare FOLLOW=
		declare FILE="${#}"
		(( ${FILE} > 0 )) && [[ -f ${!FILE} ]] && FOLLOW="--follow"
		${GIT_CMD} log ${GIT_FMT} ${DIFF} ${FOLLOW} "${@}" >${VDIFF} 2>&1
	else
		SEARCH="+/^[-+]"
		diff ${DIFF_OPTS} "${@}" >${VDIFF}
	fi
	${VIEW} ${SEARCH} ${VDIFF}
	${RM} ${VDIFF} >/dev/null 2>&1
	return 0
}

########################################

function vpn {
	if [[ ${1} == -a ]]; then
		killall -9 autossh
		autossh \
			-M 0 -f \
			-i ${HOME}/.ssh/remote_id \
			-R 65535:127.0.0.1:22 \
			plastic@me.garybgenett.net
	elif [[ ${1} == -v ]]; then
		declare SRC="root@me.garybgenett.net:/.g/_data/zactive"
		${RSYNC_U} ${SRC}/.setup/openvpn/openvpn.conf+VPN			/etc/openvpn/openvpn.conf
		${RSYNC_U} ${SRC}/.static/.openssl/server-ca.garybgenett.net.crt	/etc/openvpn
		${RSYNC_U} ${SRC}/.static/.openssl/vpn-client.garybgenett.net.*		/etc/openvpn
		fwinit off
		iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
		echo "1" >/proc/sys/net/ipv4/ip_forward
		/etc/init.d/openvpn restart
		tail --follow /var/log/syslog
	fi
	return 0
}

########################################

function zpim-commit {
	declare RETURN
	cd ${PIMDIR}
	chown -R plastic:plastic ${PIMDIR}
	chmod -R 750 ${PIMDIR}
	chmod 755 \
		${PIMDIR} \
		${PIMDIR}/tasks* \
		${PIMDIR}/zoho*
	${SED} -i \
		-e "/^[[:space:]]+[<]DD[>]$/d" \
		-e "s/<HR>([[:space:]])/<HR>\n\1/g" \
		bookmarks.html
	if [[ -n "${@}" ]]; then
		declare FILE="${1}" && shift
		declare LIST=
		if [[ ${FILE} == tasks ]]; then
			LIST=".auth* .token* taskd*"
		fi
		if [[ ${FILE} == zoho ]]; then
			LIST=".zoho*"
		fi
		${GIT_ADD} ${FILE}* ${LIST} "${@}"
		${GIT_CMT} ${FILE}* ${LIST} "${@}" --edit --message="Updated \"${FILE}\"."
		RETURN="${?}"
	fi
	if [[ ${RETURN} == 0 ]]; then
		${GIT_STS}
	fi
	cd - >/dev/null
	return ${RETURN}
}

################################################################################
# builds
################################################################################

# https://github.com/openrazer/openrazer/wiki/Troubleshooting
# https://github.com/openrazer/openrazer/wiki/Setting-up-the-keyboard-driver
# https://github.com/openrazer/openrazer/wiki/Using-the-keyboard-driver
# https://github.com/openrazer/openrazer/wiki/Using-the-mouse-driver
function chroma {
	declare BRIGHT="128"
	declare COLOR="\x40\x00\x00"
	declare STEP=; if [[ -n ${1} ]]; then STEP="${1}"; shift; fi
	declare MODE=; if [[ -n ${1} ]]; then MODE="${1}"; shift; fi
	declare DRIVER_DIR="/sys/bus/hid/drivers"
	declare RAZER_KB="1532:0232"
	declare RAZER_MS="1532:005C"
	RAZER_KB="$(basename $(ls -d ${DRIVER_DIR}/{hid,razer}*/*:${RAZER_KB}.* 2>/dev/null | tail -n1))"
	RAZER_MS="$(basename $(ls -d ${DRIVER_DIR}/{hid,razer}*/*:${RAZER_MS}.* 2>/dev/null | head -n1))"
	echo -en "${RAZER_KB}\n"
	echo -en "${RAZER_MS}\n"
	if [[ ${STEP} == "bld" ]]; then
		cd /.g/_data/_build/razer/python-daemonize			&&
			python setup.py build					&&
			python setup.py install					&&
		cd /.g/_data/_build/razer/openrazer				&&
			${RM} /usr/share/man/man*/openrazer-daemon*		&&
			${RM} /usr/share/man/man*/razer.conf*			&&
			${SED} -i "s|/usr/lib/udev|/lib/udev|g" ./Makefile	&&
			prompt -z make						&&
			prompt -z make driver_install				&&
			prompt -z make setup_dkms				&&
			prompt -z make udev_install				&&
			prompt -z make daemon_install				&&
			prompt -z make python_library_install			&&
		cd /.g/_data/_build/razer/polychromatic				&&
			prompt -z make LESSC="lesscpy" install			&&
		echo -en "\n[${FUNCNAME}: ${STEP}]\n"
		return 0
	fi
	if [[ ${STEP} == "set" ]]; then
		gpasswd --add root plugdev					&&
			modprobe razerkbd					&&
			modprobe razermouse					&&
			/lib/udev/razer_mount razerkbd ${RAZER_KB}		&&
			/lib/udev/razer_mount razermouse ${RAZER_MS}		&&
			${LL} ${DRIVER_DIR}/{hid,razer}*			&&
		echo -en "\n[${FUNCNAME}: ${STEP} ${MODE}]\n"
		echo -en "\n"
		cat								${DRIVER_DIR}/razerkbd/${RAZER_KB}/device_type
		cat								${DRIVER_DIR}/razerkbd/${RAZER_KB}/firmware_version
			echo -en "\x03\x00"					>${DRIVER_DIR}/razerkbd/${RAZER_KB}/device_mode
			echo -en "0"						>${DRIVER_DIR}/razerkbd/${RAZER_KB}/fn_toggle
			echo -en "0"						>${DRIVER_DIR}/razerkbd/${RAZER_KB}/logo_led_state
			echo -en "${BRIGHT}"					>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_brightness
			[[ ${MODE} == "off"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_none
			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_wave
			[[ ${MODE} == "spect"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_spectrum
			[[ ${MODE} == "react"	]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_reactive
			[[ -z ${MODE}		]] && echo -en "${COLOR}"	>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_static
		cat								${DRIVER_DIR}/razermouse/${RAZER_MS}/device_type
		cat								${DRIVER_DIR}/razermouse/${RAZER_MS}/firmware_version
			echo -en "\x03\x00"					>${DRIVER_DIR}/razermouse/${RAZER_MS}/device_mode
			echo -en "${BRIGHT}"					>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_led_brightness
			[[ ${MODE} == "off"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_none
			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_spectrum
			[[ ${MODE} == "spect"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_spectrum
			[[ ${MODE} == "react"	]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_reactive
			[[ -z ${MODE}		]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_reactive
			echo -en "${BRIGHT}"					>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_led_brightness
			[[ ${MODE} == "off"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_none
			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_spectrum
			[[ ${MODE} == "spect"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_spectrum
			[[ ${MODE} == "react"	]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_reactive
			[[ -z ${MODE}		]] && echo -en "${COLOR}"	>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_static
		return 0
	fi
	if [[ ${STEP} == "dmn" ]]; then
		${FUNCNAME} set
		cd /.runit/runsvdir/current					&&
			${RM} ./dbus						&&
			${LN} ../../services/dbus ./				&&
		prompt -d -x							&&
		openrazer-daemon --verbose --foreground --respawn --as-root	&&
		return 0
	fi
	if [[ ${STEP} == "ctl" ]]; then
		prompt -d -x							&&
		polychromatic-controller --verbose --debug --print-device-info	&&
		polychromatic-controller --verbose --debug			&&
		return 0
	fi
	return 0
}

########################################

function task-build {
	declare PROG="task"
	declare VERS="master"
	[[ -n ${1} ]] && PROG="${1}" && shift
	[[ -n ${1} ]] && VERS="${1}" && shift
	function task-build-fixes {
		# the fix for TW-1149 scrambles all the timestamps unncecessarily:
		#	https://bug.tasktools.org/browse/TW-1149
		# removing this hackish fix obviates the need for "task-track" below
		#	(it operates directly on the data files, which breaks "sync")
		if [[ -f ./src/commands/CmdEdit.cpp ]]; then
			${SED} -i \
				"s|(^[ ]+when[ ][+][=][ ][(]const[ ]int[)][ ]annotations[.]size[ ][(][)][;])$|//\1|g" \
				./src/commands/CmdEdit.cpp	|| return 1
		fi
		if [[ -x ./doc/rc/refresh ]]; then
			(cd ./doc/rc && ./refresh)
		fi
		return 0
	}
	cd /.g/_data/_build/taskwarrior/${PROG}		&&
		${GIT} checkout --force ${VERS}		&&
		git reset --hard			&&
		cmake ./				&&
		make clean				&&
		task-build-fixes			&&
		cmake					\
			-DCMAKE_INSTALL_PREFIX=/usr	\
			-DTASK_DOCDIR=share/task	\
			-DTASK_RCDIR=share/task/rc	\
			./				&&
		make -j1				&&
		make -j1 install			&&
		${GIT_STS}				&&
		${PROG} --version
	return 0
}

################################################################################
# impersonate functions
################################################################################

function task-export-calendar {
	cd ${PIMDIR}
	gcalendar_export.pl \
		"c|export.gtd:dHJlc29iaXMub3JnXzFmY29nMjNjMWEwOTlhcGdqdTlvN3ZmbTE4QGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
		"c|export.default:Z2FyeUB0cmVzb2Jpcy5vcmc" \
		"c|export.personal:dHJlc29iaXMub3JnX2c4djBwa3RzbnQ4NGVvdHM4aGtpanRzanZnQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
		"c|export.orion:dHJlc29iaXMub3JnX2FiZm9wc3UxdHZmNDRiYzBqZTdtZHFzNmNvQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
		"c|export.rachel:dHJlc29iaXMub3JnX3RoYTF1cjFnbzJpZDRlZGxkZHRnOW90YzlvQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
		"c|export.kori:dHJlc29iaXMub3JnX28zZHBwNWNzbmIzaG1ocGV2czMxZDJrZGlvQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
		${@}
	${SED} -i \
		-e "s/^(DTSTAMP[:]).+$/\119700101T000000Z/g" \
		calendar-export.*.ics
	sudo chown -vR plastic:plastic calendar*
	sudo chmod -vR 750 calendar*
	cd - >/dev/null
	return 0
}

########################################

function task-export-drive {
	cd ${PIMDIR}
	sudo chown plastic:plastic \
		${NOTES_MD} \
		${IDEAS_MD}
#>>>		${SALES_MD}
	sudo chmod 755 \
		$(dirname ${NOTES_MD}) ${NOTES_MD} \
		$(dirname ${IDEAS_MD}) ${IDEAS_MD}
#>>>		$(dirname ${SALES_MD}) ${SALES_MD}
#>>>	gcalendar_export.pl \
#>>>		"d|${NOTES_MD}:${NOTES_MD_ID}" \
#>>>		"d|${IDEAS_MD}:${IDEAS_MD_ID}" \
#>>>		"d|${SALES_MD}:${SALES_MD_ID}"
#>>>		${@}
#>>>	${RSYNC_U} /.g/_data/zactive/_drive/_notes.md drive-notes.md
#>>>	sudo chown -vR plastic:plastic drive*
#>>>	sudo chmod -vR 750 drive*
#>>>		"${NOTES_MD}:${NOTES_MD_ID}" \
#>>>		"${IDEAS_MD}:${IDEAS_MD_ID}" \
#>>>		"${SALES_MD}:${SALES_MD_ID}"
	gdrive_export.pl \
		"${NOTES_MD}:${NOTES_MD_ID}" \
		"${IDEAS_MD}:${IDEAS_MD_ID}" \
		${@} || return 1
#>>>		"${SALES_MD}:${SALES_MD_ID}" \
	cd - >/dev/null
	return 0
}

########################################

function task-export-drive-sync {
	${RCLONE_U} \
		--filter="- /_sync/" \
		\
		${GDRIVE_REMOTE}:/ \
		/.g/_data/zactive/_drive
	${RCLONE_U} \
		--delete-excluded \
		--filter="- /_pim/taskd/orgs/local/users/*/tx.data" \
		--filter="- /_pim/tasks/undo.*" \
		/.g/_data/zactive/_drive/_sync/ \
		${GDRIVE_REMOTE}:/_sync
	${RCLONE_C} about ${GDRIVE_REMOTE}:
	${LL} \
		/.g/_data/zactive/_drive/_sync \
		$(find -H -L /.g/_data/zactive/_drive/_sync -type l 2>/dev/null)
	return 0
}

########################################

function task-export {
	declare FILE=
	cd ${PIMDIR}
#>>>	gtasks_export.pl twimport "+Inbox"
	gtasks_export.pl purge "+Inbox,@agenda,@errand"	"+GTD"
#>>>	gtasks_export.pl twexport "+Alerts"		"mind"	"project.isnt:_gtd"
	gtasks_export.pl twexport "+Notes"		"note"
#>>>	gtasks_export.pl twexport "-Data"		"data"
#>>>	gtasks_export.pl twexport "-Fail"		"fail"
#>>>	gtasks_export.pl twexport "-Mark"		"mark"
#>>>	gtasks_export.pl twexport "-Mind"		"mind"
	gtasks_export.pl twexport "-Todo"		"todo"
#>>>	for FILE in $(task reports 2>&1 | ${GREP} "[ ]Custom[ ][[]" | awk '{print $1;}'); do
#>>>		gtasks_export.pl twexport ".${FILE}"	"${FILE}"
#>>>	done
#>>>	for FILE in $(task uda 2>&1 | ${GREP} "^area" | awk '{print $4;}' | tr ',' ' '); do
#>>>		gtasks_export.pl twexport "=${FILE}"	"view"	"area:${FILE}"
#>>>	done
#>>>	for FILE in $(task _unique tags); do
#>>>		gtasks_export.pl twexport "@${FILE}"	"view"	"tags:${FILE}"
#>>>	done
	gtasks_export.pl twexport "@agenda"		"agenda"
	gtasks_export.pl twexport "@errand"		"errand"
	cd - >/dev/null
	return 0
}

########################################

function task-export-zoho {
	declare UPLOAD=
	if [[ ${1} == "upload" ]]; then
		UPLOAD="${1}"; shift
	fi
	cd ${PIMDIR}
	cat ${PIMDIR}/.zoho.reports
#>>>	gdrive_export.pl ${UPLOAD} "${SALES_MD}:${SALES_MD_ID}" || return 1
	if [[ ! -f ${PIMDIR}/zoho.today.out.md ]]; then
		${RSYNC_U} ${SALES_MD} ${PIMDIR}/zoho.today.out.md
	fi
	eval zohocrm_events.pl \
		$(cat ${PIMDIR}/.zoho.reports) \
		"${@}"
	declare RETURN="${?}"
#>>>	gdrive_export.pl ${UPLOAD} "${SALES_MD}:${SALES_MD_ID}" || return 1
	cd - >/dev/null
	return ${RETURN}
}

########################################

function task-export-report {
	declare DATE="$(date --iso)"
	declare REPORT="${1}.${DATE}" && shift
	declare TASKS_LIST="${1}" && shift
	declare EMAIL_DEST="${1}" && shift
	declare EMAIL_MAIL="${1}" && shift
	declare EMAIL_NAME="${1}" && shift
	declare EMAIL_SIGN="${1}" && shift
	declare TIMELINE_Y="${1}" && shift
	if [[ ${TIMELINE_Y} != false ]] && [[ ${TIMELINE_Y} != true ]]; then
		TIMELINE_Y="false"
	fi
	task-export-text "${EMAIL_NAME}" "${TASKS_LIST}"
	${CP} ${PIMDIR}/tasks.md.html		${REPORT}.projects.html
	${CP} ${PIMDIR}/tasks.timeline.html	${REPORT}.timeline.html
		perl -i -pe '
			use JSON::XS;
			my $json = JSON::XS->new();
			my $tracking = $json->encode(decode_json("[" . qx(cat '${PIMDIR}/tasks.timeline.json')		. "]"));
			my $projects = $json->encode(decode_json("[" . qx(cat '${PIMDIR}/tasks.timeline.projects.json')	. "]"));
			sub reformat {
				my $format = shift();
				$format =~ s|^[[]||g;
				$format =~ s|\\n|\\\\n|g;
				$format =~ s|\\t|\\\\t|g;
				$format =~ s|[]]$||g;
				return(${format});
			};
			$tracking = &reformat(${tracking});
			$projects = &reformat(${projects});
			s|.+tasks.timeline.json.+$|		var parsed_e = JSON.parse('\''${tracking}'\''); eventSource.loadJSON(parsed_e, "");|g;
			s|.+tasks.timeline.projects.json.+$|	var parsed_p = JSON.parse('\''${projects}'\''); projectSource.loadJSON(parsed_p, "");|g;
		' \
		${REPORT}.timeline.html
cat >${REPORT}.txt <<END_OF_FILE
This is my weekly status report.  It is an automated message, and should be generated every weekend.

END_OF_FILE
if ! ${TIMELINE_Y}; then cat >>${REPORT}.txt <<END_OF_FILE
The attached HTML file should open in any browser, and contains a list of all projects along with their status and all notes.
END_OF_FILE
else cat >>${REPORT}.txt <<END_OF_FILE
Attached are two HTML files which should open in any browser:
	* Projects
		* List of all projects, along with their status and all notes
		* The projects report is self-explanatory, and does not have any further details in this message
	* Timeline
		* Interactive visualization, for projects which have deadlines
		* The timeline report requires some additional context, which is the remainder of this message

Internet access is required to properly view the timeline file, as it uses 3rd party Javascript libraries to render the output.  Your browser may request that you accept running the script / blocked content, which you will need to do.

There are four slider bars in the report, progressing in scope from monthly to weekly to daily to hourly.  The highlighted areas show what portion of the more granular timeframes are being displayed.  Long-term project tracking is shown on the top two bars (monthly and weekly), and daily time-tracking is on the bottom two bars (daily and hourly).

Long-term project tracking legend:
	* Text color coding:
		* Black text -- final / due items
		* Gray text -- dependencies / sub-tasks
	* Bar color coding:
		* Green -- in progress (hours have been logged)
		* Yellow -- not yet started
		* Red -- overdue
		* Black -- complete
		* White -- skipped / deleted

Some important notes:
	* Mousing over each item will show a pop-up with start and end dates, along with any "hold" dates and the first and last dates logged against the task
	* The long-term tracking is just a guideline/overview, since not all tasks will take the amount of time allotted
	* Not all time is accounted for in the hourly time-tracking in this report
END_OF_FILE
fi
cat >>${REPORT}.txt <<END_OF_FILE

Please see me with any comments or questions.
END_OF_FILE
	if [[ -n ${EMAIL_SIGN} ]]; then
		echo -en "\n-- \n${EMAIL_SIGN}\n" >>${REPORT}.txt
	fi
	if [[ -n ${EMAIL_DEST} ]] && [[ -n ${EMAIL_MAIL} ]]; then
		cat ${REPORT}.txt |
			EMAIL_MAIL="${EMAIL_MAIL}" \
			EMAIL_NAME="${EMAIL_NAME}" \
			email -x \
				-s "Status Report: ${DATE}" \
				-a ${REPORT}.projects.html \
				$(if ${TIMELINE_Y}; then echo "-a ${REPORT}.timeline.html"; fi) \
				-c ${EMAIL_MAIL} \
				"${@}" \
				-- ${EMAIL_DEST}
	fi
	return 0
}

########################################

function task-export-text {
	declare NAME="${1}" && shift
	cd ${PIMDIR}
	sudo chmod 755 \
		$(dirname ${NOTES_MD}) ${NOTES_MD} \
		$(dirname ${IDEAS_MD}) ${IDEAS_MD}
#>>>		$(dirname ${SALES_MD}) ${SALES_MD}
	perl -e '
		use strict;
		use warnings;
		use JSON::XS;
		use POSIX qw(strftime);
		use Time::Local qw(timegm timelocal);
		use MIME::Base64;
		my $name = shift();
		my $extn = ".md";
		my $args = join("\" \"", @ARGV); if (${args}) { $args = "\"${args}\""; };
		my $root = qx(task _get rc.data.location); chomp(${root});
		my $data = qx(task export ${args}); $data =~ s/\n//g; $data = decode_json(${data});
		my $base = ${root}; $base =~ s|^.*/||g;
		open(JSON, ">", ${root} . ".json")			|| die();
		open(TIME, ">", ${root} . ".csv")			|| die();
		open(PROJ, ">", ${root} . ".timeline.projects.json")	|| die();
		open(LINE, ">", ${root} . ".timeline.json")		|| die();
		open(NOTE, ">", ${root} . ".md")			|| die();
		foreach my $task (@{$data}) { delete($task->{"id"}); delete($task->{"urgency"}); };
		my $json = JSON::XS->new(); print JSON $json->canonical->pretty->encode(${data});
		print TIME "\"[DESC]\",\"[PROJ]\",\"[KIND]\",\"[AREA]\",\"[TAGS]\",";
		print TIME "\"[.UID]\",";
		print TIME "\"[.BRN]\",\"[_BRN]\",\"[=BRN]\",";
		print TIME "\"[.DIE]\",\"[_DIE]\",\"[=DIE]\",";
		print TIME "\"[=AGE]\",";
		print TIME "\"[.BEG]\",\"[_BEG]\",\"[=BEG]\",";
		print TIME "\"[.END]\",\"[_END]\",\"[=END]\",";
		print TIME "\"[=HRS]\",";
		print TIME "\n";
		print NOTE "% Taskwarrior: Project List & Notes\n";
		print NOTE "% " . ${name} . "\n";
		print NOTE "% " . localtime() . "\n";
		my $NOTE = {}; $NOTE->{"other"} = {};
		my $multi_tag = [];
		my $proj_dups = {};
		my $proj = {
			"dateTimeFormat"	=> "iso8601",
			"events"		=> [],
		};
		my $line = {
			"dateTimeFormat"	=> "iso8601",
			"events"		=> [],
		};
		#>>> https://www.w3schools.com/colors/colors_groups.asp
		my $text_color = "black";
		my $proj_color = {
			"working"	=> "green",
			"nostart"	=> "yellow",
			"overdue"	=> "red",
			"history"	=> "black",
			"deleted"	=> "white",
		};
		my $line_color = {
			"_gtd"		=> "red",
			"computer"	=> "blue",
			"family"	=> "yellow",
			"gear"		=> "orange",
			"health"	=> "yellow",
			"money"		=> "green",
			"people"	=> "purple",
			"self"		=> "orange",
			"travel"	=> "cyan",
			"work"		=> "brown",
			"work-em"	=> "brown",
			"work.em"	=> "brown",
			"work.f5"	=> "brown",
			"writing"	=> "magenta",
		};
		my $udas = [ qx(task udas) ];
		@{$udas} = grep ( /^area/, @{$udas} );
		$udas->[0] =~ s/^area.+Area\s+([^\s]+).+$/$1/g;
		foreach my $uda (split( ",", $udas->[0] )) {
			if (!defined( $line_color->{ $uda } )) {
				$line_color->{ $uda } = "pink";
			};
		};
		my $current_time = strftime("%Y-%m-%d %H:%M:%S", localtime(time()));
		sub lead { return(2* (7*			(60*60*24)	)); };
		sub plus { return(2* (1*			(60*60*24)	)); };
		sub days { return(sprintf("%.9f", shift() /	(60*60*24)	)); };
		sub hour { return(sprintf("%.9f", shift() /	(60*60)		)); };
		sub time_format {
			my $stamp = shift();
			$stamp =~ m/^([0-9]{4})([0-9]{2})([0-9]{2})[T]([0-9]{2})([0-9]{2})([0-9]{2})[Z]$/;
			my($yr,$mo,$dy,$hr,$mn,$sc) = ($1,$2,$3,$4,$5,$6);
			my $epoch = timegm($sc,$mn,$hr,$dy,($mo-1),$yr);
			my $ltime = strftime("%Y-%m-%d %H:%M:%S", localtime(${epoch}));
			return(${epoch}, ${ltime});
		};
		sub calculate_due {
			my $task = shift();
			my($date, $z) = &time_format(shift());
			my $result = ${date} - &lead();
			my $hold = &hold_date(${task});
			if (${hold}) {
				$hold =~ m/^([0-9]{4})[-]([0-9]{2})[-]([0-9]{2})[ ]([0-9]{2})[:]([0-9]{2})[:]([0-9]{2})$/;
				my($yr,$mo,$dy,$hr,$mn,$sc) = ($1,$2,$3,$4,$5,$6);
				$hold = timelocal($sc,$mn,$hr,$dy,($mo-1),$yr);
				if (${result} lt (${hold} + &plus())) {
					$result = ${hold} + &plus();
				};
			};
			$result = strftime("%Y%m%dT%H%M%SZ", gmtime(${result}));
			return(${result});
		};
		sub calculate_beg {
			my $due_l = shift();
			my $beg_s = shift();
			my $end_s = shift();
			my $result;
			if (${due_l}) {
				my($due_s, $due_d) = &time_format(${due_l});
				if (${due_s} gt (${end_s} - &plus())) {
					$due_s = ${end_s} - &plus();
				};
				$result = strftime("%Y-%m-%d %H:%M:%S", localtime(${due_s}));
			}
			else {
				if (${beg_s} gt (${end_s} - &plus())) {
					$beg_s = ${end_s} - &plus();
				};
				$result = strftime("%Y-%m-%d %H:%M:%S", localtime(${beg_s}));
			};
			return(${result});
		};
		sub get_by_uuid {
			my $uuid = shift();
			my $task;
			foreach my $item (@{$data}) {
				if ($item->{"uuid"} eq ${uuid}) {
					$task = ${item};
					last;
				};
			};
			return(${task});
		};
		sub hold_date {
			my $task = shift();
			my $result = "";
			if ((exists($task->{"wait"})) && (exists($task->{"scheduled"}))) {
				if ($task->{"wait"} gt $task->{"scheduled"}) {
					$result = $task->{"wait"};
				}
				else {
					$result = $task->{"scheduled"};
				};
			}
			elsif (exists($task->{"wait"})) {
				$result = $task->{"wait"};
			}
			elsif (exists($task->{"scheduled"})) {
				$result = $task->{"scheduled"};
			};
			if (${result}) { my $z;
				($z, $result) = &time_format(${result});
			};
			return(${result});
		};
		sub export_proj {
			my $task		= shift();
			my $main		= shift();
			if (exists($proj_dups->{$task->{"uuid"}})) {
				warn("SKIPPING DUPLICATE[" . $task->{"uuid"} . " " . $task->{"description"} . "]");
				return(0);
			}
			else {
				$proj_dups->{$task->{"uuid"}} = ${task};
			};
			my($beg_s, $beg_d)	= &time_format($task->{"entry"})				if (exists($task->{"entry"}));
			my($end_s, $end_d)	= &time_format($task->{"due"})					if (exists($task->{"due"}));
			my $fst_d		= ""								;
			my $lst_d		= ""								;
			foreach my $annotation (@{$task->{"annotations"}}) { my $z;
				($z, $fst_d)	= &time_format($annotation->{"entry"})				if ((!${fst_d}) && ($annotation->{"description"} =~ m/^[[]track[]][:][[]begin[]]$/));
				($z, $lst_d)	= &time_format($annotation->{"entry"})				if ($annotation->{"description"} =~ m/^[[]track[]][:][[]end[]]$/);
			};
			my $clr_b		= $proj_color->{"nostart"}					;
				$clr_b		= $proj_color->{"working"}					if (${fst_d});
				$clr_b		= $proj_color->{"overdue"}					if (${current_time} gt ${end_d});
				$clr_b		= $proj_color->{"history"}					if (exists($task->{"end"}));
				$clr_b		= $proj_color->{"deleted"}					if ($task->{"status"} eq "deleted");
			my $clr_t		= ${text_color}							;
				$clr_t		= "gray"							if (!${main});
			my $due_l;
			if (exists($task->{"depends"})) {
				foreach my $dep (sort(split(",", $task->{"depends"}))) {
					my $item = &get_by_uuid(${dep});
					if (!${item}) {
						warn("UUID NOT INCLUDED: ${dep}");
					}
					else {
						if (!exists($item->{"due"})) {
							if (!exists($item->{"end"})) {
								$item->{"due"} = &calculate_due(${item}, $task->{"due"});
							}
							else {
								$item->{"due"} = $item->{"end"};
							};
						};
						if ((!${due_l}) || (${due_l} lt $item->{"due"})) {
							$due_l = $item->{"due"};
						};
						&export_proj(${item}, 0);
					};
				};
			};
			$beg_d = &calculate_beg(
				${due_l},
				${beg_s},
				${end_s},
			);
			&export_line(
				${proj},
				${task},
				${clr_b},
				${clr_t},
				${beg_d},
				${fst_d},
				${lst_d},
				${end_d},
			);
		};
		sub export_line {
			my $type	= shift();
			my $task	= shift();
			my $clr_b	= shift();
			my $clr_t	= shift();
			my $beg_d	= shift();
			my $fst_d	= shift();
			my $lst_d	= shift();
			my $end_d	= shift();
			my $title	= $task->{"description"}					if (exists($task->{"description"}));
				$title	= "[" . $task->{"project"} . "] " . $task->{"description"}	if ((exists($task->{"project"})) && ($task->{"project"} ne "_gtd"));
			my $tags	= join(" ", @{$task->{"tags"}})					if (exists($task->{"tags"}));
			my $hld_d	= &hold_date(${task})						;
			my $beg_1	= ${beg_d} . "Z"						if (${beg_d});
				$beg_1	= ${hld_d} . "Z"						if (${hld_d});
			my $beg_2	= ""								;
			my $end_1	= ""								;
			my $end_2	= ${end_d} . "Z"						if (${end_d});
			if (${fst_d}) {
				if (${fst_d} lt ${beg_d}) {
					$beg_1	= ${fst_d} . "Z";
					$beg_2	= ${beg_d} . "Z";
				}
				elsif (${fst_d} lt ${end_d}) {
#>>> uncomment to show late starts
#>>>					$beg_2	= ${fst_d} . "Z";
				};
			};
			if (${lst_d}) {
				if (${lst_d} gt ${end_d}) {
					$end_1	= ${end_d} . "Z";
					$end_2	= ${lst_d} . "Z";
				}
				elsif (${lst_d} gt ${beg_d}) {
#>>> uncomment to show early finishes
#>>>					$end_1	= ${lst_d} . "Z";
				};
			};
			push(@{$type->{"events"}}, {
				"title"		=> ${title},
				"start"		=> ${beg_1},
				"latestStart"	=> ${beg_2},
				"earliestEnd"	=> ${end_1},
				"end"		=> ${end_2},
				"color"		=> ${clr_b},
				"textColor"	=> ${clr_t},
				"durationEvent"	=> "true",
				"caption"	=> ""
					. "[Title]\t"	. ($task->{"description"}	|| "-") . "\n"
					. "[UUID]\t"	. ($task->{"uuid"}		|| "-") . "\n"
					. "\n"
					. "[Project]\t"	. ($task->{"project"}		|| "-") . "\n"
					. "[Kind]\t"	. ($task->{"kind"}		|| "-") . "\n"
					. "[Area]\t"	. ($task->{"area"}		|| "-") . "\n"
					. "[Tags]\t"	. (${tags}			|| "-") . "\n"
					. "\n"
					. "[Status]\t"	. ($task->{"status"}		|| "-") . "\n"
					. "[Begin]\t"	. (${beg_d}			|| "-") . "\n"
					. "[Hold]\t"	. (${hld_d}			|| "-") . "\n"
					. "[First]\t"	. (${fst_d}			|| "-") . "\n"
					. "[Last]\t"	. (${lst_d}			|| "-") . "\n"
					. "[End]\t"	. (${end_d}			|| "-") . "\n"
				. "",
			});
		};
		sub export_note {
			my $task	= shift();
			my $annotation	= shift();
			my $object	= shift();
			my $description = (($task->{"project"}) ? "(" . $task->{"project"} . ") " : "") . $task->{"description"}; $description =~ s|([*_])|\\$1|g;
			my($z, $modified, $output, $note) = ("", "", "", "");
			if ($annotation) {
				($z, $modified) = &time_format($annotation->{"entry"});
				$modified = "Updated: " . ${modified};
				$output = $annotation->{"description"};
				$output =~ s/^[[]notes[]][:]//g;
				$output = "\n" . decode_base64(${output}) . "\n";
				while (${output} =~ m/^\[TASKLIST[ ]?([^\n]*)?\]$/gms) {
					my $project = ${1} || $task->{"project"};
					warn("EXPORTING TASKLIST[${project}]");
					my $tasklist = qx(.bashrc task-depends project.is:${project});
					$tasklist =~ s/^\n*/<!-- TASKLIST[${project}] -->\n/g;
					$tasklist =~ s/\n*$//g;
					$output =~ s/^\[TASKLIST[ ]?([^\n]*)?\]$/${tasklist}/ms;
				};
				while (${output} =~ m/^\[TASKCMD[ ]?([^\n]*)?\]$/gms) {
					my $command = ${1};
					warn("EXPORTING TASKCMD[${command}]");
					my $taskcmd = qx(task ${command});
					$taskcmd =~ s/^\n*/<!-- TASKCMD[${command}] -->\n/g;
					$taskcmd =~ s/\n*$//g;
					$output =~ s/^\[TASKCMD[ ]?([^\n]*)?\]$/${taskcmd}/ms;
				};
				while (${output} =~ m/^\[TASKFILE[ ]?([^\n]*)?\]$/gms) {
					my $source = ${1};
					warn("EXPORTING TASKFILE[${source}]");
					open(TASKFILE, "<", ${source}) || die();
					my $taskfile = do { local $/; <TASKFILE> }; $taskfile =~ s/\n+$//g;
					close(TASKFILE) || die();
					$taskfile =~ s/^\n*/<!-- TASKFILE[${source}] -->\n/g;
					$taskfile =~ s/\n*$//g;
					$output =~ s/^\[TASKFILE[ ]?([^\n]*)?\]$/${taskfile}/ms;
				};
			} else {
				$modified = "No Notes";
			};
			$note .= "\n\n" . ${description} . " {#uuid-" . $task->{"uuid"} . "}\n";
			$note .= ("-" x 40) . "\n\n";
			$note .= "**" . ${modified} . " | UUID: [" . $task->{"uuid"} . "](#uuid-" . $task->{"uuid"} . ") | [TOC](#TOC) [GTD](#gtd) [Dir](./" . ${base} . ") [" . ${extn} . "](./" . ${base} . "/" . $task->{"uuid"} . ${extn} . ")**\n";
			$note .= ${output};
			if	((exists($task->{"project"})) && ($task->{"project"} eq ".someday"))	{
				if ($task->{"status"} eq "pending")					{ $NOTE->{"someday"}		.= ${note}; }
				else									{ $NOTE->{"other"}{"someday"}	.= ${note}; };
			}
			elsif	((exists($task->{"project"})) && ($task->{"project"} eq "_data"))	{ $object->{"data"}		.= ${note}; }
			elsif	((exists($task->{"project"})) && ($task->{"project"} eq "_journal"))	{ $object->{"journal"}		.= ${note}; }
			elsif	($task->{"status"} eq "pending")					{ $object->{"open"}		.= ${note}; }
			elsif	($task->{"status"} eq "completed")					{ $object->{"completed"}	.= ${note}; }
			elsif	($task->{"status"} eq "deleted")					{ $object->{"deleted"}		.= ${note}; }
			else										{ die("INVALID STATUS!"); };
		};
		foreach my $task (sort({
			(($a->{"project"}	|| "") cmp ($b->{"project"}	|| "")) ||
			(($a->{"description"}	|| "") cmp ($b->{"description"}	|| ""))
		} @{$data})) {
			my $started = "0";
			my $begin = "0";
			my $notes = "0";
			if ((exists($task->{"project"})) && ($task->{"project"} eq "_journal")) {
				my $date = $task->{"description"};
				$date =~ s/^([0-9]{4}[-][0-9]{2}[-][0-9]{2}).*$/$1/g;
				$date =~ s/[-]//g;
				my $z;
				if (${date} !~ m/^[0-9]{8}$/) {
					($z, $date) = ("NULL", strftime("%Y-%m-%d %H:%M:%S", localtime(time())));
				} else {
					($z, $date) = &time_format(${date} . "T230000Z");
				};
				my $entry = "";
				my $entries = "0";
				foreach my $annotation (@{$task->{"annotations"}}) {
					if (($task->{"kind"} eq "notes") && ($annotation->{"description"} =~ m/^[[]notes[]][:]/)) {
						if (${entries}) {
							use Data::Dumper;
							print Dumper(${task});
							die("MULTIPLE ENTRIES!");
						};
						$entries = "1";
						my $output = $annotation->{"description"};
						$output =~ s/^[[]notes[]][:]//g;
						$entry = decode_base64(${output});
					};
				};
				push(@{$line->{"events"}}, {
					"title"		=> $task->{"description"},
					"start"		=> ${date},
					"durationEvent"	=> "false",
					"caption"	=> ${entry},
				});
			};
			if ((exists($task->{"due"})) && (!exists($task->{"recur"})) && (exists($task->{"depends"}))) {
				&export_proj(${task}, 1);
			};
			foreach my $annotation (@{$task->{"annotations"}}) {
				if ((((exists($task->{"project"})) && ($task->{"project"} eq "_journal")) || ((!exists($task->{"kind"})) || ($task->{"kind"} eq "track"))) && ($annotation->{"description"} =~ m/^[[]track[]][:][[]begin[]]$/)) {
					my $tags		= join(" ", @{$task->{"tags"}})		if (exists($task->{"tags"}));
					my($brn_s, $brn_d)	= &time_format($task->{"entry"})	if (exists($task->{"entry"}));
					my($die_s, $die_d)	= &time_format($task->{"end"})		if (exists($task->{"end"}));
					my $t_age		= &days(${die_s} - ${brn_s})		if (${die_s});
					my($beg_s, $beg_d)	= &time_format($annotation->{"entry"})	if (exists($annotation->{"entry"}));
					print TIME "\"" . ($task->{"description"}			|| "-") . "\",";
					print TIME "\"" . ($task->{"project"}				|| "-") . "\",";
					print TIME "\"" . ($task->{"kind"}				|| "-") . "\",";
					print TIME "\"" . ($task->{"area"}				|| "-") . "\",";
					print TIME "\"" . (${tags}					|| "-") . "\",";
					print TIME "\"" . ($task->{"uuid"}				|| "-") . "\",";
					print TIME "\"" . ($task->{"entry"}				|| "-") . "\",";
					print TIME "\"" . (${brn_s}					|| "-") . "\",";
					print TIME "\"" . (${brn_d}					|| "-") . "\",";
					print TIME "\"" . ($task->{"end"}				|| "-") . "\",";
					print TIME "\"" . (${die_s}					|| "-") . "\",";
					print TIME "\"" . (${die_d}					|| "-") . "\",";
					print TIME "\"" . (${t_age}					|| "-") . "\",";
					print TIME "\"" . ($annotation->{"entry"}			|| "-") . "\",";
					print TIME "\"" . (${beg_s}					|| "-") . "\",";
					print TIME "\"" . (${beg_d}					|| "-") . "\",";
					$started	= ${beg_s};
					$begin		= ${beg_d};
				}
				elsif ((((exists($task->{"project"})) && ($task->{"project"} eq "_journal")) || ((!exists($task->{"kind"})) || ($task->{"kind"} eq "track"))) && ($annotation->{"description"} =~ m/^[[]track[]][:][[]end[]]$/)) {
					my $tags		= join(" ", @{$task->{"tags"}})		if (exists($task->{"tags"}));
					my($end_s, $end_d)	= &time_format($annotation->{"entry"})	if (exists($annotation->{"entry"}));
					my $t_hrs		= &hour(${end_s} - ${started})		;
					print TIME "\"" . ($annotation->{"entry"}			|| "-") . "\",";
					print TIME "\"" . (${end_s}					|| "-") . "\",";
					print TIME "\"" . (${end_d}					|| "-") . "\",";
					print TIME "\"" . (${t_hrs}					|| "-") . "\",";
					print TIME "\n";
					&export_line(
						${line},
						${task},
						$line_color->{$task->{"area"}},
						${text_color},
						${begin},
						"",
						"",
						${end_d},
					);
					$started	= "0";
					$begin		= "0";
				}
				elsif (((exists($task->{"kind"})) && ($task->{"kind"} eq "notes")) && ($annotation->{"description"} =~ m/^[[]notes[]][:]/)) {
					if (${notes}) {
						use Data::Dumper;
						print Dumper(${task});
						die("MULTIPLE NOTES!");
					};
					$notes = "1";
					&export_note(${task}, ${annotation}, ${NOTE});
				}
				else {
					use Data::Dumper;
					print Dumper(${task});
					die("BAD ANNOTATION!");
				};
			};
			if ((!${notes}) && ((exists($task->{"kind"})) && ($task->{"kind"} eq "notes"))) {
				&export_note(${task}, "", $NOTE->{"other"});
			};
			if (${started}) {
				print TIME "\"-\"," x 4;
				print TIME "\n";
			};
			if ($#{$task->{"tags"}} > 0) {
				push(@{$multi_tag}, ${task});
			};
		};
		print PROJ $json->pretty->encode(${proj});
		print LINE $json->pretty->encode(${line});
		if (exists($NOTE->{"data"}))			{ print NOTE "\n\nData"			. " {#list-data}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"data"}				; };
		if (exists(${$NOTE->{"other"}}{"data"}))	{ print NOTE "\n\nData (Other)"		. " {#list-data-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"data"}		; };
		if (exists($NOTE->{"journal"}))			{ print NOTE "\n\nJournal"		. " {#list-journal}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"journal"}			; };
		if (exists(${$NOTE->{"other"}}{"journal"}))	{ print NOTE "\n\nJournal (Other)"	. " {#list-journal-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"journal"}		; };
		if (exists($NOTE->{"open"}))			{ print NOTE "\n\nOpen"			. " {#list-open}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"open"}				; };
		if (exists(${$NOTE->{"other"}}{"open"}))	{ print NOTE "\n\nOpen (Other)"		. " {#list-open-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"open"}		; };
		if (exists($NOTE->{"completed"}))		{ print NOTE "\n\nCompleted"		. " {#list-completed}\n"	. ("=" x 80) . "\n"; print NOTE $NOTE->{"completed"}			; };
		if (exists(${$NOTE->{"other"}}{"completed"}))	{ print NOTE "\n\nCompleted (Other)"	. " {#list-completed-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"completed"}	; };
		if (exists($NOTE->{"deleted"}))			{ print NOTE "\n\nDeleted"		. " {#list-deleted}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"deleted"}			; };
		if (exists(${$NOTE->{"other"}}{"deleted"}))	{ print NOTE "\n\nDeleted (Other)"	. " {#list-deleted-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"deleted"}		; };
		if (exists($NOTE->{"someday"}))			{ print NOTE "\n\nSomeday"		. " {#list-someday}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"someday"}			; };
		if (exists(${$NOTE->{"other"}}{"someday"}))	{ print NOTE "\n\nSomeday (Other)"	. " {#list-someday-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"someday"}		; };
		close(JSON) || die();
		close(TIME) || die();
		close(PROJ) || die();
		close(LINE) || die();
		close(NOTE) || die();
		foreach my $task (sort({
			(($a->{"project"}	|| "") cmp ($b->{"project"}	|| "")) ||
			(($a->{"description"}	|| "") cmp ($b->{"description"}	|| ""))
		} @{$multi_tag})) {
			warn("MULTIPLE TAGS[" . $task->{"uuid"} . " " . $task->{"description"} . "](" . join(" ", @{$task->{"tags"}}) . ")");
		};
		if (-f "${ENV{COMPOSER}}") {
			my $compose = "make"
				. " -f ${ENV{COMPOSER}}"
				. " -C ${ENV{PIMDIR}}"
				. " TOC=6"
				. " ${base}${extn}.html"
				;
			if (system(${compose}) != 0) { die(); };
			unlink(${ENV{PIMDIR}} . "/.composed") || warn();
		};
	' -- "${NAME}" "${@}" || return 1
	${GREP} "[-][-][ ]TASK" tasks.md
	${SED} -n "s/^#+ //gp" tasks.md |
		sort |
		uniq -c |
		${SED} \
			-e "s/^ *//g" \
			-e "/^1 /d" \
			-e "s/^[0-9]+ //g" \
			-e "s/([^A-Za-z0-9])/\\\\\1/g" \
			|
		xargs -i -d "\n" \
			${GREP} -B10 -A10 '^#+ {}' tasks.md
	${GREP} "#section" tasks.md.html
	${GREP} -B1 "^[\"][0-9]{8}T[0-9]{6}Z" tasks.csv
	cd - >/dev/null
	return 0
}

########################################

function task-journal {
#>>>	if [[ -z "${@}" ]]; then
#>>>		return 1
#>>>	fi
	declare DATE="$(date --iso)"
	if [[ -n "$(echo "${1}" | ${GREP} "^[0-9]{4}[-][0-9]{2}[-][0-9]{2}$")" ]]; then
		DATE="${1}"
		shift
	fi
	declare UUIDS="$(task uuids project:_journal -- /${DATE}/)"
	declare UUID
	if [[ -z ${UUIDS} ]]; then
		task add project:_journal kind:notes area:writing -- "${DATE} $(date --date="${DATE}" +%a) {${@}}"
		${FUNCNAME} "${DATE}"
	else
		for UUID in ${UUIDS}; do
			task view +ACTIVE
			task "${UUID}" read
			declare ENTER=
			read ENTER
			if [[ ${ENTER} != n ]]; then
				task "${UUID}" start
				task-notes "${UUID}"
				task "${UUID}" stop
				task "${UUID}" done
			fi
		done
	fi
	return 0
}

########################################

function task-notes {
	perl -e '
		use strict;
		use warnings;
		use JSON::XS;
		use MIME::Base64;
		my $automatic = "0";
		my $printonly = "0";
		if (($ARGV[0]) && (-f $ARGV[0])) {
			$automatic = $ARGV[0];
			shift();
		}
		elsif (($ARGV[0]) && ($ARGV[0] eq "-x")) {
			$printonly = $ARGV[0];
			shift();
		};
		my $extn = ".md";
		my $args = join("\" \"", @ARGV); if (${args}) { $args = "\"${args}\""; };
		my $root = qx(task _get rc.data.location); chomp(${root});
		my $data = qx(task export kind:notes ${args}); $data =~ s/\n//g; $data = decode_json(${data});
		my $edit = ${args}; $edit =~ s/\"/\\\"/g; $edit = "${ENV{EDITOR}} -c \"map \~ <ESC>:!task read ${edit}<CR>\" -c \"map \\ <ESC>:!task \"";
		my $mark = "DELETE";
		if (!@{$data}) {
			die("NO MATCHES!");
		}
		elsif (
			(!${printonly}) &&
			($#{$data} >= 1)
		) {
			use Data::Dumper;
			print Dumper(${data});
			die("TOO MANY MATCHES!");
		};
		my $uuids = [];
		foreach my $task (sort({
			(($a->{"project"}	|| "") cmp ($b->{"project"}	|| "")) ||
			(($a->{"description"}	|| "") cmp ($b->{"description"}	|| ""))
		} @{$data})) {
			my $file = ${root} . "/" . $task->{"uuid"} . ${extn};
			my $text = "[" . $task->{"description"} . "]";
			my $notes = "0";
			foreach my $annotation (@{$task->{"annotations"}}) {
				if (($task->{"kind"} eq "notes") && ($annotation->{"description"} =~ m/^[[]notes[]][:]/)) {
					if (${notes}) {
						use Data::Dumper;
						print Dumper(${task});
						die("MULTIPLE NOTES!");
					};
					$notes = "1";
					my $output = $annotation->{"description"};
					$output =~ s/^[[]notes[]][:]//g;
					$text = decode_base64(${output});
				};
			};
			push(@{$uuids}, $task->{"uuid"});
			if (${printonly}) {
				print "<!-- [ " . $task->{"uuid"} . " :: " . $task->{"description"} . " ] -->";
				print "\n";
				print ${text};
				print "\n";
			} else {
				open(NOTE, ">", ${file}) || die();
				print NOTE ${text};
				close(NOTE) || die();
			};
		};
		if (!${printonly}) {
			chdir(${root}) || die();
			my $filelist = join("${extn} ", @{$uuids}) . ${extn};
			if (${automatic}) {
				if (! -f ${filelist}) {
					die("FILE AND FILELIST!");
				};
				system("rsync -avv ${automatic} ${filelist}");
			} else {
				system("${edit} ${filelist}");
			};
			foreach my $uuid (@{$uuids}) {
				my $file = ${root} . "/" . ${uuid} . ${extn};
				my $text;
				if (-s ${file}) {
					open(NOTE, "<", ${file}) || die();
					$text = do { local $/; <NOTE> }; $text =~ s/\n+$//g;
					close(NOTE) || die();
					system("task ${uuid} denotate -- \"[notes]:\"");
				};
				if ((-s ${file}) && (${text} ne ${mark})) {
					my $input = encode_base64(${text}, "");
					system("task ${uuid} annotate -- \"[notes]:${input}\"");
				};
			};
			chdir(${root}) || die();
			foreach my $file (@{$uuids}) {
				unlink(${file} . ${extn}) || warn();
			};
		};
	' -- "${@}" || return 1
	return 0
}

########################################

function task-track {
	perl -e '
		use strict;
		use warnings;
		use JSON::XS;
		use POSIX qw(strftime);
		use Time::Local qw(timelocal);
		my $args = join("\" \"", @ARGV); if (${args}) { $args = "\"${args}\""; };
		my $root = qx(task _get rc.data.location); chomp(${root});
		my $uuid = qx(task uuids ${args}); chomp(${uuid}); $uuid = [ split(" ", ${uuid}) ];
		if (!@{$uuid}) {
			die("NO MATCHES!");
		}
		elsif ($#{$uuid} >= 1) {
			use Data::Dumper;
			print Dumper(${uuid});
			die("TOO MANY MATCHES!");
		}
		else {
			$uuid = ${$uuid}[0];
		};
		my $mark = " => ";
		my $edit = ${args}; $edit =~ s/\"/\\\"/g; $edit = "${ENV{EDITOR}} -c \"map \~ <ESC>:!task read ${edit}<CR>\" -c \"map \\ <ESC>:!task \"";
		my $data = qx(${ENV{GREP}} "uuid:\\\"${uuid}\\\"" "${root}"/{completed,pending}.data); chomp(${data});
		my $file = ${data}; $file =~ s/[:].+$//g; $data =~ s/^.+(completed|pending)[.]data[:]//g; $data =~ s/^[[]//g; $data =~ s/[]]$//g;
		my $text = ${root} . "/" . ${uuid};
		my $old = ${data};
		my $new = ${data};
		my $entries = {};
		while (${data} =~ m|(annotation_([0-9]{10})[:][^[:space:]]+)|g) {
			my $ltime = strftime("%Y-%m-%d %H:%M:%S", localtime(${2}));
			$entries->{$1} = ${ltime};
		};
		open(TRACK, ">", ${text}) || die();
		foreach my $key (sort(keys(${entries}))) {
			print TRACK $entries->{$key} . ${mark} . ${key} . "\n";
		};
		close(TRACK) || die();
		system("${edit} ${text}");
		open(TRACK, "<", ${text}) || die();
		while(<TRACK>) {
			chomp(my $line = $_);
			my($val, $key) = split(${mark}, ${line});
			$val =~ m/^([0-9]{4})[-]([0-9]{2})[-]([0-9]{2})[ ]([0-9]{2})[:]([0-9]{2})[:]([0-9]{2})$/;
			my($yr,$mo,$dy,$hr,$mn,$sc) = ($1,$2,$3,$4,$5,$6);
			$val = timelocal($sc,$mn,$hr,$dy,($mo-1),$yr);
			$entries->{$key} = ${val};
		};
		close(TRACK) || die();
		unlink(${text}) || warn();
		foreach my $key (sort(keys(${entries}))) {
			my $find = ${key}; $find =~ s/[:].+$//g;
			my $repl = "annotation_" . $entries->{$key};
			$new =~ s/${find}/${repl}/g;
		};
		if (${new} ne ${old}) {
			system("${ENV{GREP}} \"uuid:\\\"${uuid}\\\"\" \"${file}\""); print "\n";
			open(TRACK, "<", ${file}) || die();
			$data = do { local $/; <TRACK> }; $data =~ s/\n+$//g;
			close(TRACK) || die();
			open(TRACK, ">", ${file}) || die();
			$data =~ s|\Q${old}|${new}|g;
			print TRACK ${data};
			close(TRACK) || die();
			system("${ENV{GREP}} \"uuid:\\\"${uuid}\\\"\" \"${file}\"");
		};
	' -- "${@}" || return 1
	return 0
}

########################################

function task-depends {
	perl -e '
		use strict;
		use warnings;
		use JSON::XS;
		use POSIX qw(strftime);
		use Time::Local qw(timegm timelocal);
#>>>		my $c_uid = 36;
		my $c_uid = 8;
#>>>		my $c_dat = 23;
		my $c_dat = 14;
		my $c_fld = {
			"project"	=> "0",
			"priority"	=> "0",
			"tags"		=> "0",
		};
		foreach my $field (keys(%{$c_fld})) {
			foreach my $value (qx(task _unique ${field})) {
				chomp(${value});
				my $len = length(${value});
				if (${len} > $c_fld->{$field}) {
					$c_fld->{$field} = ${len};
				};
			};
		};
		my $udas = {};
		foreach my $line (qx(task show uda)) {
			if ($line =~ m/^uda[.]([^.]+)[.]values\s+(.+)$/) {
				my $uda = ${1};
				my $val = ${2};
				$val =~ s/^,/-,/g;
				$val =~ s/,,/,-,/g;
				$val =~ s/,$/,-/g;
				$udas->{$uda} = [ split(",", ${val}) ];
			};
		};
		my $init_deep = "0";
		my $print_all = "0";
		if (($ARGV[0]) && ($ARGV[0] eq "-a")) {
			$print_all = $ARGV[0];
			shift();
		};
		my $args = join("\" \"", @ARGV); if (${args}) { $args = "\"${args}\""; };
		my $data = qx(task export);		$data =~ s/\n//g; $data = decode_json(${data});
		my $show = qx(task export ${args});	$show =~ s/\n//g; $show = decode_json(${show});
		my $list = {};
		my $rdep = {};
		my $filt = {};
		my $lnum = {};
		my $dnum = {};
		my $pnum = {};
		my $onum = {};
		my $header;
		foreach my $task (@{$data}) {
			$list->{$task->{"uuid"}} = ${task};
			if (exists($task->{"depends"})) {
				foreach my $uuid (split(",", $task->{"depends"})) {
					push(@{$rdep->{$uuid}}, $task->{"uuid"});
				};
			};
		};
		foreach my $task (@{$show}) {
			$filt->{$task->{"uuid"}} = ${task};
		};
		foreach my $task (sort({
			(($a->{"project"}	|| "") cmp ($b->{"project"}	|| "")) ||
			(($a->{"description"}	|| "") cmp ($b->{"description"}	|| ""))
		} @{$show})) {
			if ((
				(
					(!exists($rdep->{$task->{"uuid"}}))
				) || (
					(exists($task->{"project"})) &&
					($task->{"project"} =~ /[.]/) &&
					(exists($task->{"kind"})) &&
					($task->{"kind"} eq "notes")
				)
			) && (
				(!${print_all}) &&
				(exists($task->{"depends"})) &&
				($task->{"depends"})
			)) {
				&print_task($task->{"uuid"}, ${init_deep});
			}
			elsif (${print_all}) {
				&print_task($task->{"uuid"}, ${init_deep});
				$onum->{ $task->{"uuid"} }++;
			};
		};
		sub time_format {
			my $stamp = shift();
			$stamp =~ m/^([0-9]{4})([0-9]{2})([0-9]{2})[T]([0-9]{2})([0-9]{2})([0-9]{2})[Z]$/;
			my($yr,$mo,$dy,$hr,$mn,$sc) = ($1,$2,$3,$4,$5,$6);
			my $epoch = timegm($sc,$mn,$hr,$dy,($mo-1),$yr);
#>>>			my $ltime = strftime("%Y-%m-%d %H:%M:%S", localtime(${epoch}));
			my $ltime = strftime("%Y-%m-%d", localtime(${epoch}));
			return(${epoch}, ${ltime});
		};
		sub do_time {
			my $date = shift();
			my($epoch, $ltime);
			if ((${date}) && (${date} =~ m/^[0-9TZ]+$/)) {
				(${epoch}, ${ltime}) = &time_format(${date});
				$date = ${ltime};
			};
			return (${date});
		};
		# https://stackoverflow.com/questions/8171528/in-perl-how-can-i-sort-hash-keys-using-a-custom-ordering#48692004
		sub print_task_sorter_udas {
			my $uda = shift();
			my $one = shift();
			my $two = shift();
			my $eno;
			my $owt;
			my $num = 0;
			foreach my $test (@{$udas->{$uda}}) {
				if ((($list->{$one}{$uda}) && ($list->{$one}{$uda} eq ${test})) || ((!defined(${eno})) && (${test} eq "-"))) { $eno = ${num}; };
				if ((($list->{$two}{$uda}) && ($list->{$two}{$uda} eq ${test})) || ((!defined(${owt})) && (${test} eq "-"))) { $owt = ${num}; };
				${num}++;
			};
			# taskwarrior ranks udas (n..1) instead of (1..n), so (uda+) should be entered ($a, $b) and we will reverse it to ($b, $a), and vice versa
			return(${owt} <=> ${eno});
		};
		# report.skim.sort=project+,kind-,priority-,depends+,description+,entry+
		sub print_task_sorter {
			(($list->{$a}{"project"}		|| "") cmp ($list->{$b}{"project"}	|| "")) ||
			(&print_task_sorter_udas("kind",	${b}, ${a})				) ||
			(&print_task_sorter_udas("priority",	${b}, ${a})				) ||
			(($list->{$a}{"depends"}		|| "") cmp ($list->{$b}{"depends"}	|| "")) ||
			(($list->{$a}{"description"}		|| "") cmp ($list->{$b}{"description"}	|| "")) ||
			(($list->{$a}{"entry"}			|| "") cmp ($list->{$b}{"entry"}	|| ""))
		};
		sub print_header {
			$header = "1";
			&print_task("0", "HEADER");
			print "" . ("|:---" x 7) . "|\n";
		};
		sub print_task {
			my $uuid = shift();
			my $deep = shift() || 0;
			my $task = $list->{$uuid};
			# report.skim.labels=+UUID,PROJECT,TAGS,P,+DEAD,+DIED,KIND,DESCRIPTION
			if (!${header}) {
				&print_header();
			};
			if(${deep} eq "HEADER") {
				$deep = "0";
				$task = {
					"status"	=> "HEADER",
					"uuid"		=> "+UUID",
					"project"	=> "PROJECT",
					"tags"		=> "TAGS",
					"priority"	=> "P",
					"due"		=> "+DEAD",
					"end"		=> "+DIED",
					"kind"		=> "KIND",
					"description"	=> "DESCRIPTION",
				};
			};
			print "| "; printf("%-${c_uid}.${c_uid}s", $task->{"uuid"});
			print " | "; printf("%-" . $c_fld->{"project"}	. "." . $c_fld->{"project"}	. "s", $task->{"project"} || "-");
			print " | "; printf("%-" . $c_fld->{"tags"}	. "." . $c_fld->{"tags"}	. "s", (
				(ref($task->{"tags"}) eq "ARRAY") ?
				(join(" ", @{$task->{"tags"}}) || "-") :
				($task->{"tags"} || "-")
				)
			);
			print " | "; printf("%-" . $c_fld->{"priority"}	. "." . $c_fld->{"priority"}	. "s", $task->{"priority"} || "-");
			my $due = (&do_time($task->{"due"}) || "-");
			my $end = (&do_time($task->{"end"}) || "-"); if ($task->{"status"} eq "deleted") { $end = "~~" . ${end} . "~~"; };
			print " | "; printf("%-${c_dat}.${c_dat}s", ${due});
			print " | "; printf("%-${c_dat}.${c_dat}s", ${end});
			if (${deep} >= 0) {
				if (${deep} == 0) {	print " | ";
				} else {		print " | " . (". " x ${deep}) . "${deep} ";
				};
			} else {
				if (${deep} == -1) {	print " | - ";
				} else {		print " | - " . ("- " x (abs(${deep}) - 1)) . (abs(${deep}) - 1) . " ";
				};
			};
			my $title = $task->{"description"};
			if (exists($task->{"kind"}))		{ $title = "[" . $task->{"kind"} . "] " . ${title}; };
			if (
				(!$filt->{$uuid}) &&
				($task->{"status"} ne "HEADER")
			)					{ $title = "\`" . ${title} . "\`"; };
			if (
				($task->{"status"} ne "HEADER") &&
				($task->{"status"} ne "pending")
			)					{ $title = "~~" . ${title} . "~~"; };
			if ((
				(exists($task->{"priority"})) ||
				(exists($task->{"due"}))
			) && (
				($task->{"status"} ne "HEADER")
			))					{ $title = "**" . ${title} . "**"; };
			print ${title} . "\n";
			if (${deep} >= 0) {
				if ($task->{"depends"}) {
					foreach my $uuid (sort(print_task_sorter split(",", $task->{"depends"}))) {
						&print_task(${uuid}, (${deep} + 1));
					};
				};
			} else {
				foreach my $uuid (sort(print_task_sorter @{$rdep->{$task->{"uuid"}}})) {
					&print_task(${uuid}, (${deep} - 1));
				};
			};
			if (
				(${uuid}) &&
				(${deep} >= 0)
			) {
				if ($filt->{$uuid}) {
					$lnum->{$uuid}++;
				} else {
					$dnum->{$uuid}++;
				};
				$pnum->{$uuid}++;
			};
		};
		foreach my $uuid (keys(%{$filt})) {
			if (!$pnum->{$uuid}) {
				$onum->{$uuid}++;
			};
		};
		if (%{$onum}) {
			if (!${header}) {
				&print_header();
			};
			print "" . ("| - " x 7) . "\n";
			foreach my $uuid (sort(print_task_sorter keys(%{$onum}))) {
				&print_task(${uuid}, -1);
			};
		};
		my $c_lnum = scalar(keys(%{$lnum}));
		my $c_dnum = scalar(keys(%{$dnum}));
		my $c_pnum = scalar(keys(%{$pnum}));
		my $c_onum = scalar(keys(%{$onum}));
		print "\n";
		print "Tasks [${args}]: ";
		print "${c_lnum} linked + ${c_dnum} depended = ${c_pnum} printed";
		print " / ";
		print "${c_lnum} linked + ${c_onum} orphaned = " . (${c_lnum} + ${c_onum}) . " matched\n";
	' -- "${@}" || return 1
	return 0
}

########################################

function task-recur {
	perl -e '
		use strict;
		use warnings;
		use JSON::XS;
		use POSIX qw(strftime);
		use Time::Local qw(timegm timelocal);
		my $c_fld = {
			"project"	=> "0",
			"priority"	=> "0",
			"tags"		=> "0",
		};
		foreach my $field (keys(%{$c_fld})) {
			foreach my $value (qx(task _unique ${field})) {
				chomp(${value});
				my $len = length(${value});
				if (${len} > $c_fld->{$field}) {
					$c_fld->{$field} = ${len};
				};
			};
		};
		my $args = join("\" \"", @ARGV); if (${args}) { $args = "\"${args}\""; };
		my $data = qx(task export ${args}); $data =~ s/\n//g; $data = decode_json(${data});
		my $list = {};
		my $keys = [];
		my $count = {};
		foreach my $task (@{$data}) {
			if (exists($task->{"mask"})) {
				$list->{$task->{"description"}} = $task;
			};
		};
		sub time_format {
			my $stamp = shift();
			$stamp =~ m/^([0-9]{4})([0-9]{2})([0-9]{2})[T]([0-9]{2})([0-9]{2})([0-9]{2})[Z]$/;
			my($yr,$mo,$dy,$hr,$mn,$sc) = ($1,$2,$3,$4,$5,$6);
			my $epoch = timegm($sc,$mn,$hr,$dy,($mo-1),$yr);
#>>>			my $ltime = strftime("%Y-%m-%d %H:%M:%S", localtime(${epoch}));
			my $ltime = strftime("%Y-%m-%d", localtime(${epoch}));
			return(${epoch}, ${ltime});
		};
		sub do_time {
			my $date = shift();
			my($epoch, $ltime);
			if ((${date}) && (${date} =~ m/^[0-9TZ]+$/)) {
				(${epoch}, ${ltime}) = &time_format(${date});
				$date = ${ltime};
			};
			return (${date});
		};
		while (my($key, $val) = each(%{$list})) {
			push(@{$keys}, ${key});
		};
		if (@{$keys}) {
			# report.dump.labels=ID,B,U,S,D,DESCRIPTION,PROJECT,KIND,AREA,TAGS,A,R,P,+STAT,+BORN,+WAIT,+HOLD,+REAP,+MOVE,+DEAD,+DIED,+UUID,+PUID,+I,+M
			print "\n";
			print "| +UUID | PROJECT | +DIED | +STAT | R | DESCRIPTION\n";
			print "|:---|:---|:---|:---|:---|:---|\n";
		};
		# report.dump.sort=entry+
		foreach my $key (sort(@{$keys})) {
			my $item = $list->{$key};
			print "| "; printf("%-8.8s", $item->{"uuid"});
			print " | "; printf("%-10.10s", &do_time($item->{"end"}) || "-");
			print " | "; printf("%-9.9s", $item->{"status"});
			print " | "; printf("%-9.9s", $item->{"recur"});
			print " | "; printf("%-" . $c_fld->{"project"} . "." . $c_fld->{"project"} . "s", $item->{"project"} || "-");
			print " | ". $item->{"description"};
			print "\n";
			$count->{$item->{"uuid"}}++;
		};
		print "\n";
		print "Tasks [${args}]: " . scalar(keys(%{$count})) . " recurring\n";
	' -- "${@}" || return 1
	return 0
}

########################################

function task-duplicates {
	declare FILE="$(task _get rc.data.location)/completed.data"
	declare UUID
	for UUID in $(task diagnostics | grep "Found[ ]duplicate" | awk '{print $3;}'); do
		echo -en "\n${UUID}\n";
		${GREP} -n "uuid[:][\"]${UUID}[\"]" ${FILE}
		echo -en "\n"
		# http://www.linuxtopia.org/online_books/linux_tool_guides/the_sed_faq/sedfaq4_004.html
		${SED} -i "0,/uuid[:][\"]${UUID}[\"]/{//d;}" "${FILE}"
		${GREP} -n "uuid[:][\"]${UUID}[\"]" ${FILE}
	done
	return 0
}

########################################

function task-switch {
	FILE="$(task uuids status:pending "${@}")"
	task view +ACTIVE
	if (
		[[ "${@}" == "-" ]]
	) || (
		[[ -n "${@}" ]] && [[ -n "${FILE}" ]]
	); then
#>>>		if [[ "${@}" != "-" ]] && [[ "${FILE}" == *(*)[ ]*(*) ]]; then
		if [[ "${@}" != "-" ]] && [[ -n "$(echo "${FILE}" | ${GREP} "[ ]")" ]]; then
			task read "${FILE}"
		else
			echo "no" | task $(task uuids +ACTIVE) stop rc.bulk=0
			if [[ "${@}" != "-" ]]; then
				sleep 1
				echo "no" | task "${FILE}" start
			fi
			task view +ACTIVE
		fi
	fi
	return 0
}

########################################

function task-copy {
	perl -e '
		use strict;
		use warnings;
		use JSON::XS;
		my $links = [];
		if (($ARGV[0]) && ($ARGV[0] =~ m/^[+]/)) {
			my $list = shift();
			$list =~ s/^[+]//g;
			@{ $links } = split(/,/, ${list});
		};
		if ((!$ARGV[0]) && (!$ARGV[1])) {
			exit(0);
		};
		my $orig = shift();
		chomp($orig = qx(task uuids ${orig}));
		my $data = qx(task export ${orig}); $data =~ s/\n//g; $data = decode_json(${data});
		$data = @{$data}[0];
		while (@{ARGV}) {
			my $field = shift();
			if (${field} =~ m/^(p(ro(ject)?)?[:])(.*)$/)		{ $data->{"project"}	= ${4}; }
			elsif (${field} =~ m/^(k(ind)?[:])(.*)$/)		{ $data->{"kind"}	= ${3}; }
			elsif (${field} =~ m/^(a(rea)?[:])(.*)$/)		{ $data->{"area"}	= ${3}; }
			elsif (${field} =~ m/^(t(ag(s)?)?[:])(.*)$/)		{ ${$data->{"tags"}}[0]	= ${4}; }
			elsif (${field} =~ m/^(d(ue)?[:])(.*)$/)		{ $data->{"due"}	= ${3}; }
			elsif (${field} =~ m/^(dep(ends)?[:])(.*)$/)		{ $data->{"depends"}	= ${3}; }
			elsif (${field} =~ m/^(p(ri(ority)?)?[:])(.*)$/)	{ $data->{"priority"}	= ${4}; }
			elsif (${field} =~ m/^[-][-]$/)				{ last; };
		};
		if (@{ARGV}) {
			$data->{"description"} = join(" ", @{ARGV});
		};
		system("task add"
			. " " . ($data->{"project"}	? "project:"	. $data->{"project"}		: "")
			. " " . ($data->{"kind"}	? "kind:"	. $data->{"kind"}		: "")
			. " " . ($data->{"area"}	? "area:"	. $data->{"area"}		: "")
			. " " . ($data->{"tags"}	? "tags:"	. join(",", @{$data->{"tags"}})	: "")
			. " " . ($data->{"due"}		? "due:"	. $data->{"due"}		: "")
			. " " . ($data->{"depends"}	? "depends:"	. $data->{"depends"}		: "")
			. " " . ($data->{"priority"}	? "priority:"	. $data->{"priority"}		: "")
			. " -- " . $data->{"description"}
		);
		if (${?} == 0) {
			chomp(my $done = qx(task rc.verbose=nothing ids));
			$done =~ s/^1[-]//g;
			foreach my $link (@{$links}) {
				system("task modify ${link} depends:${done}");
			};
			system("task read ${orig} ${done} " . join(" ", @{$links}));
		};
	' -- "${@}" || return 1
	return 0
}

########################################

function task-move {
	declare PSRC="${1}"; declare PSID="$(task uuids kind:notes project.is:${1})"; shift
	declare PDST="${1}"; declare PDID="$(task uuids kind:notes project.is:${1})"; shift
	declare FILE=
	if [[ -n ${PSID} ]] && [[ -n ${PDID} ]]; then
		for FILE in $(task uuids "${@}"); do
			task modify ${FILE} project:${PDST}
			task modify ${PSID} depends:-${FILE} &&
			task modify ${PDID} depends:${FILE}
		done
	fi
	return 0
}

########################################

function task-insert {
	declare UNDO="false"
	if [[ ${1} == -d ]]; then
		UNDO="true"
		shift
	fi
	if [[ -n ${1} ]] && [[ -n ${2} ]] && [[ -n ${3} ]]; then
		declare PRNT="$(task uuids ${1})"; shift
		declare CHLD="$(task uuids ${1})"; shift
		declare HOST="$(task uuids ${1})"; shift
		if ! ${UNDO}; then
			task modify ${HOST} depends:${CHLD}
			task modify ${PRNT} depends:-${CHLD},${HOST}
		else
			task modify ${HOST} depends:-${CHLD}
			task modify ${PRNT} depends:${CHLD},-${HOST}
		fi
	fi
	return 0
}

########################################

function task-flush {
	declare FILE=
	for FILE in "${@}"; do
		declare UUIDS="$(task uuids \
			project.is:${FILE} \
			'(status:completed or status:deleted)' \
			kind.none: \
		)"
		if [[ -n "${UUIDS}" ]]; then
			task read ${UUIDS}
			task-move ${FILE} ${FILE}.done ${UUIDS}
			task read ${UUIDS}
		fi
	done
	return 0
}

################################################################################

export TW="IMPERSONATE_NAME=task .bashrc impersonate_command"
alias tw="${TW}"

if [[ ${IMPERSONATE_NAME} == task ]]; then
	declare FILE=
	unalias -a
	function impersonate_command {
		declare MARKER='echo -en "\e[1;34m"; printf "~%.0s" {1..120}; echo -en "\e[0;37m\n"'
		declare TASKFILE="$(task _get rc.data.location)"
		declare TASKUUID="$(task uuids project:_data -- /.review/)"
		declare WORKUUID="$(task uuids project:_data -- /.status/)"
#>>>		declare TODOUUID="$(task uuids project:_data -- /.today/)"
		declare TODOUUID="${NOTES_MD}"
		# color.active=white on green -> blue instead, same as marker above
		declare ECHO_CLR="\e[1;31;44m"
		declare ECHO_DFL="\e[0m"
		function _echo {
			declare INDENT="1"
			declare FILLER="-"
			if [[ ${1} == +([0-9]) ]]; then
				INDENT="${1}"; shift
			fi
			if [[ ${1} == [=]+(*) ]]; then
				FILLER="${1/#=}"; shift
			fi
			declare BEG="$(declare NUM; for NUM in $(eval echo "{1..${INDENT}}");	do echo -en "${FILLER}"; done)"
			declare END="$(declare NUM; for NUM in {1..120};			do echo -en "${FILLER}"; done)"
			eval ${MARKER}
			echo -en "${ECHO_CLR}"
			eval printf \"%-120.120s\" \"${BEG} ${@} ${END}\"
			echo -en "${ECHO_DFL}"
			echo -en "\n"
		}
		function _task {
			eval ${MARKER}
			echo -en "[task ${@}]\n"
			task \
				rc._forcecolor=1 \
				rc.verbose=nothing \
				"${@}" 2>&1
		}
		function _task_parse {
			declare TWUUID="${1}"; shift
			declare REPORT="${1}"; shift
			# https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed/1252191#1252191
			${SED} -n "/[#][ ]${REPORT}/,/^[#]/p" "$(
				if [[ -f "${TWUUID}" ]]; then
					echo -en "${TWUUID}"
				elif [[ -f "${TASKFILE}/${TWUUID}.md" ]]; then
					echo -en "${TASKFILE}/${TWUUID}.md"
				else
					echo -en "${TASKFILE}.md"
				fi
			)" | ${SED} ":a;N;\$!ba; s/\n\n[#].*$//g"
		}
		function _task_parse_cmd {
			_task_parse "${@}" |
				${GREP} "[\`]" |
				${SED} \
					-e "s/^[^\`]*[\`]//g" \
					-e "s/[\`][^\`]*$//g" \
					-e "s/[\`][,][ ][\`]/\n/g" \
					-e "s/(['&])/\\\\\1/g"
		}
		function _task_parse_cmd_bash {
			_task_parse_cmd "${@}" |
				${SED} \
					-e "s/^([^#=+.])/_task \1/g" \
					-e "s/([ ])(task[ ])/\1_\2/g" \
					-e "s/^[=](.*)/_echo\ \1/g" \
					-e "s/^[+]//g" \
					-e "s/^[.]/impersonate_command /g" \
					-e "s/^(impersonate_command|task[-])/eval\ \${MARKER}\;\ \1/g" \
					-e "s/(impersonate_command|task[-])/IMPERSONATE_NAME=task .bashrc \1/g" \
					-e "s/$/;/g"
		}
		if [[ ${1} == "RESET" ]]; then
			shift
			if [[ ${1} == "SYNC" ]]; then
				shift
				uuidgen >	${PIMDIR}/tasks/backlog.data
#>>>				task export >	${PIMDIR}/taskd/orgs/local/users/*/tx.data
				echo -n	>	${PIMDIR}/taskd/orgs/local/users/*/tx.data
				cat		${PIMDIR}/tasks/backlog.data \
					>>	${PIMDIR}/taskd/orgs/local/users/*/tx.data
				task sync
				return 0
			fi
			declare LIST="tasks"
			if [[ ${1} == "ALL" ]]; then
				shift
				LIST="${LIST} taskd"
			fi
			cd ${PIMDIR}
			GIT_PAGER= \
			${GIT} diff ${LIST}	|| return 1
			${GIT} reset ${LIST}	|| return 1
			${GIT} checkout ${LIST}	|| return 1
			sudo chown -vR plastic:plastic ${LIST}
			sudo chmod -vR 750 ${LIST}
			cd - >/dev/null
		elif [[ ${1} == "in" ]]; then
			shift
			impersonate_command =
			cd ${PIMDIR}
			declare BEG="$(task rc.verbose=nothing ids | ${SED} "s/^1[-]//g")"
			gtasks_export.pl twimport "+Inbox"
			declare END="$(task rc.verbose=nothing ids | ${SED} "s/^1[-]//g")"
			if [[ ${BEG} != ${END} ]]; then
				declare IDS="$((${BEG}+1))-${END}"
				echo -en "IDs: ${IDS}\n"
				task ${IDS} read
			fi
			cd - >/dev/null
		elif [[ ${1} == "view" ]]; then
			shift
			cat /dev/null						 >${TASKFILE}.weekly.txt
			echo -en "###[ Weekly Review Steps & Commands ]###\n"	>>${TASKFILE}.weekly.txt
			declare FILE
			for FILE in \
				"System" \
				"Weekly[ ]Review" \
				"Weekly[ ]Report" \
			; do
				echo -en "\n#[ Markdown Source ]\n"				>>${TASKFILE}.weekly.txt; _task_parse		"${TASKUUID}" "${FILE}" | ${SED} "s/^/\#\]/g"		>>${TASKFILE}.weekly.txt
				echo -en "\n#[ _task_parse_cmd :: impersonate_command ]\n"	>>${TASKFILE}.weekly.txt; _task_parse_cmd	"${TASKUUID}" "${FILE}" | ${SED} "s/^/\#\|/g"		>>${TASKFILE}.weekly.txt
				echo -en "\n#[ _task_parse_cmd_bash :: bash]\n"			>>${TASKFILE}.weekly.txt; _task_parse_cmd_bash	"${TASKUUID}" "${FILE}" | ${SED} "s/[_](task[ ])/\1/g"	>>${TASKFILE}.weekly.txt
			done
			(
				_task logo
				eval $(_task_parse_cmd_bash "${TASKUUID}" "Weekly[ ]Review")
				eval ${MARKER}
			) | ${MORE}
		elif [[ ${1} == "repo" ]]; then
			shift
			(
				_task logo
				eval $(_task_parse_cmd_bash "${TASKUUID}" "Weekly[ ]Report")
				eval ${MARKER}
			) | ${MORE}
		elif [[ ${1} == "todo" ]]; then
			shift
			declare SOURCE
			declare HEADER[@]
			declare FILE
			if [[ -z "${@}" ]]; then
				SOURCE="${TODOUUID}"
				HEADER[0]="Priorities"
				HEADER[1]="Projects"
				HEADER[2]="Notes"
			else
				SOURCE="${1}"; shift
				declare NUM="0"
				for FILE in "${@}"; do
					HEADER[${NUM}]="${FILE}"
					NUM=$((${NUM}+1))
				done
			fi
			(
				for FILE in "${HEADER[@]}"; do
					_echo					"3" "=>" "${FILE}"
					_task					read +ACTIVE
#>>>					eval ${MARKER}; _task_parse_cmd_bash	"${SOURCE}" "${FILE}"
					eval $(_task_parse_cmd_bash		"${SOURCE}" "${FILE}")
				done
				eval ${MARKER}
			) | ${MORE}
		elif [[ ${1} == [=] ]]; then
			shift
			task-export-text	|| return 1
#>>>			task-export		|| return 1
			zpim-commit tasks
		elif [[ ${1} == [@] ]]; then
			task-export-drive || return 1
			${EDITOR} -c "map ~ <ESC>:!${TW} todo<CR>" -c "map \\ <ESC>:!${TW} " \
				${NOTES_MD} \
				${IDEAS_MD} \
#>>>				${SALES_MD}
			if [[ -s ${NOTES_MD} ]] &&
			   [[ -s ${IDEAS_MD} ]]; then
#>>>			   [[ -s ${SALES_MD} ]]; then
				task-export-drive upload || return 1
			fi
		elif [[ ${1} == [%] ]]; then
			shift
			if [[ -n ${1} ]]; then
				declare COMMIT="false"; [[ ${1} == [12] ]] && COMMIT="true"
				declare PLANIT="false"; [[ ${1} == 2 ]] && PLANIT="true"
				[[ ${1} == [0-9] ]] && shift
				task-export-zoho "${@}" || return 1
				declare CHANGED="false"; [[ -n "$(cd "${PIMDIR}" && GIT_PAGER= ${GIT_CMD} diff zoho.md 2>&1)" ]] && CHANGED="true"
				if ${PLANIT}; then
					if [[ ! -f ${PIMDIR}/zoho.today.out.md ]]; then
						${RSYNC_U} ${SALES_MD} ${PIMDIR}/zoho.today.out.md
					fi
					cd ${PIMDIR}
					${EDITOR} \
						${PIMDIR}/zoho.today.out.md \
						${PIMDIR}/zoho.today.tmp.md
					cd - >/dev/null
					if [[ -n "$(diff ${PIMDIR}/zoho.today.out.md ${SALES_MD})" ]]; then
						${RSYNC_U} ${PIMDIR}/zoho.today.out.md ${SALES_MD}
						(
							task-export-zoho upload "${@}" &&
							${RM} ${PIMDIR}/zoho.today.out.md
						) || return 1
						CHANGED="true"
					else
						${RM} ${PIMDIR}/zoho.today.out.md
					fi
				else
					${RM} ${PIMDIR}/zoho.today.out.md
				fi
				${RM} ${PIMDIR}/zoho.today.tmp.md
				if ${COMMIT} && zpim-commit zoho && ${CHANGED}; then
					true # no operation, because below commented
#>>>					task-notes "${PIMDIR}/zoho.md" "${WORKUUID}"
#>>>					impersonate_command =
				fi
			fi
			eval task-export-text \"Test Work Report\" $(${SED} -n "s/^(.+area[.]is[:]work.+)[ ][\\]$/\1/gp" ${HOME}/scripts/_sync)
			declare HEADER_LINKS
			HEADER_LINKS="${HEADER_LINKS}<ul>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"zoho.md.html\\\">[Zoho Report: HTML]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"zoho.md\\\">[Zoho Report: Raw]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"zoho.all.md.html\\\">[Complete Zoho Report: HTML]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"zoho.all.md\\\">[Complete Zoho Report: Raw]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"zoho.today.md.html\\\">[Zoho Planning: HTML]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"zoho.today.md\\\">[Zoho Planning: Raw]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}<li><a href=\\\"http://10.255.255.254/zactive/data.business/quote.html\\\">[E-Mail Template]</a></li>"
			HEADER_LINKS="${HEADER_LINKS}</ul>"
			${SED} -i "s|^(</header>)$|\1\n${HEADER_LINKS}|g" "${PIMDIR}/tasks.md.html"
			declare FILES="zoho.md.html zoho.all.md.html zoho.today.md.html"
			if [[ -f "${COMPOSER}" ]]; then
				make all			\
					-f "${COMPOSER}"	\
					-C "${PIMDIR}"		\
					TOC="6"			\
					COMPOSER_TARGETS="${FILES}"
				declare ENTER=
				read ENTER
			fi
			FILES=".composed ${FILES}"
			(cd ${PIMDIR} &&
				${RM} ${FILES} &&
				${GIT} rm --force --ignore-unmatch ${FILES} &&
				${GIT} reset zoho* &&
				${GIT_STS}
			)
		elif [[ ${1} == [_] ]]; then
			shift
#>>>			task-switch -
			task-journal "${@}"
#>>>			task-switch _reporting
		elif [[ ${1} == [+] ]]; then
			shift
			task-notes "${@}"
		elif [[ ${1} == [~] ]]; then
			shift
			declare PROJECT="${1}" && shift
			task-notes project.is:${PROJECT} "${@}"
		elif [[ ${1} == [-] ]]; then
			shift
			task view project.isnt:_gtd /:/ "${@}" | ${SED} -ne "s/^[^a-z]+([a-z][^:]+)[:].+$/\1/gp" | sort | uniq
			task view project.isnt:_gtd /:/ "${@}"
		elif [[ ${1} == [/] ]]; then
			shift
			task-switch "${@}"
		elif [[ ${1} == [d] ]]; then
			shift
			task-depends "${@}"
		elif [[ ${1} == [c] ]]; then
			shift
			task-copy "${@}"
		elif [[ ${1} == [m] ]]; then
			shift
			task-move "${@}"
		elif [[ ${1} == [i] ]]; then
			shift
			task-insert "${@}"
		elif [[ ${1} == [p] ]]; then
			shift
			declare FILE=
			for FILE in "${@}"; do
				task read	project.is:${FILE}
				task-depends	project.is:${FILE}
				task view	project.is:${FILE}
			done
		elif [[ ${1} == [f] ]]; then
			shift
			task status.isnt:pending priority.any: read
			task status.isnt:pending priority.any: modify priority:
			task-flush \
				em.tasks.admin \
				em.tasks.opsmgr \
				em.tasks.track \
				"${@}"
		else
			declare COLS="$(tput cols)"
			declare LINE="$(tput lines)"
			declare LIMT="$((${LINE}-5))"
			declare OPTS="
				rc.gc=1
				rc.recurrence=1
				rc.verbose=label,affected
				rc.detection=0
				rc.defaultwidth=${COLS}
				rc.defaultheight=${LINE}
				rc.limit=${LIMT}
			"
#>>>			(cd ${PIMDIR} && ${GIT_STS} taskd tasks*)
#>>>			task tags status:pending
#>>>			task mark rc.gc=1 rc.recurrence=1
			if [[ ${1} == [,] ]]; then
				shift
				task view \
					${OPTS} \
					"${@}" 2>/dev/null
			elif [[ ${1} == [.] ]]; then
				shift
				task view \
					${OPTS} \
					project.isnt:em.opsmgr \
					project.isnt:em.tasks.opsmgr \
					project.isnt:em.tasks.track \
					area.isnt:computer \
					area.isnt:writing \
					tag.isnt:.waiting \
					"${@}" 2>/dev/null
			else
				task todo \
					${OPTS} \
					"${@}" 2>/dev/null
			fi
		fi
		return 0
	}
fi

################################################################################

if [[ "${-/i}" != "${-}" ]] && {
   [[ -f /.g/_data/zactive.workspace ]] ||
   [[ -f /.g/_data/zactive.workspace.config ]];
}; then
	echo -en "\n"
	echo -en "\e[37;44m"
	${LL} /.g/_data/zactive.workspace*
	echo -en "\e[0m"
fi

########################################

if [[ "${SCRIPT}" == ".bashrc" ]]; then
	${@}
	exit "${?}"
fi

################################################################################
# end of file
################################################################################
