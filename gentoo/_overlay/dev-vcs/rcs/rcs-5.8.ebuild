# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-vcs/rcs/rcs-5.8.ebuild,v 1.8 2012/03/08 22:57:34 ranger Exp $

EAPI="4"

inherit eutils

DESCRIPTION="Revision Control System"
HOMEPAGE="http://www.gnu.org/software/rcs/"
SRC_URI="mirror://gnu/rcs/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris"
IUSE="doc"

RDEPEND="sys-apps/diffutils"

#Anomoly occurs in test cases t510 & t511; an apparent bug related files in /tests.
RESTRICT="test"

src_prepare() {
	epatch "${FILESDIR}/${P}-include.patch"
	epatch "${FILESDIR}/glibc_no_more_gets_fix.patch"
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS ChangeLog NEWS README

	if use doc; then
		emake DESTDIR="${D}" install-html
		rm -R "${ED}/usr/share/doc/rcs"
		dohtml -r doc/rcs.html/
	fi
}
