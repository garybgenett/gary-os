# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

JOB_ID="898266"

DESCRIPTION="WebRTC pluggable transport proxy for Tor"
HOMEPAGE="https://snowflake.torproject.org/ \
	https://community.torproject.org/relay/setup/snowflake/standalone/ \
	https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake "
SRC_URI="https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/-/jobs/${JOB_ID}/artifacts/raw/snowflake-v${PV}.tar.gz"

S=${WORKDIR}/snowflake-v${PV}

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.21"

src_prepare() {
	COMPONENTS=(
		broker
		client
		probetest
		proxy
		server
	)

	sed -i -e "s|./client|/usr/bin/snowflake-client|" \
		client/{torrc,torrc.localhost} \
		|| die "sed failed to fix torrc example"

	default
}

src_compile() {
	local component
	for component in "${COMPONENTS[@]}"; do
		pushd ${component} || die
		einfo "Building ${component}"
		ego build
		popd || die
	done
}

src_test() {
	ego test ./...
}

src_install() {
	local component
	for component in "${COMPONENTS[@]}"; do
		newbin ${component}/${component} snowflake-${component}
		newdoc ${component}/README.md README_${component}.md
	done

	einstalldocs
	dodoc doc/*.txt doc/*.md
	doman doc/*.1

	systemd_dounit "${FILESDIR}"/snowflake-proxy.service
}
