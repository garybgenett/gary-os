# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils cmake-utils bash-completion-r1 git-r3

DESCRIPTION="Taskwarrior is a command-line todo list manager"
HOMEPAGE="http://taskwarrior.org/"
EGIT_REPO_URI="https://git.tasktools.org/TM/${PN}.git"
EGIT_COMMIT="v2.5.1"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm x86 ~x64-macos"
IUSE="gnutls vim-syntax zsh-completion"

DEPEND="sys-libs/readline:0
	gnutls? ( net-libs/gnutls )
	elibc_glibc? ( sys-apps/util-linux )"
RDEPEND="${DEPEND}"

src_prepare() {
	# use the correct directory locations
	sed -i "s:/usr/local/bin:${EPREFIX}/usr/bin:" \
		scripts/add-ons/* || die

	# don't automatically install scripts
	sed -i '/scripts/d' CMakeLists.txt || die

	# this is for versions 2.4.4 and earlier
#>>>	epatch "${FILESDIR}"/0001-${P}-annotations-edit-fix.patch
}

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_use gnutls GNUTLS)
		-DTASK_DOCDIR=share/doc/${PF}
		-DTASK_RCDIR=share/${PN}/rc
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newbashcomp scripts/bash/task.sh task

	if use vim-syntax ; then
		rm scripts/vim/README
		insinto /usr/share/vim/vimfiles
		doins -r scripts/vim/*
	fi

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins scripts/zsh/*
	fi

	exeinto /usr/share/${PN}/scripts
	doexe scripts/add-ons/*
}
