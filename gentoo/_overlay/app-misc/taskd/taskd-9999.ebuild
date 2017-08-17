# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils cmake-utils bash-completion-r1 git-r3

DESCRIPTION="Taskwarrior is a command-line todo list manager (server package)"
HOMEPAGE="http://taskwarrior.org/"
EGIT_REPO_URI="https://git.tasktools.org/TM/${PN}.git"
EGIT_COMMIT="v1.1.0"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm x86 ~x64-macos"
IUSE="gnutls vim-syntax zsh-completion"

DEPEND="sys-libs/readline:0
	gnutls? ( net-libs/gnutls )
	elibc_glibc? ( sys-apps/util-linux )"
RDEPEND="${DEPEND}"

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_use gnutls GNUTLS)
		-DTASK_DOCDIR=share/doc/${PF}
		-DTASK_RCDIR=share/${PN}/rc
	)
	cmake-utils_src_configure
}
