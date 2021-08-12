# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Advanced Linux Sound Architecture OSS compatibility layer"
HOMEPAGE="https://alsa-project.org/"
SRC_URI="https://www.alsa-project.org/files/pub/oss-lib/alsa-oss-1.1.8.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND=">=media-libs/alsa-lib-${PV}"
DEPEND="${RDEPEND}"

PATCHES=( "${REPODIR}/media-sound/files/${PN}/${PN}-1.0.12-hardened.patch" )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-aoss
		$(use_enable static-libs static)
	)
	ECONF_SOURCE=${S} econf "${myeconfargs[@]}"
}

src_install() {
	einstalldocs
	if ! use static-libs ; then
		find "${ED}" -name '*.a' -delete || die
	fi
	find "${ED}" -name '*.la' -delete || die
	sed -e 's:\${exec_prefix}/\\$LIB/::' -i "${ED}/usr/bin/aoss" || die
}