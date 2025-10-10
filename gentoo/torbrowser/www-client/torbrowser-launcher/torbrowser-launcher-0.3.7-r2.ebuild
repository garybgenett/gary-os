# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 optfeature xdg

DESCRIPTION="A program to download, update and run the Tor Browser Bundle"
HOMEPAGE="https://gitlab.torproject.org/tpo/applications/torbrowser-launcher"
SRC_URI="https://gitlab.torproject.org/tpo/applications/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.bz2"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

FIREFOX_BIN="app-accessibility/at-spi2-core
	dev-libs/dbus-glib
	>=dev-libs/glib-2.26:2
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	sys-apps/dbus
	virtual/freedesktop-icon-theme
	>=x11-libs/cairo-1.10[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-3.11:3[wayland,X]
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXt
	>=x11-libs/pango-1.22.0"

DEPEND="${PYTHON_DEPS}
	dev-python/distro[${PYTHON_USEDEP}]"

RDEPEND="${PYTHON_DEPS}
	${FIREFOX_BIN}
	dev-python/gpgmepy[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pyqt5[${PYTHON_USEDEP},widgets]
	dev-python/pysocks[${PYTHON_USEDEP}]
	dev-python/distro[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	!www-client/torbrowser"

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "updating over system Tor" net-vpn/tor dev-python/txsocksx
}
