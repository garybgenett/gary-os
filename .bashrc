#!/usr/bin/env bash
################################################################################
# bash configuration file
################################################################################
#>>> set -e		# exit on any failure
#>>> set -u		# exit on undeclared variables
#>>> set -o pipefail	# return value of all commands in a pipe
#>>> set -x		# command tracing
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

export HOME="$(realpath ${HOME})"

if [[ "${-/i}" != "${-}" ]]; then
	mkdir -p ${HOME}/.history/screen	2>/dev/null
	mkdir -p ${HOME}/.history/shell		2>/dev/null

	export SCREENDIR="${HOME}/.screen"
	mkdir -p ${SCREENDIR}			2>/dev/null
	chown -R ${USER}:root ${SCREENDIR}	2>/dev/null
	chmod -R 700 ${SCREENDIR}		2>/dev/null
fi

################################################################################
# variables
################################################################################

export _BASHED="true"

unset _SELF
unset SCRIPT
if [[ "${-/i}" == "${-}" ]]; then
	export _SELF="$(realpath -- "${0}")"
	export SCRIPT="$(basename -- "${_SELF}")"
fi
export UNAME="$(uname -s)"

export COMPOSER="/.g/_data/zactive/coding/composer/Makefile";	alias composer="make -f ${COMPOSER}"
export PIMDIR="/.g/_data/zactive/_pim"
export NULLDIR="/.g/_data/zactive/_zcache"
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

#>>>export CARCH="i686"
#>>>export CHOST="i686-pc-linux-gnu"
export CARCH="x86_64"
export CHOST="x86_64-pc-linux-gnu"

#>>>export CFLAGS="-march=i686 -mtune=i686 -m32 -O2 -ggdb -pipe"
#>>>export CFLAGS="-march=core2 -mtune=core2 -m64 -O2 -ggdb -pipe"
#>>>export CFLAGS="-march=core2 -mtune=core2 -O2 -pipe"
export CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,--hash-style=gnu -Wl,--as-needed"
export MAKEFLAGS="-j21"

export CCACHE_DIR="/tmp/.ccache"

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
if [[ -d /data/data/com.termux/files ]]; then
	export PATH="${PATH}:/data/data/com.termux/files/usr/bin"
	export PATH="${PATH}:/data/data/com.termux/files/usr/bin/applets"
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

if [[ ${HOSTNAME} == phoenix ]] ||
   [[ ${HOSTNAME} == spider ]]; then
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
if [[ -d /data/data/com.termux/files ]] &&
   [[ -z ${PROMPT} ]]; then
	export PROMPT="android"
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

export NICELY="sudo -E ionice -c 2 -n 7 -t nice -n 19"		; alias nicely="${NICELY}"
export REALTIME="sudo -E ionice -c 1 -n 0 -t nice -n -20"	; alias realtime="${REALTIME}"

