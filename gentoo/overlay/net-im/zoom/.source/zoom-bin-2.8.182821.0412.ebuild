# Copyright 2019 Yurij Mikhalevich <yurij@mikhalevi.ch>
# Distributed under the terms of the MIT License

EAPI=7

inherit unpacker xdg

MY_PN="${PN/-bin/}"

DESCRIPTION="Video conferencing and web conferencing service"
BASE_SERVER_URI="https://zoom.us"
HOMEPAGE="https://zoom.us"
SRC_URI="${BASE_SERVER_URI}/client/${PV}/${MY_PN}_x86_64.pkg.tar.xz -> ${MY_PN}-${PV}_x86_64.pkg.tar.xz"

LICENSE="ZOOM"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror"

IUSE="pulseaudio"

QA_PREBUILT="opt/zoom/*"

RDEPEND="${DEPEND}
	pulseaudio? ( media-sound/pulseaudio )
	dev-db/sqlite
	dev-db/unixODBC
	dev-libs/glib
	dev-libs/nss
	dev-libs/libxslt
	dev-qt/qtmultimedia
	media-libs/fontconfig
	media-libs/gstreamer:0.10
	media-libs/gst-plugins-base:0.10
	media-libs/mesa
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXi
	x11-libs/libXrender
	dev-qt/qtwebengine
	dev-qt/qtsvg"
DEPEND="${RDEPEND}
	app-admin/chrpath
"

S=${WORKDIR}

src_prepare() {
	rm -f ${WORKDIR}/.PKGINFO ${WORKDIR}/.INSTALL ${WORKDIR}/.MTREE
	rmdir usr/share/doc/zoom usr/share/doc
	sed -i -e 's:Icon=Zoom.png:Icon=Zoom:' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	sed -i -e 's:Application;::' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	chrpath -r '' opt/zoom/platforminputcontexts/libfcitxplatforminputcontextplugin.so
	scanelf -Xr opt/zoom/platforminputcontexts/libfcitxplatforminputcontextplugin.so
	eapply_user
}

src_install() {
	cp -Rp "${S}/"* "${D}"
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}
