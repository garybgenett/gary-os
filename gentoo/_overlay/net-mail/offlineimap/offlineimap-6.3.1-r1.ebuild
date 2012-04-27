# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/offlineimap/offlineimap-6.3.1-r1.ebuild,v 1.8 2012/02/25 02:41:28 patrick Exp $

EAPI="3"
PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads ssl?"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* 2.7-pypy-*"

inherit eutils distutils

DESCRIPTION="Powerful IMAP/Maildir synchronization and reader support"
HOMEPAGE="http://github.com/nicolas33/offlineimap"
SRC_URI="https://github.com/nicolas33/offlineimap/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc ssl"

DEPEND="doc? ( app-text/docbook-sgml-utils )"
RDEPEND=""

# I already emailed upstream about sane tarball naming.
S="${WORKDIR}/nicolas33-${PN}-98f5181"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}"/${P}-darwin10.patch \
		"${FILESDIR}"/${P}-version.patch
}

src_compile() {
	distutils_src_compile
	if use doc ; then
		docbook2man offlineimap.sgml || die "building manpage failed"
	fi
}

src_install() {
	distutils_src_install
	dodoc offlineimap.conf offlineimap.conf.minimal
	if use doc ; then
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
