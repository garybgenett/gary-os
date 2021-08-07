# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-build

DESCRIPTION="Virtual for Rust language compiler"

LICENSE=""
SLOT="0"
KEYWORDS="-* riscv64"

BDEPEND=""
RDEPEND="|| ( ~dev-lang/rust-${PV}[${MULTILIB_USEDEP}] )"
