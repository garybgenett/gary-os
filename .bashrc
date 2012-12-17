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
setterm -blank 10	2>/dev/null
setterm -blength 0	2>/dev/null

if [[ -f /etc/profile.d/bash-completion.sh ]]; then
	source /etc/profile.d/bash-completion.sh
fi
complete -d -o dirnames cd

########################################

mkdir -pv ${HOME}/.history/screen	2>/dev/null
mkdir -pv ${HOME}/.history/shell	2>/dev/null

################################################################################
# variables
################################################################################

export SCRIPT="$(basename -- "${0}")"
export UNAME="$(uname -s)"

export PIMDIR="/.g/_data/zactive/_pim"
export MAILDIR="${HOME}/Maildir"
export MAILCAPS="${HOME}/.mailcap"

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

#>>>export CFLAGS="-march=i686 -mtune=i686 -O2 -ggdb -pipe"
export CFLAGS="-march=core2 -mtune=core2 -O2 -ggdb -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,--hash-style=gnu -Wl,--as-needed"
export MAKEFLAGS="-j9"

export CCACHE_DIR="/tmp/.ccache"
export CCACHE_LOGFILE= #>>>"/tmp/.ccache.log"

########################################

export CDPATH="."
export CDPATH="${CDPATH}:${HOME}"
export CDPATH="${CDPATH}:/.g"
export CDPATH="${CDPATH}:/.g/_data"
export CDPATH="${CDPATH}:/.g/_data/media"
export CDPATH="${CDPATH}:/.g/_data/zactive"

export PATH="."
export PATH="${PATH}:${HOME}"
export PATH="${PATH}:${HOME}/scripts"
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

########################################

export PROMPT_DIRTRIM=
declare PROMPT_TOKEN_HOST="\h"
declare PROMPT_TOKEN_PPWD="\w"

if [[ ${HOSTNAME} == spider ]]; then
	PROMPT_TOKEN_HOST="\e[1;32m\h\e[0;37m"
fi

declare PRE_PROMPT='\
\e]0;\
${PROMPT_KEY}[ ${TERM} | ${USER}@${HOSTNAME%%.*} | ${PWD/#$HOME/~} ]\
\a'

