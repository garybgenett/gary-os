# Distributed under the terms of the GNU General Public License v2

# Documentation for adding new kernels -- do not remove!
#
# Find latest stable kernel release for debian here:
#   https://packages.debian.org/unstable/kernel/

EAPI=5

inherit check-reqs eutils mount-boot

SLOT=$PF
CKV=${PV}
KV_FULL=${PN}-${PVR}
DEB_PV_BASE="5.4.6"
DEB_EXTRAVERSION="-1"
EXTRAVERSION="_p1"

# install modules to /lib/modules/${DEB_PV_BASE}${EXTRAVERSION}-$MODULE_EXT
MODULE_EXT=${EXTRAVERSION}
[ "$PR" != "r0" ] && MODULE_EXT=$MODULE_EXT-$PR
MODULE_EXT=$MODULE_EXT-${PN}
# install sources to /usr/src/$LINUX_SRCDIR
LINUX_SRCDIR=linux-${PF}
DEB_PV="$DEB_PV_BASE${DEB_EXTRAVERSION}"
KERNEL_ARCHIVE="linux_${DEB_PV_BASE}.orig.tar.xz"
PATCH_ARCHIVE="linux_${DEB_PV}.debian.tar.xz"
RESTRICT="binchecks strip mirror"
LICENSE="GPL-2"
KEYWORDS=""
IUSE="binary btrfs custom-cflags ec2 luks lvm sign-modules zfs"
DEPEND="
	virtual/libelf
	binary? ( >=sys-kernel/genkernel-3.4.40.7 )
	btrfs? ( sys-fs/btrfs-progs sys-kernel/genkernel[btrfs] )
	zfs? ( sys-fs/zfs )
	luks? ( sys-kernel/genkernel[cryptsetup] )"
REQUIRED_USE="
btrfs? ( binary )
custom-cflags? ( binary )
luks? ( binary )
lvm? ( binary )
sign-modules? ( binary )
zfs? ( binary )
"
DESCRIPTION="Debian Sources (and optional binary kernel)"
DEB_UPSTREAM="http://http.debian.net/debian/pool/main/l/linux"
HOMEPAGE="https://packages.debian.org/unstable/kernel/"
SRC_URI="$DEB_UPSTREAM/${KERNEL_ARCHIVE} $DEB_UPSTREAM/${PATCH_ARCHIVE}"
S="$WORKDIR/linux-${DEB_PV_BASE}"

get_patch_list() {
	[[ -z "${1}" ]] && die "No patch series file specified"
	local patch_series="${1}"
	while read line ; do
		if [[ "${line:0:1}" != "#" ]] ; then
			echo "${line}"
		fi
	done < "${patch_series}"
}

tweak_config() {
	einfo "Setting $2=$3 in kernel config."
	sed -i -e "/^$2=/d" $1
	echo "$2=$3" >> $1
}

setno_config() {
	einfo "Setting $2*=y to n in kernel config."
	sed -i -e "s/^$2\(.*\)=.*/$2\1=n/g" $1
}

setyes_config() {
	einfo "Setting $2*=* to y in kernel config."
	sed -i -e "s/^$2\(.*\)=.*/$2\1=y/g" $1
}

zap_config() {
	einfo "Removing *$2* from kernel config."
	sed -i -e "/$2/d" $1
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	if use binary ; then
		CHECKREQS_DISK_BUILD="5G"
		check-reqs_pkg_setup
	fi
}

get_certs_dir() {
	# find a certificate dir in /etc/kernel/certs/ that contains signing cert for modules.
	for subdir in $PF $P linux; do
		certdir=/etc/kernel/certs/$subdir
		if [ -d $certdir ]; then
			if [ ! -e $certdir/signing_key.pem ]; then
				eerror "$certdir exists but missing signing key; exiting."
				exit 1
			fi
			echo $certdir
			return
		fi
	done
}

pkg_setup() {
	export REAL_ARCH="$ARCH"
	unset ARCH; unset LDFLAGS #will interfere with Makefile if set
}

