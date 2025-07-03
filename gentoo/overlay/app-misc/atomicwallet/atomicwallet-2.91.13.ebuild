EAPI=8
inherit desktop unpacker xdg

DESCRIPTION="Crypto Wallet for Buying, Staking & Exchanging"
HOMEPAGE="https://atomicwallet.io"
SRC_URI="https://releases.atomicwallet.io/AtomicWallet-${PV}.deb"
#>>> https://atomicwallet.io/licensing

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

#>>>	sys-libs/libuuid -> sys-apps/util-linux
RDEPEND="
	x11-libs/gtk+
	x11-libs/libnotify
	dev-libs/nss
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-misc/xdg-utils
	app-accessibility/at-spi2-core
	sys-apps/util-linux
	app-crypt/libsecret
"

S="${WORKDIR}"

src_install() {
	insinto /opt
	cp -aR ${S}'/opt/Atomic Wallet' ${D}/opt/atomicwallet

	dodir /usr/bin
	dosym -r /opt/atomicwallet/atomic /usr/bin/atomic

	insinto /usr/share/applications
	newins ${S}/usr/share/applications/atomic.desktop atomic.desktop
	insinto /usr/share/pixmaps
	newins ${S}/usr/share/icons/hicolor/0x0/apps/atomic.png atomic.png
}

pkg_postinst() {
	xdg_pkg_postinst
}