if { [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; } ||
   [[ "${UNAME}" == "Darwin" ]] ||
   [[ -d /data/data/com.termux/files ]]; then
	export NICELY=
	export REALTIME=
fi

#>>> export NICELY=		; unalias nicely
#>>> export REALTIME=	; unalias realtime

########################################

export MORE="less -rX"						; alias more="${MORE}"
export VI="${REALTIME} vim -u ${HOME}/.vimrc -i NONE -p"	; alias vi="${VI}"
export GVI="prompt -d -x ; ${VI} -g"				; alias gvim="${GVI}"
export VIEW="${VI}"						; alias view="${VIEW}"
if [[ "${UNAME}" == "Darwin" ]]; then
	VI="${VI/#${REALTIME} }"				; alias vi="${VI}"
	GVI="${GVI/#prompt -d -x ; ${REALTIME} }"		; alias gvim="${GVI}"
	VIEW="${VI/#${REALTIME} }"				; alias view="${VIEW}"
fi

export PAGER="${MORE}"
export EDITOR="${VI}"
export VISUAL="${VI}"

########################################

export CP="cp -pvR"			; alias cp="${CP}"
export GREP="grep --color=auto -E"	; alias grep="${GREP}"
export LN="ln -fsv"			; alias ln="${LN}"
export MKDIR="mkdir -pv"		; alias mkdir="${MKDIR}"
export MV="mv -v"			; alias mv="${MV}"
export PS="ps u -ww --sort=pid -e"	; alias psl="${PS/ -ww}"
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

export DU="du -b --time --time-style=long-iso"			; alias du="${DU}"
export LU="${DU} -ak --max-depth 1"				; alias lu="${LU}"
export NCDU="ncdu --confirm-quit -2 -rr -x -e"			; alias ncdu="(sleep 2 && echo cmgg &); ${NCDU}"

########################################

export CVS="reporter cvs"			; alias cvs="${CVS}"
export SVN="reporter svn"			; alias svn="${SVN}"
export SVNSYNC="reporter svnsync"		; alias svnsync="${SVNSYNC}"

export GIT_TRACE="1"
export GIT_CMD="git"
export GIT="reporter ${GIT_CMD}"		#>>> ; alias git="${GIT}"
export GIT_ADD="${GIT} add --verbose --all"	; alias git-add="${GIT_ADD}"
export GIT_CMT="${GIT} commit --verbose"	; alias git-commit="${GIT_CMT}"
export GIT_STS="${GIT} status"			; alias git-status="${GIT_STS}"
export GIT_SVN="${GIT} svn"			; alias git-svn="${GIT_SVN}"

export DIFF_OPTS="-u -U10"
export GIT_DIF="--find-renames --full-index --summary --stat=128,128"
export GIT_FMT="${GIT_DIF} --pretty=fuller --date=iso --decorate"
export GIT_PAT="${GIT_DIF} --attach --binary --keep-subject"

########################################

export HTOPRC="${HOME}/.htoprc"
alias htop="${CP} -L ${HOME}/.htoprc.bak ${HOME}/.htoprc ; htop"

export LAST="last --system --fullnames --fulltimes --hostlast --ip"		; alias last="${LAST}"

export PV="pv --cursor --bytes --timer --progress --eta --rate --average-rate"	; alias pv="${PV}"
export XARGS="xargs --max-procs=2 --max-args=10"				; alias xargs="${XARGS}"

export XPDF="sudo -H -u plastic DISPLAY=:0 firefox"				; alias xpdf="${XPDF}"
export XPDF_READ="qpdfview"							; alias xpdf-read="${XPDF_READ}"

#>>>export RDP="rdesktop -z -n NULL -g 1024x768 -a 24 -r sound:remote"		; alias rdp="${RDP}"
#>>>export RDP="xfreerdp /dynamic-resolution /sound:sys:alsa"			; alias rdp="${RDP}"
export RDP="xfreerdp /dynamic-resolution /sound"				; alias rdp="${RDP}"
export VNC="vncviewer -Shared -FullColor"					; alias vnc="${VNC}"
export X2VNC="x2vnc -west -tunnel -shared -noblank -lockdelay 60 -timeout 60"	; alias x2vnc="${X2VNC}"

#>>>export VLC="vlc --intf ncurses --no-color"					; alias vlc-c="${VLC}"
export VLC="vlc --intf ncurses --no-color --no-playlist-tree"			; alias vlc-c="${VLC}"

########################################

unset EMERGE_DEFAULT_OPTS
export EMERGE="prompt -z emerge \
	--tree \
	--unordered-display \
	--deep \
	--newuse \
	--update \
	--selective=n \
"

alias emerge="${EMERGE}"

########################################

export ENCFS6_CONFIG="${ENCFS6_CONFIG:-/.g/_data/zactive/.static/.encfs/encfs6.primary.xml}"
export ENCFS_FILE="${ENCFS6_CONFIG/%xml/asc}"

#>>>	--verbose \
#>>>	--idle=60 \
export ENCFS="encfs \
	--nocache \
	--standard \
	--no-default-flags \
	--public"

alias encfs="${ENCFS}"

########################################

export UNISON="/.g/_data/-track/-unison"
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
#>>>	--fast-list \
export RCLONE_U="${RCLONE_C} sync \
	-vv \
	--config ${HOME}/.rclone.conf \
	--progress \
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
	--user-agent=Mozilla/5.0 \
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
alias zcode="cd /.g/_data/zactive/coding ; clear ; ${LL}"
alias zwrite="cd /.g/_data/zactive/writing ; clear ; ${LL}"
alias zplan="IMPERSONATE_NAME=task ${HOME}/.bashrc impersonate_command %"

alias s="run-mailcap"
alias x="cd / ; clear"
alias zdesk="cd ${NULLDIR} ; clear ; ${LL}"
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
alias synctail="${GREP} -a '^ERROR[:][ ]' /.g/_data/-track/-sync/_sync.log ; echo ; tail --follow /.g/_data/-track/-sync/_sync.log"

########################################

alias astatus="zstatus ; echo ; zstatus -l gdata/zactive ; echo ; (cd /.g/_data/zbackup && git-list | head -n10) ; echo ; estatus"
alias cal="cal --monday --three"
alias clean="_sync clean"
alias clock="clockywock"
alias dict="sdcv"
alias diskio="iostat -cdmtN -p sda,sdb,sdc,sdd 1"
alias emount="_sync upload mount"
alias estatus="_sync upload status"
alias ftp="lftp"
alias jokes="cd data.personal ; ${EDITOR} _jokes.txt ; ${LL} -t"
alias loopfile="dcfldd if=/dev/zero of=/tmp/loopfile bs=1k count=98288"
alias man="PAGER='less' man"
alias mozall="_sync _moz _save"
alias mozall-reset="_sync _moz _clone"
alias mozall-sync="_sync _moz _upload"
alias mozfox="_sync _moz _firefox"
alias mozfox-reset="_sync _moz _firefox _reset"
alias mozfox-view="_sync _moz _firefox _view"
alias mplayer="mplayer -fs"
alias pics="feh -. -Sname"
alias quote="cd data.personal ; ${EDITOR} _quotes.txt ; strfile _quotes.txt _quotes.txt.dat ; fortune _quotes.txt ; ${LL} -t"
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
alias torrent="rtorrent -n -d ./.torrent -s ./.torrent"
alias trust="_sync archive"
alias vlc-help="${VLC} --help --full-help --longhelp --advanced 2>&1 | ${MORE}"
alias vlc-play="${VLC} ${HOME}/setup/_misc/playlist.m3u"
alias web="w3m https://www.google.com"
alias workspace="_sync workspace"
alias wpa="ip-setup wpa"
alias zstatus="mount-zfs -! -?"

if [[ "${UNAME}" == "Darwin" ]]; then
	alias trust="/_install/_mac_osx.txt -r ; /_install/_mac_osx.txt -x ; /_install/_mac_osx.txt -s"
	alias workspace="/_install/_mac_osx.txt -w"
fi

################################################################################
# functions
################################################################################

function adb-run {
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

function date-string {
	date --iso=seconds |
		${SED} \
			-e "s|[-]([0-9]{2}[:]?[0-9]{2})$|T\1|g" \
			-e "s|[-:]||g" \
			-e "s|T|-|g"
	return 0
}

########################################

function dd {
	declare SRC="$((${#}-1))"	; SRC="${!SRC}"
	declare DST="${#}"		; DST="${!DST}"
	declare MAP="/tmp/.${FUNCNAME}-$(basename ${SRC})-$(basename ${DST}).mapfile"
	if [[ ${1} == --rescue ]]; then
		shift
		echo -en "\n"
		${LL} ${MAP}
		echo -en "\n"
		ddrescue --force --idirect --odirect "${@}" ${MAP}
	elif [[ ${1} == --dd ]]; then
		shift
		dd_rescue --alwayswrite "${@}"
	else
		dcfldd conv=noerror,notrunc "${@}"
	fi
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
	declare MUTT_X="${NULLDIR}/_mutt_mail"
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
	declare TMPFILE="${NULLDIR}/_mutt_copy"
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

function enc-fs {
	declare DST="${#}"; DST="${!DST}"
	declare OUT=
	if [[ ! -f ${ENCFS_FILE} ]]; then
		echo -en "${FUNCNAME}: "
		read -s OUT
		echo -en "\n"
	else
		OUT="$(gpg --decrypt ${ENCFS_FILE} 2>/dev/null)"
	fi
	mount-robust -u ${DST}
	echo "${OUT}" | (${ENCFS} -f --stdinpass "${@}") &
	sleep 1
	if [[ -z $(${GREP} "encfs[ ]${DST}[ ]fuse.encfs" /proc/mounts) ]]; then
		echo -en "${FUNCNAME}: failed!"
		echo -en "\n"
		return 1
	fi
	return 0
}

########################################

function enc-rsync {
	if [[ ${1} == -c ]]; then
		shift
		lsof | ${GREP} "^encfs" | ${GREP} "${@}"
		return 0
	fi
	declare SRC="${1}" && shift
	declare DST="${1}" && shift
	if [[ -z ${SRC} ]] || [[ -z ${DST} ]]; then
		return 1
	fi
	declare FAIL="false"
	declare MNT="/mnt/.${FUNCNAME}/$(basename ${SRC})"
	${MKDIR} ${MNT}				|| return 1
	enc-fs -o ro --reverse ${SRC} ${MNT}	|| return 1
	${RSYNC_U} "${@}" ${MNT}/ ${DST}	|| FAIL="true"
	mount-robust -u ${MNT}			|| FAIL="true"
	${FAIL}					&& return 1
#>>>	${RM} ${MNT}
	return 0
}

########################################

function enc-sshfs {
	declare RWR="ro"
	if [[ ${1} == -r ]]; then
		RWR="rw"
		shift
	fi
	declare UMT="false"
	if [[ ${1} == -u ]]; then
		UMT="true"
		shift
	fi
	declare SRC="${1}" && shift
	declare DST="${1}" && shift
	declare TGT=
	if [[ ${1} == [+]+(*) ]]; then
		TGT="/${1/#+}" && shift
	fi
	if [[ -z ${SRC} ]] || [[ -z ${DST} ]]; then
		return 1
	fi
	declare MNT="/mnt/.${FUNCNAME}/$(basename ${DST})"
	if ! ${UMT}; then
		${MKDIR} ${MNT}
		if [[ -z $(${GREP} "${SRC}[ ]${MNT}[ ]fuse.sshfs" /proc/mounts) ]]; then
			(sshfs -f -o ${RWR} ${SRC} ${MNT}) &
		fi
		sleep 1
		if [[ -z $(${GREP} "${SRC}[ ]${MNT}[ ]fuse.sshfs" /proc/mounts) ]]; then
			return 1
		fi
		${MKDIR} ${MNT}${TGT}			|| return 1
		enc-fs -o ${RWR} ${MNT}${TGT} ${DST}	|| return 1
	else
		mount-robust -u ${DST}			|| return 1
		mount-robust -u ${MNT}			|| return 1
#>>>		${RM} ${MNT}
	fi
	${GREP} "^${SRC}[ ]${MNT}[ ]fuse.sshfs"		/proc/mounts
	${GREP} "^encfs[ ]${DST}[ ]fuse.encfs"		/proc/mounts
	return 0
}

########################################

function enc-status {
	declare CMD="ssh -o LogLevel=INFO ${ENCFS_HOST:-ssh@example.net}"
	declare ELS="${1}" && shift
	declare EDU="${1}" && shift
	ELS+=" .ssh .zfs .zfs/*"
#>>>	EDU+=" .ssh .zfs .zfs/* .zfs/snapshot/*"
	echo -en "\n"
	${CMD} "pwd" || return 1
	echo -en "\n"
	${CMD} "quota" #>>> 2>/dev/null
	echo -en "\n"
	${CMD} "${LL/--color=auto --time-style=long-iso } ./ ${ELS}" #>>> 2>/dev/null
	echo -en "\n"
	#>>>		${CMD} "find ./ -mindepth 1 -maxdepth 2 -type d" 2>/dev/null ; \
	${CMD} "du -cms $(
		echo "$(
			echo -en "${EDU// /\\\n}\n" ; \
			echo -en "\n" ; \
			${CMD} "find ./ -mindepth 1 -maxdepth 2 -type d" ; \
		)" \
			| ${SED} \
				-e "s|^[[:space:]]+||g" \
				-e "s|^[.][/]||g" \
				-e "/^$/d" \
			| sort -u \
			| tr '\n' ' ' \
	)" #>>> 2>/dev/null
	${CMD} "id"
	return 0
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
	elif [[ ${1} == -f ]]; then
		shift
		mkfs.exfat "${@}"
	elif [[ ${1} == -n ]]; then
		shift
		mkfs.ntfs -vI "${@}"
	elif [[ ${1} == -l ]]; then
		shift
		# https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encryption_options_for_LUKS_mode
		cryptsetup --verbose --type luks2 --sector-size 4096 --cipher aes-xts-plain64 --key-size 256 --hash sha256 luksFormat "${@}"
	elif [[ ${1} == -s ]]; then
		shift
		# https://openzfs.org/wiki/Performance_tuning#Alignment_shift
		zpool create -o ashift=12 "${@}"
	else
		# https://bbs.archlinux.org/viewtopic.php?pid=1627961#p1627961
		# for b in /sys/block/*/*/start; do s=$(cat $b); echo $b : $s: $(($s % 8)) : $(($s % 4096)); done
		mkfs.ext4 -b 4096 -jvm 0 "${@}"
	fi
}

########################################

function git {
	declare WORK="$(realpath "${PWD}")"
	declare REPO="$(realpath "${PWD}.git")"
	if [[ ! -d ${REPO} ]]; then
		if [[ -d ${WORK}/.git ]] || [[ -f ${WORK}/.git ]]; then
			REPO="${WORK}/.git"
		elif [[ ${WORK/%.git} != ${WORK} ]]; then
			REPO="${WORK}"
		fi
	fi
	${NICELY} $(which git) --git-dir="${REPO}" --work-tree="${WORK}" "${@}"
}

########################################

function git-am {
	${GIT} -c gc.auto=0 am \
		--ignore-space-change \
		--ignore-whitespace \
		--whitespace="nowarn" \
		"${@}"
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
		index-dir -0 ${DIR} -r "${@}"
		return 0
	fi
	echo -en "* -delta\n" >${DIR}/.gitattributes
	if [[ "${1}" == -! ]]; then
		shift
	else
		index-dir -0 ${DIR} $(
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
	if [[ ${1} == -d ]]; then
		shift
		vdiff ${1}{,.git-check-new}
		return 0
	fi
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

function git-fsck {
	${GIT} fsck --verbose --full --no-reflogs --strict	|| return 1
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
	git-fsck									|| return 1
	return 0
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

	if [[ -n $(ls ${EXP_DIR}/[_a-z]*.gitlog/new/* 2>/dev/null) ]]; then
		(cd ${EXP_DIR} &&
			${EXP_PRE_PROC} ${EXP_DIR}/[_a-z]*.gitlog/new/*
		)						|| return 1
	fi
	for FILE in $(
		sort_by_date ${EXP_DIR}/[_a-z]*.gitlog/new/*
	); do
		(cd ${EXP_DIR}/.${EXP_NAM} && git-am ${FILE})	|| return 1
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

function git-patch {
	${GIT} format-patch ${GIT_PAT} ${DIFF_OPTS} "${@}"
}

########################################

function git-perms {
	if [[ -n ${@} ]]; then
		declare USERNAME="${1}" && shift
		chown -R ${USERNAME}:plastic ./
		find ./ -type d -exec chmod 755 {} \;
		find ./ -type f -exec chmod 644 {} \;
		chmod 755 $(find ./ | ${GREP} "Makefile") ${@}
	else
		${GIT_CMD} diff ${GIT_DIF} ${DIFF_OPTS} -R "${@}" |
			${GREP} "^(diff|(old|new) mode)" |
			${GIT_CMD} apply
	fi
	${GIT_STS}
}

########################################

function git-purge {
	declare DIR="$(realpath "${PWD}")"
	declare MEM_DIR="/dev/shm"
	declare PURGE="${1}" && shift
	if [[ -z "$(echo -en "${PURGE}" | ${GREP} "[0-9a-f]{40}")" ]]; then
		PURGE="$(${GIT_CMD} rev-parse "HEAD~$((${PURGE}-1))")"
	fi
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

function git-remove {
	declare FILTER="git rm -fr --cached --ignore-unmatch ${@}"
	${GIT} filter-branch --index-filter "${FILTER}" HEAD
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

function hd-sn-list {
	for FILE in $(fdisk -l 2>&1 | ${SED} -n "s|^Disk[ ]([/][^:]+)[:].+$|\1|gp" | ${GREP} -v "/dev/mapper"); do
		echo -en "${FILE}:"
		FILE="$(hdparm -I ${FILE} 2>&1 | ${SED} -n "s|^.+Serial Number[:][[:space:]]+(.+)$|\1|gp")"
		if [[ -n ${FILE} ]]; then
			echo -en " ${FILE}"
		fi
		echo -en "\n"
	done
	return 0
}

########################################

function hist-grep {
	if [[ ${1} == -l ]]; then
		shift
		export HIST_DATES="."
		export HIST_FINDS="."
		if [[ -n $(echo "${1}" | ${GREP} "^[][(|)^.*0-9T:+-]+$") ]]; then
			HIST_DATES="${1}" && shift
		fi
		if [[ -n ${1} ]]; then
			HIST_FINDS="${1}" && shift
		fi
		echo "DATES: ${HIST_DATES}"
		echo "FINDS: ${HIST_FINDS}"
		cat ${HOME}/.history/shell/${HOSTNAME}.${USER}.$(basename ${SHELL}).* |
			perl -e '
				use strict;
				use warnings;
				use POSIX qw(strftime);
				my $history = do { local $/; <STDIN> };
				while (${history} =~ m|^#([0-9]{10})\n([^\n]+)|gms) {
					my $datetime = strftime("%Y-%m-%dT%H:%M:%S%z", localtime(${1}));
					my $command = ${2};
					if (
						(${datetime} =~ m/${ENV{HIST_DATES}}/) &&
						(${command} =~ m/${ENV{HIST_FINDS}}/)
					) {
						print "${datetime} ${command}\n";
					};
				};
			' -- "${@}" |
			sort |
			${GREP} -a "${@}" -e "${HIST_FINDS/#^/\ }"
	else
		${GREP} "${@}" ${HOME}/.history/shell/${HOSTNAME}.${USER}.$(basename ${SHELL}).* |
			cut -d: -f2- |
			sort |
			uniq --count |
			sort --numeric-sort |
			${GREP} -a "${@}"
	fi
}

########################################

function index-dir {
	declare INDEX_D="${PWD}"
	declare N_FILES="$((3+1))"
	declare INDEX_N="$((0+${N_FILES}))"
	declare OPTION=
	declare QUICK="true"; declare QUICK_OPT=""
	declare SINGLE="false"
	[[ "${1}" == -q ]]		&& QUICK="false"			&& shift && QUICK_OPT="-q"
	[[ "${1}" == -0 ]]		&& SINGLE="true"			&& shift
	[[ "${1}" == +([0-9]) ]]	&& INDEX_N="$((${1}+${N_FILES}))"	&& shift
	[[ -d "${1}" ]]			&& INDEX_D="${1}"			&& shift
	[[ "${1}" == -[a-z] ]]		&& OPTION="${1}"			&& shift
	INDEX_D="$(realpath ${INDEX_D})"
	declare EXCL_PATHS=
	for FILE in "${@}"; do
		EXCL_PATHS="${EXCL_PATHS} \( -path \"./${FILE/#\.\/}\" -prune \) -o"
	done
	declare INDEX_I="${INDEX_D}/+index"
	declare CUR_IDX="${INDEX_I}/$(date-string)"
	declare CUR_LNK="${INDEX_I}/_current.txt"
	declare I_ERROR="${INDEX_I}/_error.log"
	declare I_USAGE="${INDEX_I}/_usage.txt"
	if [[ -n "${OPTION}" ]]; then
		if [[ -f ${INDEX_I} ]]; then
			cat ${INDEX_I}
		else
			cat ${CUR_LNK}
		fi |
		indexer ${QUICK_OPT} "${OPTION}" "${@}"
		return 0
	fi
	echo -en "\n"
	echo -en "${FUNCNAME}: ${INDEX_D}\n"
	if ${SINGLE}; then
		if ${QUICK}; then
			(cd ${INDEX_D} && \
				indexer ${QUICK_OPT} -0 "${@}"			2>&3 | ${PV} |
				cat				>${INDEX_I}	) 3>&2
			sort -t"\0" -k11 -o ${INDEX_I}		${INDEX_I}
		else
			(cd ${INDEX_D} && \
				(	eval find . ${EXCL_PATHS} -print	2>&3; [[ -n "${@}" ]] &&
					eval find "${@}" -type d -print		2>&3) | ${PV} -N find |
				sort						2>&3  | ${PV} -N sort |
				indexer ${QUICK_OPT} -0				2>&3  | ${PV} -N indx |
				cat				>${INDEX_I}	) 3>&2
		fi
	else
		${MKDIR} ${INDEX_I}
		cat /dev/null							>${I_ERROR}
		(cd ${INDEX_I} && \
			${LN} $(basename ${CUR_IDX}) ${CUR_LNK}			) 2>>${I_ERROR}
		if ${QUICK}; then
			(cd ${INDEX_D} && \
				indexer ${QUICK_OPT} "${@}"			2>&3 | ${PV} |
				cat				>${CUR_IDX}	) 3>>${I_ERROR}
			sort -t"\0" -k11 -o ${CUR_IDX}		${CUR_IDX}	>>${I_ERROR}
			(cd ${INDEX_D} && \
				eval ${NCDU} -1 \
					$(for FILE in "${@}"; do
						echo "--exclude \"${FILE/#\.\/}\""
					done) \
					-o			${I_USAGE}	) #>>> 2>>${I_ERROR}
		else
			(cd ${INDEX_D} && \
				(	eval find . ${EXCL_PATHS} -print	2>&3; [[ -n "${@}" ]] &&
					eval find "${@}" -type d -print		2>&3) | ${PV} -N find |
				sort						2>&3  | ${PV} -N sort |
				indexer ${QUICK_OPT}				2>&3  | ${PV} -N indx |
				cat				>${CUR_IDX}	) 3>>${I_ERROR}
			(cd ${INDEX_D} && \
				cat ${CUR_IDX} |
					indexer ${QUICK_OPT} -s	>${I_USAGE}	) 2>>${I_ERROR}
		fi
		if (( ${INDEX_N} > ${N_FILES} )); then
			(cd ${INDEX_I} && \
				${RM} $(ls -A | sort -r | tail -n+${INDEX_N})	) 2>>${I_ERROR}
		fi
	fi
	return 0
}

########################################

function indexer {
####################
#  1	type
#  2	target_type
#  3	empty		[0=empty, 1=non-empty]
#  4	uid
#  5	gid
#  6	octal_mode
#  7	size_in_bytes	[*=skipped]
#  8	mod_time_epoch
#  9	mod_time_iso
# 10	sha1sum		[*=skipped]
# 11	name
# 12	target
####################
#  1	type,target_type
#  2	inode
#  3	hard_links
#  4	char_mode,octal_mode
#  5	user:group,uid:gid
#  6	mod_time_iso,mod_time_epoch
#  7	blocks,size_in_b
#  8	size_in_b	[*,!,x]		(directories only)
#  9	md5_hash	[*,!,x]		(files only)
# 10	@d,@f		[*,!,-]		(directories and files only, denotes empty)
# 11	name
# 12	(target)
####################
	declare NULL_CHAR="*"
	declare HASH_TYPE="sha1sum"
	declare HASH_SIZE="40"
	declare HASH_NULL="$(eval printf "${NULL_CHAR}%.0s" {1..${HASH_SIZE}})"
	declare SED_DATE="([0-9]{4}[-][0-9]{2}[-][0-9]{2})"
	declare SED_TIME="([0-9]{2}[:][0-9]{2}[:][0-9]{2})"
	declare SED_NANO="([.][0-9]{10})"
	declare SED_ZONE="([A-Z]{3}|([+-][0-9]{2})([0-9]{2}))"
	declare FILE=
	declare DEBUG="false"
	declare QUICK="true"
	[[ "${1}" == -d ]] && DEBUG="true" && shift
	[[ "${1}" == -q ]] && QUICK="false" && shift
	if [[ "${1}" == -[a-z] ]] &&
	   [[ "${1}" != -m ]] &&
	   [[ "${1}" != -c ]] &&
	   (( "${#}" >= 2 )); then
		declare OPTION="${1}" && shift
		${FUNCNAME} \
			$(! ${QUICK} && echo "-q") \
			-m "${@}" \
		| ${FUNCNAME} \
			$(! ${QUICK} && echo "-q") \
			$(${DEBUG} && echo "-d") \
			"${OPTION}"
		return 0
	elif [[ "${1}" == -p ]]; then
		shift
		if ${QUICK}; then
			sort -u -t'\0' -k11 | tr '\0' '\t'
		else
			sort -u -t'\0' -k11 | tr '\0' '\t'
		fi
	elif [[ "${1}" == -m ]]; then
		shift
		DEBUG="${DEBUG}" QUICK="${QUICK}" perl -e '
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
					if(${ENV{QUICK}} eq "true"){
						if($a->[10] =~ m|${match}|){
							print "${_}\n";
						};
					}else{
						if($a->[10] =~ m|${match}|){
							print "${_}\n";
						};
					};
				};
			};
		' -- "${@}" || return 1
	elif [[ "${1}" == -l ]]; then
		shift
		DEBUG="${DEBUG}" QUICK="${QUICK}" perl -e '
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
				if(${ENV{QUICK}} eq "true"){
					if($a->[0] eq "d" && $a->[2] eq "0"){ push(@{$emp_dir}, $a); };
					if($a->[0] eq "f" && $a->[2] eq "0"){ push(@{$emp_fil}, $a); };
					if($a->[0] eq "l"){
						if($a->[1] eq "l"){ push(@{$brk_sym}, $a); };
						push(@{$symlink}, $a); };
					if($a->[9] =~ "FAILED"){ push(@{$failure}, $a); };
				}else{
					if($a->[9] eq "\@d"){ push(@{$emp_dir}, $a); };
					if($a->[9] eq "\@f"){ push(@{$emp_fil}, $a); };
					if($a->[0] eq "l,l"){ push(@{$brk_sym}, $a); };
					if($a->[0] =~ /l,/ ){ push(@{$symlink}, $a); };
					if($a->[7] eq "!"  ||
					   $a->[8] eq "!"  ||
					   $a->[9] eq "!"  ){ push(@{$failure}, $a); };
				};
			};
			print ">>> Empty directories: "	. ($#{$emp_dir} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$emp_dir}) { print "@{$out}\n"; }; };
			print ">>> Empty files: "	. ($#{$emp_fil} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$emp_fil}) { print "@{$out}\n"; }; };
			print ">>> Broken symlinks: "	. ($#{$brk_sym} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$brk_sym}) { print "@{$out}\n"; }; };
			print ">>> Symlinks: "		. ($#{$symlink} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$symlink}) { print "@{$out}\n"; }; };
			print ">>> Failures: "		. ($#{$failure} + 1) . "\n"; if (${ENV{DEBUG}} eq "true") { foreach my $out (@{$failure}) { print "@{$out}\n"; }; };
		' -- "${@}" || return 1
	elif [[ "${1}" == -s ]]; then
		shift
		DEBUG="${DEBUG}" QUICK="${QUICK}" perl -e '
			use strict;
			use warnings;
			my $tlds = [];
			my $subs = {};
			if(${ENV{QUICK}} eq "true"){
				exit(0);
			};
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
		if ${QUICK}; then
			if ! ${DEBUG}; then
				if [[ -f +${FUNCNAME}.failed ]]; then
					${RM} +${FUNCNAME}.failed
				fi
			fi
			tr '\0' '\t' | while read -r FILE; do
				declare CHK="$(echo -en "${FILE}" | cut -d'\t' -f10)"
				declare FIL="$(echo -en "${FILE}" | cut -d'\t' -f11)"
				if [[ ${CHK} == +([0-9a-f]) ]]; then
					if [[ $(${HASH_TYPE} "${FIL}" 2>/dev/null | ${SED} "s|[[:space:]].+$||g") == ${CHK} ]]; then
						if ${DEBUG}; then
							echo -en "CHECKING: ${FIL}\n"
						else
							echo -en "="
						fi
					else
						if ${DEBUG}; then
							echo -en "FAILED: ${FIL}\n" 1>&2
						else
							echo -en "!"
							echo "${FILE}" | tr '\t' '\0' >>+${FUNCNAME}.failed
						fi
					fi
				fi
			done
			if ! ${DEBUG}; then
				echo -en "\n"
				if [[ -f +${FUNCNAME}.failed ]]; then
					echo -en "\n"
					cat +${FUNCNAME}.failed | ${FUNCNAME} -d $(if ! ${QUICK}; then echo "-q"; fi) -v
				fi
			fi
		else
			tr '\0' '\t' | while read -r FILE; do
				declare MD5="$(echo -en "${FILE}" | cut -d'\t' -f9)"
				declare FIL="$(echo -en "${FILE}" | cut -d'\t' -f11)"
				if [[ "${MD5}" != "${NULL_CHAR}" ]] &&
				   [[ "${MD5}" != "!" ]] &&
				   [[ "${MD5}" != "x" ]]; then
					echo "${MD5}  ${FIL}"
				fi
			done | ${NICELY} md5sum -c -
		fi
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
			declare    TARGET="$(echo -en "${FILE}" | cut -d'\t' -f11)"
			declare IDX__TYPE="$(echo -en "${FILE}" | cut -d'\t' -f1 | cut -d, -f1)"
			declare IDX_EMPTY="$(echo -en "${FILE}" | cut -d'\t' -f10)"
			if ${QUICK}; then
				   TARGET="$(echo -en "${FILE}" | cut -d'\t' -f11)"
				IDX__TYPE="$(echo -en "${FILE}" | cut -d'\t' -f1)"
				IDX_EMPTY="$(echo -en "${FILE}" | cut -d'\t' -f3)"
				if [[ "${IDX__TYPE}" == "d" ]] && [[ "${IDX_EMPTY}" == "${NULL_CHAR}0" ]]; then
					IDX_EMPTY="@d"
				fi
			fi
			if [[ -e "${TARGET}" ]] ||
			   [[ "${IDX_EMPTY}" == "@d" ]]; then
				declare IDX_CHMOD="$(echo -en "${FILE}" | cut -d'\t' -f4 | cut -d, -f2)"
				declare IDX_CHOWN="$(echo -en "${FILE}" | cut -d'\t' -f5 | cut -d, -f2)"
				declare IDX_TOUCH="$(echo -en "${FILE}" | cut -d'\t' -f6 | cut -d, -f2 | ${SED} "s/^/@/g")"
				if ${QUICK}; then
					IDX_CHMOD="$(echo -en "${FILE}" | cut -d'\t' -f6)"
					IDX_CHOWN="$(echo -en "${FILE}" | cut -d'\t' -f4):$(echo -en "${FILE}" | cut -d'\t' -f5)"
					IDX_TOUCH="$(echo -en "${FILE}" | cut -d'\t' -f8 | ${SED} "s/^/@/g")"
				fi
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
					echo -en "${NULL_CHAR}"
					echo "${FILE}" | tr '\t' '\0' >>+${FUNCNAME}.missing
				fi
			fi
		done
		if ! ${DEBUG}; then
			echo -en "\n"
			for FILE in errors missing; do
				if [[ -f +${FUNCNAME}.${FILE} ]]; then
					echo -en "\n"
					cat +${FUNCNAME}.${FILE} | ${FUNCNAME} -d $(if ! ${QUICK}; then echo "-q"; fi) -r
				fi
			done
		fi
	elif [[ "${1}" == -c ]]; then
		shift
		declare TMP="$(mktemp /tmp/${FUNCNAME}.XXX 2>/dev/null)"
		declare OLD="${1}" && shift
		declare NEW="${1}" && shift
		diff -a ${OLD} ${NEW} |
			cut -d "" --output-delimiter=" " $(
				if ${QUICK}; then
					echo "-f1,2,9-"
				else
					echo "-f1,6,9-"
				fi
			) \
			>${TMP}
		${VIEW} -- ${TMP}
		${RM} ${TMP}
	elif [[ "${1}" == -du ]]; then
		shift
		DEBUG="${DEBUG}" QUICK="${QUICK}" perl -e '
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
		DEBUG="${DEBUG}" QUICK="${QUICK}" perl -e '
			while(<>){
				chomp();
				# \000 = null character
				# \042 = double quote
				# \047 = single quote
				if(${_} =~ m|([^A-Za-z0-9 \000\042\047 \(\)\[\]\{\} \!\#\$\%\&\*\+\,\/\:\;\=\?\@\^\~ _.-])|){
					print "[$1]: ${_}\n";
				};
			};
		' -- "${@}" || return 1
	else
		declare FORKS="true"
		if [[ "${1}" == -0 ]]; then
			FORKS="false"
			shift
		fi
		if ${QUICK}; then
			eval find ./ \
				$(for FILE in "${@}"; do
					echo "\\( -path \"./${FILE/#\.\/}\" -prune \\) -o"
				done) \
				\\\( \
					-printf \"%y\\\0%Y\" \
					\\\( \
						\\\( -empty -printf \"\\\0${NULL_CHAR}\\\060\" \\\) -or \
						\\\( -printf \"\\\0${NULL_CHAR}\\\061\" \\\) \
					\\\) \
					-printf \"\\\0%U\\\0%G\\\0%m\" \
					\\\( \
						\\\( \
							$(if ${FORKS}; then echo "-true"; else echo "-false"; fi) \
							-printf \"\\\0%s\" \
						\\\) -or \\\( \
							-printf \"\\\0${NULL_CHAR}\" \
						\\\) \
					\\\) \
					-printf \"\\\0%T@\\\0%TY%Tm%Td-%TH%TM%TS%Tz\" \
					\\\( \
						\\\( \
							$(if ${FORKS}; then echo "-true"; else echo "-false"; fi) \
							-type f -printf \"\\\0\" -exec ${HASH_TYPE} \\\{\\\} \\\; \
						\\\) -or \\\( \
							-printf \"\\\0${NULL_CHAR}\\\0%p\" \
							\\\( \
								\\\( -type l -printf \"\\\0%l\\\n\" \\\) -or \
								\\\( -printf \"\\\n\" \\\) \
							\\\) \
						\\\) \
					\\\) \
				\\\) \
				| ${SED} \
					-e "s|([0-9a-f]{${HASH_SIZE}})[[:space:]]+([.][/])|\1\x00\2|g" \
					-e "s|([0-9]{8}[-][0-9]{6})${SED_NANO}|\1|g"
		else
			function get_output {
				if ${FORKS}; then
					#>>> this is a really hugly hack... where did these garbage characters come from?
					#>>> sed fix is below
					echo -en ">>>"
					${NICELY} "${@}" "${FILE}" 2>/dev/null | ${SED} -e "s/^[^0-9a-f]+//g" -e "s/[[:space:]].+$//g"
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
				declare SIZE="${NULL_CHAR}"
				declare HASH="${NULL_CHAR}"
				declare NULL="${NULL_CHAR}"
				test -d "${FILE}" -a ! -L "${FILE}"	&& SIZE="$(get_output du -bs)" && NULL="$(get_null d)"
				test -f "${FILE}" -a ! -L "${FILE}"	&& HASH="$(get_output md5sum)" && NULL="$(get_null f)"
				test -z "${SIZE}"			&& SIZE="!"
				test -z "${HASH}"			&& HASH="!"
				test -z "${NULL}"			&& NULL="!"
				${NICELY} find "${FILE}" \
					-maxdepth 0 \
					-printf "%y,%Y\0%i\0%n\0%M,%m\0%u:%g,%U:%G\0%T+%Tz,%T@\0%k,%s\0${SIZE}\0${HASH}\0${NULL}\0%p\0(%l)\n" |
						${SED} \
							-e "s/>>>[^0-9a-f]*//g" \
							-e "s/${SED_TIME}${SED_NANO}/\1/g" \
							-e "s/${SED_DATE}[T+]${SED_TIME}${SED_ZONE}/\1T\2\4:\5/g"
			done
		fi
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
		$(date-string).txt
	prompt
#>>>	cd - >/dev/null
	return 0
}

########################################

function ldir {
	if [[ ${1} == -i ]]; then
		shift
		DIR="${PWD}"
		if [[ -d ${1} ]]; then
			DIR="${1}"
			shift
		fi
		(cd "${DIR}"; indexer) | indexer -p
	elif [[ ${1} == -t ]]; then
		shift
		tree -asF -hCD --du "${@}"
	else
		${LL} --color=always --recursive "${@}"
	fi | ${PAGER}
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

function mixer {
	if (( $(id -u) == 0 )); then
		sudo -H -u \#1000 ${HOME}/.bashrc ${FUNCNAME} "${@}"
		return 0
	fi
	declare MIXER_DAT="/proc/asound/cards"
	declare MIXER_DEV="/dev/mixer"
	declare MIXER_CMD="(pactl|pavucontrol)"
	declare MIXER_NUM="$(
		${SED} -n "s|^[^0-9]*([0-9]+).+$(
			${SED} -n "s|^.*${MIXER_DAT} = ([^\t]+)\t+([^\t]+)$|\1|gp" ${HOME}/.asoundrc |
			head -n1
		).*$|\1|gp" ${MIXER_DAT}
	)"
	declare MIXER_SNK="$(
		pactl list short sinks 2>/dev/null |
		${SED} -n "s|^([0-9]+).+$(
			${SED} -n "s|^.*${MIXER_DAT} = (.+)[[:space:]]+(.+)$|\2|gp" ${HOME}/.asoundrc |
			head -n1
		).*$|\1|gp"
	)"
	declare MIXER_SRC="$(
		pactl list short sources 2>/dev/null |
		${SED} -n "s|^([0-9]+).+$(
			${SED} -n "s|^.*${MIXER_DAT} = (.+)[[:space:]]+(.+)$|\2|gp" ${HOME}/.asoundrc |
			head -n1
		).*$|\1|gp"
	)"
	if [[ -n ${MIXER_NUM} ]]; then
		#>>> & == avoid delay on disk i/o
		sudo ${SED} -i "s%^(defaults.(pcm|ctl).card[[:space:]]+)([0-9]+)$%\1${MIXER_NUM}%g" ${HOME}/.asoundrc &
		if [[ ${MIXER_NUM} != 0 ]]; then
			MIXER_DEV+="${MIXER_NUM}"
		fi
	fi
	if {
		[[ -n ${MIXER_SNK} ]] &&
		[[ -n ${MIXER_SRC} ]];
	}; then
		#>>> pavucontrol
		#>>>	playback	= clients / sink-inputs
		#>>>	recording	= clients / source-outputs
		#>>>	output devices	= sinks
		#>>>	input devices	= sources
		pactl set-default-sink ${MIXER_SNK}
		pactl set-sink-mute ${MIXER_SNK} false
		for FILE in $(
			pactl list short sink-inputs |
			${SED} -n "s|^([0-9]+).+$|\1|gp"
		); do
			pactl move-sink-input ${FILE} ${MIXER_SNK}
			pactl set-sink-input-mute ${FILE} false
			pactl set-sink-input-volume ${FILE} "100%"
		done
		for FILE in $(
			pactl list short sources |
			${SED} -n "s|^([0-9]+).+$|\1|gp"
		); do
			pactl set-source-mute ${FILE} $(
				if [[ ${FILE} == ${MIXER_SRC} ]]; then
					echo "false"
				else
					echo "true"
				fi
			)
			pactl set-source-volume ${FILE} "100%"
		done
		for FILE in $(
			pactl list short clients |
			${GREP} -v "${MIXER_CMD}$" |
			${SED} -n "s|^([0-9]+).+$|\1|gp" |
			sort -nu
		); do
			for DIR in $(
				pactl list short source-outputs |
				${SED} -n "s|^([0-9]+).+[[:space:]]${FILE}[[:space:]].+$|\1|gp"
			); do
				pactl move-source-output ${DIR} ${MIXER_SRC}
				pactl set-source-output-mute ${DIR} false
				pactl set-source-output-volume ${DIR} "100%"
			done
		done
	fi
	if [[ ${1} == +([0-9]) ]]; then
		if [[ -n ${MIXER_SNK} ]]; then
			pactl set-sink-volume ${MIXER_SNK} "${1}%"
		fi
		aumix -d ${MIXER_DEV} -L -v ${1} -w ${1}
	elif [[ -n ${@} ]] && [[ ${1} != - ]]; then
		aumix -d ${MIXER_DEV} "${@}"
	elif [[ -z ${@} ]]; then
		aumix -d ${MIXER_DEV} -C ansi
	fi
	if [[ -n ${MIXER_SNK} ]]; then
		pactl list short clients
		pactl list sinks |
			${SED} -n "/^Sink[ ][#]${MIXER_SNK}/,/^$/p" |
			${GREP} --color=never -A1 "Volume"
	fi
	aumix -d ${MIXER_DEV} -q
	return 0
}

########################################

function mount-robust {
	echo -en "=== [Robust Mount: ${@}]\n"
	declare FINDMNT="findmnt --noheadings" #>>> --first-only"
	declare LSBLK="lsblk --noheadings --fs --output FSTYPE"
	declare DEBUG="false"
	declare TEST="false"
	declare RO=
	declare DM="false"
	declare OV="false"
	declare ZF="false"
	declare UN="false"
	declare DEV=
	declare DIR=
	if [[ ${1} == DEBUG ]]; then	DEBUG="true";	shift; fi
	if [[ ${1} == TEST ]]; then	TEST="true";	shift; fi
	if [[ ${1} == -0 ]]; then	RO="ro,";	shift; fi
	if [[ ${1} == -d ]]; then	DM="true";	shift; fi
	if [[ ${1} == -o ]]; then	OV="true";	shift; fi
	if [[ ${1} == -z ]]; then	ZF="true";	shift; fi
	if [[ ${1} == -u ]]; then	UN="true";	shift; fi
	if [[ -n ${1} ]]; then		DEV="${1}";	shift; fi
	if [[ -n ${1} ]]; then		DIR="${1}";	shift; fi
	if [[ ${DEV} == --dev ]]; then
		declare DEV_DIRS=(
			/dev
			/dev/pts
			/dev/shm
			/proc
			/sys
		)
		if [[ ! -d ${DIR} ]]; then
			echo -en "- <Target Is Not A Directory!>\n" 1>&2
			if [[ -n ${DIR} ]]; then
				${LL} -d ${DIR}
			fi
			return 1
		fi
		declare DEV_DIR=
		if ! ${UN} ]]; then
			${MKDIR} ${DIR}${DEV_DIR}
			for DEV_DIR in ${DEV_DIRS[@]}; do
				${FUNCNAME} ${DEV_DIR} ${DIR}${DEV_DIR}		|| return 1
			done
		else
			for DEV_DIR in $(eval echo "{$((${#DEV_DIRS[@]}-1))..0}"); do
				${FUNCNAME} -u ${DIR}${DEV_DIRS[${DEV_DIR}]}	|| return 1
			done
		fi
		return 0
	fi
	if ! ${TEST} && {
		{ [[ ! -b ${DEV} ]] && [[ ! -d ${DEV} ]] && [[ ! -f ${DEV} ]]; } ||
		{ [[   -f ${DEV} ]] && [[ ! -d ${DIR} ]] && ! ${UN}; } ||
		{ [[ ! -d ${DEV} ]] && [[ ! -f ${DEV} ]] && ${OV}; } ||
		{ [[ ! -d ${DIR} ]] && ! ${UN}; };
	}; then
		echo -en "- <Invalid Arguments!>\n" 1>&2
		if ! ${DEBUG}; then
			return 1
		fi
	fi
	declare IS_LUKS="false"
	declare LUKS_DEV="${DEV}"
	if cryptsetup isLuks ${DEV} >/dev/null 2>&1; then
		if ! ${TEST}; then
			DEV="/dev/mapper/$(basename ${DEV} 2>/dev/null)_crypt"
		fi
		echo -en "- (LUKS: ${DEV})\n" 1>&2
		IS_LUKS="true"
	fi
	declare DEV_SRC="$(${FINDMNT} --output SOURCE --source ${DEV} 2>/dev/null | tail -n1)"; declare	DEV_TGT="$(${FINDMNT} --output TARGET --source ${DEV} 2>/dev/null | tail -n1)"
	declare DIR_SRC="$(${FINDMNT} --output SOURCE --target ${DIR} 2>/dev/null | tail -n1)"; declare	DIR_TGT="$(${FINDMNT} --output TARGET --target ${DIR} 2>/dev/null | tail -n1)"
	if [[ -d ${DEV} ]]; then
		DEV_SRC="$(${FINDMNT} --output SOURCE --target ${DEV} 2>/dev/null | tail -n1)";		DEV_TGT="$(${FINDMNT} --output TARGET --target ${DEV} 2>/dev/null | tail -n1)"
	fi
	declare ZFS_CHECK_IMPORT="mount-zfs -?"
	declare ZFS_CHECK="mount-zfs -! -?"
	declare ZFS_PINT=
	declare ZFS_POOL=
	declare ZFS_MTPT=
	declare ZFS_LIVE=
	declare ZFS_STAT=
	declare IS_ZFS="false"
	if ${ZF}; then
		if ${UN} &&	${ZFS_CHECK}		${DEV} 2>&1 >/dev/null; then IS_ZFS="true"
		elif ! ${UN} &&	${ZFS_CHECK_IMPORT}	${DEV} 2>&1 >/dev/null; then IS_ZFS="true"
		fi
	fi
	if ${IS_ZFS}; then
		ZFS_PINT="$(${ZFS_CHECK} ${DEV} pint	2>/dev/null)"
		ZFS_POOL="$(${ZFS_CHECK} ${DEV} pool	2>/dev/null)"
		ZFS_MTPT="$(${ZFS_CHECK} ${DEV} mount	2>/dev/null)"
		ZFS_LIVE="$(${ZFS_CHECK} ${DEV} live	2>/dev/null)"
		ZFS_STAT="$(${ZFS_CHECK} ${DEV} state	2>/dev/null)"
	fi
	if [[ -b ${DEV} ]] && ${IS_ZFS}; then
		DEV_SRC="${DEV}"
		DEV_TGT="ZFS(${ZFS_POOL})"
	fi
	if [[ -d ${DEV} ]] && ${IS_ZFS}; then
		DEV_SRC="ZFS(${ZFS_POOL})"
		DEV_TGT="${ZFS_MTPT}"
	fi
	if [[ -d ${DIR} ]] && ${IS_ZFS}; then
		DIR_SRC="ZFS(${ZFS_POOL})"
		DIR_TGT="${ZFS_MTPT}"
	fi
	IS_OVLY="false"
	if ${OV} || [[ ${DEV_SRC} == overlay ]]; then
		DEV_SRC="$(${SED} -n "s|^overlay[ ]${DEV_TGT}[ ]overlay[ ].+lowerdir[=]([^:, ]+).*$|\1|gp" /proc/mounts)"
		echo -en "- (Overlay Mount)\n" 1>&2
		IS_OVLY="true"
	fi
	declare IS_ROOT="false"
	if ${IS_ZFS}; then
		if {
			[[ ${ZFS_MTPT} == / ]] ||
			{ [[ -b ${DEV} ]] && [[ ${DIR} == / ]]; };
		}; then
			IS_ROOT="true"
		fi
	elif {
#>>>		{ ! ${UN} &&	[[ -b ${DEV} ]] && [[ ${DEV_TGT} == / ]];	} ||
		{ ! ${UN} &&	[[ -d ${DIR} ]] && [[ ${DIR} == / ]];		} ||
		{ ${UN} &&	[[ -b ${DEV} ]] && [[ ${DEV_TGT} == / ]];	} ||
		{ ${UN} &&	[[ -d ${DEV} ]] && [[ ${DEV} == / ]];		};
	}; then
		echo -en "- (Root Filesystem)\n" 1>&2
		IS_ROOT="true"
	elif {
		{ ! ${UN} &&	[[ -b ${DEV} ]] && [[ ${DEV_TGT} == / ]];	};
	}; then
		echo -en "- <Remounting Root Device!>\n" 1>&2
		IS_ROOT="true"
	fi
	declare IS_MOUNT="false"
	if ${IS_ZFS}; then
		if {
			[[ ${ZFS_LIVE} == yes ]] &&
			[[ ${ZFS_STAT} == online ]] &&
			[[ ${DEV_TGT} == ${DIR_SRC} ]];
		}; then
			IS_MOUNT="true"
		fi
	elif {
#>>>		{ ! ${UN} &&	[[ -b ${DEV} ]] && [[ ${DEV} == ${DEV_SRC} ]];	} ||
		{ ! ${UN} &&	[[ -d ${DIR} ]] && [[ ${DIR} == ${DIR_TGT} ]];	} ||
		{ ${UN} &&	[[ -b ${DEV} ]] && [[ ${DEV} == ${DEV_SRC} ]];	} ||
		{ ${UN} &&	[[ -d ${DEV} ]] && [[ ${DEV} == ${DEV_TGT} ]];	};
	}; then
		echo -en "- (Mounted Filesystem)\n" 1>&2
		IS_MOUNT="true"
	elif {
		{ ! ${UN} &&	[[ -b ${DEV} ]] && [[ ${DEV} == ${DEV_SRC} ]];	};
	}; then
		echo -en "- <Remounting Mounted Device!>\n" 1>&2
		IS_MOUNT="true"
	fi
	if ${DEBUG}; then
		echo -en "- [Device Source: ${DEV_SRC}]\n"
		echo -en "- [Device Target: ${DEV_TGT}]\n"
		echo -en "- [Directory Source: ${DIR_SRC}]\n"
		echo -en "- [Directory Target: ${DIR_TGT}]\n"
	fi
	if ${TEST}; then
		declare DO_DEBUG="DEBUG"
		declare TEST_SRC="/mnt/.${FUNCNAME}/source"
		declare TEST_TGT="/mnt/.${FUNCNAME}/target"
		if [[ -z ${@} ]]; then
			declare PRINTF="%-20.20s %-30.30s %-30.30s %-30.30s %s\n"
			printf "${PRINTF}" "TEST"			"${FUNCNAME} TEST SRC_DEV"	"SRC_DIR"		"TGT_DIR"	"NOTES"
			printf "${PRINTF}" "normal"			"${FUNCNAME} TEST /dev/sdc3"	"${TEST_SRC}"		"${TEST_TGT}"
			printf "${PRINTF}" "mounted source"		"${FUNCNAME} TEST /dev/sdc3"	"${TEST_SRC}"		"${TEST_TGT}"	"mount /dev/sdc3 ${TEST_SRC}"
			printf "${PRINTF}" "mounted target"		"${FUNCNAME} TEST /dev/sdc3"	"${TEST_SRC}"		"${TEST_TGT}"	"mount /dev/sdc2 ${TEST_TGT}"
			printf "${PRINTF}" "root source"		"${FUNCNAME} TEST /dev/sda2"	"/"			"${TEST_TGT}"	"DANGEROUS"
			printf "${PRINTF}" "root target"		"${FUNCNAME} TEST /dev/sdc2"	"/.g/clone_root"	"/"		"DANGEROUS"
			printf "${PRINTF}" "bad source"			"${FUNCNAME} TEST /dev/sdz"	"/null"			"${TEST_TGT}"
			printf "${PRINTF}" "bad target"			"${FUNCNAME} TEST /dev/sdc3"	"${TEST_SRC}"		"/null"
			printf "${PRINTF}" "luks"			"${FUNCNAME} TEST /dev/sdc4"	"${TEST_SRC}"		"${TEST_TGT}"
			${MKDIR} ${TEST_SRC} ${TEST_TGT}
			return 1
		fi
		echo -en "\n"
		mount
		echo -en "\nDEVICE MOUNT:\n";				${FUNCNAME} ${DO_DEBUG} ${DEV} ${1}	|| echo -en "FAILED!\n"
		echo -en "\nDEVICE UMOUNT:\n";				${FUNCNAME} ${DO_DEBUG} -u ${DEV}	|| echo -en "FAILED!\n"
		echo -en "\nDIRECTORY MOUNT:\n";			${FUNCNAME} ${DO_DEBUG} ${DIR} ${1}	|| echo -en "FAILED!\n"
		echo -en "\nDIRECTORY UMOUNT:\n";			${FUNCNAME} ${DO_DEBUG} -u ${1}		|| echo -en "FAILED!\n"
		if [[ -b ${DEV} ]]; then
			echo -en "\nPROCESS MOUNT:\n";			${FUNCNAME} ${DO_DEBUG} ${DEV} ${1}	|| echo -en "FAILED!\n"; (cd ${1} && $(which sleep) 10) &
			echo -en "\nPROCESS UMOUNT (DEVICE):\n";	${FUNCNAME} ${DO_DEBUG} -u ${DEV}	|| echo -en "FAILED!\n"; sleep 5
			echo -en "\nPROCESS UMOUNT (DIRECTORY):\n";	${FUNCNAME} ${DO_DEBUG} -u ${1}		|| echo -en "FAILED!\n"; sleep 5
			echo -en "\nPROCESS UMOUNT:\n";			${FUNCNAME} ${DO_DEBUG} -u ${1}		|| echo -en "FAILED!\n"
		fi
		echo -en "\n"
		mount
		return 1
	fi
	if { {
		{ ! ${UN} && ${IS_MOUNT}; } && {
			{
				{ ! ${DM}; };
			};
		};
	} || {
		{ ${UN} && ! ${IS_MOUNT}; } && {
			{
				{ ! ${IS_LUKS} || [[ ! -b ${DEV} ]]; };
			} && {
				! ${IS_ZFS} ||
				[[ -z ${ZFS_PINT} ]];
			};
		};
	}; }; then
		echo -en "- <Nothing To Be Done.>\n" 1>&2
		return 0
	fi
	if ${UN}; then
		if ${IS_ROOT}; then
			echo -en "- <Will Not Unmount Root Filesystem!>\n" 1>&2
			return 1
		fi
		if ${IS_MOUNT}; then
			declare TRUE_DIR="${DEV}"
			if ${IS_ZFS}; then
				TRUE_DIR="${ZFS_MTPT}"
			elif [[ -b ${DEV} ]]; then
				TRUE_DIR="${DEV_TGT}"
			fi
			declare PROCESS="$(lsof | ${GREP} "[[:space:]]${TRUE_DIR}([/].+)?$")"
			if [[ -n ${PROCESS} ]]; then
				echo -en "- <Processes Still Running In Mount!>\n" 1>&2
				echo -en "${PROCESS}\n"
				return 1
			fi
			if ${IS_ZFS}; then
				if ! ${DEBUG}; then
					mount-zfs -u ${DEV}	|| return 1
				fi
			else
				echo -en "- Unmounting...\n"
				if ! ${DEBUG}; then
					umount -drv ${TRUE_DIR}	|| return 1
				fi
			fi
			if {
				[[ $(${FINDMNT} --output TARGET --target ${TRUE_DIR}	2>/dev/null | tail -n1) == ${TRUE_DIR} ]] ||
				[[ $(${ZFS_CHECK} ${DEV} live				2>/dev/null) == yes ]];
			}; then
				echo -en "- <Directory Is Still Mounted!>\n" 1>&2
				return 1
			fi
			if ${IS_OVLY}; then
				declare OVLY_DIR="${DEV_SRC}.${FUNCNAME}"
				if [[ -d ${DEV_TGT}/.${FUNCNAME} ]]; then
					OVLY_DIR="${DEV_TGT}/.${FUNCNAME}"
					${FUNCNAME} -u ${DEV_TGT}/.${FUNCNAME}/lowerdir
				fi
				declare FILES="$(find ${OVLY_DIR} -type f)"
				if [[ -n ${FILES} ]]; then
					echo -en "\n"
					${LL} -d ${OVLY_DIR}
					${LL} ${OVLY_DIR}
					echo -en "\n"
					${LL} -d ${OVLY_DIR}/upperdir
					${LL} ${OVLY_DIR}/upperdir
				else
					${RM} ${OVLY_DIR}
				fi
			fi
		fi
		if ${IS_ZFS}; then
			if ! ${DEBUG}; then
				mount-zfs -u ${DEV} || return 1
			fi
		fi
		if ${IS_LUKS} && [[ -b ${DEV} ]]; then
			echo -en "- Closing Encryption...\n"
			if ! ${DEBUG}; then
				cryptsetup luksClose ${DEV} || return 1
			fi
		fi
	else
		if ${IS_LUKS} && [[ ! -b ${DEV} ]]; then
			echo -en "- Opening Encrypton...\n"
			if ! ${DEBUG}; then
				cryptsetup luksOpen ${LUKS_DEV} $(basename ${DEV})	|| return 1
				cryptsetup luksDump ${LUKS_DEV}				|| return 1
				if ${ZFS_CHECK_IMPORT} ${DEV} 2>&1 >/dev/null | ${GREP} -v "Failed Detection"; then IS_ZFS="true"; fi
			fi
		fi
		if ${DM} || ! ${IS_MOUNT}; then
			if ! ${IS_ZFS}; then
				echo -en "- Mounting...\n"
			fi
			if ${DEBUG}; then
				return 0
			fi
			declare TYP="$(${LSBLK} ${DEV} 2>/dev/null | tail -n1)"
			declare OVERLAY=
			if ${OV}; then
				modprobe --all fuse overlay #>>> || return 1
				TYP="overlay overlay"
				declare LOWER_DIRS="${DEV}:${DIR}"
				if [[ -f ${DEV} ]]; then
					LOWER_DIRS="${DIR}/.${FUNCNAME}/lowerdir:${DIR}"
				fi
				while [[ -d ${1} ]]; do
					LOWER_DIRS+=":${1}"
					shift
				done
				OVERLAY="lowerdir=${LOWER_DIRS}"
				if [[ -z ${RO} ]]; then
					if [[ -f ${DEV} ]]; then
						${MKDIR} ${DIR}/.${FUNCNAME}/{lowerdir,upperdir,workdir}
						mount -o loop ${DEV} ${DIR}/.${FUNCNAME}/lowerdir
						OVERLAY+=",upperdir=${DIR}/.${FUNCNAME}/upperdir,workdir=${DIR}/.${FUNCNAME}/workdir"
					else
						${MKDIR} ${DEV}.${FUNCNAME}
						OVERLAY+=",upperdir=${DEV},workdir=${DEV}.${FUNCNAME}"
					fi
				elif [[ -f ${DEV} ]]; then
					OV="false"
				fi
			fi
			if [[ ${TYP} == exfat ]]; then
				modprobe --all fuse #>>> || return 1
			fi
			declare DID="false"
			if [[ ${TYP} == ext4		]]; then DID="true"; fsck -MV -t ${TYP} -pC	${DEV} || return 1; fi
			if [[ ${TYP} == exfat		]]; then DID="true"; fsck.${TYP}		${DEV} || return 1; fi
			if [[ ${TYP} == ntfs		]]; then DID="true"; fsck -MV -t ${TYP}-3g	${DEV} || return 1; fi
			if [[ ${TYP} == vfat		]]; then DID="true"; fsck -MV -t ${TYP}		${DEV} || return 1; fi
			if ! ${OV} && [[ -d ${DEV}	]]; then DID="true"; mount -v --bind ${RO:+-o ${RO/%,}}						"${@}" ${DEV} ${DIR} || return 1; fi
			if ! ${OV} && [[ -f ${DEV}	]]; then DID="true"; mount -v -o ${RO}loop							"${@}" ${DEV} ${DIR} || return 1; fi
			if ${OV}			]]; then DID="true"; mount -v -t ${TYP} -o ${OVERLAY}						"${@}"        ${DIR} || return 1; fi
			if [[ ${TYP} == ext4		]]; then DID="true"; mount -v -t ${TYP} -o ${RO}relatime,errors=remount-ro			"${@}" ${DEV} ${DIR} || return 1; fi
			if [[ ${TYP} == exfat		]]; then DID="true"; mount -v -t ${TYP} -o ${RO}relatime					"${@}" ${DEV} ${DIR} || return 1; fi
			if [[ ${TYP} == ntfs		]]; then DID="true"; mount -v -t ${TYP}-3g -o ${RO}relatime,errors=remount-ro,shortname=mixed	"${@}" ${DEV} ${DIR} || return 1; fi
			if [[ ${TYP} == vfat		]]; then DID="true"; mount -v -t ${TYP} -o ${RO}relatime,errors=remount-ro,shortname=mixed	"${@}" ${DEV} ${DIR} || return 1; fi
			if [[ ${TYP} == zfs_member	]]; then DID="true"; mount-zfs ${RO:+-0}							"${@}" ${DEV} ${DIR} || return 1; fi
			if ! ${DID}; then
				echo -en "- <Unknown Filesystem Type!>\n" 1>&2
				return 1
			fi
		fi
	fi
	return 0
}

