# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/task/task-2.3.0.ebuild,v 1.2 2014/11/28 17:16:35 radhermit Exp $

EAPI=5

inherit eutils cmake-utils bash-completion-r1 git-r3

DESCRIPTION="Taskwarrior is a command-line todo list manager (server package)"
HOMEPAGE="http://taskwarrior.org/"
EGIT_REPO_URI="https://git.tasktools.org/scm/tm/${PN}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86 ~x64-macos"

DEPEND="net-libs/gnutls
	sys-libs/readline
	elibc_glibc? ( sys-apps/util-linux )"
RDEPEND="${DEPEND}"

src_configure() {
	mycmakeargs=(
		-DTASK_DOCDIR=share/doc/${PF}
		-DTASK_RCDIR=share/${PN}/rc
	)
	cmake-utils_src_configure
}