if { [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; } &&
   { [[ -z ${PROMPT} ]] || [[ ${PROMPT} == \$P\$G ]]; }; then
	export PROMPT="cygwin"
fi

if [[ ${PROMPT} == simple ]]; then
	export PROMPT="simple"
	export PROMPT_KEY=
	export PROMPT_COMMAND=
	echo -en "\e]0;\a"
	PROMPT_TOKEN_PPWD="<\W>"
else
	if [[ -z ${PROMPT} ]]; then
		export PROMPT=
		export PROMPT_KEY=
	else
		export PROMPT="${PROMPT}"
		export PROMPT_KEY="( ${PROMPT} )"
	fi
	export PROMPT_COMMAND="echo -en \"${PRE_PROMPT}\""
	if [[ -n ${PROMPT_KEY} ]] &&
	   [[ ${BASH_EXECUTION_STRING/%\ *} != rsync  ]] &&
	   [[ ${BASH_EXECUTION_STRING/%\ *} != scp    ]] &&
	   [[ ${BASH_EXECUTION_STRING/%\ *} != unison ]]; then
		eval "echo -en \"${PRE_PROMPT}\""
	fi
fi

export PS1="\u@\h:\w\$ "
export PS1="\
\n\
[\u@${PROMPT_TOKEN_HOST}]:[\D{%a/%j_%FT%T%z}]\
\n\
[\#/\!]\[\ek\e\\\\\]:${PROMPT_TOKEN_PPWD}\$"

################################################################################
# commands
################################################################################

export NICELY="sudo nice -n 19 ionice --class 2 --classdata 7"		; alias nicely="${NICELY}"
export NICELY="sudo nice -n 19 ionice -c 2 -n 7"			; alias nicely="${NICELY}"
export REALTIME="sudo nice -n -20 ionice --class 1 --classdata 0"	; alias realtime="${REALTIME}"
export REALTIME="sudo nice -n -20 ionice -c 1 -n 0"			; alias realtime="${REALTIME}"

if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	export NICELY=
	export REALTIME=
fi

########################################

export MORE="less -RX"					; alias more="${MORE}"
export VI="${REALTIME} vim -u ${HOME}/.vimrc -i NONE"	; alias vi="${VI}"
export VIEW="eval ${VI} -nR -c \"set nowrap\""		; alias view="${VIEW/#eval\ /}"

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

export DU="du -b --time --time-style=long-iso"			; alias du="${DU}"
export LU="${DU} -ak --max-depth 1"				; alias lu="${LU}"

########################################

export EMERGE_CMD="prompt -z emerge"		; alias emerge="${EMERGE_CMD}"

export CVS="reporter cvs"			; alias cvs="${CVS}"
export SVN="reporter svn"			; alias svn="${SVN}"

export GIT_CMD="git"
export GIT="reporter ${GIT_CMD}"		; alias git="${GIT}"
export GIT_ADD="${GIT} add --verbose"		; alias git-add="${GIT_ADD}"
export GIT_CMT="${GIT} commit --verbose"	; alias git-commit="${GIT_CMT}"
export GIT_STS="${GIT} status"			; alias git-status="${GIT_STS}"
export GIT_SVN="${GIT} svn"			; alias git-svn="${GIT_SVN}"

export DIFF_OPTS="-u -U10"
export GIT_DIF="--find-renames --full-index --summary --stat=128,128"
export GIT_FMT="${GIT_DIF} --pretty=fuller --date=iso --decorate"
export GIT_PAT="${GIT_DIF} --attach --binary --keep-subject"

########################################

export PV="pv --cursor --bytes --timer --rate --average-rate"			; alias pv="${PV}"
export XARGS="xargs --max-procs=2 --max-args=10"				; alias xargs="${XARGS}"

export XPDF="ACRO_ALLOW_SUDO=set /opt/Adobe/Reader*/bin/acroread"		; alias xpdf="${XPDF}"

export RDP="rdesktop -z -n NULL -g 90% -a 24 -r sound:remote"			; alias rdp="${RDP}"
export VNC="vncviewer -Shared -FullColor"					; alias vnc="${VNC}"
export X2VNC="x2vnc -west -tunnel -shared -noblank -lockdelay 60 -timeout 60"	; alias x2vnc="${X2VNC}"

########################################

export RDIFF_BACKUP="reporter rdiff-backup \
	-v6 \
	--force \
	--backup-mode \
	--no-hard-links \
	--preserve-numerical-ids"
export RDIFF_RM="rdiff-backup \
	--force \
	--remove-older-than 6M"

alias rdiff-backup="${RDIFF_BACKUP}"
alias rdiff-rm="${RDIFF_RM}"

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

export UNISON="${HOME}/.unison"

export UNISON_W="reporter unison \
	-log \
	-logfile ${HOME}/.unison/_log \
	-times \
	-perms 0"
export UNISON_U="${UNISON_W} \
	-perms -1 \
	-numericids \
	-owner \
	-group"
export UNISON_F="${UNISON_U} \
	-fastcheck false"

alias unison="${UNISON_U}"

########################################

export WGET_C="wget \
	--verbose \
	--execute robots=off \
	--user-agent=Mozilla/5.0 \
	--restrict-file-names=windows \
	--no-check-certificate \
	--server-response \
	--adjust-extension \
	--timestamping"
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
	--tries=3 \
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
alias zwrite="cd /.g/_data/zactive/writing/tresobis ; clear ; ${LL}"

alias s="run-mailcap"
alias x="cd / ; clear"
alias zdesk="cd /.g/_data/zactive/_zcache ; clear ; ${LL}"
if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	alias s="cygstart"
	alias x="cd / ; clear"
	alias zdesk="cd \"${USERPROFILE}/Desktop\" ; clear ; ${LL}"
fi

########################################

alias rsynclook="${GREP} -v '^[.<>c][fdDLS]'"

alias logtail="tail -f /.runit/log/syslogd"
alias synctail="${GREP} '^ERROR[:][ ]' /.g/_data/+sync/_sync.log ; echo ; tail -f /.g/_data/+sync/_sync.log"

alias filter="iptables -L -nvx --line-numbers | ${MORE}"
alias mangler="iptables -L -nvx --line-numbers -t mangle | ${MORE}"
alias natter="iptables -L -nvx --line-numbers -t nat | ${MORE}"

########################################

alias clean="_sync clean"
alias clock="clockywock"
alias cryptsetup="cryptsetup --hash sha256 --cipher aes-cbc-essiv:sha256 --key-size 256"
alias dd="dcfldd conv=noerror,notrunc"
alias dict="sdcv"
alias diskio="iostat -cdmtN -p sda,sdb,sdc,sdd 1"
alias ftp="lftp"
alias htop="${CP} -L ${HOME}/.htoprc.bak ${HOME}/.htoprc ; htop"
alias loopfile="dcfldd if=/dev/zero of=/tmp/loopfile bs=1k count=98288"
alias mixer="aumix -C ansi"
alias mplayer="mplayer -fs"
alias pics="feh -F -Sname"
alias pics-s="feh -F -rz -D5"
alias pics-x="feh -F -rz -D5 /.g/_data/personal/pictures/*/[0-9][0-9][0-9][0-9]"
alias ports="netstat -an | ${MORE}"
alias pstree="pstree -clnpuA"
alias remind="remind -v -uplastic"
alias schedule="remind -v -uplastic -g -m -b1 -cc+2 -w90 ${HOME}/.reminders"
alias sheep="electricsheep --debug 1 --mplayer 1 --server d2v6.sheepserver.net"
alias sknow="_sync backup know"
alias smount="_sync mount"
alias torrent="rtorrent -n -s ."
alias trust="_sync archive"
alias vlc="vlc -I ncurses --no-color --fullscreen"
alias vlc-help="vlc --help --full-help --longhelp --advanced 2>&1 | ${MORE}"
alias vlc-play="vlc ${HOME}/setup/_misc/playlist.m3u"
alias web="w3m google.com"

################################################################################
# basic functions
################################################################################

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
	fi
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
		mkdosfs -vF 32 "${@}"
	elif [[ ${1} == -n ]]; then
		shift
		mkntfs -vI "${@}"
	else
		mke2fs -t ext4 -jvm 0 "${@}"
	fi
}