########################################

function mount-zfs {
	declare ZFS_ROTATE="${ZFS_ROTATE:-true}"
	declare ZFS_KILLER="${ZFS_KILLER:-false}"
	declare ZFS_SNAPSHOTS="${ZFS_SNAPSHOTS:-0}"
	declare ZFS_PARAM_PRINTF="30"
	# /proc/spl/kstat/zfs/dbgmsg
	declare ZFS_DBG_ENB="1"				# default: 0
	declare ZFS_DBG_SIZ="$((100* 2**20))"		# default: 4194304
	# https://serverfault.com/questions/581669/why-isnt-the-arc-max-setting-honoured-on-zfs-on-linux
	declare ZFS_ARC_MIN="$(( (2**30) / 2 ))"	# default: dynamic	512M
	declare ZFS_ARC_MAX="$(( (2**30) * 2 ))"	# default: dynamic	2G
	# https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/ZFS%20on%20Linux%20Module%20Parameters.html#snapshot
	declare ZFS_ADMIN_SNAP="0"			# default: 1
	# https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/ZFS%20on%20Linux%20Module%20Parameters.html#zfs-initialize-value
	declare ZFS_INITIALIZE="0"			# default: 0xdeadbeef
	ZFS_INITIALIZE="0x$(uuidgen | ${SED} -e "s|[-]||g" -e "s|^([a-z0-9]{16}).+$|\1|g")"
	# https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/ZFS%20on%20Linux%20Module%20Parameters.html#resilver
	# https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/ZFS%20on%20Linux%20Module%20Parameters.html#scrub
	# https://www.svennd.be/tuning-of-zfs-module
	declare -A ZFS_PARAM
	ZFS_PARAM[TXG_TIME]="10";			ZFS_PARAM[TXG_TIME_DEF]="5"
	ZFS_PARAM[SLV_DDEF]="1";			ZFS_PARAM[SLV_DDEF_DEF]="0"
	ZFS_PARAM[SLV_MTMS]="5000";			ZFS_PARAM[SLV_MTMS_DEF]="3000"
	ZFS_PARAM[SCB_MTMS]="5000";			ZFS_PARAM[SCB_MTMS_DEF]="1000"
	ZFS_PARAM[VDV_SMNA]="32";			ZFS_PARAM[VDV_SMNA_DEF]="1"
	ZFS_PARAM[VDV_SMXA]="64";			ZFS_PARAM[VDV_SMXA_DEF]="2"
	declare Z_DATE="$(date-string)"
	declare Z_DREG="[-0-9]+"
	declare Z_IMPORT="zpool import -d /dev/disk/by-id -d /dev -N"
	declare Z_LIST="zpool list -H -P -v"
	declare Z_GET="zpool get -H -o value"
	declare Z_GET_ALL="zpool get -o all all"
	declare Z_DAT="zfs get -H -o value"
	declare Z_DAT_ALL="zfs get -o all all"
	declare Z_ZDB="zdb -l"
	declare Z_ZDB_META="zdb -u"
	declare Z_MOUNT="zfs mount -O"
	declare Z_IOINFO="zpool iostat -P -v"
	declare Z_STATUS="zpool status -P -v -i"
#>>>	declare Z_SNAPSHOT="zfs snapshot -r"
	declare Z_SNAPSHOT="zfs snapshot"
	declare Z_LIST_IDS="${Z_LIST} -g"
#>>>	declare Z_LIST_ALL="zfs list -r -t all -o name,type,creation,used,available,referenced,compressratio,version"
#>>>	declare Z_LIST_ALL="zfs list -r -t all -o name,type,creation,available,used,usedbydataset,usedbychildren,usedbysnapshots,usedbyrefreservation,quota,compressratio"
#>>>	declare Z_LIST_ALL="zfs list -r -t all -o name,type,creation,available,used,usedbydataset,usedbychildren,usedbysnapshots,usedbyrefreservation,quota,referenced,written,compressratio,mounted,createtxg,version"
	declare Z_LIST_ALL="zfs list -H -r -t all -o name"
	declare Z_LIST_INF="zfs list -r -t all -o name,type,creation,available,used,usedbydataset,compressratio,mounted,createtxg,version"
	declare Z_LIST_SIZ="zfs list -r -t all -o name,type,available,used,usedbydataset,usedbychildren,usedbysnapshots,usedbyrefreservation,quota,referenced,written"
	declare Z_LIST_BIT="zfs list -r -t all -p -o        available,used,usedbydataset,usedbychildren,usedbysnapshots,usedbyrefreservation,name"
	declare Z_FSEP="|"
	declare Z_PSEP=":"
	declare Z_DSEP="."
	declare ZOPTS=
	ZOPTS+=" compression=lz4"
	ZOPTS+=" canmount=noauto"
	ZOPTS+=" sharenfs=off"
	ZOPTS+=" sharesmb=off"
	ZOPTS+=" relatime=on"
	declare ZOPTS_DONE="${ZOPTS}"
	ZOPTS_DONE+=" mountpoint=none"
	ZOPTS_DONE+=" readonly=on"
	function zfs_import_pools {
		declare ZDEF="_DEF"
		if ${ZFS_KILLER}; then
			ZDEF=
		fi
		modprobe --all zfs >/dev/null 2>&1 #>>> || return 1
		declare ZPARAM="/sys/module/zfs/parameters"
		if [[ -d ${ZPARAM} ]]; then
			echo -en "${ZFS_DBG_ENB}"			>${ZPARAM}/zfs_dbgmsg_enable
			echo -en "${ZFS_DBG_SIZ}"			>${ZPARAM}/zfs_dbgmsg_maxsize
			echo -en "${ZFS_ARC_MIN}"			>${ZPARAM}/zfs_arc_min
			echo -en "${ZFS_ARC_MAX}"			>${ZPARAM}/zfs_arc_max
#>>>			echo -en "3"					>/proc/sys/vm/drop_caches
			echo -en "${ZFS_ADMIN_SNAP}"			>${ZPARAM}/zfs_admin_snapshot
			echo -en "${ZFS_INITIALIZE}"			>${ZPARAM}/zfs_initialize_value
			echo -en "${ZFS_PARAM[TXG_TIME${ZDEF}]}"	>${ZPARAM}/zfs_txg_timeout
			echo -en "${ZFS_PARAM[SLV_DDEF${ZDEF}]}"	>${ZPARAM}/zfs_resilver_disable_defer
			echo -en "${ZFS_PARAM[SLV_MTMS${ZDEF}]}"	>${ZPARAM}/zfs_resilver_min_time_ms
			echo -en "${ZFS_PARAM[SCB_MTMS${ZDEF}]}"	>${ZPARAM}/zfs_scrub_min_time_ms
			echo -en "${ZFS_PARAM[VDV_SMNA${ZDEF}]}"	>${ZPARAM}/zfs_vdev_scrub_min_active
			echo -en "${ZFS_PARAM[VDV_SMXA${ZDEF}]}"	>${ZPARAM}/zfs_vdev_scrub_max_active
		fi
		for FILE in $(${Z_IMPORT} 2>/dev/null | ${SED} -n "s|^[[:space:]]+pool[:][ ](.+)$|\1|gp"); do
			echo -en "- (ZFS Importing: ${FILE})\n" 1>&2
			${Z_IMPORT} ${FILE}		|| return 1
			zfs set ${ZOPTS_DONE} ${FILE}	|| return 1
		done
		return 0
	}
	function zfs_pool_status {
		if {
			${IS} &&
			! ${SL} && {
				[[ -z ${1} ]] ||
				[[ ${1} != ${ZDATA} ]];
			};
		}; then
			zfs_pool_info
			echo -en "\n"
			${Z_STATUS} "${@}"
			echo -en "\n"
			${Z_IOINFO} "${@}"
			echo -en "\n"
		fi
		if ${SL}; then
			${Z_LIST_INF} "${@}"
			echo -en "\n"
			${Z_LIST_SIZ} "${@}"
			echo -en "\n"
			${Z_DAT_ALL} -s local \
				| ${GREP} --color=never "^${1}" \
				| ${GREP} --color=never "[[:space:]]((ref)?reservation|quota)[[:space:]]"
			echo -en "\n"
			${Z_LIST_BIT/-t all/-t filesystem,volume} "${@}" |
				${GREP} -v "NAME" |
				sort -nr -k3 -k4 -k5 -k6
			echo -en "\n"
			declare -a TOTALS=(0 0 0 0 0 0 0)
			declare TOTAL="0"
			for DIR in 3 5 6; do
				for FILE in $(
					${Z_LIST_BIT/-t all/-t filesystem,volume} -H "${@}" |
					cut -d$'\t' -f${DIR}
				); do
					TOTALS[$DIR]="$((${TOTALS[$DIR]}+${FILE}))"
				done
				TOTAL="$((${TOTAL}+${TOTALS[$DIR]}))"
			done
			for DIR in {1..6}; do
				echo -en "${TOTALS[$DIR]} "
			done
			echo -en "= ${TOTAL}\n"
		elif ${SN}; then
			${Z_LIST_INF/-t all/-t filesystem,volume} "${@}"
			echo -en "\n"
			${Z_LIST_SIZ} "${@}"
		else
			${Z_LIST_INF/-t all/-t filesystem,volume} "${@}"
			echo -en "\n"
			${Z_LIST_SIZ/-t all/-t filesystem,volume} "${@}"
		fi
		return 0
	}
	function zfs_pool_info {
		${Z_GET_ALL} \
			| if [[ -n ${ZPOOL} ]]; then
				${GREP} --color=never "^${ZPOOL}"
			else
				cat
			fi \
			| ${GREP} --color=never "[-]$"
		if [[ -z ${ZPOOL} ]]; then
			echo -en "\n" 1>&2
		fi
		${Z_DAT_ALL} -s local \
			| ${GREP} --color=never "^[^[:space:]@]+[[:space:]]" \
			| if [[ -n ${ZPOOL} ]]; then
				${GREP} --color=never "^${ZPOOL}"
			else
				cat
			fi
		if [[ -n ${ZPOOL} ]]; then
			if [[ ${ZPINT} == ${ZPOOL} ]]; then
				${Z_ZDB_META} ${ZPOOL}
			else
				echo -en "- (ZFS Name: ${ZPINT} -> ${ZPOOL})\n" 1>&2
			fi
		fi
		return 0
	}
	declare IMPORT="true"
	declare IS="false"
	declare RO="false"
	declare UN="false"
	declare SL="false"
	declare SN="false"; declare SN_ALL="false"; declare SN_SKP=""; declare SN_OPT="-s"
	declare DEV=
	declare DIR=
	if [[ ${1} == -! ]]; then		IMPORT="false";	shift; fi
	if [[ ${1} == -[?] ]]; then		IS="true";	shift; fi
	if [[ ${1} == -0 ]]; then		RO="true";	shift; fi; if ${RO}; then ZFS_ROTATE="false"; fi
	if [[ ${1} == -u ]]; then		UN="true";	shift; fi; if ${UN}; then IMPORT="false"; fi
	if [[ ${1} == -l ]]; then		SL="true";	shift; fi; if ${SL}; then IMPORT="false"; fi
	if [[ ${1} == ${SN_OPT} ]]; then	SN="true";	shift; fi; if ${SN}; then IMPORT="false"; fi
		if ${SN} && [[ ${1} == -a ]]; then		SN_ALL="true"; shift; fi
		if ${SN} && [[ ${1} == - ]]; then		SN_SKP="${1}"; shift; fi
		if ${SN} && [[ ${1} == +([0-9]) ]]; then	ZFS_SNAPSHOTS="${1}"; shift; fi
	if [[ -n ${1} ]]; then			DEV="${1}";	shift; fi
	if [[ -n ${1} ]]; then			DIR="${1}";	shift; fi
	if { {
		[[ -z ${DEV} ]] ||
		{ [[ ! -b ${DEV} ]] && { ! ${IS} && ! ${UN}; }; } ||
		{ [[ ! -d ${DIR} ]] && { ! ${IS} && ! ${UN}; }; };
	} && {
		! { ! ${UN} && [[ -b ${DEV} ]] && [[ -n ${DIR} ]]; } &&
		! { ${SN} && ${SN_ALL}; } &&
		! { ${SN} && [[ -n ${DEV} ]]; };
	}; }; then
		if ${IS}; then
			if ${IMPORT}; then
				zfs_import_pools || return 1
			fi
			if ! ${SL}; then
				hd-sn-list
				echo -en "\n"
				for FILE in $(
					set | ${SED} -n "s|^.+[>][ ][$][{]ZPARAM[}]/([^;]+).*$|\1|gp" | sort -u
				); do
					printf "%-${ZFS_PARAM_PRINTF}.${ZFS_PARAM_PRINTF}s %s\n" "${FILE}" "$(cat /sys/module/zfs/parameters/${FILE})"
				done
				echo -en "\n"
			fi
			zfs_pool_status
			return 0
		else
			echo -en "- <ZFS: Invalid Arguments!>\n" 1>&2
		fi
		return 1
	fi
	if ${SN} && ${SN_ALL}; then
		declare FAIL="false"
		declare ZBEG="true"
		for FILE in $(
			${Z_LIST} 2>&1 | ${SED} -n "s|^([^[:space:]]+).+$|\1|gp"
		); do
			if ${ZBEG}; then
				ZBEG="false"
			else
				echo -en "\n"
			fi
			${FUNCNAME} ${SN_OPT} ${SN_SKP} ${ZFS_SNAPSHOTS} ${FILE} || FAIL="true"
		done
		if ${FAIL}; then
			return 1
		fi
		return 0
	fi
	if ${IMPORT}; then
		zfs_import_pools || return 1
	fi
	declare ZPOOL=
	declare ZPOOL_EXT="false"
	declare ZDEVS_DIR="$(${Z_ZDB}					${DIR}	2>/dev/null | ${SED} -n "s|^[ ]{4}name[:][ ][\'](.+)[\']$|\1|gp"			)"
	declare ZMTPT_DIR="$(${Z_DAT},name mountpoint			${DIR}	2>/dev/null | ${SED} -n "s|^${DIR}[[:space:]]+(.+)$|\1|gp"				)"
	declare ZPOOL_DIR="$(if [[ -n $(${Z_LIST}			${DIR}	2>/dev/null) ]]; then echo "${DIR}"; fi)"
	if {
		{ ! ${UN} && [[ -b ${DEV} ]] && [[ -n ${DIR} ]]; };
	}; then
		if	[[ -n ${ZDEVS_DIR} ]]; then ZPOOL_EXT="true"; ZPOOL="${ZDEVS_DIR}"
		elif	[[ -n ${ZMTPT_DIR} ]]; then ZPOOL_EXT="true"; ZPOOL="${ZMTPT_DIR}"
		elif	[[ -n ${ZPOOL_DIR} ]]; then ZPOOL_EXT="true"; ZPOOL="${ZPOOL_DIR}"
		fi
	fi
	if ${ZPOOL_EXT}; then DIR= ; fi
	if [[ -n ${ZPOOL} ]]; then echo -en ""
	elif [[ -b ${DEV} ]]; then ZPOOL="$(${Z_ZDB}			${DEV}	2>/dev/null | ${SED} -n "s|^[ ]{4}name[:][ ][\'](.+)[\']$|\1|gp"			)"
	elif [[ -d ${DEV} ]]; then ZPOOL="$(${Z_DAT},name mountpoint	${DEV}	2>/dev/null | ${SED} -n "s|^${DEV}[[:space:]]+(.+)$|\1|gp"				)"
	elif [[ -n $(${Z_LIST}						${DEV}	2>/dev/null) ]]; then ZPOOL="${DEV}"
	fi
	declare ZDATA="$(${Z_LIST_ALL/-t all/-t filesystem,volume}	${DEV}	2>/dev/null | ${GREP} -o "^${DEV}$" | ${GREP} "[/]"					)"
	if [[ -n ${ZDATA} ]]; then
		ZPOOL="$(echo "${ZDATA}" | ${SED} -n "s|^([^/]+)[/].*$|\1|gp")"
	fi
	declare ZDVID="$(${Z_ZDB}					${DEV}	2>/dev/null | ${SED} -n "s|^[ ]{4}guid[:][ ](.+)$|\1|gp"				)"
	declare ZNAME="$(echo "${ZPOOL}"					2>/dev/null | ${SED} "s|[${Z_DSEP}]${Z_DREG}$||g"					)"
	declare ZROOT="$(echo "${ZPOOL}"					2>/dev/null | ${SED} "s|([${Z_PSEP}]${Z_DREG})?([${Z_DSEP}]${Z_DREG})?$||g"		)"
	if {
		[[ -z $(${Z_LIST}		${ZPOOL}			2>/dev/null) ]] &&
		[[ -n $(${Z_LIST_IDS}		${ZNAME}			2>/dev/null | ${SED} -n "s|^[[:space:]]+(${ZDVID}).+$|\1|gp"				) ]];
	}; then
		ZPOOL="${ZNAME}"
	fi
	declare ZGUID="$(${Z_GET} guid		${ZPOOL}			2>/dev/null										)"
	declare ZDEVS=($(${Z_LIST}		${ZPOOL}			2>/dev/null | ${SED} -n "s|^[[:space:]]+(/dev/[^[:space:]]+).+$|\1|gp"			))
	declare ZDIDS=($(${Z_LIST_IDS}		${ZPOOL}			2>/dev/null | ${SED} -n "s|^[[:space:]]+([^[:space:]]+).+$|\1|gp"			))
	declare ZTIME="$(${Z_ZDB_META}		${ZPOOL}			2>/dev/null | ${SED} -n "s|^[[:space:]]+timestamp[ ][=][ ]([^ ]+)[ ].+$|\1|gp"		)"
	declare ZMTPT="$(${Z_DAT} mountpoint	${ZPOOL}			2>/dev/null										)"
	declare ZLIVE="$(${Z_DAT} mounted	${ZPOOL}			2>/dev/null										)"
	declare ZMEMBER="false"
	declare ZDEVICE="${DEV}"
	if (( ${#ZDIDS[@]} > 1 )); then ZDIDS=("${ZDIDS[@]:1}"); fi
	if [[ -n ${ZDIDS[@]} ]]; then
		for FILE in $(eval echo "{0..$((${#ZDIDS[@]}-1))}"); do
			if [[ ${ZDIDS[${FILE}]} == ${ZDVID} ]]; then
				ZMEMBER="true"
				ZDEVICE="${ZDEVS[${FILE}]}"
				break
			fi
		done
	fi
	if [[ -n ${ZTIME} ]]; then ZTIME="$(date --iso=seconds --date="@${ZTIME}")"; fi
	declare ZSTAT="$(${Z_STATUS}		${ZPOOL}			2>/dev/null | ${SED} -n "s|^[[:space:]]+${ZDEVICE}[[:space:]]+([A-Z]+).+$|\1|gp"	)"
	ZSTAT="${ZSTAT,,}"
	declare ZPINT_Z="$(${Z_ZDB}		${ZDEVS[0]}			2>/dev/null | ${SED} -n "s|^[ ]{4}name[:][ ][\'](.+)[\']$|\1|gp"			)"
	declare ZPINT="$(${Z_ZDB}		${ZDEVICE}			2>/dev/null | ${SED} -n "s|^[ ]{4}name[:][ ][\'](.+)[\']$|\1|gp"			)"
	declare ZMNAM="${ZPOOL}${Z_DSEP}${Z_DATE}"
	declare ZDNAM="${ZNAME}${Z_DSEP}${Z_DATE}"
	declare ZPNAM="${ZROOT}${Z_PSEP}${Z_DATE}"
	declare ZTYPE=
	if {
		[[ -n $(${Z_LIST_ALL/-t all/-t filesystem},type ${ZDATA} 2>/dev/null | ${SED} -n "s|^(${ZDATA})[[:space:]]filesystem$|\1|gp") ]];
	}; then
		ZTYPE="dataset"
	elif {
		[[ -n $(${Z_LIST_ALL/-t all/-t volume},type ${ZDATA} 2>/dev/null | ${SED} -n "s|^(${ZDATA})[[:space:]]volume$|\1|gp") ]];
	}; then
		ZTYPE="volume"
	elif {
		[[ ${ZPOOL} == ${DEV} ]] ||
		[[ ${ZPINT} == ${DEV} ]];
	}; then
		ZTYPE="pool"
	elif {
		${ZMEMBER};
	}; then
		if [[ ${ZDIDS[0]} == ${ZDVID} ]]; then
			ZTYPE="primary"
		else
			ZTYPE="member"
		fi
	elif {
		[[ -b ${DEV} ]] &&
		[[ -n ${ZPOOL} ]];
	}; then
		ZTYPE="device"
	elif {
		[[ ${ZMTPT} == ${DEV} ]];
	}; then
		ZTYPE="mount"
	else
		echo -en "- <ZFS: Failed Detection!>\n" 1>&2
		return 1
	fi
	if { ${IS} || ${SN}; }; then					echo -en "- (ZFS ${ZTYPE^}: ${ZPOOL})\n" 1>&2
		if { [[ ${ZMTPT} == / ]] || [[ ${DIR} == / ]]; }; then	echo -en "- (ZFS: Root Filesystem)\n" 1>&2
		fi
		if [[ ${ZLIVE} == yes ]]; then				echo -en "- (ZFS: Mounted Filesystem)\n" 1>&2
		elif [[ ${ZTYPE} != filesystem ]]; then			echo -en "- (ZFS: Exported Filesystem)\n" 1>&2
		else							echo -en "- (ZFS: Detected Filesystem)\n" 1>&2
		fi
	fi
	if ${IS}; then
		if [[ -n ${DIR} ]]; then
			if [[ ${DIR} == all ]] || [[ ${DIR} == pint	]]; then echo -en "${ZPINT_Z}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == pool	]]; then echo -en "${ZPOOL}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == name	]]; then echo -en "${ZNAME}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == root	]]; then echo -en "${ZROOT}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == guid	]]; then echo -en "${ZGUID}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == devs	]]; then echo -en "${ZDEVS[@]}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == devids	]]; then echo -en "${ZDIDS[@]}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == devid	]]; then echo -en "${ZDVID}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == time	]]; then echo -en "${ZTIME}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == mount	]]; then echo -en "${ZMTPT}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == live	]]; then echo -en "${ZLIVE}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == state	]]; then echo -en "${ZSTAT}"	; fi; if [[ ${DIR} == all ]]; then echo -en "${Z_FSEP}"; fi
			if [[ ${DIR} == all ]] || [[ ${DIR} == type	]]; then echo -en "${ZTYPE}"	; fi; #>>> if { [[ -z ${DIR} ]] || [[ ${DIR} == all ]]; }; then echo -en "${Z_FSEP}"; fi
			echo -en "\n"
		else
			if [[ -n ${ZDATA} ]]; then
				ZPOOL="${ZDATA}"
			fi
			echo -en "\n"
			zfs_pool_status ${ZPOOL}
		fi
		return 0
	fi
	if ${SN}; then
		if [[ -n ${ZDATA} ]]; then
			ZPOOL="${ZDATA}"
		fi
		if [[ -z ${SN_SKP} ]]; then
			if [[ ${DIR} == - ]]; then
				echo -en "- Recursive Snapshot... ${ZPOOL}@${Z_DATE}\n"
				${Z_SNAPSHOT} -r ${ZPOOL}@${Z_DATE}	|| return 1
			else
				for FILE in \
					${ZPOOL} \
					${DIR} \
					${@} \
				; do
					echo -en "- Creating Snapshot... ${FILE}@${Z_DATE}\n"
					${Z_SNAPSHOT} ${FILE}@${Z_DATE}	|| return 1
				done
			fi
		fi
		if {
			[[ ${ZFS_SNAPSHOTS} == +([0-9]) ]] && {
				[[ -n ${SN_SKP} ]] ||
				(( ${ZFS_SNAPSHOTS} > 0 ));
			};
		}; then
			declare Z_TRIM="$((${ZFS_SNAPSHOTS}+1))"
			if [[ ${DIR} == - ]]; then
				declare Z_ITEMS=($(${Z_LIST_ALL/-t all/-t filesystem,volume} ${ZPOOL} 2>/dev/null))
			else
				declare Z_ITEMS=(
					${ZPOOL} \
					${DIR} \
					${@} \
				)
			fi
			if {
				[[ -n ${SN_SKP} ]] &&
				[[ ${ZFS_SNAPSHOTS} == 0 ]];
			}; then
				Z_TRIM="0"
			elif (( ${Z_TRIM} < 2 )); then
				Z_TRIM="2"
			fi
			declare Z_ITEM=
			for Z_ITEM in ${Z_ITEMS[@]}; do
				declare Z_SNAP=
				for Z_SNAP in $(
					${Z_LIST_ALL/-t all/-t snapshot} ${Z_ITEM} 2>/dev/null |
					${GREP} "^${Z_ITEM}@" |
					sort -nr |
					tail -n+${Z_TRIM} |
					sort -n
				); do
					echo -en "- Destroying Snapshot... ${Z_SNAP}\n"
					zfs destroy ${Z_SNAP}	|| return 1
				done
			done
		fi
		echo -en "\n"
		zfs_pool_status ${Z_ITEMS[@]}
		return 0
	fi
	if ${UN}; then
		if [[ -z ${ZPINT} ]]; then
			return 0
		fi
		if [[ $(${Z_DAT} readonly ${ZPOOL} 2>/dev/null) == on ]]; then
			ZFS_ROTATE="false"
		fi
		function zfs_unmount_pool {
			${Z_STATUS} ${ZPOOL}
			echo -en "- Closing Pool...\n"
			for FILE in $(eval echo "{0..$((${#ZDIDS[@]}-1))}"); do
				if [[ ${ZDIDS[0]} != ${ZDIDS[${FILE}]} ]]; then
					echo -en "- Deactivating Member... ${ZDEVS[${FILE}]}\n"
					zpool offline ${ZPOOL} ${ZDIDS[${FILE}]}	|| return 1
				fi
			done
			if [[ -n $(${Z_DAT} mountpoint ${Z_POOL}) ]]; then
				if [[ ${ZLIVE} == yes ]]; then
					zfs umount "${@}" ${ZPOOL}			|| return 1
				fi
				zfs set ${ZOPTS_DONE} ${ZPOOL}				|| return 1
			fi
			if {
				${ZFS_ROTATE} && {
					[[ ${ZPOOL} == ${ZNAME} ]] || {
						[[ ${ZPOOL} != ${ZNAME} ]] &&
						[[ ${ZNAME} == ${ZROOT} ]];
					};
				};
			}; then
				zfs_pool_info						|| return 1
				echo -en "- Renaming Pool...\n"
				zpool export ${ZPOOL}					|| return 1
				if {
					[[ ${ZPOOL} != ${ZNAME} ]] &&
					[[ ${ZNAME} == ${ZROOT} ]];
				}; then
					ZPOOL="${ZMNAM}"
				else
					ZPOOL="${ZDNAM}"
				fi
				${Z_IMPORT} ${ZPINT} ${ZPOOL}				|| return 1
			fi
			zfs_pool_info							|| return 1
			zpool export ${ZPOOL}						|| return 1
			return 0
		}
		function zfs_unmount_member {
			if [[ ${ZDIDS[0]} == ${ZDVID} ]]; then
				zfs_unmount_pool					|| return 1
			elif [[ ${ZSTAT} != online ]]; then
				echo -en "- Inactive Member... ${DEV}\n"
			else
				echo -en "- Removing Member... (${ZPOOL}) ${DEV}\n"
				declare ZPOOL_NEW=
				if [[ ${ZPOOL} == ${ZROOT} ]]; then
					ZPOOL_NEW="${ZPNAM}"
				else
					ZPOOL_NEW="${ZDNAM}"
				fi
				zpool split -P ${ZPOOL} ${ZPOOL_NEW} ${ZDEVICE}		|| return 1
				${Z_IMPORT} ${ZPOOL_NEW}				|| return 1
				zfs set ${ZOPTS_DONE} ${ZPOOL_NEW}			|| return 1
				${Z_STATUS} ${ZPOOL_NEW}				|| return 1
				zpool export ${ZPOOL_NEW}				|| return 1
				${Z_STATUS} ${ZPOOL}					|| return 1
			fi
			return 0
		}
		if {
			[[ ${ZTYPE} == pool ]] ||
			[[ ${ZTYPE} == mount ]];
		}; then
			zfs_unmount_pool						|| return 1
		elif {
			[[ ${ZTYPE} == primary ]] ||
			[[ ${ZTYPE} == member ]] ||
			[[ ${ZTYPE} == filesystem ]];
		}; then
			zfs_unmount_member						|| return 1
		fi
		return 0
	else
		function zfs_mount_pool {
			if [[ ${ZLIVE} == no ]]; then
				echo -en "- Opening Pool...\n"
				if {
					${ZFS_ROTATE} &&
					[[ ${ZPOOL} != ${ZNAME} ]];
				}; then
					zfs_pool_info					|| return 1
					echo -en "- Renaming Pool...\n"
					zpool export ${ZPOOL}				|| return 1
					ZPOOL="${ZNAME}"
					${Z_IMPORT} -t ${ZPINT} ${ZPOOL}		|| return 1
				fi
				zfs set \
					${ZOPTS} \
					mountpoint=${DIR} \
					$(if ${RO}; then	echo "readonly=on"
						else		echo "readonly=off"
					fi) \
					${ZPOOL}					|| return 1
				if [[ $(${Z_DAT} mounted ${ZPOOL}) == no ]]; then
					${Z_MOUNT} "${@}" ${ZPOOL}			|| return 1
				fi
				for FILE in $(${Z_LIST_ALL/-t all/-t filesystem} ${ZPOOL} | ${GREP} -v "^${ZPOOL}$"); do
					${Z_MOUNT} ${FILE}				|| return 1
				done
				zfs_pool_info						|| return 1
			fi
			return 0
		}
		function zfs_mount_member {
#>>>			if [[ ${ZDIDS[0]} == ${ZDVID} ]]; then
				zfs_mount_pool						|| return 1
#>>>			fi
			if ! ${ZMEMBER}; then
				echo -en "- Attaching Member... (${ZPOOL}) ${DEV}\n"
				if { {
					[[ -n ${ZPINT} ]] &&
					[[ ${ZPINT} != ${ZPOOL} ]] &&
					[[ ${ZPINT} != ${ZROOT} ]];
				} && {
					[[ -n $(${Z_LIST} ${ZPINT} 2>/dev/null) ]];
				}; }; then
					echo -en "- Destroying Old Pool... ${ZPINT}\n"
					zpool destroy ${ZPINT}				|| return 1
				fi
#>>>				wipefs --force --all ${ZDEVICE}				|| return 1
				zpool attach -f ${ZPOOL} ${ZDIDS[0]} ${ZDEVICE}		|| return 1
			fi
			if [[ ${ZSTAT} != online ]]; then
				echo -en "- Activating Member... ${DEV}\n"
				zpool online ${ZPOOL} ${ZDEVICE}			|| return 1
			fi
			return 0
		}
		if {
			[[ ${ZTYPE} == pool ]] ||
			[[ ${ZTYPE} == mount ]];
		}; then
			zfs_mount_pool							|| return 1
		elif {
			[[ ${ZTYPE} == primary ]] ||
			[[ ${ZTYPE} == member ]] ||
			[[ ${ZTYPE} == filesystem ]];
		}; then
			zfs_mount_member						|| return 1
		fi
		${Z_STATUS} ${ZPOOL}
		return 0
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