src_prepare() {
	cd "${S}"
	for debpatch in $( get_patch_list "${WORKDIR}/debian/patches/series" ); do
		epatch -p1 "${WORKDIR}/debian/patches/${debpatch}"
	done
	# end of debian-specific stuff...

	# do not include debian devs certificates
	rm -rf "${WORKDIR}"/debian/certs

	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${MODULE_EXT}:" Makefile || die
	sed	-i -e 's:#export\tINSTALL_PATH:export\tINSTALL_PATH:' Makefile || die
	rm -f .config >/dev/null
	cp -a "${WORKDIR}"/debian "${T}"
	make -s mrproper || die "make mrproper failed"
	#make -s include/linux/version.h || die "make include/linux/version.h failed"
	cd "${S}"
	cp -aR "${WORKDIR}"/debian "${S}"/debian

	## XFS LIBCRC kernel config fixes, FL-823
	epatch "${FILESDIR}"/${DEB_PV_BASE}/${PN}-${DEB_PV_BASE}-xfs-libcrc32c-fix.patch

	## FL-4424: enable legacy support for MCELOG.
	epatch "${FILESDIR}"/${DEB_PV_BASE}/${PN}-${DEB_PV_BASE}-mcelog.patch

	## do not configure debian devs certs.
	epatch "${FILESDIR}"/${DEB_PV_BASE}/${PN}-${DEB_PV_BASE}-nocerts.patch

	## FL-3381. enable IKCONFIG
	epatch "${FILESDIR}"/${DEB_PV_BASE}/${PN}-${DEB_PV_BASE}-ikconfig.patch

	## increase bluetooth polling patch
	epatch "${FILESDIR}"/${DEB_PV_BASE}/${PN}-${DEB_PV_BASE}-fix-bluetooth-polling.patch

	local arch featureset subarch
	featureset="standard"
	if [[ ${REAL_ARCH} == x86 ]]; then
		arch="i386"
		subarch="686-pae"
	elif [[ ${REAL_ARCH} == amd64 ]]; then
		arch="amd64"
		subarch="amd64"
	else
	die "Architecture not handled in ebuild"
	fi
	cp "${FILESDIR}"/config-extract . || die
	chmod +x config-extract || die
	./config-extract ${arch} ${featureset} ${subarch} || die
	setno_config .config CONFIG_DEBUG
	if use ec2; then
		setyes_config .config CONFIG_BLK_DEV_NVME
		setyes_config .config CONFIG_XEN_BLKDEV_FRONTEND
		setyes_config .config CONFIG_XEN_BLKDEV_BACKEND
		setyes_config .config CONFIG_IXGBEVF
	fi
	if use sign-modules; then
		certs_dir=$(get_certs_dir)
		echo
		if [ -z "$certs_dir" ]; then
			eerror "No certs dir found in /etc/kernel/certs; aborting."
			die
		else
			einfo "Using certificate directory of $certs_dir for kernel module signing."
		fi
		echo
		# turn on options for signing modules.
		# first, remove existing configs and comments:
		zap_config .config CONFIG_MODULE_SIG
		# now add our settings:
		tweak_config .config CONFIG_MODULE_SIG y
		tweak_config .config CONFIG_MODULE_SIG_FORCE n
		tweak_config .config CONFIG_MODULE_SIG_ALL n
		tweak_config .config CONFIG_MODULE_SIG_HASH \"sha512\"
		tweak_config .config CONFIG_MODULE_SIG_KEY  \"${certs_dir}/signing_key.pem\"
		tweak_config .config CONFIG_SYSTEM_TRUSTED_KEYRING y
		tweak_config .config CONFIG_SYSTEM_EXTRA_CERTIFICATE y
		tweak_config .config CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE 4096
		echo "CONFIG_MODULE_SIG_SHA512=y" >> .config
		ewarn "This kernel will ALLOW non-signed modules to be loaded with a WARNING."
		ewarn "To enable strict enforcement, YOU MUST add module.sig_enforce=1 as a kernel boot"
		ewarn "parameter (to params in /etc/boot.conf, and re-run boot-update.)"
		echo
	fi
	if use custom-cflags; then
		MARCH="$(python -c "import portage; print(portage.settings[\"CFLAGS\"])" | sed 's/ /\n/g' | grep "march")"
		if [ -n "$MARCH" ]; then
			sed -i -e 's/-mtune=generic/$MARCH/g' arch/x86/Makefile || die "Canna optimize this kernel anymore, captain!"
		fi
	fi
	# get config into good state:
	yes "" | make oldconfig >/dev/null 2>&1 || die
	cp .config "${T}"/config || die
	make -s mrproper || die "make mrproper failed"
}

src_compile() {
	! use binary && return
	install -d "${WORKDIR}"/out/{lib,boot}
	install -d "${T}"/{cache,twork}
	install -d "${WORKDIR}"/build
	cp "${T}"/config "${WORKDIR}"/build/.config
	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" genkernel ${GKARGS} \
		--no-save-config \
		--no-oldconfig \
		--kernel-config=${T}/config \
		--kernname="${PN}" \
		--build-src="${S}" \
		--build-dst="${WORKDIR}"/build \
		--makeopts="${MAKEOPTS}" \
		--cachedir="${T}"/cache \
		--tempdir="${T}"/twork \
		--logfile="${WORKDIR}"/genkernel.log \
		--bootdir="${WORKDIR}"/out/boot \
		--disklabel \
		$(usex lvm --lvm --no-lvm ) \
		$(usex luks --luks --no-luks ) \
		--mdadm \
		$(usex btrfs --btrfs --no-btrfs) \
		$(usex zfs --zfs --no-zfs) \
		--module-prefix="${WORKDIR}"/out \
		all || die
}

src_install() {
	# copy sources into place:
	dodir /usr/src
	cp -a "${S}" "${D}"/usr/src/${LINUX_SRCDIR} || die
	cd "${D}"/usr/src/${LINUX_SRCDIR}
	# prepare for real-world use and 3rd-party module building:
	make mrproper || die
	cp "${T}"/config .config || die
	cp -a "${T}"/debian debian || die


	# if we didn't use genkernel, we're done. The kernel source tree is left in
	# an unconfigured state - you can't compile 3rd-party modules against it yet.
	use binary || return
	make prepare || die
	make scripts || die
	# OK, now the source tree is configured to allow 3rd-party modules to be
	# built against it, since we want that to work since we have a binary kernel
	# built.
	cp -a "${WORKDIR}"/out/* "${D}"/ || die "couldn't copy output files into place"
	# module symlink fixup:
	rm -f "${D}"/lib/modules/*/source || die
	rm -f "${D}"/lib/modules/*/build || die
	cd "${D}"/lib/modules
	local moddir="$(ls -d [234]*)"
	ln -s /usr/src/${LINUX_SRCDIR} "${D}"/lib/modules/${moddir}/source || die
	ln -s /usr/src/${LINUX_SRCDIR} "${D}"/lib/modules/${moddir}/build || die
	# Fixes FL-14
	cp "${WORKDIR}/build/System.map" "${D}/usr/src/${LINUX_SRCDIR}/" || die
	cp "${WORKDIR}/build/Module.symvers" "${D}/usr/src/${LINUX_SRCDIR}/" || die
	if use sign-modules; then
		for x in $(find "${D}"/lib/modules -iname *.ko); do
			# $certs_dir defined previously in this function.
			${WORKDIR}/build/scripts/sign-file sha512 $certs_dir/signing_key.pem $certs_dir/signing_key.x509 $x || die
		done
		# install the sign-file executable for future use.
		exeinto /usr/src/${LINUX_SRCDIR}/scripts
		doexe ${WORKDIR}/build/scripts/sign-file
	fi

	# The new naming scheme leaves an extra -${PN} at the name of various things in /boot. This should fix that.
	cd ${D}/boot
	for x in $(ls *); do
		xnew=${x%-${PN}}
		mv $x ${xnew} || die
	done


}

pkg_postinst() {
	if use binary && [[ -h "${ROOT}"usr/src/linux ]]; then
		rm "${ROOT}"usr/src/linux
	fi
	if use binary && [[ ! -e "${ROOT}"usr/src/linux ]]; then
		ewarn "With binary use flag enabled /usr/src/linux"
		ewarn "symlink automatically set to debian kernel"
		ln -sf ${LINUX_SRCDIR} "${ROOT}"usr/src/linux
	fi

	if [ -e ${ROOT}lib/modules ]; then
		depmod -a $DEP_PV
	fi
	if [ -e /etc/boot.conf ]; then
		ego boot update
	fi
}
