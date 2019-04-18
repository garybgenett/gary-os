#!/usr/bin/make --makefile
################################################################################
# GaryOS :: Primary Makefile
################################################################################

override GARYOS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

########################################

override CHROOT	:= -g

override C	?= $(GARYOS_DIR)
override S	?= $(GARYOS_DIR)/sources
override O	?= $(GARYOS_DIR)/build
override L	?= gary-os

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

.PHONY: usage
usage:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> GARYOS BUILD SYSTEM <<<$(RESET)\n"
	@$(MARKER)
	@$(ECHO) "$(STATE)This Makefile is a simple wrapper to the \"_system\" script, and has just a few targets:$(RESET)\n"
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
	@$(ECHO) "$(STATE)All of the targets run non-interactively, except \"update\" and \"edit\", along with \"shell\".$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Use these variables to change the directories and packages:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Configuration Directory:"			"I=\"$(I)\""
	@$(PRINTF) "Sources Directory:"				"S=\"$(S)\""
	@$(PRINTF) "Output Directory:"				"O=\"$(O)\""
	@$(PRINTF) "Package List:"				"L=\"$(L)\""
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)A full example to initialize a new chroot build would be:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)make init I=\"$(I)\" S=\"$(S)\" O=\"$(O)\" L=\"$(L)\"$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)For more options, use the \"_system\" script directly (see below).$(RESET)\n"
	@$(MARKER)
	@$(ECHO) "$(NOTES)Happy Hacking!$(RESET)\n"
	@$(MARKER)
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system -v

########################################

.DEFAULT_GOAL := usage
.DEFAULT:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> CURRENT SYSTEM PACKAGE LOOKUP: $(@) <<<$(RESET)\n"
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system -q -l "$(@)"
	@$(ECHO) "\n"
	@$(ECHO) "$(NOTES)>>> CHROOT SYSTEM PACKAGE LOOKUP: $(@) <<<$(RESET)\n"
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system -q $(CHROOT) -l "$(@)"
	@$(MARKER)

################################################################################

.PHONY: update
update:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system -a -u

########################################

.PHONY: init
init:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system $(CHROOT) -0

.PHONY: doit
doit:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system $(CHROOT) -/

.PHONY: redo
redo:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system $(CHROOT) -1

.PHONY: edit
edit:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system $(CHROOT) -2

########################################

.PHONY: shell
shell:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system $(CHROOT) -s

.PHONY: umount
umount:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(I)/gentoo/_system $(CHROOT) -z

################################################################################
# End Of File
################################################################################
