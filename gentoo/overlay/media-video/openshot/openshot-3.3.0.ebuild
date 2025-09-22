# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

#>>>EAPI=7
EAPI=8
#>>>

#>>>PYTHON_COMPAT=( python3_{10..11} )
PYTHON_COMPAT=( python3_{10..13} )
#>>>
PYTHON_REQ_USE="xml(+)"
DISTUTILS_SINGLE_IMPL=1

#>>>inherit distutils-r1 xdg
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1 xdg git-r3
#>>>

MY_PN="${PN}-qt"

DESCRIPTION="Award-winning free and open-source video editor"
HOMEPAGE="https://openshot.org/"
#>>>SRC_URI="https://github.com/OpenShot/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
#>>>S="${WORKDIR}/${MY_PN}-${PV}"
EGIT_REPO_URI="https://github.com/OpenShot/${MY_PN}.git"
EGIT_COMMIT="v${PV}"
S="${WORKDIR}/${PN}-${PV}"
#>>>

LICENSE="GPL-3+"
SLOT="1"
KEYWORDS="amd64 ~x86"
IUSE="doc"

#>>>		dev-python/PyQt5[${PYTHON_USEDEP},gui,svg,widgets]
#>>>		dev-python/pyqtWebEngine[${PYTHON_USEDEP}]
RDEPEND="$(python_gen_cond_dep '
		dev-python/httplib2[${PYTHON_USEDEP}]
		dev-python/pyqt6[${PYTHON_USEDEP},gui,svg,widgets]
		dev-python/pyqt6-webengine[${PYTHON_USEDEP}]
		dev-python/pyzmq[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
	>=media-libs/libopenshot-0.3.2:0=[python,${PYTHON_SINGLE_USEDEP}]"
DEPEND=""
BDEPEND="$(python_gen_cond_dep '
		doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	')"

src_prepare() {
	distutils-r1_python_prepare_all
	# prevent setup.py from trying to update MIME databases
	sed -i 's/^ROOT =.*/ROOT = False/' setup.py || die
#>>>
	# ImportError: cannot import name 'install' from 'installer' (consider renaming '/var/tmp/portage/media-video/openshot-3.3.0/work/openshot-3.3.0/installer/__init__.py' if it has the same name as a library you intended to import)
	rm installer/__init__.py
#>>>
}

python_compile_all() {
	use doc && emake -C doc html
}

python_test() {
	distutils_install_for_testing
	"${EPYTHON}" src/tests/query_tests.py -v --platform minimal || die
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/_build/html/. )
	distutils-r1_python_install_all
}
