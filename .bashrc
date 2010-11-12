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

if [[ -f /etc/bash_completion ]]; then
	source /etc/bash_completion
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

export CARCH="i686"
export CHOST="i686-pc-linux-gnu"

export CFLAGS="-march=i686 -mtune=i686 -O2 -ggdb -pipe"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,--hash-style=gnu -Wl,--as-needed"
export MAKEFLAGS="-j3"

export CCACHE_DIR="/tmp/.ccache"
export CCACHE_LOGFILE= #>>>"/_arch/=ccache.log"

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
export PATH="${PATH}:/usr/lib/perl5/core_perl/bin"
if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	export PATH="${PATH}:/c/WINDOWS"
	export PATH="${PATH}:/c/WINDOWS/system32"
fi

########################################

export PS1='\u@\h:\w\$ '
export PS1='\
\n\
[\u@\h]:[\D{%a/%j_%FT%T%z}]\
\n\
[\#/\!]\[\033k\033\\\]:\w\$'

declare PRE_PROMPT='\
\033]0;\
${PROMPT_KEY}[ ${TERM} | ${USER}@${HOSTNAME%%.*} | ${PWD/#$HOME/~} ]\
\007'

if { [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; } &&
   { [[ -z ${PROMPT} ]] || [[ ${PROMPT} == \$P\$G ]]; }; then
	export PROMPT="cygwin"
fi

if [[ ${PROMPT} == basic ]]; then
	export PROMPT="basic"
	export PROMPT_KEY=
	export PROMPT_COMMAND=
	export PS1='[\!]\[\033k\033\\\]:\W\$'
elif [[ ${PROMPT} == simple ]]; then
	export PROMPT="simple"
	export PROMPT_KEY=
	export PROMPT_COMMAND=
	export PS1='\n[\u@\h]\n[\#/\!]\[\033k\033\\\]:\W\$'
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
	   [[ ${BASH_EXECUTION_STRING/%\ *} != rsync ]] &&
	   [[ ${BASH_EXECUTION_STRING/%\ *} != scp ]]; then
		eval "echo -en \"${PRE_PROMPT}\""
	fi
fi

################################################################################
# commands
################################################################################

export CP="cp -pvR"				; alias cp="${CP}"
export GREP="grep --color=auto -E"		; alias grep="${GREP}"
export LN="ln -fsv"				; alias ln="${LN}"
export MKDIR="mkdir -pv"			; alias mkdir="${MKDIR}"
export MORE="less -RX"				; alias more="${MORE}"
export MV="mv -v"				; alias mv="${MV}"
export PS="ps aux -ww"				; alias psl="${PS}"
export RM="rm -frv"				; alias rm="${RM}"
export RMDIR="rmdir -v"				; alias rmdir="${RMDIR}"
export SED="sed -r"				; alias sed="${SED}"
export VI="vim -u ${HOME}/.vimrc -i NONE"	; alias vi="${VI}"
export VIEW="eval ${VI} -nR -c \"set nowrap\""	; alias view="${VIEW/#eval\ /}"

########################################

export PAGER="${MORE}"
export EDITOR="${VI}"
unset VISUAL

########################################

export LS="ls --color=auto"			; alias ls="${LS}"
export LL="ls --color=auto -asF -l"		; alias ll="${LL}"
export LX="ls --color=auto -asF -kC"		; alias lx="${LX}"
export LF="eval ${LL} -d \
\`find . -maxdepth 1 ! -type l\`"		; alias lf="${LF}"

export DU="du -b --time --time-style=long-iso"	; alias du="${DU}"
export LU="${DU} -ak --max-depth 1"		; alias lu="${LU}"

########################################

export GIT_CMD="git"
export GIT="reporter ${GIT_CMD}"		; alias git="${GIT}"
export GIT_ADD="${GIT} add --verbose"		; alias git-add="${GIT_ADD}"
export GIT_CMT="${GIT} commit --verbose"	; alias git-commit="${GIT_CMT}"
export GIT_STS="${GIT} status"			; alias git-status="${GIT_STS}"
export GIT_SVN="${GIT} svn"			; alias git-svn="${GIT_SVN}"

export DIFF_OPTS="-u -U10"
export GIT_FMT="-M --full-index --summary --stat=128,128 --date=iso --pretty=fuller"
export GIT_PAT="-M --full-index --summary --stat=128,128 --attach --binary --keep-subject"

########################################

export CVS="reporter cvs"							; alias cvs="${CVS}"
export SVN="reporter svn"							; alias svn="${SVN}"

export METASTORE="metastore --file +metastore --verbose --mtime"		; alias metastore="${METASTORE}"
export RDP="rdesktop -z -n NULL -g 90% -a 24 -r sound:remote"			; alias rdp="${RDP}"
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
	--remove-older-than 3Y"

alias rdiff-backup="${RDIFF_BACKUP}"
alias rdiff-rm="${RDIFF_RM}"

########################################

export RSYNC_C="reporter rsync \
	-vv \
	--rsh=ssh \
	--recursive \
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

export WGET="wget \
	--verbose \
	--user-agent=Mozilla/5.0 \
	--execute robots=off \
	--server-response \
	--restrict-file-names=windows \
	--no-check-certificate \
	--recursive \
	--level=inf \
	--force-directories \
	--no-host-directories \
	--no-parent \
	--backup-converted \
	--page-requisites \
	--html-extension \
	--convert-links \
	--timestamping \
	--random-wait \
	--tries=3 \
	--wait=3"

#>>>alias wget="${WGET}"

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

alias synctail="tail -f /.g/_data/+sync/_sync.log"
alias logtail="tail -f /.runit/log/syslogd"

alias rsynclook="${GREP} -v '^[.<>c][fdDLS]'"
alias tcplook="tcpdump -r /.runit/log/tcpdump"

alias filter="iptables -L -nvx --line-numbers | ${MORE}"
alias natter="iptables -L -nvx --line-numbers -t nat | ${MORE}"
alias mangler="iptables -L -nvx --line-numbers -t mangle | ${MORE}"

########################################

alias adb="$(ls /.g/_data/source/android/android-sdk-linux*/tools/adb 2>/dev/null)"
if [[ -n ${CYGWIN} ]] || [[ -n ${CYGWIN_ROOT} ]]; then
	alias adb="\"$(ls "${SYSTEMROOT}/android-sdk-windows/tools/adb" 2>/dev/null)\""
fi
alias clean="_sync clean"
alias clock="clockywock"
alias cryptsetup="cryptsetup --hash sha256 --cipher aes-cbc-essiv:sha256 --key-size 256"
alias dd="dcfldd"
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
alias projectm="LC_NUMERIC=C projectM-pulseaudio"
alias pstree="pstree -clnpuA"
alias remind="remind -v -uplastic"
alias schedule="remind -v -uplastic -g -m -b1 -cc+2 -w90 ${HOME}/.reminders"
alias sheep="electricsheep --debug 1 --mplayer 1 --server d2v6.sheepserver.net"
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
		cdrecord -v --devices "${@}"
	elif [[ ${1} == -i ]]; then
		shift
		cdrecord -v -data "${@}"
	elif [[ ${1} == -e ]]; then
		shift
		cdrecord -v -eject "${@}"
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
		mke2fs -jvm 0 "${@}"
	fi
}

