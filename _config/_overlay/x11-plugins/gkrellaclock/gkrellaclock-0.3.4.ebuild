# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/gkrellaclock/gkrellaclock-0.3.4.ebuild,v 1.10 2009/12/15 17:52:16 ssuominen Exp $

inherit gkrellm-plugin

IUSE=""
S=${WORKDIR}/${P/a/A}
DESCRIPTION="Nice analog clock for GKrellM2"
SRC_URI="mirror://gentoo/${P}.tar.gz"
HOMEPAGE="http://www.gkrellm.net/"

SLOT="2"
LICENSE="GPL-2"
KEYWORDS="alpha amd64 ppc sparc x86"

src_compile() {
	make clean #166133
	epatch "${FILESDIR}"/xclock_size_hack.patch

	export CFLAGS="${CFLAGS/-O?/}"
	emake || die 'emake failed'
}
