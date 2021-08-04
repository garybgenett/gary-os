# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit python-single-r1

DESCRIPTION="Funtoo's configuration tool: ego, epro, edoc, boot-update"
HOMEPAGE="http://www.funtoo.org/Package:Ego"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="zsh-completion"
GITHUB_REPO="$PN"
GITHUB_USER="funtoo"
GITHUB_TAG="${PVR}"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

DEPEND=""
RDEPEND="$PYTHON_DEPS !sys-boot/boot-update"
PDEPEND=">=dev-python/appi-0.2[${PYTHON_USEDEP}]
dev-python/mwparserfromhell[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${PN}"-??????? "${S}" || die
}

src_install() {
	exeinto /usr/share/ego/modules
	doexe $S/modules/*.ego
	rm $D/usr/share/ego/modules/upgrade*
	insinto /usr/share/ego/modules-info
	doins $S/modules-info/*
	rm $D/usr/share/ego/modules-info/upgrade*
	insinto /usr/share/ego/python
	doins -r $S/python/*
	rm -rf $D/usr/share/ego/python/test
	dobin $S/ego
	dosym ego /usr/bin/epro
	dosym ego /usr/bin/edoc
	dosym /usr/bin/ego /sbin/boot-update
	doman doc/*.[1-8]
	dodoc doc/*.rst
	insinto /etc
	doins $S/etc/*.conf*
	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/completion/zsh/_ego
	fi
}

pkg_postinst() {
	if [ ! -e $ROOT/etc/boot.conf ]; then
		einfo "Installing default /etc/boot.conf file..."
		cp -f $ROOT/etc/boot.conf.dist $ROOT/etc/boot.conf
	fi
	if [ -e $ROOT/usr/share/portage/config/repos.conf ]; then
		rm -f $ROOT/usr/share/portage/config/repos.conf
	fi
	[ -h $ROOT/usr/sbin/epro ] && rm $ROOT/usr/sbin/epro
	if [ "$ROOT" = "/" ]; then
		/usr/bin/ego sync --in-place
	fi
}