########################################

function git {
	$(which git) --git-dir="${PWD}.git" --work-tree="${PWD}" "${@}"
}

########################################

function git-list {
	${GIT_CMD} log --pretty=format:"%ai %H %s %d" "${@}"
}

########################################

function git-patch {
	if [[ ${1} == -l ]]; then
		shift
		${GIT} format-patch ${GIT_PAT/--binary/--no-binary} ${DIFF_OPTS} "${@}"
	else
		${GIT} format-patch ${GIT_PAT} ${DIFF_OPTS} "${@}"
	fi
}

########################################

function ldir {
	${LL} -R "${@}" | more
}

########################################

function nxrun {
	prompt -d 8
	_menu ${@}
	tail -f /.runit/log/nxproxys
}

########################################

function pages {
	calc "$(lynx -dump "${@}" | wc -l) / 60"
}

########################################

function psg {
	$(which ps) -uww -p $(pgrep -d, -f "${@}" | ${SED} "s/[,]$//g")
}

########################################

function psk {
	declare PSNAME="${1}" && shift
	kill "${@}" $(pgrep -f "${PSNAME}")
}

########################################

function mirror {
	declare PREFIX="$(echo "${!#}" | ${SED} "s|^(http\|ftp)[s]?://||g" | ${SED} "s|^([^/]+)/.+$|\1|g")-$(date +%Y.%m.%d)"
	${WGET} -P "${PREFIX}" "${@}" 2>&1 | tee -a ${PREFIX}.log
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
	${MKDIR} ${TMPDIR}
	cd ${TMPDIR}
	prompt -x ${FUNCNAME}
	if [[ ${1} == -x ]]
	then
		shift
		sudo -H -u \#1000 mutt \
			-nxF /dev/null \
			-e "set sendmail = \"msmtp -d -C ${HOME}/.msmtprc\"" \
			-e "set realname = \"${EMAIL_NAME:-GaryBGenett.net Automation}\"" \
			-e "set from = \"${EMAIL_MAIL:-root@garybgenett.net}\"" \
			-e "set use_envelope_from = yes" \
			-e "set copy = no" \
			"${@}"
	else
		sudo -H -u \#1000 EDITOR="${VI} +/^$" mutt \
			-nF ${HOME}/.muttrc \
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
	if [[ -n "$(which metastore)" ]]; then
#>>>		${METASTORE} --compare |
#>>>			${GREP} -v "no difference" |
#>>>			sort >+metastore.diff					|| FAIL="1"
		${METASTORE} --save						|| FAIL="1"
	fi
	${GIT_ADD} ./								|| return 1
	${GIT_CMT} --all --message="[${FUNCNAME} :: $(date --iso=s)]"		|| return 1
	if [[ -n "${1}" ]]; then
		{ git-purge "${1}" &&
			${RM} ${PWD}.gitlog; }					|| FAIL="1"
	fi
#>>>	git-logdir								|| FAIL="1"
	if [[ -n ${FAIL} ]]; then
		return 1
	fi
	return 0
}

########################################

function git-clean {
	${GIT} reset --soft					|| return 1
	${GIT} reflog expire --all --expire-unreachable=0	|| return 1
	${GIT} gc --prune=0					|| return 1
	${GIT} gc --auto					|| return 1
	${GIT} fsck --full --no-reflogs --strict		|| return 1
	return 0
}

########################################

function git-logdir {
	declare GITDIR="${PWD}.gitlog"
	declare LAST_P="$(ls ${GITDIR}/cur 2>/dev/null |
		sort -n |
		tail -n1)"
	declare FROM_C="$(${GIT_CMD} log --full-index --pretty=oneline |
		tail -n1 |
		cut -d' ' -f1)"
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
	git-patch -l \
		--start-number ${FROM_N} \
		--output-directory ${GITDIR}/cur \
		${FROM_C}	|| return 1
	return 0
}