########################################

function git {
	${NICELY} $(which git) --git-dir="${PWD}.git" --work-tree="${PWD}" "${@}"
}

########################################

function git-clone {
	if [[ ${1} == svn ]]; then
		shift
		reporter $(which git) svn clone "${@}"
	else
		reporter $(which git) clone --verbose "${@}"
	fi
	(cd ${!#} &&
		${MV} "${PWD}/.git" "${PWD}.git")
}

########################################

function git-list {
	if [[ -n "$(echo "${1}" | ${GREP} "^[a-z0-9]{40}$")" ]]; then
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

function git-remove {
	${GIT} filter-branch --index-filter "git rm -fr --cached --ignore-unmatch ${@}" HEAD
}

########################################

function hist-grep {
	${GREP} "${@}" ${HOME}/.history/shell/${HOSTNAME}.${USER}.$(basename ${SHELL}).* |
		cut -d: -f2- |
		sort |
		uniq --count |
		${GREP} "${@}"
}

########################################

function ldir {
	${LL} -R "${@}" | more
}

########################################

function pages {
	calc "$(lynx -dump "${@}" | wc -l) / 60"
}

########################################

function psg {
	$(which ps) u -ww -p $(pgrep -d, -f "${@}" | ${SED} "s/[,]$//g")
}

########################################

function psk {
	declare PSNAME="${1}" && shift
	kill "${@}" $(pgrep -f "${PSNAME}")
}

########################################

function mirror {
	declare PREFIX="$(echo "${!#}" | ${SED} "s|^(http\|ftp)[s]?://||g" | ${SED} "s|^([^/]+).*$|\1|g")-$(date --iso)"
	${WGET_R} -P "${PREFIX}" "${@}" 2>&1 | tee -a ${PREFIX}.log
}

function vlc-rc {
	if [[ -n ${@} ]]; then
		echo "${@}" | nc -q 1 127.0.0.1 4212
	else
		nc 127.0.0.1 4212
	fi
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
	if [[ ${1} == -k ]]; then
		shift
		CONTACTS="contacts-keep"
	elif [[ ${1} == -l ]]; then
		shift
		CONTACTS="contacts-ldap"
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
				"s/^xmozillaanyphone/telephoneNumber/g" \
				./${EXP_DIR}/${FILE/%\.adb}.ldif
			sudo -H -u \#1000 abook \
				--convert \
				--infile ./${FILE} \
				--informat abook \
				--outfile ./${EXP_DIR}/${FILE/%\.adb}.vcf \
				--outformat gcrd
		done
		sudo -H -u \#1000 dos2unix ./${EXP_DIR}/*.{ldif,vcf}
		chmod -R 750 ./${EXP_DIR}
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
	declare TMPDIR="/.g/_data/zactive/_zcache"
	declare MUTTRC="${HOME}/.muttrc"
	if [[ ${1} == -x ]] || [[ ${1} == -i ]]
	then
		TMPDIR="/tmp/_mutt"
	fi
	if [[ ${1} == -i ]]; then
		shift
		MUTTRC="${MUTTRC}.imap"
	fi
	sudo -H -u \#1000 \
		${MKDIR} ${TMPDIR}
	cd ${TMPDIR}
	prompt -x ${FUNCNAME}
	if [[ ${1} == -x ]]
	then
		shift
		${REALTIME} \
		sudo -H -u \#1000 \
				TMPDIR="${TMPDIR}" \
			mutt \
			-nxF /dev/null \
			-e "set sendmail = \"msmtp -d -C ${HOME}/.msmtprc\"" \
			-e "set realname = \"${EMAIL_NAME:-GaryBGenett.net Automation}\"" \
			-e "set from = \"${EMAIL_MAIL:-root@garybgenett.net}\"" \
			-e "set use_envelope_from = yes" \
			-e "set copy = no" \
			"${@}"
	else
		${REALTIME} \
		sudo -H -u \#1000 \
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
			echo -en "<tag-pattern>~A<enter>" >>${TMPFILE}
			echo -en "<tag-prefix><copy-message><kill-line>${DST}<enter>y" >>${TMPFILE}
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
	declare FAIL=
	if [[ "${1}" == -r ]]; then
		shift
		declare COMMIT="HEAD"
		declare ENTIRE=
		[[ -n "$(echo "${1}" | ${GREP} "^[a-z0-9]{40}$")" ]] && COMMIT="${1}" && shift
		[[ -z "${@}" ]] && ENTIRE="."
		touch +${FUNCNAME}				>/dev/null 2>&1 &&
		${GIT_ADD} +${FUNCNAME}				>/dev/null 2>&1 &&
		${RM} +${FUNCNAME}				>/dev/null 2>&1 &&
		${GIT} rm -r --cached .				>/dev/null 2>&1 &&
		${GIT} checkout ${COMMIT} ${ENTIRE} "${@}"	&&
		${GIT} checkout ${COMMIT} +index		>/dev/null 2>&1 &&
		index-dir ${PWD} -r "${@}"
		return 0
	fi
	if [[ "${1}" == -! ]]; then
		shift
	else
		index-dir ${PWD} -0 $(
			${GREP} "^/" .gitignore |
			${SED} -e "s|^/|./|g" -e "s|/$||g"
			)
	fi
	git-save ${FUNCNAME}				|| return 1
	if [[ -n "${1}" ]]; then
		{ git-purge "${1}" &&
			${RM} ${PWD}.gitlog; }		|| FAIL="1"
	fi
#>>>	git-logdir					|| FAIL="1"
	if [[ -n "${FAIL}" ]]; then
		return 1
	fi
	return 0
}

########################################

function git-clean {
	${GIT} reset --soft						|| return 1
	${GIT} reflog expire --verbose --all --expire-unreachable=0	|| return 1
	${GIT} gc --prune=0						|| return 1
	${GIT} gc --auto						|| return 1
	${GIT} fsck --verbose --full --no-reflogs --strict		|| return 1
	return 0
}

########################################

function git-logdir {
	declare GITDIR="${PWD}.gitlog"
	declare LAST_P="$(ls ${GITDIR}/cur 2>/dev/null |
		sort -n |
		tail -n1)"
	declare FROM_C="--root"
	declare FROM_N="1"
	if [[ ! -d ${GITDIR} ]]; then
		maildirmake ${GITDIR}
	fi
	if [[ -n "${LAST_P}" ]]; then
		FROM_C="$(${GREP} "^From[ ]" ${GITDIR}/cur/${LAST_P} |
			head -n1 |
			cut -d' ' -f2)"
		FROM_N="$(( $(echo "${LAST_P}" |
			${SED} "s/^0*//" |
			${SED} "s/-.+$//g") +1 ))"
	fi
	git-patch \
		--start-number ${FROM_N} \
		--output-directory ${GITDIR}/cur \
		${FROM_C}	|| return 1
	return 0
}

