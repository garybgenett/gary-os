#!/usr/bin/make --makefile
################################################################################
# GaryOS :: Primary Makefile
################################################################################

override CHROOT	:= -x

override I	?= $(CURDIR)
override S	?= $(CURDIR)/sources
override O	?= $(CURDIR)/build
override L	?= metro

################################################################################

.PHONY: usage
usage: override TITLE	:= \e[1;32m
usage: override STATE	:= \e[0;35m
usage: override HOWTO	:= \e[0;36m
usage: override NOTES	:= \e[0;33m
usage: override OTHER	:= \e[1;34m
usage: override RESET	:= \e[0;37m
usage: override PRINTF	:= printf "$(TITLE)%-45.45s$(RESET) $(HOWTO)%s$(RESET)\n"
usage: override MARKER	:= echo -en "$(OTHER)"; printf "~%.0s" {1..80}; echo -en "$(RESET)\n"
usage:
	@$(MARKER)
	@echo -en "$(NOTES)>>> GARYOS MAKEFILE <<<$(RESET)\n"
	@$(MARKER)
	@echo -en "$(STATE)This Makefile is a simple wrapper to the \"_system\" script, and has just a few targets:$(RESET)\n"
	@echo -en "\n"
	@$(PRINTF) "Update Current System:"		"make update"
	@$(PRINTF) "Information Lookup (Package Data):"	"make {package}"
	@echo -en "\n"
	@$(PRINTF) "Chroot Build (Initial):"		"make init"
	@$(PRINTF) "Chroot Build (Update Only):"	"make doit"
	@$(PRINTF) "Chroot Build (Complete Rebuild):"	"make redo"
	@$(PRINTF) "Chroot Build (Configuration):"	"make edit"
	@echo -en "\n"
	@$(PRINTF) "Chroot Shell (Run Command):"	"make shell"
	@$(PRINTF) "Chroot Unmount Cleanup:"		"make umount"
	@echo -en "\n"
	@echo -en "$(STATE)All of the targets run non-interactively, except \"edit\" and \"shell\".$(RESET)\n"
	@echo -en "\n"
	@echo -en "$(STATE)Use these variables to change the behavior slightly:$(RESET)\n"
	@echo -en "\n"
	@$(PRINTF) "Input Directory:"			"I=\"$(I)\""
	@$(PRINTF) "Source Directory:"			"S=\"$(S)\""
	@$(PRINTF) "Output Directory:"			"O=\"$(O)\""
	@$(PRINTF) "Package List:"			"L=\"$(L)\""
	@echo -en "\n"
	@echo -en "$(STATE)A full example to initialize a new chroot build would be:$(RESET)\n"
	@echo -en "\n"
	@echo -en "$(HOWTO)make init I=\"$(I)\" S=\"$(S)\" O=\"$(O)\" L=\"$(L)\"$(RESET)\n"
	@echo -en "\n"
	@echo -en "$(STATE)For more options, use the \"_system\" script directly (see below).$(RESET)\n"
	@$(MARKER)
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system -q

########################################

.DEFAULT_GOAL := usage
.DEFAULT:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system -l "$(@)"

################################################################################

.PHONY: update
update:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system -a -u

########################################

.PHONY: init
init:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system $(CHROOT) -0

.PHONY: doit
doit:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system $(CHROOT) -/

.PHONY: redo
redo:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system $(CHROOT) -1

.PHONY: edit
edit:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system $(CHROOT) -2

########################################

.PHONY: shell
shell:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system $(CHROOT) -s

.PHONY: umount
umount:
	SETDIR="$(I)" SOURCE="$(S)" OUTDIR="$(O)" PKGOUT="$(L)" $(CURDIR)/gentoo/_system $(CHROOT) -z

################################################################################
# End Of File
################################################################################