########################################

function git-purge {
	declare MEM_DIR="/dev/shm"
	declare PURGE="$(${GIT_CMD} rev-parse "HEAD@{${1}}")" && shift
	declare _HEAD="$(${GIT_CMD} rev-parse "HEAD")"
	if [[ -z ${PURGE} ]] ||
	   [[ -z ${_HEAD} ]] ||
	   [[ ${PURGE} == ${_HEAD} ]]; then
		echo -en "\n !!! ERROR IN PURGE REQUEST !!!\n\n" >&2
		return 1
	fi
	${GIT} filter-branch \
		-d ${MEM_DIR}/.git_purge \
		--original refs/.git_purge \
		--parent-filter "[ ${PURGE} = \$GIT_COMMIT ] || cat" \
		HEAD			|| return 1
#>>>	${RM} ./.git_purge		|| return 1
#>>>	${RM} ./.git/refs/.git_purge	|| return 1
	git-clean			|| return 1
	return 0
}

########################################

function journal {
	declare JOURNAL_DIR="/.g/_data/zactive/_pim/journal"
	if [[ -d "${1}" ]]; then
		JOURNAL_DIR="${1}"
		shift
	fi
	cd "${JOURNAL_DIR}"
	prompt -x ${FUNCNAME}
	${VI} \
		"${@}" \
		$(date --iso=s).txt
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

function organize {
	declare SEARCH="\*"
	declare ORGANIZE="_mission.txt"
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
		${SED} "s/^[[:space:]]+//g" "${ORGANIZE}" |
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
		${SED} "s/^[[:space:]]+//g" "${ORGANIZE}" |
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
		${VI} "${@}" "${ORGANIZE}"
	fi
	prompt
	cd - >/dev/null
	return 0
}

########################################

function prompt {
	if [[ ${1} == -z ]]; then
		shift
		export CMD="bash --login --noprofile --norc -o vi"
		if [[ ${1} == zsh ]]; then
			shift
			CMD="zsh -l -d -f ${@}"
		elif [[ -n ${@} ]]; then
			CMD="${@}"
		fi
		/usr/bin/env -i \
			PS1='------------------------------\nENV(\u@\h \w)\$ ' \
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
			${CMD} || return 1
		return 0
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
	elif [[ ${1} == -b ]]; then
		export PROMPT="basic"
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
	declare CMD="$(basename ${1})"
	declare SRC="$((${#}-1))"	; SRC="${!SRC}"
	declare DST="${#}"		; DST="${!DST}"
	echo -en "\n reporting [${CMD}]: '${SRC}' -> '${DST}'\n"
	echo -en "(${HOSTNAME}:${PWD}) ${@}\n"
	time "${@}" || return 1
	return 0
}

########################################

function session {
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
			screen -xAR "${@}" || return 1
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
		prompt -x "${FUNCNAME}_${DEST}"
		minicom ${DEST}
		prompt
		cd - >/dev/null
		return 0
	fi
	case ${DEST} in
		(me)	DEST="me.garybgenett.net"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5900[:]") ]] && OPTS="${OPTS} -L 5900:127.0.0.1:5900"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5901[:]") ]] && OPTS="${OPTS} -L 5901:127.0.0.1:5901"
			;;
		(hp)	DEST="hp.gbg.es.f5net.com"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5903[:]") ]] && OPTS="${OPTS} -L 5903:127.0.0.1:5900"
			;;
		(nin)	DEST="pogo.gbg.es.f5net.com"
			[[ -z $(${PS} 2>/dev/null | ${GREP} "5904[:]") ]] && OPTS="${OPTS} -L 5904:127.0.0.1:5901"
			;;
		(1|2)	DEST="localhost -p6553${DEST}"
			LOG="plastic"
			;;
		(3|4)	DEST="localhost -p6553${DEST}"
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
		OPTS="${OPTS} -t \"bash -c 'source ~/.bashrc ; session -p${1/#-s/}'\""
		shift
	fi
	cd
	prompt -x "${FUNCNAME}_${DEST}"
	eval TERM=ansi ${SSH} ${LOG}@${DEST} ${OPTS} "${@}"
	prompt
	cd - >/dev/null
	return 0
}

########################################

function vdiff {
	declare VDIFF="/tmp/vdiff"
	declare SEARCH=
	if [[ ${1} == -g ]]; then
		shift
		SEARCH="+/^diff"
		declare TREE=
		[[ -z ${1} ]]		&& TREE="HEAD"			&& shift
		[[ ${1} == -c ]]	&& TREE="--cached HEAD"		&& shift
		[[ ${1} == -i ]]	&& TREE=""			&& shift
		echo "diff" >${VDIFF}
		${GIT_CMD} diff ${GIT_FMT} ${DIFF_OPTS} ${TREE} "${@}" >>${VDIFF} 2>&1
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
	else
		cd /.g/_data/zactive/data.f5/zwww/scripts/sslvpn
		killall -9 pppd
		./${1}.sh
		cd - >/dev/null
	fi
	return 0
}

################################################################################
# end of file
################################################################################
