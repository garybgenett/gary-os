# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/dosemu/dosemu-1.4.0.1.ebuild,v 1.3 2009/02/06 13:40:32 hanno Exp $

inherit flag-o-matic eutils

P_FD="dosemu-freedos-1.0-bin"
DESCRIPTION="DOS Emulator"
HOMEPAGE="http://www.dosemu.org/"
SRC_URI="mirror://sourceforge/dosemu/${P_FD}.tgz
	mirror://sourceforge/dosemu/${PN}-1.4.0.tgz
	http://dosemu.sourceforge.net/prereleases/patch-${PV}.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="X svga gpm debug"

RDEPEND="X? ( x11-libs/libXxf86vm
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-apps/xset
		x11-apps/xlsfonts
		x11-apps/bdftopcf
		x11-apps/mkfontdir )
	svga? ( media-libs/svgalib )
	gpm? ( sys-libs/gpm )
	>=sys-libs/slang-1.4"

DEPEND="${RDEPEND}
	X? ( x11-proto/xf86dgaproto )
	>=sys-devel/autoconf-2.57"
S="${WORKDIR}/${PN}-1.4.0"

src_unpack() {
	unpack "${PN}-1.4.0.tgz"
	cd "${S}"

	epatch "${DISTDIR}/patch-${PV}.gz"
	epatch "${FILESDIR}"/dosemu-1.3.4-shm.diff
	epatch "${FILESDIR}/${P}-gcc433.diff"
}

src_compile() {
	# Has problems with -O3 on some systems
	replace-flags -O[3-9] -O2

	# Fix compilation on hardened
	append-flags -fno-pic

	unset KERNEL

	econf `use_with X x` \
		`use_enable svga svgalib` \
		`use_enable debug` \
		`use_with gpm` \
		--with-fdtarball="${DISTDIR}"/${P_FD}.tgz \
		--sysconfdir=/etc/dosemu/ \
		--with-docdir=/usr/share/doc/${PF} || die

	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	# Don't remove COPYING, see bug #137286
	dodoc BUGS ChangeLog COPYING NEWS README THANKS || die
}
