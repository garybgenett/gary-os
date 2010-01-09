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
export LC_ALL="en_US.UTF-8"
export LC_COLLATE="C"
#>>>export LC_TIME="en_DK.UTF-8"
export LC_ALL=

export HISTFILE="${HOSTNAME}.${USER}.$(basename ${SHELL}).$(date +%Y-%m)"
export HISTFILE="${HOME}/.history/shell/${HISTFILE}"
export HISTSIZE="$(( (2**31)-1 ))"
export HISTFILESIZE="${HISTFILESIZE}"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S "

export MAKEFLAGS="-j3"
export CC="gcc"
export CXX="g++"
export CFLAGS="-march=i686 -mtune=i686 -O2 -ggdb -pipe"
export CXXFLAGS="${CFLAGS}"
export CCACHE_DIR="/_ccache"
export PKG_CONFIG_PATH="/System/Links/Libraries/pkgconfig:/usr/lib/pkgconfig"

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
#>>>export PATH="${PATH}:/Programs/CCache/Current/bin"
export PATH="${PATH}:/System/Links/Executables"
export PATH="${PATH}:/usr/local/bin"
export PATH="${PATH}:/usr/local/sbin"
export PATH="${PATH}:/usr/bin"
export PATH="${PATH}:/usr/sbin"
export PATH="${PATH}:/bin"
export PATH="${PATH}:/sbin"
export PATH="${PATH}:/usr/X11R6/bin"
export PATH="${PATH}:/usr/games"
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
[\#/\!]\033k\033\\:\w\$'

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
	export PS1='[\!]\033k\033\\:\W\$'
elif [[ ${PROMPT} == simple ]]; then
	export PROMPT="simple"
	export PROMPT_KEY=
	export PROMPT_COMMAND=
	export PS1='\n[\u@\h]\n[\#/\!]\033k\033\\:\W\$'
else
	if [[ -z ${PROMPT} ]]; then
		export PROMPT=
		export PROMPT_KEY=
	else
		export PROMPT="${PROMPT}"
		export PROMPT_KEY="( ${PROMPT} )"
	fi
	export PROMPT_COMMAND="echo -ne \"${PRE_PROMPT}\""
	if [[ -n ${PROMPT_KEY} ]] &&
	   [[ ${BASH_EXECUTION_STRING/%\ *} != rsync ]] &&
	   [[ ${BASH_EXECUTION_STRING/%\ *} != scp ]]; then
		eval "echo -ne \"${PRE_PROMPT}\""
	fi
fi

################################################################################
# commands
################################################################################

export CP="cp -pvR"						; alias cp="${CP}"
export GREP="grep --color=auto -E"				; alias grep="${GREP}"
export LN="ln -fsv"						; alias ln="${LN}"
export MKDIR="mkdir -pv"					; alias mkdir="${MKDIR}"
export MORE="less -RX"						; alias more="${MORE}"
export PS="ps -auwwx"						; alias psl="${PS}"
export MV="mv -v"						; alias mv="${MV}"
export RM="rm -frv"						; alias rm="${RM}"
export RMDIR="rmdir -v"						; alias rmdir="${RMDIR}"
export VI="vim -u ${HOME}/.vimrc -i NONE"			; alias vi="${VI}"
export VIEW="eval ${VI} -nR -c \"set nowrap\""			; alias view="${VIEW/#eval\ /}"

########################################

export PAGER="${MORE}"
export EDITOR="${VI}"
unset VISUAL

########################################

export LS="ls --color=auto"					; alias ls="${LS}"
export LL="ls --color=auto -asF -l"				; alias ll="${LL}"
export LX="ls --color=auto -asF -kC"				; alias lx="${LX}"
if [[ ${UNAME} == FreeBSD ]]; then
	export LS="ls -G"					; alias ls="${LS}"
	export LL="ls -G -asF -l"				; alias ll="${LL}"
	export LX="ls -G -asF -kx"				; alias lx="${LX}"
fi
export LF="eval ${LL} -d \`find . -maxdepth 1 ! -type l\`"	; alias lf="${LF}"

########################################

export DU="du -b --time --time-style=long-iso"			; alias du="${DU}"
export LU="${DU} -ak --max-depth 1"				; alias lu="${LU}"

########################################

export SED="sed -r"						; alias sed="${SED}"
if [[ ${UNAME} == FreeBSD ]]; then
	export SED="sed -E"					; alias sed="${SED}"
fi

########################################

export RDP="rdesktop -z -n NULL -g 90% -a 24 -r sound:remote"	; alias rdp="${RDP}"
export SVN="reporter svn"					; alias svn="${SVN}"

########################################

export GOBO_ENV="prompt -z"
if [[ -f /etc/debian_version ]] &&
   [[ -n $(mount | ${GREP} "/.g/[+]gobo") ]]; then
	export GOBO_ENV="prompt -z -g"
fi

export GOBO_COMPILE="/Programs/Compile/Current/bin/Compile \
	--batch \
	--no-dependencies \
	--symlink force"
export GOBO_FINDPKG="/Programs/Scripts/Current/bin/FindPackage \
	--substring"
export GOBO_FRESHEN="/Programs/Freshen/Current/bin/Freshen \
	--no-cache \
	--recipe \
	--prompt-install"
#>>>	--with-revisions \
#>>>	--thorough \
#>>>	--package \
export GOBO_INSTALL="/Programs/Scripts/Current/bin/InstallPackage \
	--batch \
	--keep \
	--same remove"
export GOBO_REMPROG="/Programs/Scripts/Current/bin/RemoveProgram"
export GOBO_SYMLINK="/Programs/Scripts/Current/bin/SymlinkProgram \
	--conflict overwrite \
	--unmanaged install \
	--relative"

alias        Compile="${GOBO_ENV} ${GOBO_COMPILE}"
alias    FindPackage="${GOBO_ENV} ${GOBO_FINDPKG}"
alias        Freshen="${GOBO_ENV} ${GOBO_FRESHEN}"
alias InstallPackage="${GOBO_ENV} ${GOBO_INSTALL}"
alias  RemoveProgram="${GOBO_ENV} ${GOBO_REMPROG}"
alias SymlinkProgram="${GOBO_ENV} ${GOBO_SYMLINK}"

########################################

export DIFF_OPTS="-u -U10"

export GIT="reporter git"
export GIT_FMT="-B -M --full-index --stat --summary --date=iso --pretty=fuller"
export GIT_PAT="-B -M --full-index --stat --summary --binary --keep-subject --raw ${DIFF_OPTS}"

alias git="${GIT}"
alias git-add="${GIT} add --verbose"
alias git-commit="${GIT} commit --verbose"
alias git-patch="${GIT} format-patch ${GIT_PAT}"

########################################

export RDIFF_BACKUP="reporter rdiff-backup \
	-v6 \
	--force \
	--backup-mode \
	--no-hard-links \
	--preserve-numerical-ids"
export RDIFF_RM="rdiff-backup \
	--force \
	--remove-older-than 1Y"

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
alias vlc-vlm="telnet 127.0.0.1 4212"
if [[ ${UNAME} == FreeBSD ]]; then
	alias watch="cmdwatch"
fi
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
		if [[ ${UNAME} == FreeBSD ]]; then
			newfs -U "${@}"
		else
			mke2fs -jvm 0 "${@}"
		fi
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

function archiver {
	declare DATE="$(date --iso=s)"
	declare YEAR="${DATE/%-*}"
	declare PIM
	declare FILE
	declare FOLD
	declare EXTN
	declare LAST
	declare INPUT
	cd ${PIMDIR}
	prompt -x ${FUNCNAME}
	for PIM in \
		_mission:_mission:txt \
		bookmarks:bookmarks:html \
		calendar:calendar:rem \
		contacts:contacts:adb \
		contacts-keep:contacts:adb \
		passwords:passwords:kdb
	do
		FILE="$(echo "${PIM}" | ${SED} "s/^(.+):(.+):(.+)$/\1/g")"
		FOLD="$(echo "${PIM}" | ${SED} "s/^(.+):(.+):(.+)$/\2/g")"
		EXTN="$(echo "${PIM}" | ${SED} "s/^(.+):(.+):(.+)$/\3/g")"
		LAST="$(ls ${PIMDIR}/${FOLD}-[0-9][0-9][0-9][0-9]/${FILE}-[0-9][0-9][0-9][0-9]-*.${EXTN} 2>/dev/null | sort | tail -n1)"
		echo -ne "${FILE}:\t$(basename ${LAST})\n"
		if [[ -z $(diff ${LAST} ${PIMDIR}/${FILE}.${EXTN} 2>/dev/null) ]]; then
			continue
		fi
		vdiff ${LAST} ${PIMDIR}/${FILE}.${EXTN}
		echo -ne "\n Archive (y/n)? "
		read -n1 INPUT
		echo -ne "\n"
		if [[ ${INPUT} != y ]]; then
			continue
		fi
		if [[ ! -d ${PIMDIR}/${FOLD}-${YEAR} ]]; then
			${MKDIR} ${PIMDIR}/${FOLD}-${YEAR}
		fi
		${CP} ${PIMDIR}/${FILE}.${EXTN} ${PIMDIR}/${FOLD}-${YEAR}/${FILE}-${DATE}.${EXTN}
		for INPUT in contacts contacts-keep; do
			if [[ ${FILE}.${EXTN} == ${INPUT}.adb ]]; then
				${RM} ${PIMDIR}/${INPUT}.vcf
				sudo -H -u \#1000 abook \
					--convert \
					--infile ${PIMDIR}/${INPUT}.adb \
					--informat abook \
					--outfile ${PIMDIR}/${INPUT}.vcf \
					--outformat gcrd
				sudo -H -u \#1000 dos2unix ${PIMDIR}/${INPUT}.vcf
			fi
		done
	done
	prompt
	cd - >/dev/null
	return 0
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
	if [[ ${1} == -k ]]; then
		shift
		CONTACTS="contacts-keep"
	fi
	cd ${PIMDIR}
	prompt -x ${FUNCNAME}
	sudo -H -u \#1000 abook \
		--config ${HOME}/.abookrc \
		--datafile ${CONTACTS}.adb \
		"${@}"
	prompt
	cd - >/dev/null
	return 0
}

########################################

function edit {
	declare DIFF="diff"
	declare EDIT="vi"
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
			echo -ne "\n----------[ ${FILE} ]----------\n"
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
			-e "set realname = \"GaryBGenett.net Automation\"" \
			-e "set from = \"root@garybgenett.net\"" \
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
		echo -ne "set mbox_type = maildir\n" >${TMPFILE}
		echo -ne "folder-hook . \"push " >>${TMPFILE}
			echo -ne "<tag-pattern>~A<enter>" >>${TMPFILE}
			echo -ne "<tag-prefix><copy-message><kill-line>${DST}<enter>y" >>${TMPFILE}
			echo -ne "<quit>y" >>${TMPFILE}
		echo -ne "\"\n" >>${TMPFILE}
		sudo -H -u \#1000 mutt \
			-nF ${TMPFILE} \
			-zRf ${SRC}
		${RM} ${TMPFILE}
	fi
	return 0
}

########################################

function git-backup {
	${GIT} add --verbose .							|| return 1
	${GIT} commit --all --message="[${FUNCNAME} :: $(date --iso=s)]"	|| return 1
	declare FAIL=
	if [[ -n "${1}" ]]; then
		git-purge "${1}"	|| FAIL="1"
		git-logfile		|| FAIL="1"
	fi
	if [[ -n ${FAIL} ]]; then
		return 1
	fi
	return 0
}

########################################

function git-logfile {
	$(which git) log ${GIT_FMT} --walk-reflogs >./+gitlog.txt	|| return 1
	return 0
}

########################################

function git-purge {
	declare PURGE="$($(which git) rev-parse "HEAD@{${1}}")" && shift
	declare _HEAD="$($(which git) rev-parse "HEAD")"
	if [[ -z ${PURGE} ]] ||
	   [[ -z ${_HEAD} ]] ||
	   [[ ${PURGE} == ${_HEAD} ]]; then
		echo -ne "\n !!! ERROR IN PURGE REQUEST !!!\n\n" >&2
		return 1
	fi
	${GIT} filter-branch \
		-d /dev/shm/.git_filter \
		--original refs/.git_filter \
		--parent-filter "[ ${PURGE} = \$GIT_COMMIT ] || cat" \
		HEAD						|| return 1
	${RM} ${G_DATA}/_gobo/.git/refs/.git_filter		|| return 1
	${GIT} reset --soft					|| return 1
	${GIT} reflog expire --all --expire-unreachable=0	|| return 1
	${GIT} gc --prune=0					|| return 1
	${GIT} gc --auto					|| return 1
	${GIT} fsck --full --no-reflogs --strict		|| return 1
	return 0
}

########################################

function journal {
	cd /.g/_data/zactive/writing/tresobis/_staging
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
		elif [[ ${1} == -d ]]; then
			shift
			CMD="chroot /.g/+debian ${@}"
		elif [[ ${1} == -g ]]; then
			shift
			CMD="chroot /.g/+gobo ${@}"
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
			MAKEFLAGS="${MAKEFLAGS}" \
			CC="${CC}" \
			CXX="${CXX}" \
			CFLAGS="${CFLAGS}" \
			CXXFLAGS="${CXXFLAGS}" \
			CCACHE_DIR="${CCACHE_DIR}" \
			PKG_CONFIG_PATH="${PKG_CONFIG_PATH}" \
			PATH="${PATH}" \
			${CMD} || return 1
		return 0
	fi
	if [[ ${1} == -g ]]; then
		cd /.g/_data/source/gobolinux
		source Programs/Rootless/Current/bin/StartRootless
		cd - >/dev/null
		return 0
	fi
	if [[ ${1} == -d ]]; then
		if [[ ${2} == [0-9] ]]; then
			export DISPLAY=":${2}.0"
		else
			export DISPLAY=":0.0"
		fi
		if [[ ${2} == -x ]] || [[ ${3} == -x ]]; then
			declare XAUTH="/var/lib/xdm/{,authdir/}authfiles/*"
			export XAUTHORITY="$(eval "ls ${XAUTH}" 2>/dev/null | head -n1)"
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
		echo -ne "\n ${DEV}:\n"
		tc -d -s filter show dev ${DEV}
		echo -ne "\n"
		tc -d -s qdisc show dev ${DEV}
		echo -ne "\n"
		tc -d -s class show dev ${DEV}
	done 2>&1 | ${MORE}
	return 0
}

########################################

function reporter {
	declare CMD="$(basename ${1})"
	declare SRC="$((${#}-1))"	; SRC="${!SRC}"
	declare DST="${#}"		; DST="${!DST}"
	echo -ne "\n reporting [${CMD}]: '${SRC}' -> '${DST}'\n"
	echo -ne "(${HOSTNAME}:${PWD}) ${@}\n"
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
		(run)	DEST="me.garybgenett.net"
			LOG="plastic"
			OPTS="${OPTS} \"bash -c 'source ~/.bashrc ; _menu ${1}'\""
			shift
			;;
		(bas)	DEST="bastion.olympus.f5net.com"
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

function sslvpn {
	cd /.g/_data/zactive/data.f5/zwww/scripts/sslvpn
	killall -9 pppd
	./${1}.sh
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
		[[ -z ${1} ]] && TREE="HEAD" && shift
		[[ ${1} == -c ]] && TREE="--cached" && shift
		echo "diff" >${VDIFF}
		$(which git) diff ${GIT_FMT} ${DIFF_OPTS} ${TREE} "${@}" >>${VDIFF} 2>&1
	elif [[ ${1} == -l ]] ||
	     [[ ${1} == -s ]]; then
		declare DIFF="${DIFF_OPTS}"
		[[ ${1} == -s ]] && DIFF=
		shift
		SEARCH="+/^commit"
		declare FOLLOW=
		declare FILE="${#}"
		(( ${FILE} > 0 )) && [[ -f ${!FILE} ]] && FOLLOW="--follow"
		$(which git) log ${GIT_FMT} ${DIFF} ${FOLLOW} "${@}" >${VDIFF} 2>&1
	else
		diff ${DIFF_OPTS} "${@}" >${VDIFF}
	fi
	${VIEW} ${SEARCH} ${VDIFF}
	${RM} ${VDIFF} >/dev/null 2>&1
	return 0
}

########################################

function vpn {
	if [[ ${1} == 0 ]]; then
		ifdown eth0
		ifup eth0
		ifdown eth1
		ifup eth1
		/etc/init.d/openvpn stop
		psk "openvpn"
		psk "adb fork-server server"
	elif [[ ${1} == 1 ]]; then
		setconf /etc/openvpn
		${VI} +/remote /etc/openvpn/openvpn.conf
		${FUNCNAME} 0
		adb forward tcp:443 localabstract:Tunnel
		/etc/init.d/openvpn start
	elif [[ ${1} == -a ]]; then
		killall -9 autossh
		autossh \
			-M 0 -f \
			-i ${HOME}/.ssh/remote_id \
			-R 65535:127.0.0.1:22 \
			plastic@me.garybgenett.net
	elif [[ ${1} == -x ]]; then
		shell $(
			arp -an |
			${GREP} -i "$(
				cat /etc/openvpn/status.log |
				${GREP} "^[0-9a-f:]+,client.garybgenett.net" |
				cut -d, -f1
			)" |
			${SED} "s/^.+\((.+)\).+$/\1/g"
		) -v9
	elif [[ ${1} == -c ]]; then
		shift
		declare DEST="${1}" && shift
		pkill -9 -f "do[ ]htc"
		killall -9 htc
		(bash -c "while :; do htc -w -F 8080 ${DEST}:8080 ; sleep 10 ; done" \
			>/dev/null 2>&1 &)
	elif [[ ${1} == -s ]]; then
		shift
		pkill -9 -f "do[ ]hts"
		killall -9 hts
		(bash -c "while :; do hts -w -F 127.0.0.1:22 8080 ; sleep 10 ; done" \
			>/dev/null 2>&1 &)
	elif [[ ${1} == -z ]]; then
		pkill -9 -f "do[ ]htc"
		killall -9 htc
		pkill -9 -f "do[ ]hts"
		killall -9 hts
	fi
	return 0
}

################################################################################
# end of file
################################################################################
