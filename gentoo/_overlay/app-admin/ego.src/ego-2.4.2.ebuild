# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4..7} )

inherit python-single-r1

DESCRIPTION="Funtoo's configuration tool: ego, epro, edoc."
HOMEPAGE="http://www.funtoo.org/Package:Ego"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="zsh-completion"
RESTRICT="mirror"
GITHUB_REPO="$PN"
GITHUB_USER="funtoo"
GITHUB_TAG="${PV}"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

DEPEND=""
RDEPEND="$PYTHON_DEPS"
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
	insinto /usr/share/ego/modules-info
	doins $S/modules-info/*
	insinto /usr/share/ego/python
	doins -r $S/python/*
	rm -rf $D/usr/share/ego/python/test
	dobin $S/ego
	dosym ego /usr/bin/epro
	dosym ego /usr/bin/edoc
	doman doc/*.[1-8]
	insinto /etc
	doins $FILESDIR/ego.conf
	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/completion/zsh/_ego
	fi
}

pkg_postinst() {
	if [ -e $ROOT/usr/share/portage/config/repos.conf ]; then
		rm -f $ROOT/usr/share/portage/config/repos.conf
	fi
	[ -h $ROOT/usr/sbin/epro ] && rm $ROOT/usr/sbin/epro
	if [ "$ROOT" = "/" ]; then
		/usr/bin/ego sync --config-only
	fi
}
