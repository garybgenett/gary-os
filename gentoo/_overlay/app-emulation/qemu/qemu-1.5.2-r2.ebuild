# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/qemu/qemu-1.5.2-r2.ebuild,v 1.3 2013/08/19 14:07:08 cardoe Exp $

EAPI=5

PYTHON_COMPAT=( python{2_5,2_6,2_7} )
PYTHON_REQ_USE="ncurses,readline"

inherit eutils flag-o-matic linux-info toolchain-funcs multilib python-r1 \
	user udev fcaps readme.gentoo

BACKPORTS=fd9f079c

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="git://git.qemu.org/qemu.git"
	inherit git-2
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="http://wiki.qemu-project.org/download/${P}.tar.bz2
	${BACKPORTS:+
		http://dev.gentoo.org/~cardoe/distfiles/${P}-${BACKPORTS}.tar.xz}"
	KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
fi

DESCRIPTION="QEMU + Kernel-based Virtual Machine userland tools"
HOMEPAGE="http://www.qemu.org http://www.linux-kvm.org"

LICENSE="GPL-2 LGPL-2 BSD-2"
SLOT="0"
IUSE="accessibility +aio alsa bluetooth +caps +curl debug fdt glusterfs \
gtk iscsi +jpeg \
kernel_linux kernel_FreeBSD mixemu ncurses opengl +png pulseaudio python \
rbd sasl +seccomp sdl selinux smartcard spice static static-softmmu \
static-user systemtap tci test +threads tls usbredir +uuid vde +vhost-net \
virtfs +vnc xattr xen xfs"

COMMON_TARGETS="i386 x86_64 alpha arm cris m68k microblaze microblazeel mips
mipsel mips64 mips64el or32 ppc ppc64 sh4 sh4eb sparc sparc64 s390x unicore32"
IUSE_SOFTMMU_TARGETS="${COMMON_TARGETS} lm32 moxie ppcemb xtensa xtensaeb"
IUSE_USER_TARGETS="${COMMON_TARGETS} armeb mipsn32 mipsn32el ppc64abi32 sparc32plus"

# Setup the default SoftMMU targets, while using the loops
# below to setup the other targets.
REQUIRED_USE="|| ("

for target in ${IUSE_SOFTMMU_TARGETS}; do
	IUSE="${IUSE} qemu_softmmu_targets_${target}"
	REQUIRED_USE="${REQUIRED_USE} qemu_softmmu_targets_${target}"
done

for target in ${IUSE_USER_TARGETS}; do
	IUSE="${IUSE} qemu_user_targets_${target}"
	REQUIRED_USE="${REQUIRED_USE} qemu_user_targets_${target}"
done
REQUIRED_USE="${REQUIRED_USE} )"

# Block USE flag configurations known to not work
REQUIRED_USE="${REQUIRED_USE}
	python? ( ${PYTHON_REQUIRED_USE} )
	static? ( static-softmmu static-user )
	static-softmmu? ( !alsa !pulseaudio !bluetooth !opengl !gtk )
	virtfs? ( xattr )"

# Yep, you need both libcap and libcap-ng since virtfs only uses libcap.
LIB_DEPEND=">=dev-libs/glib-2.0[static-libs(+)]
	sys-apps/pciutils[static-libs(+)]
	sys-libs/zlib[static-libs(+)]
	>=x11-libs/pixman-0.28.0[static-libs(+)]
	aio? ( dev-libs/libaio[static-libs(+)] )
	caps? ( sys-libs/libcap-ng[static-libs(+)] )
	curl? ( >=net-misc/curl-7.15.4[static-libs(+)] )
	fdt? ( >=sys-apps/dtc-1.2.0[static-libs(+)] <sys-apps/dtc-1.4.0[static-libs(+)] )
	glusterfs? ( >=sys-cluster/glusterfs-3.4.0[static-libs(+)] )
	jpeg? ( virtual/jpeg[static-libs(+)] )
	ncurses? ( sys-libs/ncurses[static-libs(+)] )
	png? ( media-libs/libpng[static-libs(+)] )
	rbd? ( sys-cluster/ceph[static-libs(+)] )
	sasl? ( dev-libs/cyrus-sasl[static-libs(+)] )
	sdl? ( >=media-libs/libsdl-1.2.11[static-libs(+)] )
	seccomp? ( >=sys-libs/libseccomp-1.0.1[static-libs(+)] )
	spice? ( >=app-emulation/spice-0.12.0[static-libs(+)] )
	tls? ( net-libs/gnutls[static-libs(+)] )
	uuid? ( >=sys-apps/util-linux-2.16.0[static-libs(+)] )
	vde? ( net-misc/vde[static-libs(+)] )
	xattr? ( sys-apps/attr[static-libs(+)] )
	xfs? ( sys-fs/xfsprogs[static-libs(+)] )"
RDEPEND="!static-softmmu? ( ${LIB_DEPEND//\[static-libs(+)]} )
	static-user? ( >=dev-libs/glib-2.0[static-libs(+)] )
	qemu_softmmu_targets_i386? (
		>=sys-firmware/ipxe-1.0.0_p20130624
		~sys-firmware/seabios-1.7.2.2
		~sys-firmware/sgabios-0.1_pre8
		~sys-firmware/vgabios-0.7a
	)
	qemu_softmmu_targets_x86_64? (
		>=sys-firmware/ipxe-1.0.0_p20130624
		~sys-firmware/seabios-1.7.2.2
		~sys-firmware/sgabios-0.1_pre8
		~sys-firmware/vgabios-0.7a
	)
	accessibility? ( app-accessibility/brltty )
	alsa? ( >=media-libs/alsa-lib-1.0.13 )
	bluetooth? ( net-wireless/bluez )
	gtk? (
		x11-libs/gtk+:3
		x11-libs/vte:2.90
	)
	iscsi? ( net-libs/libiscsi )
	opengl? ( virtual/opengl )
	pulseaudio? ( media-sound/pulseaudio )
	python? ( ${PYTHON_DEPS} )
	sdl? ( media-libs/libsdl[X] )
	selinux? ( sec-policy/selinux-qemu )
	smartcard? ( dev-libs/nss !app-emulation/libcacard )
	spice? ( >=app-emulation/spice-protocol-0.12.3 )
	systemtap? ( dev-util/systemtap )
	usbredir? ( >=sys-apps/usbredir-0.6 )
	virtfs? ( sys-libs/libcap )
	xen? ( app-emulation/xen-tools )"

DEPEND="${RDEPEND}
	dev-lang/perl
	=dev-lang/python-2*
	sys-apps/texinfo
	virtual/pkgconfig
	kernel_linux? ( >=sys-kernel/linux-headers-2.6.35 )
	static-softmmu? ( ${LIB_DEPEND} )
	test? (
		dev-libs/glib[utils]
		sys-devel/bc
	)"

STRIP_MASK="/usr/share/qemu/palcode-clipper"

QA_PREBUILT="
	usr/share/qemu/openbios-ppc
	usr/share/qemu/openbios-sparc64
	usr/share/qemu/openbios-sparc32
	usr/share/qemu/palcode-clipper
	usr/share/qemu/s390-ccw.img"

QA_WX_LOAD="usr/bin/qemu-i386
	usr/bin/qemu-x86_64
	usr/bin/qemu-alpha
	usr/bin/qemu-arm
	usr/bin/qemu-cris
	usr/bin/qemu-m68k
	usr/bin/qemu-microblaze
	usr/bin/qemu-microblazeel
	usr/bin/qemu-mips
	usr/bin/qemu-mipsel
	usr/bin/qemu-or32
	usr/bin/qemu-ppc
	usr/bin/qemu-ppc64
	usr/bin/qemu-ppc64abi32
	usr/bin/qemu-sh4
	usr/bin/qemu-sh4eb
	usr/bin/qemu-sparc
	usr/bin/qemu-sparc64
	usr/bin/qemu-armeb
	usr/bin/qemu-sparc32plus
	usr/bin/qemu-s390x
	usr/bin/qemu-unicore32"

DOC_CONTENTS="If you don't have kvm compiled into the kernel, make sure
you have the kernel module loaded before running kvm. The easiest way to
ensure that the kernel module is loaded is to load it on boot.\n
For AMD CPUs the module is called 'kvm-amd'\n
For Intel CPUs the module is called 'kvm-intel'\n
Please review /etc/conf.d/modules for how to load these\n\n
Make sure your user is in the 'kvm' group\n
Just run 'gpasswd -a <USER> kvm', then have <USER> re-login."

qemu_support_kvm() {
	if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386 \
		use qemu_softmmu_targets_ppc || use qemu_softmmu_targets_ppc64 \
		use qemu_softmmu_targets_s390x; then
		return 0
	fi

	return 1
}

pkg_pretend() {
	if use kernel_linux && kernel_is lt 2 6 25; then
		eerror "This version of KVM requres a host kernel of 2.6.25 or higher."
	elif use kernel_linux; then
		if ! linux_config_exists; then
			eerror "Unable to check your kernel for KVM support"
		else
			CONFIG_CHECK="~KVM ~TUN ~BRIDGE"
			ERROR_KVM="You must enable KVM in your kernel to continue"
			ERROR_KVM_AMD="If you have an AMD CPU, you must enable KVM_AMD in"
			ERROR_KVM_AMD+=" your kernel configuration."
			ERROR_KVM_INTEL="If you have an Intel CPU, you must enable"
			ERROR_KVM_INTEL+=" KVM_INTEL in your kernel configuration."
			ERROR_TUN="You will need the Universal TUN/TAP driver compiled"
			ERROR_TUN+=" into your kernel or loaded as a module to use the"
			ERROR_TUN+=" virtual network device if using -net tap."
			ERROR_BRIDGE="You will also need support for 802.1d"
			ERROR_BRIDGE+=" Ethernet Bridging for some network configurations."
			use vhost-net && CONFIG_CHECK+=" ~VHOST_NET"
			ERROR_VHOST_NET="You must enable VHOST_NET to have vhost-net"
			ERROR_VHOST_NET+=" support"

			if use amd64 || use x86 || use amd64-linux || use x86-linux; then
				CONFIG_CHECK+=" ~KVM_AMD ~KVM_INTEL"
			fi

			use python && CONFIG_CHECK+=" ~DEBUG_FS"
			ERROR_DEBUG_FS="debugFS support required for kvm_stat"

			# Now do the actual checks setup above
			check_extra_config
		fi
	fi
}

pkg_setup() {
	enewgroup kvm 78

	python_export_best
}

src_prepare() {
	# Alter target makefiles to accept CFLAGS set via flag-o
	sed -i 's/^\(C\|OP_C\|HELPER_C\)FLAGS=/\1FLAGS+=/' \
		Makefile Makefile.target || die

	epatch "${FILESDIR}"/qemu-9999-cflags.patch
	[[ -n ${BACKPORTS} ]] && \
		EPATCH_FORCE=yes EPATCH_SUFFIX="patch" EPATCH_SOURCE="${S}/patches" \
			epatch

	# Fix ld and objcopy being called directly
	tc-export LD OBJCOPY

	# Verbose builds
	MAKEOPTS+=" V=1"

	epatch_user
}

##
# configures qemu based on the build directory and the build type
# we are using.
#
qemu_src_configure() {
	debug-print-function $FUNCNAME "$@"

	local buildtype=$1
	local builddir=$2
	local conf_opts audio_opts
	local static_flag="static-${buildtype}"

	conf_opts="--prefix=/usr"
	conf_opts+=" --sysconfdir=/etc"
	conf_opts+=" --libdir=/usr/$(get_libdir)"
	conf_opts+=" --docdir=/usr/share/doc/${PF}/html"
	conf_opts+=" --disable-bsd-user"
	conf_opts+=" --disable-guest-agent"
	conf_opts+=" --disable-strip"
	conf_opts+=" --disable-werror"
	conf_opts+=" --python=${PYTHON}"

	# audio options
	audio_opts="oss"
	use alsa && audio_opts="alsa,${audio_opts}"
	use sdl && audio_opts="sdl,${audio_opts}"
	use pulseaudio && audio_opts="pa,${audio_opts}"

	if [[ ${buildtype} == "user" ]]; then
		conf_opts+=" --enable-linux-user"
		conf_opts+=" --disable-system"
		conf_opts+=" --target-list=${user_targets}"
		conf_opts+=" --disable-blobs"
		conf_opts+=" --disable-bluez"
		conf_opts+=" --disable-curses"
		conf_opts+=" --disable-kvm"
		conf_opts+=" --disable-libiscsi"
		conf_opts+=" --disable-glusterfs"
		conf_opts+=" $(use_enable seccomp)"
		conf_opts+=" --disable-sdl"
		conf_opts+=" --disable-smartcard-nss"
		conf_opts+=" --disable-tools"
		conf_opts+=" --disable-vde"
	fi

	if [[ ${buildtype} == "softmmu" ]]; then
		conf_opts+=" --disable-linux-user"
		conf_opts+=" --enable-system"
		conf_opts+=" --with-system-pixman"
		conf_opts+=" --target-list=${softmmu_targets}"
		conf_opts+=" $(use_enable bluetooth bluez)"
		conf_opts+=" $(use_enable gtk)"
		use gtk && conf_opts+=" --with-gtkabi=3.0"
		conf_opts+=" $(use_enable sdl)"
		conf_opts+=" $(use_enable aio linux-aio)"
		conf_opts+=" $(use_enable accessibility brlapi)"
		conf_opts+=" $(use_enable caps cap-ng)"
		conf_opts+=" $(use_enable curl)"
		conf_opts+=" $(use_enable fdt)"
		conf_opts+=" $(use_enable glusterfs)"
		conf_opts+=" $(use_enable iscsi libiscsi)"
		conf_opts+=" $(use_enable jpeg vnc-jpeg)"
		conf_opts+=" $(use_enable kernel_linux kvm)"
		conf_opts+=" $(use_enable kernel_linux nptl)"
		conf_opts+=" $(use_enable ncurses curses)"
		conf_opts+=" $(use_enable opengl glx)"
		conf_opts+=" $(use_enable png vnc-png)"
		conf_opts+=" $(use_enable rbd)"
		conf_opts+=" $(use_enable sasl vnc-sasl)"
		conf_opts+=" $(use_enable seccomp)"
		conf_opts+=" $(use_enable smartcard smartcard-nss)"
		conf_opts+=" $(use_enable spice)"
		conf_opts+=" $(use_enable tls vnc-tls)"
		conf_opts+=" $(use_enable tls vnc-ws)"
		conf_opts+=" $(use_enable usbredir usb-redir)"
		conf_opts+=" $(use_enable uuid)"
		conf_opts+=" $(use_enable vde)"
		conf_opts+=" $(use_enable vhost-net)"
		conf_opts+=" $(use_enable virtfs)"
		conf_opts+=" $(use_enable vnc)"
		conf_opts+=" $(use_enable xattr attr)"
		conf_opts+=" $(use_enable xen)"
		conf_opts+=" $(use_enable xen xen-pci-passthrough)"
		conf_opts+=" $(use_enable xfs xfsctl)"
		use mixemu && conf_opts+=" --enable-mixemu"
		conf_opts+=" --audio-drv-list=${audio_opts}"
		conf_opts+=" --enable-migration-from-qemu-kvm"
	fi

	conf_opts+=" $(use_enable debug debug-info)"
	conf_opts+=" $(use_enable debug debug-tcg)"
	conf_opts+=" --enable-docs"
	conf_opts+=" $(use_enable tci tcg-interpreter)"

	# Add support for SystemTAP
	use systemtap && conf_opts="${conf_opts} --enable-trace-backend=dtrace"

	# Add support for static builds
	use ${static_flag} && conf_opts="${conf_opts} --static --disable-pie"

	# We always want to attempt to build with PIE support as it results
	# in a more secure binary. But it doesn't work with static or if
	# the current GCC doesn't have PIE support.
	if ! use ${static_flag} && gcc-specs-pie; then
		conf_opts="${conf_opts} --enable-pie"
	fi

	einfo "./configure ${conf_opts}"
	cd ${builddir}
	../configure \
		--cc="$(tc-getCC)" \
		--host-cc="$(tc-getBUILD_CC)" \
		${conf_opts} \
		|| die "configure failed"

		# FreeBSD's kernel does not support QEMU assigning/grabbing
		# host USB devices yet
		use kernel_FreeBSD && \
			sed -E -e "s|^(HOST_USB=)bsd|\1stub|" -i "${S}"/config-host.mak
}

src_configure() {
	softmmu_targets=
	user_targets=

	for target in ${IUSE_SOFTMMU_TARGETS} ; do
		use "qemu_softmmu_targets_${target}" && \
		softmmu_targets="${softmmu_targets},${target}-softmmu"
	done

	for target in ${IUSE_USER_TARGETS} ; do
		use "qemu_user_targets_${target}" && \
		user_targets="${user_targets},${target}-linux-user"
	done

	[[ -n ${softmmu_targets} ]] && \
		einfo "Building the following softmmu targets: ${softmmu_targets}"

	[[ -n ${user_targets} ]] && \
		einfo "Building the following user targets: ${user_targets}"

	if [[ -n ${softmmu_targets} ]]; then
		mkdir "${S}/softmmu-build"
		qemu_src_configure "softmmu" "${S}/softmmu-build"
	fi

	if [[ -n ${user_targets} ]]; then
		mkdir "${S}/user-build"
		qemu_src_configure "user" "${S}/user-build"
	fi
}

src_compile() {
	if [[ -n ${user_targets} ]]; then
		cd "${S}/user-build"
		default
	fi

	if [[ -n ${softmmu_targets} ]]; then
		cd "${S}/softmmu-build"
		default
	fi
}

src_test() {
	cd "${S}/softmmu-build"
	emake -j1 check
	emake -j1 check-report.html
}

qemu_python_install() {
	python_domodule "${S}/QMP/qmp.py"

	python_doscript "${S}/scripts/kvm/kvm_stat"
	python_doscript "${S}/scripts/kvm/vmxcap"
	python_doscript "${S}/QMP/qmp-shell"
	python_doscript "${S}/QMP/qemu-ga-client"
}

src_install() {
	if [[ -n ${user_targets} ]]; then
		cd "${S}/user-build"
		emake DESTDIR="${ED}" install

		# Install binfmt handler init script for user targets
		newinitd "${FILESDIR}/qemu-binfmt.initd-r1" qemu-binfmt
	fi

	if [[ -n ${softmmu_targets} ]]; then
		cd "${S}/softmmu-build"
		emake DESTDIR="${ED}" install

		if use test; then
			dohtml check-report.html
		fi

		if use kernel_linux; then
			udev_dorules "${FILESDIR}"/65-kvm.rules
		fi

		if use qemu_softmmu_targets_x86_64 ; then
			newbin "${FILESDIR}/qemu-kvm-1.4" qemu-kvm
			ewarn "The deprecated '/usr/bin/kvm' symlink is no longer installed"
			ewarn "You should use '/usr/bin/qemu-kvm', you may need to edit"
			ewarn "your libvirt configs or other wrappers for ${PN}"
		elif use x86 || use amd64; then
			elog "You disabled QEMU_SOFTMMU_TARGETS=x86_64, this disables install"
			elog "of the /usr/bin/qemu-kvm script."
		fi

		if use python; then
			python_foreach_impl qemu_python_install
		fi
	fi

	# Install config file example for qemu-bridge-helper
	insinto "/etc/qemu"
	doins "${FILESDIR}/bridge.conf"

	# Remove the docdir placed qmp-commands.txt
	mv "${ED}/usr/share/doc/${PF}/html/qmp-commands.txt" "${S}/QMP/"

	cd "${S}"
	dodoc Changelog MAINTAINERS docs/specs/pci-ids.txt
	newdoc pc-bios/README README.pc-bios
	dodoc QMP/qmp-commands.txt QMP/qmp-events.txt QMP/qmp-spec.txt

	# Remove SeaBIOS since we're using the SeaBIOS packaged one
	rm "${ED}/usr/share/qemu/bios.bin"
	if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
		dosym ../seabios/bios.bin /usr/share/qemu/bios.bin
	fi

	# Remove vgabios since we're using the vgabios packaged one
	rm "${ED}/usr/share/qemu/vgabios.bin"
	rm "${ED}/usr/share/qemu/vgabios-cirrus.bin"
	rm "${ED}/usr/share/qemu/vgabios-qxl.bin"
	rm "${ED}/usr/share/qemu/vgabios-stdvga.bin"
	rm "${ED}/usr/share/qemu/vgabios-vmware.bin"
	if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
		dosym ../vgabios/vgabios.bin /usr/share/qemu/vgabios.bin
		dosym ../vgabios/vgabios-cirrus.bin /usr/share/qemu/vgabios-cirrus.bin
		dosym ../vgabios/vgabios-qxl.bin /usr/share/qemu/vgabios-qxl.bin
		dosym ../vgabios/vgabios-stdvga.bin /usr/share/qemu/vgabios-stdvga.bin
		dosym ../vgabios/vgabios-vmware.bin /usr/share/qemu/vgabios-vmware.bin
	fi

	# Remove sgabios since we're using the sgabios packaged one
	rm "${ED}/usr/share/qemu/sgabios.bin"
	if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
		dosym ../sgabios/sgabios.bin /usr/share/qemu/sgabios.bin
	fi

	# Remove iPXE since we're using the iPXE packaged one
	rm "${ED}"/usr/share/qemu/pxe-*.rom
	if use qemu_softmmu_targets_x86_64 || use qemu_softmmu_targets_i386; then
		dosym ../ipxe/8086100e.rom /usr/share/qemu/pxe-e1000.rom
		dosym ../ipxe/80861209.rom /usr/share/qemu/pxe-eepro100.rom
		dosym ../ipxe/10500940.rom /usr/share/qemu/pxe-ne2k_pci.rom
		dosym ../ipxe/10222000.rom /usr/share/qemu/pxe-pcnet.rom
		dosym ../ipxe/10ec8139.rom /usr/share/qemu/pxe-rtl8139.rom
		dosym ../ipxe/1af41000.rom /usr/share/qemu/pxe-virtio.rom
	fi

	qemu_support_kvm && readme.gentoo_create_doc
}

pkg_postinst() {
	local virtfs_caps=

	if qemu_support_kvm; then
		readme.gentoo_print_elog
		ewarn "Migration from qemu-kvm instances and loading qemu-kvm created"
		ewarn "save states will be removed in the next release (1.6.x)"
		ewarn
		ewarn "It is recommended that you migrate any VMs that may be running"
		ewarn "on qemu-kvm to a host with a newer qemu and regenerate"
		ewarn "any saved states with a newer qemu."
		ewarn
		ewarn "qemu-kvm was the primary qemu provider in Gentoo through 1.2.x"
	fi

	virtfs_caps+="cap_chown,cap_dac_override,cap_fowner,cap_fsetid,"
	virtfs_caps+="cap_setgid,cap_mknod,cap_setuid"

	fcaps cap_net_admin /usr/libexec/qemu-bridge-helper
	use virtfs && fcaps ${virtfs_caps} /usr/bin/virtfs-proxy-helper
}

pkg_info() {
	echo "Using:"
	echo "  $(best_version app-emulation/spice-protocol)"
	echo "  $(best_version sys-firmware/ipxe)"
	echo "  $(best_version sys-firmware/seabios)"
	if has_version sys-firmware/seabios[binary]; then
		echo "    USE=binary"
	else
		echo "    USE=''"
	fi
	echo "  $(best_version sys-firmware/vgabios)"
}
