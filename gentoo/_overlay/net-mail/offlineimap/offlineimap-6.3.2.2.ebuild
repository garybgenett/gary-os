# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/offlineimap/offlineimap-6.3.2.2.ebuild,v 1.5 2012/02/25 02:41:28 patrick Exp $

EAPI="3"
PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads ssl?"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* 2.7-pypy-*"

inherit eutils distutils

DESCRIPTION="Powerful IMAP/Maildir synchronization and reader support"
HOMEPAGE="http://offlineimap.org"
SRC_URI="https://github.com/nicolas33/offlineimap/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc ssl"

DEPEND="doc? ( dev-python/docutils )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	mv *-${PN}-* "${S}"
}

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}"/offlineimap-6.3.2-darwin10.patch
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
}
