# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meta package for all fortune-mod packages"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc64 ~riscv ~x86"
IUSE="l10n_cs l10n_de l10n_it"

#>>>	games-misc/fortune-mod-mormon
#>>>	games-misc/fortune-mod-scriptures
RDEPEND=">=games-misc/fortune-mod-3.6.1-r1
	games-misc/fortune-mod-bofh-excuses
	games-misc/fortune-mod-chucknorris
	games-misc/fortune-mod-flashrider
	games-misc/fortune-mod-kernelcookies
	games-misc/fortune-mod-osfortune
	games-misc/fortune-mod-taow
	games-misc/fortune-mod-zx-error
	l10n_cs? ( games-misc/fortune-mod-cs )
	l10n_de? (
		games-misc/fortune-mod-at-linux
		games-misc/fortune-mod-fvl
		games-misc/fortune-mod-norbert-tretkowski
		games-misc/fortune-mod-thomas-ogrisegg
		games-misc/fortune-mod-rss
	)
	l10n_it? ( games-misc/fortune-mod-it )

	games-misc/fortune-mod-bofh-excuses
	games-misc/fortune-mod-calvin
	games-misc/fortune-mod-chucknorris
	games-misc/fortune-mod-debilneho
	games-misc/fortune-mod-discworld
	games-misc/fortune-mod-dubya
	games-misc/fortune-mod-dune
	games-misc/fortune-mod-firefly
	games-misc/fortune-mod-flashrider
	games-misc/fortune-mod-futurama
	games-misc/fortune-mod-gentoo-dev
	games-misc/fortune-mod-gentoo-forums
	games-misc/fortune-mod-hitchhiker
	games-misc/fortune-mod-homer
	games-misc/fortune-mod-humorixfortunes
	games-misc/fortune-mod-kernelcookies
	games-misc/fortune-mod-osfortune
	games-misc/fortune-mod-pqf
	games-misc/fortune-mod-simpsons-chalkboard
	games-misc/fortune-mod-slackware
	games-misc/fortune-mod-smac
	games-misc/fortune-mod-sp-fortunes
	games-misc/fortune-mod-starwars
	games-misc/fortune-mod-strangelove
	games-misc/fortune-mod-taow
	games-misc/fortune-mod-zx-error
"
#>>>	games-misc/fortune-mod-tao
