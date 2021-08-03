export PS1="${ROOTFS_FUNC}@${_TITLE} \w> "

alias ${ROOTFS_NAME}="exec /bin/sh /initrc ${ROOTFS_NAME}"
alias un${ROOTFS_NAME}="exec /bin/sh /initrc un${ROOTFS_NAME}"
alias dotty="getty tty0 0"
alias dottys="getty ttyS0 0"

if ${DOTEST}; then
	alias boot="kill -SIGQUIT 1"
	alias ll="ls -la"
	set -o vi
fi
