# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4..7} )

inherit python-single-r1

GITHUB_REPO="$PN"
GITHUB_USER="funtoo"

if [ "$PV" = 9999 ]; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="*"
fi

DESCRIPTION="Funtoo's configuration tool: ego, epro, edoc."
HOMEPAGE="http://www.funtoo.org/Package:Ego"

LICENSE="GPL-2"
SLOT="0"
IUSE="zsh-completion"
RESTRICT="mirror"

DEPEND=""
RDEPEND="$PYTHON_DEPS
dev-python/appi:0/0.2[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]
dev-python/mwparserfromhell[${PYTHON_USEDEP}]"

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
	if [ ! -e $ROOT/etc/portage/repos.conf ]; then
		ln -s /var/git/meta-repo/repos.conf $ROOT/etc/portage/repos.conf
	fi
	if [ -e $ROOT/usr/share/portage/config/repos.conf ]; then
		rm -f $ROOT/usr/share/portage/config/repos.conf
	fi
	[ -h $ROOT/usr/sbin/epro ] && rm $ROOT/usr/sbin/epro
	if [ "$ROOT" = "/" ]; then
		/usr/bin/epro update
	fi
	# Temporary fix due to older versions of ego setting some root ownerships
	# under /var/git/meta-repo. This fix was introduced in version 2.0.13 and
	# can be removed in January 2018 when we can assume it was applied to the
	# vast majority of Funtoo stations.
	chown -R portage:portage $ROOT/var/git/meta-repo
}
