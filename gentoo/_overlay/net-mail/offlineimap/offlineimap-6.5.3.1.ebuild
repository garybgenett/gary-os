# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/offlineimap/offlineimap-6.5.3.1.ebuild,v 1.1 2012/04/26 12:12:34 tomka Exp $

EAPI="3"
PYTHON_DEPEND="2:2.6"
PYTHON_USE_WITH="threads ssl?"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.[45] 3.* 2.7-pypy-*"  #see bug 394307

inherit eutils distutils

DESCRIPTION="Powerful IMAP/Maildir synchronization and reader support"
HOMEPAGE="http://offlineimap.org"
#Why doesn't this work?
#SRC_URI="mirror://github/spaetz/${PN}/tarball/v${PV} -> ${P}.tar.gz"
SRC_URI="https://github.com/spaetz/${PN}/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc ssl"

DEPEND="doc? ( dev-python/docutils )"
RDEPEND=""
S="${WORKDIR}/${PN}"

# github changed tarball internals again...
src_unpack() {
	unpack ${A}
	mv *-${PN}-* "${S}/"
}

src_prepare() {
	distutils_src_prepare
	# see http://pogma.com/2009/09/09/snow-leopard-and-offlineimap/ and bug 284925
	epatch "${FILESDIR}"/"${P}"-darwin10.patch
}

src_compile() {
	distutils_src_compile
	if use doc ; then
		cd docs
		rst2man.py MANUAL.rst offlineimap.1 || die "building manpage failed"
	fi
}

src_install() {
	distutils_src_install
	dodoc offlineimap.conf offlineimap.conf.minimal
	if use doc ; then
		cd docs
		doman offlineimap.1 || die "installing manpage failed"
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	elog ""
	elog "You will need to configure offlineimap by creating ~/.offlineimaprc"
	elog "Sample configurations are in /usr/share/doc/${PF}/"
	elog ""

	elog "If you upgraded from 6.3.* then you may need to update your config:"
	elog ""
	elog "If you use nametrans= settings on a remote repository, you will have"
	elog "to add a \"reverse\" nametrans setting to the local repository, so that"
	elog "it knows which folders it should (not) create on the remote side."
	elog ""
	elog "If you connect via ssl/tls and don't use CA cert checking, it will"
	elog "display the server's cert fingerprint and require you to add it to the"
	elog "configuration file to be sure it connects to the same server every"
	elog "time. This serves to help fixing CVE-2010-4532 (offlineimap doesn't"
	elog "check SSL server certificate) in cases where you have no CA cert."
	elog ""
}