function pages {
	calc "$(lynx -dump "${@}" | wc -l) / 60"
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
			${PATH+PATH="${PATH}"} \
			${CYGWIN+CYGWIN="${CYGWIN}"} \
			${CYGWIN_ROOT+CYGWIN_ROOT="${CYGWIN_ROOT}"} \
			${I_KNOW_WHAT_I_AM_DOING+I_KNOW_WHAT_I_AM_DOING="${I_KNOW_WHAT_I_AM_DOING}"} \
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
	source ${HOME}/.bashrc >/dev/null || return 1
	return 0
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

function pso {
	declare P_IONC="-19.19"
	declare P_NICE="3.3"
	declare P_PROC="-120.120"
	declare P_PSNL=" "
	declare P_SPAC=" | "
	declare PSLIST="$(ps --no-headers -e -o pid | sort -nu)"
	if [[ -n "${@}" ]]; then
		PSLIST="$(pgrep -f "${@}")"
		P_PROC=
	fi
	declare PID=
	for PID in ${PSLIST}; do
		if [[ -n "$(ps --no-headers -p ${PID})" ]]; then
			printf "%${P_IONC}s${P_SPAC}%${P_NICE}s${P_SPAC}%${P_PROC}s\n" \
				"$(ionice -p ${PID} | tr "\n" "${P_PSNL}")" \
				"$(ps -o "%n" -p ${PID} --no-headers | tr "\n" "${P_PSNL}")" \
				"$(${PS/ -e} -p ${PID} --no-headers)"
		fi
	done
}

########################################

function mirror {
	declare PREFIX="$(echo "${!#}" | ${SED} "s|^(http\|ftp)[s]?://||g" | ${SED} "s|^([^/]+).*$|\1|g")-$(date-string)"
	${WGET_R} --directory-prefix "${PREFIX}" "${@}" 2>&1 | tee -a ${PREFIX}.log
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
	declare TOLERANCE="4"
	declare FORCE=
	if [[ ${1} == -f ]]; then
		FORCE="${1}"
		shift
	fi
	declare CMD="${1}"		; shift
	declare CMD_ARG="$(basename	${CMD})"
	declare SRC="$((${#}-1))"	; SRC="${!SRC}"
	declare DST="${#}"		; DST="${!DST}"
	declare MARKER="($(date --iso=s) ${HOSTNAME}:${PWD}) ${CMD} ${@}"
	echo -en "\n reporting [${CMD_ARG}]${FORCE:+(${FORCE})}:"			1>&2
	echo -en " '${SRC}' -> '${DST}'\n"						1>&2
	echo -en "${MARKER}\n"								1>&2
	if { {
		false;
	} && {
		[[ ${CMD_ARG} == rsync ]] ||
		[[ ${CMD_ARG} == unison ]];
	}; }; then
		function rsync_list {
			declare RFILE="${1}" && shift
			declare R_SSH="${@}"
			declare LIST=
			LIST="$(
				eval $(which rsync) ${R_SSH} --list-only ${RFILE}/ 2>/dev/null |
				${GREP} -v "^.+[ ][.]$" |
				${SED} "s|^.+[[:space:]]([^[:space:]]+)$|\1|g"
			)"
			if [[ -n ${LIST} ]]; then
				echo -en "${LIST}"
			else
				echo -en "$(
					eval $(which rsync) ${R_SSH} --list-only --no-dirs ${RFILE} 2>/dev/null |
					${GREP} -v "^.+[ ][.]$" |
					${SED} "s|^.+[[:space:]]([^[:space:]]+)$|\1|g"
				)"
			fi
			return 0
		}
		function rsync_match {
			declare MTCH_SRC="${1}" && shift
			declare MTCH_DST="${1}" && shift
			declare MTCH_SSH="${@}"
			if
			[[ ${MTCH_SRC/%\/} == ${MTCH_SRC} ]] &&
			[[ ${MTCH_DST/%\/} != ${MTCH_DST} ]]
			then
				echo -en "WARNING: COMPLETELY TRUSTING FILE LISTS"	1>&2
				echo -en "\n"						1>&2
				return 0
			fi
			declare SRC_LIST=( $(rsync_list ${MTCH_SRC} ${MTCH_SSH}) ) && shift
			declare DST_LIST=( $(rsync_list ${MTCH_DST} ${MTCH_SSH}) ) && shift
			declare SRC_TEST=
			declare DST_TEST=
			declare MATCHED="0"
			if [[ -z "${SRC_LIST[@]}" ]]; then
				echo -en "ERROR: ${MARKER}"				1>&2
				echo -en "\n"						1>&2
				echo -en "ERROR: EMPTY SOURCE"				1>&2
				echo -en "\n"						1>&2
				sleep 10
				return 1
			fi
#>>>			if [[ -z "${DST_LIST[@]}" ]]; then
#>>>				echo -en "ERROR: ${MARKER}"				1>&2
#>>>				echo -en "\n"						1>&2
#>>>				echo -en "ERROR: EMPTY TARGET"				1>&2
#>>>				echo -en "\n"						1>&2
#>>>				sleep 10
#>>>				return 1
#>>>			fi
			for SRC_TEST in "${SRC_LIST[@]}"; do
				for DST_TEST in "${DST_LIST[@]}"; do
					if [[ ${SRC_TEST} == ${DST_TEST} ]]; then
						MATCHED="$((${MATCHED}+1))"
					fi
				done
			done
			if { {
				(( ${#SRC_LIST[@]} > 1 )) &&
				(( ${#DST_LIST[@]} > 1 ));
			} && {
				(( ${MATCHED} == 0 )) ||
				(( ${#SRC_LIST[@]} != ${#DST_LIST[@]} ));
			}; }; then
#>>>				echo -en "WARNING: ${MARKER}"				1>&2
				echo -en "WARNING: FILE LISTS DO NOT MATCH"		1>&2
				echo -en "\n"						1>&2
				echo -en "SOURCE[${#SRC_LIST[@]}]: ${SRC_LIST[@]}"	1>&2
				echo -en "\n"						1>&2
				echo -en "TARGET[${#DST_LIST[@]}]: ${DST_LIST[@]}"	1>&2
				echo -en "\n"						1>&2
				echo -en "MATCHED[${MATCHED}](${TOLERANCE})"		1>&2
				echo -en "\n"						1>&2
				if (( ${MATCHED} == 0 )); then
					echo -en "ERROR: ${MARKER}"			1>&2
					echo -en "\n"					1>&2
					echo -en "ERROR: LISTS HAVE NO MATCHES"		1>&2
					echo -en "\n"					1>&2
					sleep 10
					return 1
				fi
				if { {
					(( ${MATCHED} < $((${#SRC_LIST[@]}/${TOLERANCE})) )) ||
					(( ${MATCHED} < $((${#DST_LIST[@]}/${TOLERANCE})) ));
				} && {
					(( ${MATCHED} != ${#DST_LIST[@]} ));
				}; }; then
					echo -en "ERROR: ${MARKER}"			1>&2
					echo -en "\n"					1>&2
					echo -en "ERROR: DIFFERENCES ARE TOO DANGEROUS"	1>&2
					echo -en "\n"					1>&2
					sleep 10
					return 1
				fi
			fi
			return 0
		}
		if [[ -z ${FORCE} ]]; then
			declare SSH_ARGS=
			declare SSH_TEST=
			for RFILE in "${@}"; do
				SSH_TEST="$(echo "${RFILE}" | ${SED} -n "s|^--rsh=[\"]?(.*ssh [^\"]+)[\"]?$|--rsh=\"\1\"|gp")"
				if [[ -n ${SSH_TEST} ]]; then
					SSH_ARGS="${SSH_TEST}"
				fi
			done
			if ! rsync_match ${SRC} ${DST} ${SSH_ARGS}; then
				return 1;
			fi
		fi
	fi
	if [[ ${CMD} != git ]]; then
		time ${NICELY} ${CMD} "${@}" || {
			echo -en "ERROR: ${MARKER}"					1>&2
			echo -en "\n"							1>&2
			return 1;
		};
	else
		time ${CMD} "${@}" || {
			echo -en "ERROR: ${MARKER}"					1>&2
			echo -en "\n"							1>&2
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
	   [[ -d /data/data/com.termux/files ]] ||
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
		${RSYNC_U} root@server.garybgenett.net:/.g/_data/zactive/.static/.ssh/id_* ${HOME}/.ssh/
		return 0
	fi
	case ${DEST} in
#>>>		(me)	DEST="me.garybgenett.net"
		(me)	DEST="server.garybgenett.net"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5900[:]") ]] && OPTS="${OPTS} -L 5900:127.0.0.1:5900"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5901[:]") ]] && OPTS="${OPTS} -L 5901:127.0.0.1:5901"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5902[:]") ]] && OPTS="${OPTS} -L 5902:127.0.0.1:5902"
			if [[ ${HOSTNAME} != phoenix ]] &&
			   [[ ${HOSTNAME} != spider ]]; then
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

function swint {
	declare INT="${1}" && shift
	declare WID="${1}" && shift
	declare WPW="${1}" && shift
	${SED} -i "s/eth0/${INT}/g" \
		${HOME}/scripts/fw.${HOSTNAME} \
		${HOME}/scripts/ip.${HOSTNAME} \
		/.runit/_config/dhclient \
		/.runit/_config/dhcpcd \
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

function sync-dir {
	declare BAS_DIR="${PWD}"
	declare REP_TYP="${1}" && shift
	declare REP_SRC="${1}" && shift
	declare REP_DST="${1}" && shift
	declare REP_FUL="${1}" && shift
	${MKDIR} $(dirname ${BAS_DIR}/${REP_DST})
	if [[ ${REP_TYP} == repo ]]; then
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			${MKDIR} ${BAS_DIR}/${REP_DST}
			(cd ${BAS_DIR}/${REP_DST} &&
				reporter ${BAS_DIR}/_repo/repo init -u ${REP_SRC//\/=\// })
		fi
		(cd ${BAS_DIR}/${REP_DST} &&
			reporter ${BAS_DIR}/_repo/repo sync)
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
			${HOME}/setup/gentoo.make/gentoo/_funtoo.kits ${BAS_DIR}/${REP_DST}
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
		${RSYNC_U} ${REP_SRC}/ ${BAS_DIR}/${REP_DST}
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
	declare CATIT="false"
	if [[ ${1} == -c ]]; then
		CATIT="true"
		shift
	fi
	declare SEARCH=
	if [[ ${1} == -g ]]; then
		shift
		SEARCH="^diff"
		declare TREE=
		[[ -z ${1} ]]		&& TREE="HEAD"			&& shift
		[[ ${1} == -c ]]	&& TREE="--cached HEAD"		&& shift
		[[ ${1} == -i ]]	&& TREE=""			&& shift
		echo -en "# vim: filetype=git\n"			>${VDIFF} 2>&1
		${GIT_CMD} diff ${GIT_DIF} ${DIFF_OPTS} ${TREE} "${@}"	>>${VDIFF} 2>&1
	elif [[ ${1} == -l ]] ||
	     [[ ${1} == -s ]]; then
		declare DIFF="${DIFF_OPTS}"
		[[ ${1} == -s ]] && DIFF=
		shift
		SEARCH="^commit"
		declare FOLLOW=
		declare FILE="${#}"
		(( ${FILE} > 0 )) && [[ -f ${!FILE} ]] && FOLLOW="--follow"
		echo -en "# vim: filetype=git\n"			>${VDIFF} 2>&1
		${GIT_CMD} log ${GIT_FMT} ${DIFF} ${FOLLOW} "${@}"	>>${VDIFF} 2>&1
	else
		SEARCH="^[-+]"
		echo -en "# vim: filetype=diff\n"	>${VDIFF} 2>&1
		diff ${DIFF_OPTS} "${@}"		>>${VDIFF} 2>&1
	fi
	if ${CATIT}; then
		${GREP} "${SEARCH}" ${VDIFF}
		${LL} ${VDIFF} #>>> >/dev/null 2>&1
	else
		${VIEW} -c "set filetype=diff" "+/${SEARCH}" ${VDIFF}
		${RM} ${VDIFF} >/dev/null 2>&1
	fi
	return 0
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

function vpn {
	if [[ ${1} == -a ]]; then
		killall -9 autossh
		autossh \
			-M 0 -f \
			-i ${HOME}/.ssh/remote_id \
			-R 65535:127.0.0.1:22 \
			plastic@server.garybgenett.net
	elif [[ ${1} == -v ]]; then
		declare SRC="root@server.garybgenett.net:/.g/_data/zactive"
		${RSYNC_U} ${SRC}/.setup/openvpn/openvpn.conf+VPN			/etc/openvpn/openvpn.conf
		${RSYNC_U} ${SRC}/.static/.openssl/server-ca.garybgenett.net.crt	/etc/openvpn
		${RSYNC_U} ${SRC}/.static/.openssl/vpn-client.garybgenett.net.*		/etc/openvpn
		fwinit off
		iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
		echo "1" >/proc/sys/net/ipv4/ip_forward
		/etc/init.d/openvpn restart
		(tail --follow /var/log/syslog) &
		read ENTER
		psk /var/log/syslog
	fi
	return 0
}

########################################

function zpim-commit {
	declare RETURN
	cd ${PIMDIR}
	sudo chown -R plastic:plastic ${PIMDIR}{,.git}
	sudo chmod -R 750 ${PIMDIR}{,.git}
	sudo chmod 755 \
		${PIMDIR} \
		${PIMDIR}/tasks* \
		${PIMDIR}/zoho*
	${SED} -i \
		-e "/^[[:space:]]+[<]DD[>]$/d" \
		-e "s/<HR>([[:space:]])/<HR>\n\1/g" \
		bookmarks.html
	${RM} \
		passwords.kdb.lock
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

########################################

function zpim-shortcuts {
	${SED} -n \
		-e "s/^.*HREF[=][\"]([^\"]+)[\"].*SHORTCUTURL[=][\"]([^\"]+)[\"].*[>]([^>]+)[<].*$/\2\t\3\t\1/gp" \
		${PIMDIR}/bookmarks.html
}

################################################################################
# builds
################################################################################

# https://github.com/openrazer/openrazer/wiki/Troubleshooting
# https://github.com/openrazer/openrazer/wiki/Setting-up-the-keyboard-driver
# https://github.com/openrazer/openrazer/wiki/Using-the-keyboard-driver
# https://github.com/openrazer/openrazer/wiki/Using-the-mouse-driver
# dependencies
#	dev-python/dbus-python
#	dev-python/lesscpy
#	dev-python/pyudev
#	dev-python/setproctitle
function chroma {
	declare BRIGHT="128"
	declare COLOR="\x40\x00\x00"
	declare STEP=; if [[ -n ${1} ]]; then STEP="${1}"; shift; fi
	declare MODE=; if [[ -n ${1} ]]; then MODE="${1}"; shift; fi
	declare DRIVER_DIR="/sys/bus/hid/drivers"
	declare RAZER_KB="1532:0239"
	declare RAZER_MS="1532:005C"
	RAZER_KB="$(basename $(ls -d ${DRIVER_DIR}/{hid,razer}*/*:${RAZER_KB}.* 2>/dev/null | tail -n1))"
	RAZER_MS="$(basename $(ls -d ${DRIVER_DIR}/{hid,razer}*/*:${RAZER_MS}.* 2>/dev/null | head -n1))"
	echo -en "${RAZER_KB}\n"
	echo -en "${RAZER_MS}\n"
	if [[ ${STEP} == "bld" ]]; then
#>>>		cd /.g/_data/_build/razer/python-daemonize			&&
#>>>			python setup.py build					&&
#>>>			python setup.py install					&&
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
#>>>		cd /.g/_data/_build/razer/polychromatic				&&
#>>>			prompt -z make LESSC="lesscpy" install			&&
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
#>>>			echo -en "0"						>${DRIVER_DIR}/razerkbd/${RAZER_KB}/fn_toggle
#>>>			echo -en "0"						>${DRIVER_DIR}/razerkbd/${RAZER_KB}/logo_led_state
			echo -en "${BRIGHT}"					>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_brightness
			[[ ${MODE} == "off"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_none
#>>>			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_wave
			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_breath
			[[ ${MODE} == "spect"	]] && echo -en "1"		>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_spectrum
			[[ ${MODE} == "react"	]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_reactive
			[[ -z ${MODE}		]] && echo -en "${COLOR}"	>${DRIVER_DIR}/razerkbd/${RAZER_KB}/matrix_effect_static
		cat								${DRIVER_DIR}/razermouse/${RAZER_MS}/device_type
		cat								${DRIVER_DIR}/razermouse/${RAZER_MS}/firmware_version
			echo -en "\x03\x00"					>${DRIVER_DIR}/razermouse/${RAZER_MS}/device_mode
			echo -en "${BRIGHT}"					>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_led_brightness
			[[ ${MODE} == "off"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_none
#>>>			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_spectrum
			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_breath
			[[ ${MODE} == "spect"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_spectrum
			[[ ${MODE} == "react"	]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_reactive
			[[ -z ${MODE}		]] && echo -en "\x03${COLOR}"	>${DRIVER_DIR}/razermouse/${RAZER_MS}/logo_matrix_effect_reactive
			echo -en "${BRIGHT}"					>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_led_brightness
			[[ ${MODE} == "off"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_none
#>>>			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_spectrum
			[[ ${MODE} == "wave"	]] && echo -en "1"		>${DRIVER_DIR}/razermouse/${RAZER_MS}/scroll_matrix_effect_breath
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

# https://github.com/Genymobile/scrcpy
# 2019-08-14 22:24:26 +0200 da5b0ec0d59a9da591507cbb7b5d19f55b76c35c Improve FAQ
# 2020-04-07 22:52:14 +0200 cdd8edbbb68d6cecdced5036d8e3a3c8583ac512 Add a note about prebuilt server in BUILD.md  (HEAD -> master, origin/master, origin/HEAD)
function scrcpy {
	declare VER="master"
	declare BLD="false"
	declare HLP="false"
	declare DST=""
	[[ -n ${1} ]] && [[ ${1} == build	]] && BLD="true" && shift
	[[ -n ${1} ]] && [[ ${1} == help	]] && HLP="true" && shift
	[[ -n ${1} ]] && ${BLD} && VER="${1}" && shift
	if { [[ -n ${@} ]] && [[ ${1} != --+(*) ]]; }; then
		DST="${1}" && shift
	fi
	if [[ -z ${DISPLAY} ]]; then
		prompt -d -x
	fi
#>>>	export ANDROID_SDK_ROOT="/opt/android-studio"
	export ANDROID_SDK_ROOT="/.g/_data/source/android-studio"
	if ${BLD}; then
		${MKDIR} ${ANDROID_SDK_ROOT} && android-studio
		cd /.g/_data/_build/other/scrcpy				&&
			${GIT} checkout --force ${VER}				&&
			git reset --hard					&&
			meson x --buildtype release --strip -Db_lto=true	&&
			chown -R plastic ${ANDROID_SDK_ROOT}			&&
			chown -R plastic /.g/_data/_build/other/scrcpy		&&
			(cd x && su plastic -c ninja)
	fi
	if ${HLP}; then
		cd /.g/_data/_build/other/scrcpy && ./run x --help 2>&1 | ${PAGER}
	else
		# https://github.com/Genymobile/scrcpy/issues/975#issuecomment-560373096
		# https://github.com/Genymobile/scrcpy/issues/951
		if [[ -n ${DST} ]]; then
			if [[ -z $(adb devices 2>/dev/null | ${GREP} "[:]5555[[:space:]]+device$") ]]; then
				adb kill-server
				psk adb -9
				adb tcpip 5555
				adb connect ${DST}:5555
			fi
			adb devices
			cd /.g/_data/_build/other/scrcpy && ./run x --prefer-text --stay-awake --lock-video-orientation=0 --max-fps=100 --bit-rate=100M --port=5555 "${@}" || return 1
		else
			if [[ -z $(adb devices 2>/dev/null | ${GREP} "[0-9a-f][[:space:]]+device$") ]]; then
				adb kill-server
				psk adb -9
			fi
			adb devices
			cd /.g/_data/_build/other/scrcpy && ./run x --prefer-text "${@}" || return 1
		fi
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

########################################

# https://github.com/koush/vysor.io/issues/242
function vysor {
	declare VERS="master"
	[[ -n ${1} ]] && VERS="${1}" && shift
	prompt -d -x
	cd /.g/_data/_build/other/vysor-app	&&
		${GIT} checkout --force ${VERS}	&&
		git reset --hard		&&
#>>>		npm install npm@latest --global	&&
		npm install			&&
		./node_modules/.bin/electron . --app-id=gidgenkbbabolejbgbpnhbimgjbffefm
	return 0
}

################################################################################
# task functions
################################################################################

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
			"id"		=> "0",
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
		my $do_report = "0";
		my $all_tasks = "0";
		my $print_all = "0";
		if (($ARGV[0]) && ($ARGV[0] eq "-r")) {
			$do_report = $ARGV[0];
			shift();
		};
		if (($ARGV[0]) && ($ARGV[0] eq "-t")) {
			$all_tasks = $ARGV[0];
			shift();
		};
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
		# report.skim.sort=project+,kind-,depends-,description+,entry+
		sub print_task_sorter {
			(($list->{$a}{"project"}		|| "") cmp ($list->{$b}{"project"}	|| "")) ||
			(&print_task_sorter_udas("kind",	${b}, ${a})				) ||
			(($list->{$b}{"depends"}		|| "") cmp ($list->{$a}{"depends"}	|| "")) ||
			(($list->{$a}{"description"}		|| "") cmp ($list->{$b}{"description"}	|| "")) ||
			(($list->{$a}{"entry"}			|| "") cmp ($list->{$b}{"entry"}	|| ""))
		};
		sub print_header {
			$header = "1";
			&print_task("0", "HEADER");
			if (${do_report}) {
				print "" . ("|:---" x 7) . "|\n";
			} else {
				print "" . ("|:---" x 2) . "|\n";
			};
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
					"id"		=> "ID",
					"project"	=> "PROJECT",
					"tags"		=> "TAGS",
					"priority"	=> "P",
					"due"		=> "+DEAD",
					"end"		=> "+DIED",
					"kind"		=> "KIND",
					"description"	=> "DESCRIPTION",
				};
			};
			if ((${all_tasks}) || ($task->{"status"} eq "pending")) {
				print "| "; printf("%-${c_uid}.${c_uid}s", $task->{"uuid"});
				if (${do_report}) {
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
				} else {
					print " | "; printf("%-" . $c_fld->{"id"}	. "." . $c_fld->{"id"}		. "s", $task->{"id"} || "-");
					print " | "; printf("%-" . $c_fld->{"project"}	. "." . $c_fld->{"project"}	. "s", $task->{"project"} || "-");
				};
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
				if (${do_report}) {
					print ${title} . "\n";
				} else {
					if ($task->{"status"} eq "HEADER") {
						print $task->{"description"} . "\n";
					} else {
						my $do_report_command = "task";
						$do_report_command .= " rc.verbose=";
						$do_report_command .= " rc.report.skim.columns=description.count";
						$do_report_command .= " rc.report.skim.labels=DESCRIPTION";
						$do_report_command .= " skim";
						$do_report_command .= " " . $task->{"uuid"};
						system(${do_report_command});
					};
				};
			};
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

function task-duplicates {
	declare FILE="$(task _get rc.data.location)"
	declare UUID
	for UUID in $(task diagnostics | grep "Found[ ]duplicate" | awk '{print $3;}'); do
		echo -en "\n"
		echo -en "${UUID}\n";
		${GREP} -nH "uuid[:][\"]${UUID}[\"]" ${FILE}/{pending,completed}.data
		echo -en "${UUID}\n";
		# http://www.linuxtopia.org/online_books/linux_tool_guides/the_sed_faq/sedfaq4_004.html
#>>>		${SED} -i "0,/uuid[:][\"]${UUID}[\"]/{//d;}" ${FILE}/{pending,completed}.data
		${GREP} -nH "uuid[:][\"]${UUID}[\"]" ${FILE}/{pending,completed}.data
	done
	return 0
}

########################################

function task-export {
	declare FILE=
	cd ${PIMDIR}
#>>>	gtasks_export.pl twimport "+Inbox"
	gtasks_export.pl purge "+Inbox,@agenda,@errand"	"+GTD"
#>>>	gtasks_export.pl twexport "+Alerts"		"mind"	"project.isnt:_gtd"
#>>>	gtasks_export.pl twexport "+Notes"		"note"
	gtasks_export.pl twexport "+Docs"		"docs"
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

function task-export-calendar {
	cd ${PIMDIR}
#>>>		"c|export.gtd:dHJlc29iaXMub3JnXzFmY29nMjNjMWEwOTlhcGdqdTlvN3ZmbTE4QGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
#>>>		"c|export.default:Z2FyeUB0cmVzb2Jpcy5vcmc" \
#>>>		"c|export.personal:dHJlc29iaXMub3JnX2c4djBwa3RzbnQ4NGVvdHM4aGtpanRzanZnQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
#>>>		"c|export.orion:dHJlc29iaXMub3JnX2FiZm9wc3UxdHZmNDRiYzBqZTdtZHFzNmNvQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
#>>>		"c|export.present:dHJlc29iaXMub3JnX28zZHBwNWNzbmIzaG1ocGV2czMxZDJrZGlvQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
#>>>		"c|export.past:dHJlc29iaXMub3JnX3RoYTF1cjFnbzJpZDRlZGxkZHRnOW90YzlvQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20" \
#>>>	gcalendar_export.pl \
#>>>		"c|export.gtd:tresobis.org_1fcog23c1a099apgju9o7vfm18@group.calendar.google.com" \
#>>>		"c|export.default:gary@tresobis.org" \
#>>>		"c|export.personal:tresobis.org_g8v0pktsnt84eots8hkijtsjvg@group.calendar.google.com" \
#>>>		"c|export.orion:tresobis.org_abfopsu1tvf44bc0je7mdqs6co@group.calendar.google.com" \
#>>>		"c|export.present:tresobis.org_o3dpp5csnb3hmhpevs31d2kdio@group.calendar.google.com" \
#>>>		"c|export.past:tresobis.org_tha1ur1go2id4edlddtg9otc9o@group.calendar.google.com" \
#>>>		${@}
	for FILE in \
		"|export.gtd:tresobis.org_1fcog23c1a099apgju9o7vfm18@group.calendar.google.com" \
		"|export.default:gary@tresobis.org" \
		"|export.personal:tresobis.org_g8v0pktsnt84eots8hkijtsjvg@group.calendar.google.com" \
		"|export.orion:tresobis.org_abfopsu1tvf44bc0je7mdqs6co@group.calendar.google.com" \
		"|export.present:tresobis.org_o3dpp5csnb3hmhpevs31d2kdio@group.calendar.google.com" \
		"|export.past:tresobis.org_tha1ur1go2id4edlddtg9otc9o@group.calendar.google.com" \
		"highspot|static.highspot:gary.genett@highspot.com" \
	; do
		declare PROF="$(echo "${FILE}" | ${SED} "s/^(.*)[|](.+)$/\1/g")"
		declare GCAL="$(echo "${FILE}" | ${SED} "s/^(.*)[|](.+)$/\2/g")"
		declare CNAM="$(echo "${GCAL}" | ${SED} "s/^(.+)[:](.+)$/\1/g")"
		declare CSRC="$(echo "${GCAL}" | ${SED} "s/^(.+)[:](.+)$/\2/g")"
		declare ACCS="$(oauth2.sh ${PROF} -c)"
		${WGET_C} --output-document \
			${PIMDIR}/calendar-${CNAM}.ics \
			"https://apidata.googleusercontent.com/caldav/v2/${CSRC}/events?access_token=${ACCS}"
	done
	${WGET_C} --output-document \
		${PIMDIR}/calendar-export.doodle.ics \
		https://doodle.com/ics/mydoodle/j4afu5q0krixfr0gfm1iltcnl1rdpry9.ics
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
		--delete-excluded \
		--filter "- /_pim/taskd/orgs/local/users/*/tx.data" \
		--filter "- /_pim/tasks/undo.*" \
		/.g/_data/zactive/_drive/_sync/ \
		${GDRIVE_REMOTE}:/_sync \
		&&
	${RCLONE_U} \
		--drive-shared-with-me \
		--filter "- /email from*" \
		${GDRIVE_REMOTE}:/ \
		/.g/_data/zactive/_drive/_shared.all \
		&&
	${RCLONE_U} \
		--filter "- /_share/*/gary/**" \
		--filter "- /_share/transmetropolitan**" \
		--filter "- /_sync/**" \
		${GDRIVE_REMOTE}:/ \
		/.g/_data/zactive/_drive \
		&&
	${RCLONE_U} \
		${GDRIVE_REMOTE}-highspot: \
		/.g/_data/zactive/data.highspot \
		&&
	${RCLONE_C} about ${GDRIVE_REMOTE}-highspot: &&
	${RCLONE_C} about ${GDRIVE_REMOTE}: &&
	${LL} \
		/.g/_data/zactive/_drive/_sync \
		$(find /.g/_data/zactive/_drive/_sync -mindepth 1 -maxdepth 1 ! -type l) \
		$(find -L /.g/_data/zactive/_drive/_sync -type l 2>/dev/null)
	return 0
}

########################################

function task-export-report {
	declare DATE="$(date --iso)"
	declare REPORT="$(realpath "${1}").$(date-string)" && shift
	declare REPORT_DIR="$(dirname ${REPORT})"
	declare TASKS_LIST="${1}" && shift
	declare EMAIL_DEST="${1}" && shift
	declare EMAIL_MAIL="${1}" && shift
	declare EMAIL_NAME="${1}" && shift
	declare EMAIL_SIGN="${1}" && shift
	declare PROJECTS_Y="${1}" && shift; if [[ ${PROJECTS_Y} != false ]] && [[ ${PROJECTS_Y} != true ]]; then PROJECTS_Y="false"; fi
	declare KANBAN_YES="${1}" && shift; if [[ ${KANBAN_YES} != false ]] && [[ ${KANBAN_YES} != true ]]; then KANBAN_YES="false"; fi
	declare TIMELINE_Y="${1}" && shift; if [[ ${TIMELINE_Y} != false ]] && [[ ${TIMELINE_Y} != true ]]; then TIMELINE_Y="false"; fi
	task-export-text "${EMAIL_NAME}" "${TASKS_LIST}"
	${MKDIR} ${REPORT_DIR}
	if ${PROJECTS_Y}; then ${CP} ${PIMDIR}/tasks.md.html		${REPORT}.projects.html	; fi
	if ${KANBAN_YES}; then ${CP} ${PIMDIR}/tasks.kanban.html	${REPORT}.kanban.html	; fi
	if ${TIMELINE_Y}; then ${CP} ${PIMDIR}/tasks.timeline.html	${REPORT}.timeline.html	; fi
	if ${KANBAN_YES}; then
		perl -i -pe '
			my $data = qx(cat '${PIMDIR}/tasks.kanban.csv'); chomp(${data});
			s|<!-- INCLUDE -->|${data}|g;
			s|<!-- INTERNAL (.*) -->|${1}|g;
#>>>			s|<!-- TEST (.*) -->|${1}|g;
#>>>			s|<!-- FULL (.*) -->|${1}|g;
		' \
		${REPORT}.kanban.html
	fi
	if ${TIMELINE_Y}; then
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
	fi
cat >${REPORT}.txt <<END_OF_FILE
This is my weekly status report.  It should be generated every weekend.

The attached HTML files can be opened in any browser:

END_OF_FILE
if ! ${PROJECTS_Y} && ! ${KANBAN_YES} && ! ${TIMELINE_Y}; then cat >>${REPORT}.txt <<END_OF_FILE
  * Oops!  I made a mistake.  Please let me know my reports are missing.
END_OF_FILE
fi
if ${PROJECTS_Y}; then cat >>${REPORT}.txt <<END_OF_FILE
  * Projects -- List of projects, their status, and all notes
END_OF_FILE
fi
if ${KANBAN_YES}; then cat >>${REPORT}.txt <<END_OF_FILE
  * Kanban -- Interactive board of all high-priority items
    * Display
        * Top line is task identifier, project and due date
        * Bottom line is the title and number of notes and/or time logs
    * Usage
        * Items may be dragged/dropped, if desired, but not saved
    * Columns
        * Except Holding and Archive, items should only show up in one column
        * Holding -- Blocked, with due date
        * Waiting -- Blocked, no due date
        * Working -- Ready to be worked (filtered, not all are active)
        * Complete -- Completed/deleted/dropped (pruned regularly)
        * Archive -- Recently modified (pruned regularly)
END_OF_FILE
fi
if ${TIMELINE_Y}; then cat >>${REPORT}.txt <<END_OF_FILE
  * Timeline -- Gantt-style chart of deadline projects and time tracking
    * Requirements
        * Internet access (it uses 3rd party Javascript libraries)
        * Browser may request authorization to run/view the content
    * Display
        * Slider bars progress down through monthly/weekly/daily/hourly
        * Highlighted areas represent displayed portions of lower scopes
        * Project tracking is on top (monthly and weekly)
        * Time tracking is on the bottom (daily and hourly)
    * Usage
        * Mousing over weekly/hourly items displays date/time details
        * Timelines are estimated (tasks may not take allotted time)
        * Not all time is accounted for in tracking (intentionally)
    * Legend
        * Black text -- Final task driving the due date
        * Gray text -- Dependencies and sub-tasks
        * Green bar -- In-progress (hours have been logged)
        * Yellow bar -- Not yet started
        * Red bar -- Overdue
        * Black bar -- Complete
        * White bar -- Deleted/dropped
END_OF_FILE
fi
cat >>${REPORT}.txt <<END_OF_FILE

That's it!  Please see me with any comments or questions.
END_OF_FILE
	if [[ -f "${COMPOSER}" ]]; then
		${MV} ${REPORT}.txt				${REPORT}.md
		make -f "${COMPOSER}" -C "${REPORT_DIR}"	${REPORT}.txt
	fi
	if [[ -f ${EMAIL_SIGN} ]]; then
		echo -en "\n"					>>${REPORT}.txt
		echo -en "-- \n"				>>${REPORT}.txt
		cat ${EMAIL_SIGN}				>>${REPORT}.txt
	fi
	if [[ -f "${COMPOSER}" ]]; then
		if [[ -f ${EMAIL_SIGN} ]]; then
			echo -en "\n"				>>${REPORT}.md
			echo -en "\t-- \n"			>>${REPORT}.md
			${SED} "s|^|\t|g" ${EMAIL_SIGN}		>>${REPORT}.md
		fi
		make -f "${COMPOSER}" -C "${REPORT_DIR}"	${REPORT}.html
		${SED} -i "/text\/css/d"			${REPORT}.html
		${RM}						${REPORT_DIR}/.composed
	fi
	if [[ -n ${EMAIL_DEST} ]] && [[ -n ${EMAIL_MAIL} ]]; then
#>>>		cat ${REPORT}.txt |
		cat ${REPORT}.html |
			EMAIL_MAIL="${EMAIL_MAIL}" \
			EMAIL_NAME="${EMAIL_NAME}" \
			email -x \
				-e "set content_type = text/html" \
				-s "Status Report: ${DATE}" \
				$(if ${PROJECTS_Y}; then echo "-a ${REPORT}.projects.html"; fi) \
				$(if ${KANBAN_YES}; then echo "-a ${REPORT}.kanban.html"; fi) \
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
		open(KNBN, ">", ${root} . ".kanban.csv")		|| die();
		open(PROJ, ">", ${root} . ".timeline.projects.json")	|| die();
		open(LINE, ">", ${root} . ".timeline.json")		|| die();
		open(TIME, ">", ${root} . ".csv")			|| die();
		open(NOTE, ">", ${root} . ".md")			|| die();
		foreach my $task (@{$data}) { delete($task->{"id"}); delete($task->{"urgency"}); };
		my $json = JSON::XS->new(); print JSON $json->canonical->pretty->encode(${data});
		# tasks.xltx
		#	data
		#		data -> get data from text/csv
		#			rename: tasks (data)
		#			applied steps
		#				removed columns -> column1
		#				changed type -> [=beg] -> date/time
		#				changed type -> [=hrs] -> decimal
		#	table
		#		insert -> pivot table -> external data source
		#			rename: tasks (table)
		#		<field list -> populate filters, rows and values>
		#			sort in data source order
		#			[=hrs] -> sum, 2 decimal places
		#			[=beg] -> ungroup -> group -> 1970-01-05, 2038-01-19, 7 days
		#		<table sort>
		#			[desc] = a-z
		#			[=beg] = old-new
		#			more options = [=hrs] -> z-a
		#			[desc] = collapse entire field
		#		<toolboxes>
		#			<data -> queries and connections>
		#			<analyze -> field list>
		#	chart
		#		insert -> pivot chart -> stacked column
		#		<right click -> move chart -> new sheet>
		#	<sort sheets: table, chart, data>
		print TIME "\"[DESC]\",\"[PROJ]\",\"[KIND]\",\"[AREA]\",\"[TAGS]\",";
		print TIME "\"[.UID]\",";
		print TIME "\"[.BRN]\",\"[_BRN]\",\"[=BRN]\",";
		print TIME "\"[.DIE]\",\"[_DIE]\",\"[=DIE]\",";
		print TIME "\"[=AGE]\",";
		print TIME "\"[.BEG]\",\"[_BEG]\",\"[=BEG]\",";
		print TIME "\"[.END]\",\"[_END]\",\"[=END]\",";
		print TIME "\"[=HRS]\",";
		print TIME "\n";
		# force week grouping to start on monday
		my $epoch = 345600;	# 60*60*24*4 = 1970-01-05 00:00:00
		my $wtime = 604800;	# 60*60*24*7 = one week / seven days
		my $rtime = time();
		my $null = "(null)";
		while (${epoch} <= ${rtime}) {
			my $marker = strftime("%Y-%m-%d %H:%M:%S", gmtime(${epoch}));
			print TIME "\"${null}\",\"${null}\",\"${null}\",\"${null}\",\"${null}\",";
			print TIME "\"${null}\",";
			print TIME "\"-\",\"-\",\"-\",";
			print TIME "\"-\",\"-\",\"-\",";
			print TIME "\"-\",";
			print TIME "\"-\",\"-\",\"${marker}\",";
			print TIME "\"-\",\"-\",\"-\",";
			print TIME "\"0.00\",";
			print TIME "\n";
			$epoch += ${wtime};
		};
		print NOTE "% Taskwarrior: Project List & Notes\n";
		print NOTE "% " . ${name} . "\n";
		print NOTE "% " . localtime() . "\n";
		my $NOTE = {}; $NOTE->{"other"} = {};
		my $multi_tag = [];
		my $kanban_length = (64 - 2 - 7 - 4); #>>> maximum - marker<= > - annotations< [####]> - ellipsis< ...>
		my $kanban = {
			"k1" => {},
			"k2" => {},
			"k3" => {},
			"k4" => {},
			"k5" => {},
		};
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
			"work.bz"	=> "brown",
			"work.cn"	=> "brown",
			"work.em"	=> "brown",
			"work.f5"	=> "brown",
			"work.hs"	=> "brown",
			"work.jb"	=> "brown",
			"work.me"	=> "brown",
			"work.tk"	=> "brown",
			"work.vn"	=> "brown",
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
		foreach my $key (sort(keys(%{$kanban}))) {
			my $kanban_export = "";
			open(KANBAN, "<", ${ENV{NOTES_MD}}) || die();
			my $kanban_text = do { local $/; <KANBAN> }; $kanban_text =~ s/\n+$//g;
			close(KANBAN) || die();
			while (${kanban_text} =~ m|^.*?${key}[:].*?[`]([^\s]+)\s+([^`]+)[`]$|gms) {
				my $kanban_filt = ${1};
				my $kanban_args = ${2}; $kanban_args =~ s|rc.context=([^\s]+)||g;
				my $kanban_cont = ${1};
				$kanban_filt = qx(task _get rc.report.${kanban_filt}.filter); chomp(${kanban_filt});
				$kanban_cont = qx(task _get rc.context.${kanban_cont}); chomp(${kanban_cont});
				$kanban_args =
					((${kanban_filt}) ? "( ${kanban_filt} )" : "") .
					((${kanban_args}) ? "( ${kanban_args} )" : "") .
					((${kanban_cont}) ? "( ${kanban_cont} )" : "");
				$kanban_args =
					((${kanban_args}) ? "\"${kanban_args}\"" : "");
				$kanban_args =~ s|\\||g;
				my $kanban_task = qx(task export ${kanban_args}); $kanban_task =~ s/\n//g; $kanban_task = decode_json(${kanban_task});
				$kanban_export .= " " . ($#{$kanban_task}+1);
				foreach my $task (@{$kanban_task}) {
					$kanban->{$key}{ $task->{"uuid"} } = ${task};
				};
			};
			$kanban_export = "${key} = " . scalar(keys(%{ $kanban->{$key} })) . " =" . ${kanban_export};
			warn("EXPORTED KANBAN[${kanban_export}]");
		};
		sub export_kanban {
			my $task = shift();
			foreach my $key (sort(keys(%{$kanban}))) {
				if (exists($kanban->{$key}{ $task->{"uuid"} })) {
					my $ktsk = $kanban->{$key}{ $task->{"uuid"} };
					$ktsk->{"uuid"}		=~ s|[-].+$||g;
					my($epoch, $ltime)		= ("", "");
					if (exists($ktsk->{"due"})) {
						($epoch, $ltime)	= &time_format( $ktsk->{"due"} );
						$ltime			=~ s|[ ][0-9:]+$||g;
					};
					$ktsk->{"description"}		=~ s|^(.{${kanban_length}}).*$|$1 ...|g;
					$ktsk->{"description"}		=~ s|,|;|g;
					if ($ktsk->{"status"} eq "pending") {		$ktsk->{"description"} = "= " . $ktsk->{"description"};
					} elsif ($ktsk->{"status"} eq "completed") {	$ktsk->{"description"} = "+ " . $ktsk->{"description"};
					} elsif ($ktsk->{"status"} eq "deleted") {	$ktsk->{"description"} = "- " . $ktsk->{"description"};
					} else {					$ktsk->{"description"} = "? " . $ktsk->{"description"};
					};
					if (exists($ktsk->{"annotations"})) {
						$ktsk->{"annotations"}	= ($#{ $ktsk->{"annotations"} } +1);
					};
					print KNBN "" . (${key}				|| "")	. ",";
					print KNBN "" . ($ktsk->{"uuid"}		|| "-")	. ",";
					print KNBN "" . ($ktsk->{"project"}		|| "")	. ",";
					print KNBN "" . (${ltime}			|| "")	. ",";
					print KNBN "" . ($ktsk->{"description"}		|| "-")	. " ";
					print KNBN "[" . ($ktsk->{"annotations"}	|| "")	. "]";
					print KNBN "\n";
				};
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
		sub export_note_process {
			my $task	= shift();
			my $output	= shift();
			while (${output} =~ m/(^|\s+)\[TASKFILE[ ]?([^]]*)?\]/gms) {
				my $source = ${2};
				warn("EXPORTING TASKFILE[${source}]");
				open(TASKFILE, "<", ${source}) || die();
				my $taskfile = do { local $/; <TASKFILE> }; $taskfile =~ s/\n+$//g;
				close(TASKFILE) || die();
				$taskfile =~ s/^\n*/<!-- TASKFILE[${source}] -->\n/g;
				$taskfile =~ s/[\s\n]*$//g;
				$output =~ s/([^\s]+)\s+(\[TASKFILE[ ]?([^]]*)?\])$/${1}\n\n${2}\n/ms;
				$output =~ s/\[TASKFILE[ ]?([^]]*)?\]/${taskfile}/ms;
				$output = &export_note_process(${task}, ${output});
			};
			while (${output} =~ m/(^|\s+)\[TASKNOTES[ ]?([^]]*)?\]/gms) {
				my $notes = ${2};
				warn("EXPORTING TASKNOTES[${notes}]");
				my $tasknotes = qx(.bashrc task-notes -x ${notes});
				$tasknotes =~ s/^\n*/<!-- TASKNOTES[${notes}] -->\n/g;
				$tasknotes =~ s/[\s\n]*$//g;
				$output =~ s/([^\s]+)\s+(\[TASKNOTES[ ]?([^]]*)?\])$/${1}\n\n${2}\n/ms;
				$output =~ s/\[TASKNOTES[ ]?([^]]*)?\]/${tasknotes}/ms;
				$output = &export_note_process(${task}, ${output});
			};
			while (${output} =~ m/(^|\s+)\[TASKLIST[ ]?([^]]*)?\]/gms) {
				my $project = ${2} || $task->{"project"};
				warn("EXPORTING TASKLIST[${project}]");
				my $tasklist = qx(.bashrc task-depends -r -t project.is:${project});
				$tasklist =~ s/^\n*/<!-- TASKLIST[${project}] -->\n/g;
				$tasklist =~ s/[\s\n]*$//g;
				$output =~ s/([^\s]+)\s+(\[TASKLIST[ ]?([^]]*)?\])$/${1}\n\n${2}\n/ms;
				$output =~ s/\[TASKLIST[ ]?([^]]*)?\]/${tasklist}/ms;
				$output = &export_note_process(${task}, ${output});
			};
			while (${output} =~ m/(^|\s+)\[TASKCMD[ ]?([^]]*)?\]/gms) {
				my $command = ${2};
				warn("EXPORTING TASKCMD[${command}]");
				my $taskcmd = qx(task ${command});
				$taskcmd =~ s/^\n*/<!-- TASKCMD[${command}] -->\n/g;
				$taskcmd =~ s/[\s\n]*$//g;
				$output =~ s/([^\s]+)\s+(\[TASKCMD[ ]?([^]]*)?\])$/${1}\n\n${2}\n/ms;
				$output =~ s/\[TASKCMD[ ]?([^]]*)?\]/${taskcmd}/ms;
				$output = &export_note_process(${task}, ${output});
			};
			return(${output});
		};
		sub export_note {
			my $task	= shift();
			my $annotation	= shift();
			my $object	= shift();
			my $description = (($task->{"project"}) ? "(" . $task->{"project"} . ") " : "") . $task->{"description"}; $description =~ s|([*_])|\\$1|g;
			if ((!exists($task->{"kind"})) || ($task->{"kind"} ne "notes")) {
				$description = "-- " . ${description};
			};
			my($z, $modified, $output, $note) = ("", "", "", "");
			if ($annotation) {
				($z, $modified) = &time_format($annotation->{"entry"});
				$modified = "Updated: " . ${modified};
				$output = $annotation->{"description"};
				$output =~ s/^[[]notes[]][:]//g;
				$output = "\n" . decode_base64(${output}) . "\n";
				$output = &export_note_process(${task}, ${output});
			} else {
				$modified = "No Notes";
			};
			$note .= "\n---\n\n";
			$note .= ${description} . " {#uuid-" . $task->{"uuid"} . "}\n";
			$note .= ("-" x 40) . "\n\n";
			$note .= "**" . ${modified} . " | UUID: [" . $task->{"uuid"} . "](#uuid-" . $task->{"uuid"} . ") | [TOC](#TOC) [GTD](#gtd) [Dir](./" . ${base} . ") [" . ${extn} . "](./" . ${base} . "/" . $task->{"uuid"} . ${extn} . ")**\n";
			$note .= ${output};
#>>>			if	((exists($task->{"project"})) && ($task->{"project"} eq ".someday"))	{
#>>>					if ($task->{"status"} eq "pending")				{ $object->{"someday"}		.= ${note}; }
#>>>					else								{ $object->{"never"}		.= ${note}; }
#>>>#>>>			};
#>>>			}
			if (0) { my $null =""; }
#>>>			elsif	(
#>>>#>>>			if	(
#>>>					($task->{"status"} eq "pending") && (
#>>>					(!exists($task->{"kind"})) || ($task->{"kind"} ne "notes")
#>>>				))									{ $object->{"notes"}		.= ${note}; }
#>>>			elsif	(
#>>>					($task->{"status"} ne "pending") && (
#>>>					(!exists($task->{"kind"})) || ($task->{"kind"} ne "notes")
#>>>				))									{ $object->{"scraps"}		.= ${note}; }
			elsif	((exists($task->{"project"})) && ($task->{"project"} eq "_data"))	{ $object->{"data"}		.= ${note}; }
			elsif	((exists($task->{"project"})) && ($task->{"project"} eq "_journal"))	{ $object->{"journal"}		.= ${note}; }
			elsif	($task->{"status"} eq "pending")					{ $object->{"open"}		.= ${note}; }
			elsif	($task->{"status"} eq "completed")					{ $object->{"completed"}	.= ${note}; }
			elsif	($task->{"status"} eq "deleted")					{ $object->{"deleted"}		.= ${note}; }
			else										{ die("INVALID STATUS!"); };
		};
		foreach my $task (sort({
			(($a->{"project"}	|| "") cmp ($b->{"project"}	|| "")) ||
			(($a->{"description"}	|| "") cmp ($b->{"description"}	|| "")) ||
			(($a->{"entry"}		|| "") cmp ($b->{"entry"}	|| ""))
		} @{$data})) {
			my $started = "0";
			my $begin = "0";
			my $notes = "0";
			&export_kanban(${task});
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
#>>>				elsif (((exists($task->{"kind"})) && ($task->{"kind"} eq "notes")) && ($annotation->{"description"} =~ m/^[[]notes[]][:]/)) {
				elsif ($annotation->{"description"} =~ m/^[[]notes[]][:]/) {
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
#>>>					print("BAD ANNOTATION!");
					die("BAD ANNOTATION!");
				};
			};
#>>>			if ((!${notes}) && ((exists($task->{"kind"})) && ($task->{"kind"} eq "notes"))) {
#>>>				&export_note(${task}, "", $NOTE->{"other"});
#>>>			};
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
		if (exists($NOTE->{"data"}))			{ print NOTE "\n---\n\n" . "Data"		. " {#list-data}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"data"}				; };
		if (exists(${$NOTE->{"other"}}{"data"}))	{ print NOTE "\n---\n\n" . "Data (Other)"	. " {#list-data-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"data"}		; };
		if (exists($NOTE->{"notes"}))			{ print NOTE "\n---\n\n" . "Notes"		. " {#list-notes}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"notes"}			; };
		if (exists(${$NOTE->{"other"}}{"notes"}))	{ print NOTE "\n---\n\n" . "Notes (Other)"	. " {#list-notes-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"notes"}		; };
		if (exists($NOTE->{"open"}))			{ print NOTE "\n---\n\n" . "Open"		. " {#list-open}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"open"}				; };
		if (exists(${$NOTE->{"other"}}{"open"}))	{ print NOTE "\n---\n\n" . "Open (Other)"	. " {#list-open-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"open"}		; };
		if (exists($NOTE->{"scraps"}))			{ print NOTE "\n---\n\n" . "Scraps"		. " {#list-scraps}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"scraps"}			; };
		if (exists(${$NOTE->{"other"}}{"scraps"}))	{ print NOTE "\n---\n\n" . "Scraps (Other)"	. " {#list-scraps-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"scraps"}		; };
		if (exists($NOTE->{"completed"}))		{ print NOTE "\n---\n\n" . "Completed"		. " {#list-completed}\n"	. ("=" x 80) . "\n"; print NOTE $NOTE->{"completed"}			; };
		if (exists(${$NOTE->{"other"}}{"completed"}))	{ print NOTE "\n---\n\n" . "Completed (Other)"	. " {#list-completed-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"completed"}	; };
		if (exists($NOTE->{"deleted"}))			{ print NOTE "\n---\n\n" . "Deleted"		. " {#list-deleted}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"deleted"}			; };
		if (exists(${$NOTE->{"other"}}{"deleted"}))	{ print NOTE "\n---\n\n" . "Deleted (Other)"	. " {#list-deleted-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"deleted"}		; };
		if (exists($NOTE->{"someday"}))			{ print NOTE "\n---\n\n" . "Someday"		. " {#list-someday}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"someday"}			; };
		if (exists(${$NOTE->{"other"}}{"someday"}))	{ print NOTE "\n---\n\n" . "Someday (Other)"	. " {#list-someday-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"someday"}		; };
		if (exists($NOTE->{"never"}))			{ print NOTE "\n---\n\n" . "Never"		. " {#list-never}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"never"}			; };
		if (exists(${$NOTE->{"other"}}{"never"}))	{ print NOTE "\n---\n\n" . "Never (Other)"	. " {#list-never-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"never"}		; };
		if (exists($NOTE->{"journal"}))			{ print NOTE "\n---\n\n" . "Journal"		. " {#list-journal}\n"		. ("=" x 80) . "\n"; print NOTE $NOTE->{"journal"}			; };
		if (exists(${$NOTE->{"other"}}{"journal"}))	{ print NOTE "\n---\n\n" . "Journal (Other)"	. " {#list-journal-other}\n"	. ("=" x 80) . "\n"; print NOTE ${$NOTE->{"other"}}{"journal"}		; };
		print NOTE "\n**End Of File**\n";
		close(JSON) || die();
		close(KNBN) || die();
		close(PROJ) || die();
		close(LINE) || die();
		close(TIME) || die();
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
				. " CSS=css_alt"
				. " TOC=6"
				. " ${base}${extn}.html"
				;
			if (system(${compose}) != 0) { die(); };
			unlink(${ENV{PIMDIR}} . "/.composed") || warn();
		};
	' -- "${NAME}" "${@}" || return 1
	echo -en "\n"			>>tasks.md
	echo -en "<!--\n"		>>tasks.md
	task-depends -r -t +BLOCKED	>>tasks.md
	echo -en "-->\n"		>>tasks.md
	${GREP} "[-][-][ ]TASK"		tasks.md
	${SED} -n "s/^#+ //gp"		tasks.md |
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
	${GREP} "[0-9]{2}[:][0-9]{2}[:][0-9]{2}[\"][,][\"][^-0-9]" tasks.csv
	${GREP} -B1 "^[\"][0-9]{8}T[0-9]{6}Z" tasks.csv
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

function task-journal {
#>>>	if [[ -z "${@}" ]]; then
#>>>		return 1
#>>>	fi
	declare DATE="$(date --iso)"
	if [[ -n "$(echo "${1}" | ${GREP} "^[0-9]{4}[-][0-9]{2}[-][0-9]{2}$")" ]]; then
		DATE="${1}"
		shift
	fi
	declare UUIDS="$(task uuids project:_journal description.startswith:${DATE})"
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
#>>>		my $data = qx(task export kind:notes ${args}); $data =~ s/\n//g; $data = decode_json(${data});
		my $data = qx(task export ${args}); $data =~ s/\n//g; $data = decode_json(${data});
		my $edit = ${args}; $edit =~ s/\"/\\\"/g; $edit = "${ENV{EDITOR}} -c \"map \~ <ESC>:!task read ${edit}<CR>\" -c \"map \\ <ESC>:!task \"";
		my $mark = "DELETE";
		my $rsync_u = ${ENV{RSYNC_U}}; $rsync_u =~ s/^reporter //g;
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
#>>>				if (($task->{"kind"} eq "notes") && ($annotation->{"description"} =~ m/^[[]notes[]][:]/)) {
				if ($annotation->{"description"} =~ m/^[[]notes[]][:]/) {
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
				system("${rsync_u} ${automatic} ${filelist}");
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

function task-project {
	declare ARGS=
	declare PROJ=
	if [[ ${1} == -r ]]; then ARGS+=" ${1}" && shift; fi
	if [[ ${1} == -t ]]; then ARGS+=" ${1}" && shift; fi
	if [[ ${1} == -a ]]; then ARGS+=" ${1}" && shift; fi
	for PROJ in "${@}"; do
		if [[ ${PROJ} == - ]]; then
			PROJ=" status:pending"
		fi
		if [[ ${ARGS} == *(*)-r*(*) ]]; then
			task read	project.is:${PROJ} -PARENT -CHILD
		fi
		task-depends	${ARGS}	project.is:${PROJ} -PARENT -CHILD
		task look		project.is:${PROJ} -PARENT -CHILD
	done
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
			print "| +UUID | PROJECT | +STAT | R | +DIED | DESCRIPTION\n";
			print "|:---|:---|:---|:---|:---|:---|\n";
		};
		# report.dump.sort=entry+
		foreach my $key (sort(@{$keys})) {
			my $item = $list->{$key};
			print "| "; printf("%-8.8s", $item->{"uuid"});
			print " | "; printf("%-" . $c_fld->{"project"} . "." . $c_fld->{"project"} . "s", $item->{"project"} || "-");
			print " | "; printf("%-9.9s", $item->{"status"});
			print " | "; printf("%-9.9s", $item->{"recur"});
			print " | "; printf("%-10.10s", &do_time($item->{"end"}) || "-");
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

function task-switch {
	declare FILTER="status:pending kind.isnt:notes +ANNOTATED"
	FILE="$(task uuids ${FILTER} "${@}")"
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
		foreach my $key (sort(keys(%{$entries}))) {
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
		foreach my $key (sort(keys(%{$entries}))) {
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

function vlc-do {
	if (( $(id -u) == 0 )); then
		sudo -H -u \#1000 ${HOME}/.bashrc ${FUNCNAME} "${@}"
		return 0
	fi
	declare VIDEO_ARG="video"
	declare REDSHIFT="on"
	if [[ ${1} == red ]]; then
		REDSHIFT="${1}"
		shift
	fi
	declare VOLUME="10"
	if [[ ${1} == +([0-9]) ]]; then
		VOLUME="${1}"
		shift
	fi
	killall -9 vlc
	sleep 1
	mixer ${VOLUME}
	declare PLAYLIST="$(
		if [[ -n ${1} ]]; then
			${GREP} -h "^[^#].*${1}.*[.]pls.*$" /.g/_data/zactive/.setup/_misc/playlists/* |
			sort -u |
			tail -n1
		fi
	)"
	if [[ -n ${PLAYLIST} ]]; then
		shift
		(DISPLAY= $(which vlc) "${@}" ${PLAYLIST}) &
	elif {
		[[ ${1} == ${VIDEO_ARG} ]] ||
		[[ -f ${1} ]];
	}; then
		PLAYLIST="${1}" && shift
		DISPLAY=:0 _menu realign/${REDSHIFT}
		DISPLAY= sudo _sync tunes off
		if [[ ${PLAYLIST} == ${VIDEO_ARG} ]]; then
			mixer
		else
			DISPLAY=:0 ${VLC} "${@}" ${PLAYLIST}
		fi
		DISPLAY= sudo _sync tunes on
		DISPLAY=:0 _menu realign/off
	fi
	return 0
}

################################################################################
# impersonate functions
################################################################################

export TW="IMPERSONATE_NAME=task .bashrc impersonate_command"
alias tw="${TW}"

if [[ ${IMPERSONATE_NAME} == task ]]; then
	declare FILE=
	unalias -a
	function impersonate_command {
#>>>		declare COLWID="160"
		declare COLWID="$(tput cols)"
		declare MARKER='echo -en "\e[1;34m"; eval printf "~%.0s" {1..${COLWID}}; echo -en "\e[0;37m\n"'
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
			declare BEG="$(declare NUM; for NUM in $(eval echo "{1..${INDENT}}"); do echo -en "${FILLER}"; done)"
			declare END="$(declare NUM; for NUM in $(eval echo "{1..${COLWID}}"); do echo -en "${FILLER}"; done)"
			eval ${MARKER}
			echo -en "${ECHO_CLR}"
			eval printf \"%-${COLWID}.${COLWID}s\" \"${BEG} ${@} ${END}\"
			echo -en "${ECHO_DFL}"
			echo -en "\n"
		}
		function _task {
			eval ${MARKER}
			echo -en "\e[1;34m"
			echo -en "[task ${@}]"
			echo -en "\e[0;37m\n"
			task \
				rc._forcecolor=1 \
				rc.verbose=nothing \
				rc.detection=0 \
				rc.defaultwidth=${COLWID} \
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
					-e "s/[\`][,[:space:]]+[\`]/\n/g" \
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
					-e "s/(impersonate_command|task[-])/eval\ \${MARKER}\;\ IMPERSONATE_NAME=task .bashrc \1/g" \
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
			declare SOURCE="${TODOUUID}"
			declare -a HEADER
			declare FILE
			if [[ -z "${@}" ]]; then
				HEADER[0]="Priorities"
				HEADER[1]="Projects"
				HEADER[2]="Notes"
			else
				if [[ -f "${1}" ]]; then
					SOURCE="${1}"
					shift
				fi
				declare NUM="0"
				for FILE in "${@}"; do
					if [[ "${FILE}" == "0" ]]; then
						HEADER[${NUM}]="Notes"; NUM=$((${NUM}+1))
						HEADER[${NUM}]="Projects"
					elif [[ "${FILE}" == "1" ]]; then
						HEADER[${NUM}]="Notes"; NUM=$((${NUM}+1))
						HEADER[${NUM}]="Kanban"
					else
						HEADER[${NUM}]="${FILE}"
					fi
					NUM=$((${NUM}+1))
				done
			fi
			( (
				for FILE in "${HEADER[@]}"; do
					_echo					"3" "=>" "${FILE}"
					_task					read +ACTIVE
#>>>					eval ${MARKER}; _task_parse_cmd_bash	"${SOURCE}" "${FILE}"
					eval $(_task_parse_cmd_bash		"${SOURCE}" "${FILE}")
				done
#>>>				eval ${MARKER}
			) | tee ${NULLDIR}/${FUNCNAME}-${IMPERSONATE_NAME}-todo ; (
				_echo "Remaining"
				_task look $(
					declare ID=
					for ID in $(
						cat ${NULLDIR}/${FUNCNAME}-${IMPERSONATE_NAME}-todo |
						${SED} "s/[[:cntrl:]][[]([0-9]+[;])*[0-9]+m//g" |
						${GREP} -o "^[[:space:]]{,3}[0-9]+" |
						sort -nu
					); do
						echo -n " id.isnt:${ID}"
					done
				)
				_echo "Success!"
				eval ${MARKER}
			) ) | ${MORE}
			${RM} ${NULLDIR}/${FUNCNAME}-${IMPERSONATE_NAME}-todo
		elif [[ ${1} == [=] ]]; then
			shift
			task-export-text "" "${@}"	|| return 1
#>>>			task-export			|| return 1
			zpim-commit tasks
		elif [[ ${1} == [@] ]]; then
			task-export-drive || return 1
			${EDITOR} +/"\[\ \]" -c "map ~ <ESC>:!${TW} todo<CR>" -c "map \\ <ESC>:!${TW} " \
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
					CSS="css_alt"		\
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
			task-notes kind:notes project.is:${PROJECT} "${@}"
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
			task-project "${@}"
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
			if [[ ${1} == k[1-5] ]]; then
				CONTEXT="${1}" && shift
				task $(
					[[ ${CONTEXT} == k1 ]] && echo "mind";	# holding
					[[ ${CONTEXT} == k2 ]] && echo "read";	# waiting
					[[ ${CONTEXT} == k3 ]] && echo "todo";	# working
					[[ ${CONTEXT} == k4 ]] && echo "read";	# complete
					[[ ${CONTEXT} == k5 ]] && echo "read";	# archive
				) \
					${OPTS/rc.gc=1} \
					rc.context=${CONTEXT} \
					"${@}" 2>/dev/null
			elif [[ ${1} == [,] ]]; then
				shift
				task view \
					${OPTS} \
					"${@}" 2>/dev/null
			elif [[ ${1} == [.] ]]; then
				shift
				task view \
					${OPTS} \
					\( \
						area.isnt:computer \
						area.isnt:writing \
					\) \
					\( \
						tags.is:calendar or \
						tags.is:computer or \
						tags.is:email \
					\) \
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
# interactive shells
################################################################################

if [[ "${-/i}" != "${-}" ]] &&
   [[ -n "${STY}" ]]; then
	session -c "${PROMPT_SCR_COLOR}"
fi

########################################

if [[ "${-/i}" != "${-}" ]]; then
	echo -en "\n"
	echo -en "\e[37;44m"
	${LL} --directory \
		/.g/_data/zactive.workspace* \
		/.g/_toor/.workspace* \
		/tmp/.wpa* \
		2>/dev/null | cat
	echo -en "\e[0m"
	echo -en "\n"
fi

########################################

if [[ "${SCRIPT}" == ".bashrc" ]]; then
	${@}
	exit "${?}"
fi

################################################################################
# end of file
################################################################################