########################################

function git-purge {
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
#>>>	${RM} ${PWD}.git/refs/${FUNCNAME}				|| return 1
	git-clean							|| return 1
	return 0
}

########################################

function git-save {
	declare MESSAGE="${FUNCNAME}"
	if [[ -n ${1} ]]; then
		MESSAGE="${1}"
	fi
	${GIT_ADD} ./								|| return 1
	${GIT_CMT} --all --message="[${MESSAGE} :: $(date --iso=seconds)]"	|| return 1
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
	if ${SINGLE}; then
		echo -en "\n"
		(cd ${INDEX_D} && \
			eval find . ${EXCL_PATHS} -print		2>&3 | ${PV} -N find |
			sort						2>&3 | ${PV} -N sort |
			indexer -0					2>&3 | ${PV} -N indx |
			cat				>${INDEX_I}	) 3>&2
	else
		${MKDIR} ${INDEX_I}
		cat /dev/null						>${I_ERROR}
		(cd ${INDEX_I} && \
			${RM} $(ls -A | sort -r | tail -n+${INDEX_N})	) 2>>${I_ERROR}
		echo -en "\n"
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
	declare SED_TIME="[0-9]{2}[:][0-9]{2}[:][0-9]{2}"
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
		perl -e '
			use strict;
			use warnings;
			while(<>){
				chomp();
				my $a = [split(/\0/)];
				print "@{$a}\n";
			};
		' -- "${@}"
	elif [[ "${1}" == -m ]]; then
		shift
		perl -e '
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
		' -- "${@}"
	elif [[ "${1}" == -l ]]; then
		shift
		perl -e '
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
			print "\n Empty directories:\n"	; foreach my $out (@{$emp_dir}){ print "@{$out}\n"; };
			print "\n Empty files:\n"	; foreach my $out (@{$emp_fil}){ print "@{$out}\n"; };
			print "\n Broken symlinks:\n"	; foreach my $out (@{$brk_sym}){ print "@{$out}\n"; };
			print "\n Symlinks:\n"		; foreach my $out (@{$symlink}){ print "@{$out}\n"; };
			print "\n Failures:\n"		; foreach my $out (@{$failure}){ print "@{$out}\n"; };
		' -- "${@}"
	elif [[ "${1}" == -s ]]; then
		shift
		perl -e '
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
		' -- "${@}"
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
				declare IDX_TOUCH="$(echo -en "${FILE}" | cut -d$'\t' -f6 | cut -d, -f1 | ${SED} "s/(${SED_DATE})[T](${SED_TIME}${SED_ZONE})/\1 \2/g")"
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
	elif [[ "${1}" == -d ]]; then
		shift
		perl -e '
			use strict;
			use warnings;
			use File::Find;
			while(<>){
				chomp;
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
		' -- "${@}"
	elif [[ "${1}" == -! ]]; then
		shift
		perl -e '
			while(<>){
				chomp();
				# \000 = null character
				# \042 = double quote
				# \047 = single quote
				if($_ =~ m|([^A-Za-z0-9 \000\042\047 \(\)\[\]\{\} \!\#\$\%\&\*\+\,\/\:\;\=\?\@\^\~ _.-])|){
					print "[$1]: $_\n";
				};
			};
		' -- "${@}"
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
					${SED} -e "s/[.]0000000000//g" -e "s/(${SED_DATE})[+](${SED_TIME}${SED_ZONE})/\1T\2/g" |
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
	declare CHK_EXT="fsck -t ext4 -pCV"
	declare CHK_FAT="fsck -t vfat -V"
	declare MNT_EXT="mount -v -t ext4 -o relatime,errors=remount-ro"
	declare MNT_FAT="mount -v -t vfat -o relatime,errors=remount-ro,shortname=mixed"
	declare MNT_BND="mount -v --bind"
	declare DEV="${1}"
	declare DIR="${2}"
	declare PNT="$(df ${DEV} 2>&1 | ${GREP} "^${DEV}" | ${SED} "s/^.+[[:space:]]//g")"
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
		${CHK_EXT}	${DEV}		||
		${CHK_FAT}	${DEV}		|| return 1
		${MNT_EXT}	${DEV}	${DIR}	||
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
		${VI} "${@}" "${ORGANIZE}"{.txt,-*}
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
		if [[ -n ${1} ]]; then
			CMD="${1}"
			shift
		fi
		/usr/bin/env -i \
			PROMPT_DIRTRIM="1" \
			PS1="------------------------------\nENV(\u@\h \w)\$ " \
			USER="${USER}" \
			HOME="${HOME}" \
			TERM="${TERM}" \
			LANG="${LANG}" \
			LC_ALL="${LANG}" \
			HISTFILE="${HISTFILE}" \
			HISTSIZE="${HISTSIZE}" \
			HISTFILESIZE="${HISTFILESIZE}" \
			HISTTIMEFORMAT="${HISTTIMEFORMAT}" \
			CARCH="${CARCH}" \
			CHOST="${CHOST}" \
			CFLAGS="${CFLAGS}" \
			CXXFLAGS="${CXXFLAGS}" \
			LDFLAGS="${LDFLAGS}" \
			MAKEFLAGS="${MAKEFLAGS}" \
			CCACHE_DIR="${CCACHE_DIR}" \
			CCACHE_LOGFILE="${CCACHE_LOGFILE}" \
			PATH="${PATH}" \
			${CMD} "${@}"
		return ${PIPESTATUS[0]}
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
		'
		return ${PIPESTATUS[0]}
	fi
	if [[ ${1} == -d ]]; then
		if [[ ${2} == [0-9] ]]; then
			export DISPLAY=":${2}"
		else
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
	source ${HOME}/.bashrc
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
	chown -vR root:root ${HOME}/.screen
	chmod -vR 700 ${HOME}/.screen
	declare NAME="session"
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
	if [[ ${1} == -l ]]; then
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
			screen -xAR -S "${NAME}" "${@}" || return 1
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
	declare SSH="sudo -H ssh -2 -X"
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
	case ${DEST} in
		(me)	DEST="me.garybgenett.net"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5900[:]") ]] && OPTS="${OPTS} -L 5900:127.0.0.1:5900"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5901[:]") ]] && OPTS="${OPTS} -L 5901:127.0.0.1:5901"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5902[:]") ]] && OPTS="${OPTS} -L 5902:127.0.0.1:5902"
			if [[ ${HOSTNAME} != spider ]]; then
				[[ -z $(${PS} 2>/dev/null | ${GREP} "5909[:]") ]] && OPTS="${OPTS} -L 5909:127.0.0.1:5900"
			fi
			;;
		(you)	DEST="bastion.olympus.f5net.com"
			if [[ ${HOSTNAME} != bastion ]]; then
				[[ -z $(${PS} 2>/dev/null | ${GREP} "5909[:]") ]] && OPTS="${OPTS} -L 5909:127.0.0.1:5900"
			fi
			;;
		(1|2|3)	DEST="localhost -p6553${DEST}"
			LOG="plastic"
			;;
		(4)	DEST="localhost -p6553${DEST}"
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
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			${MKDIR} ${BAS_DIR}/${REP_DST}
			(cd ${BAS_DIR}/${REP_DST} &&
				reporter ${BAS_DIR}/repo/repo init -u ${REP_SRC//\/=\// })
		fi
		(cd ${BAS_DIR}/${REP_DST} &&
			reporter ${BAS_DIR}/repo/repo sync)
	elif [[ ${REP_TYP} == git ]]; then
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			git-clone ${REP_SRC} ${BAS_DIR}/${REP_DST}
		fi
		(cd ${BAS_DIR}/${REP_DST} &&
			${GIT} pull)
	elif [[ ${REP_TYP} == svn ]]; then
		if [[ ! -d ${BAS_DIR}/${REP_DST} ]]; then
			git-clone svn ${REP_SRC} ${BAS_DIR}/${REP_DST}
			(cd ${BAS_DIR}/${REP_DST} &&
				${GIT} checkout --force)
		fi
		(cd ${BAS_DIR}/${REP_DST} &&
			${GIT_SVN} fetch &&
			${GIT_SVN} rebase &&
			${GIT} checkout --force)
	elif [[ ${REP_TYP} == cvs ]]; then
		declare CVSROOT=":pserver:anonymous@${REP_SRC/%\/=\/*}"
		declare CVS_MOD="${REP_SRC/#*\/=\/}"
		(cd ${BAS_DIR} &&
			${CVS} -d ${CVSROOT} checkout -d ${REP_DST} ${CVS_MOD})
		if [[ -n ${REP_FUL} ]]; then
			(cd ${BAS_DIR}/${REP_DST} &&
				${GIT} -c i18n.commitencoding=ascii cvsimport -akmR)
		fi
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
		tail -f /var/log/syslog
	fi
	return 0
}

################################################################################
# end of file
################################################################################
