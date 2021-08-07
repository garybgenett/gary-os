#!/usr/bin/env python3

import xmltodict
import datetime


async def generate(hub, **pkginfo):
	page = await hub.pkgtools.fetch.get_page(f"https://repo.or.cz/iotop.git/atom")
	xml_data = xmltodict.parse(page)
	for datums in xml_data["feed"]["entry"]:
		if "id" not in datums:
			continue
		if not datums["id"].startswith("https://repo.or.cz/iotop.git/commitdiff/"):
			continue
		sha1 = datums["id"].split("/")[-1]
		datestamp = datums["published"].split("T")[0]
		break
	url = f"https://repo.or.cz/iotop.git/snapshot/{sha1}.tar.gz"
	version = datestamp.replace("-", ".")
	final_name = f"iotop-{version}.tar.gz"
	# the latest tag is the first dict in the returned list of tag dicts
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		sha1=sha1,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
