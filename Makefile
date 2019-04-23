#!/usr/bin/make --makefile
################################################################################
# GaryOS :: Primary Makefile
################################################################################

override GARYOS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

########################################

ifneq ($(wildcard $(GARYOS_DIR)/.bashrc),)
export HOME	:= $(GARYOS_DIR)
endif
override CHROOT	:= -g

override C	?= $(GARYOS_DIR)
override S	?= $(GARYOS_DIR)/sources
override O	?= $(GARYOS_DIR)/build
override A	?= $(GARYOS_DIR)/_artifacts
override P	?= gary-os

########################################

.NOTPARALLEL:
.POSIX:
.SUFFIXES:

################################################################################

override TITLE	:= \e[1;32m
override STATE	:= \e[0;35m
override HOWTO	:= \e[0;36m
override NOTES	:= \e[0;33m
override OTHER	:= \e[1;34m
override RESET	:= \e[0;37m

override ECHO	:= echo -en
override MARKER	:= $(ECHO) "$(OTHER)"; printf "~%.0s" {1..80}; $(ECHO) "$(RESET)\n"
override PRINTF	:= printf "$(TITLE)%-45.45s$(RESET) $(HOWTO)%s$(RESET)\n"

########################################

#NOTE: KEEP THIS OUTPUT TO LESS THAN 80 CHARACTERS WIDE

.PHONY: usage
usage:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> GARYOS BUILD SYSTEM <<<$(RESET)\n"
	@$(MARKER)
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)This Makefile is a wrapper to the \"_system\" script, and has just a few targets:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Update Current System (Interactively):"	"make update"
	@$(ECHO) "\n"
	@$(PRINTF) "Information Lookup (Package Data):"		"make {package_list}"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Build (Initial):"			"make init"
	@$(PRINTF) "Chroot Build (Update Only):"		"make doit"
	@$(PRINTF) "Chroot Build (Complete Rebuild):"		"make redo"
	@$(PRINTF) "Chroot Build (Configuration):"		"make edit"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Shell (Bash):"			"make shell"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Complete (Unmount Cleanup):"		"make umount"
	@$(ECHO) "\n"
	@$(PRINTF) "Initramfs Build (Chroot Reset):"		"make clean"
	@$(PRINTF) "Initramfs Build (Chroot Create):"		"make release"
	@$(PRINTF) "Initramfs System (Live Reset):"		"make O=/ clean"
	@$(PRINTF) "Initramfs System (Live Create):"		"make O=/ release"
	@$(PRINTF) "Initramfs System (Live Unpack):"		"make O=/ unpack"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)All of the targets generally run non-interactively, except \"update\" and \"shell\".$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Use these variables to change the directories and packages:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Configuration Directory:"			"C=\"$(C)\""
	@$(PRINTF) "Sources Directory:"				"S=\"$(S)\""
	@$(PRINTF) "Output Directory:"				"O=\"$(O)\""
	@$(PRINTF) "Artifacts Directory:"			"A=\"$(A)\""
	@$(PRINTF) "Package List:"				"P=\"$(P)\""
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)A full example to initialize a new chroot build would be:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)make init C=\"$(C)\" S=\"$(S)\" O=\"$(O)\" A=\"$(A)\" P=\"$(P)\"$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)To do a complete build in the current directory using the defaults:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)make all $(NOTES)(same as: make init doit redo edit release)$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)For more options and build tools, use the \"_system\" script directly:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)make help 2>&1 | less$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Both methods are supported ways of using the GaryOS build system.$(RESET)\n"
	@$(ECHO) "\n"
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> HAPPY HACKING! <<<$(RESET)\n"
	@$(MARKER)

########################################

.PHONY: help
help: usage
ifneq ($(wildcard $(O)),)
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system -v -q $(CHROOT)
else
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system -v
endif

########################################

.DEFAULT_GOAL := usage
.DEFAULT:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> CURRENT SYSTEM PACKAGE LOOKUP: $(@) <<<$(RESET)\n"
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system -q -l "$(@)"
	@$(ECHO) "\n"
	@$(ECHO) "$(NOTES)>>> CHROOT SYSTEM PACKAGE LOOKUP: $(@) <<<$(RESET)\n"
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system -q $(CHROOT) -l "$(@)"
	@$(MARKER)

################################################################################

.PHONY: update
update:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT)
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -u

########################################

.PHONY: package_list
package_list: .DEFAULT

########################################

.PHONY: all
all: init doit redo edit release

########################################

.PHONY: init
init:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -0

.PHONY: doit
doit:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -/

.PHONY: redo
redo:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -1

.PHONY: edit
edit:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -2

########################################

.PHONY: shell
shell:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -s

########################################

.PHONY: umount
umount:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) -z

########################################

.PHONY: clean
clean:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) _release_reset

.PHONY: release
release:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) _release_ramfs

.PHONY: unpack
unpack:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" PKGGOS="$(P)" $(C)/gentoo/_system $(CHROOT) _release_unpack

################################################################################
# End Of File
################################################################################
