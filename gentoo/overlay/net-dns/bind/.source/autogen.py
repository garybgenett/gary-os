#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	python_compat = "python3+"
	src_url = "https://downloads.isc.org/isc/bind9/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")
	for link in soup.find_all("a"):
		href = link.get("href")
		if href.upper().isupper():
			continue
		minor = href.split(".")[1]
		if int(minor) % 2:
			continue
		version = href.rstrip("/")
	url = src_url + f"{version}/bind-{version}.tar.xz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, python_compat=python_compat, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
