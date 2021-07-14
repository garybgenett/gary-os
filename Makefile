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
override DOMODS	?=
override C	?= $(GARYOS_DIR)
override S	?= $(GARYOS_DIR)/sources
override O	?= $(GARYOS_DIR)/build
override A	?= $(GARYOS_DIR)/artifacts
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
override PRINTF	:= printf "$(TITLE)%-45.45s$(RESET) $(HOWTO)%s$(RESET) $(STATE)%s$(RESET)\n"

########################################

#NOTE: KEEP THIS OUTPUT TO LESS THAN 80 CHARACTERS WIDE
#>>>	@$(ECHO) "$(STATE)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$(RESET)\n"

.PHONY: usage
usage:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> GARYOS BUILD SYSTEM <<<$(RESET)\n"
	@$(MARKER)
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)This Makefile is a wrapper to the \"_system\" script, and has just a few targets:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Update Current System (Interactively):"	"$(MAKE) update"
	@$(ECHO) "\n"
	@$(PRINTF) "Information Lookup (Package Data):"		"$(MAKE) {package_list}"
	@$(PRINTF) "Information Lookup (Package Search):"	"$(MAKE) {search_list}"
	@$(PRINTF) "Information Lookup (Gentoo Bug URL):"	"$(MAKE) {bug_ids}"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Build (Initial):"			"$(MAKE) init"
	@$(PRINTF) "Chroot Build (Update Only):"		"$(MAKE) doit"
	@$(PRINTF) "Chroot Build (Complete Rebuild):"		"$(MAKE) redo"
	@$(PRINTF) "Chroot Build (Configuration):"		"$(MAKE) edit"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Shell (Bash):"			"$(MAKE) shell"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Complete (Unmount Cleanup):"		"$(MAKE) umount"
	@$(ECHO) "\n"
	@$(PRINTF) "Initramfs Build (Chroot Reset):"		"$(MAKE) clean"
	@$(PRINTF) "Initramfs Build (Chroot Create):"		"$(MAKE) release"
	@$(PRINTF) "Initramfs Build (Chroot Root):"		"$(MAKE) rootfs"
	@$(PRINTF) "Initramfs System (Live Reset):"		"$(MAKE) O=/ clean"
	@$(PRINTF) "Initramfs System (Live Create):"		"$(MAKE) O=/ release"
	@$(PRINTF) "Initramfs System (Live Root):"		"$(MAKE) O=/ rootfs"
	@$(PRINTF) "Initramfs System (Live Fetch):"		"$(MAKE) O=/ fetch"
	@$(PRINTF) "Initramfs System (Live Unpack):"		"$(MAKE) O=/ unpack"
	@$(PRINTF) "Initramfs System (Live Install):"		"$(MAKE) O=/ install"
ifneq ($(findstring help,$(MAKECMDGOALS)),)
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)There are also build script pass-through targets, for advanced use:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Distribution Prepare (Internal Only):"	"_prepare_*"
	@$(PRINTF) "Distribution Release (Internal Only):"	"_release_*"
	@$(PRINTF) "Distribution Release (Internal Only):"	"_publish_*"
endif
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
ifneq ($(findstring help,$(MAKECMDGOALS)),)
ifeq ($(DOTEST),true)
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)There are a few additional environment variables to control build behaviore:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Undocumented (Development Only):"		"ROOTFS=\"`SETDIR="$(C)" ROOTFS="$(ROOTFS)" $(C)/gentoo/_system -v $(CHROOT) ROOTFS && echo -en "$$$ROOTFS"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOMODS=\"`SETDIR="$(C)" DOMODS="$(DOMODS)" $(C)/gentoo/_system -v $(CHROOT) DOMODS && echo -en "$$$DOMODS"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOREDO=\"`SETDIR="$(C)" DOREDO="$(DOREDO)" $(C)/gentoo/_system -v $(CHROOT) DOREDO && echo -en "$$$DOREDO"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOFAST=\"`SETDIR="$(C)" DOFAST="$(DOFAST)" $(C)/gentoo/_system -v $(CHROOT) DOFAST && echo -en "$$$DOFAST"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOTEST=\"`SETDIR="$(C)" DOTEST="$(DOTEST)" $(C)/gentoo/_system -v $(CHROOT) DOTEST && echo -en "$$$DOTEST"`\""
endif
endif
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)A full example to initialize a new chroot build would be:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)$(MAKE) init C=\"$(C)\" S=\"$(S)\" O=\"$(O)\" A=\"$(A)\" P=\"$(P)\"$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)To do a complete build in the current directory using the defaults:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)$(MAKE) all $(NOTES)(same as: $(MAKE) init doit redo edit release)$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)For more options and build tools, use the \"_system\" script directly:$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(HOWTO)$(MAKE) help | less$(RESET)\n"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Both methods are supported ways of using the GaryOS build system.$(RESET)\n"
	@$(ECHO) "\n"
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> HAPPY HACKING! <<<$(RESET)\n"
	@$(MARKER)

########################################

.PHONY: help
help: usage
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system -v -q $(CHROOT)

########################################

.DEFAULT_GOAL := usage
.DEFAULT:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> CURRENT SYSTEM PACKAGE LOOKUP: $(@) <<<$(RESET)\n"
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system -q -l "$(@)"
	@$(ECHO) "\n"
	@$(ECHO) "$(NOTES)>>> CHROOT SYSTEM PACKAGE LOOKUP: $(@) <<<$(RESET)\n"
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system -q $(CHROOT) -l "$(@)"
	@$(MARKER)

################################################################################

.PHONY: update
update:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system -u

########################################

.PHONY: package_list
package_list: .DEFAULT

########################################

.PHONY: all
all: init doit redo edit release

########################################

.PHONY: init
init:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) -0

.PHONY: doit
doit:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) -/

.PHONY: redo
redo:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) -1

.PHONY: edit
edit:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) -2

########################################

.PHONY: shell
shell:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) -s

########################################

.PHONY: umount
umount:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) -z

########################################

.PHONY: clean
clean:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_reset

.PHONY: release
release:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_build

.PHONY: rootfs
rootfs:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_rootfs

.PHONY: fetch
fetch:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_fetch

.PHONY: unpack
unpack:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_unpack

.PHONY: install
install:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_install

########################################

.PHONY: _prepare_%
_prepare_%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _prepare_$(*)

.PHONY: _release_%
_release_%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_$(*)

.PHONY: _publish_%
_publish_%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _publish_$(*)

################################################################################

#NOTE: THESE ARE FOR DEVELOPMENT AND TESTING AND ARE THEREFORE UNDOCUMENTED

########################################

.PHONY: check
check:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_review

########################################

export COMPOSER		?= $(GARYOS_DIR)/.composer/Makefile
export MARKDOWN_OUTPUT	:= GaryOS-Readme.md
export COMPOSER_TARGETS	:= GaryOS-Readme.html GaryOS-Readme.pdf
#>>>export COMPOSER_DEBUGIT	:= 1
#>>>export CSS		:= css_alt
#>>>export TOC		:= 6
#>>>export OPT		:= --metadata title="GaryOS Readme"

override GREP	?= grep --color=auto -E
override SED	?= sed -r
override RM	?= rm -fv

.PHONY: readme
readme:
	@$(GREP) "^[-#*]"						$(GARYOS_DIR)/README.md
ifeq ($(DOTEST),true)
	@$(ECHO) "\n"; $(GREP) "^[[:space:]]+[*][ ][[]"			$(GARYOS_DIR)/README.md
	@$(ECHO) "\n"; $(GREP) -e "^[-#*]" -e "^[[][^]]+[]][:]"		$(GARYOS_DIR)/README.md
	@$(ECHO) "\n"; $(GREP) "^[-#*]"					$(GARYOS_DIR)/LICENSE.md
endif

.PHONY: readme-clean
readme-clean:
	@$(MAKE) --directory="$(GARYOS_DIR)" --makefile="$(COMPOSER)"	clean
	@$(RM)								$(GARYOS_DIR)/$(MARKDOWN_OUTPUT)

.PHONY: readme-all
readme-all:
	@$(SED) -r \
		-e "s|^([[]v)([0-9]+)[.]([0-9]+)([ ][X0-9]{4}-[X0-9]{2}-[X0-9]{2}[]]:[ ][#]v)[0-9]+([-][0-9]{4})|\1\2.\3\4\2.\3\5|g" \
		-e "s|^([[]v)([0-9]+)[.]([0-9]+)([]]:[ ][#]v)[0-9]+([-][0-9]{4})|\1\2.\3\4\2.\3\5|g" \
		README.md						>$(GARYOS_DIR)/$(MARKDOWN_OUTPUT)
	@$(MAKE) --directory="$(GARYOS_DIR)" --makefile="$(COMPOSER)"	$(COMPOSER_TARGETS)

########################################

ifeq ($(findstring @,$(USER)),)
override USER := me@garybgenett.net
override ACCT := garybgenett
endif
override WGET := $(if $(WGET_C),$(WGET_C),wget) --output-document=- --auth-no-challenge --user="$(USER)" $(if $(PASS),--password="$(PASS)",--ask-password)
override GRIP := grip --title="" --user="$(USER)" $(if $(PASS),--pass="$(PASS)")
override JSON := jq --raw-output
ifeq ($(ACCT),)
override ACCT := $(shell $(WGET) https://api.github.com/user | $(JSON) ".login")
ifeq ($(ACCT),)
override ACCT := $(word 2,,$(subst @, ,$(subst ., ,$(USER))))
endif
endif

ifneq ($(DOTEST),true)
override WGET := @$(WGET) 2>/dev/null
override GRIP := @$(GRIP)
endif
override SHOW := { \
	description: .description, \
	homepage: .homepage, \
	branch: .default_branch, \
	watchers: .watchers, \
	forks: .forks, \
	fork: .fork, \
	}
override LAST := { \
	message: .[0].commit.message, \
	commit: .[0].sha, \
	author: .[0].commit | { \
		author_name: .author.name, \
		author_date: .author.date, \
		commit_name: .committer.name, \
		commit_date: .committer.date, \
		} \
	}
override TREE := [ .[] | { \
		name: .name, \
		commit: .commit.sha, \
	} ]
override TAGS := [ .[] | { \
		name: .name, \
		commit: .commit.sha, \
	} ]
override TEAM := .[].login

.PHONY: readme-github
readme-github:
	@echo "USER: $(USER)"
	@echo "ACCT: $(ACCT)"
	@echo "PASS: $(PASS)"
	@iptables -I INPUT 1 --proto tcp --dport 6419 -j ACCEPT
ifeq ($(DOMODS),true)
	$(WGET) https://api.github.com/repos/$(ACCT)/gary-os			| $(JSON) '$(SHOW)'
	$(WGET) https://api.github.com/repos/$(ACCT)/gary-os/commits		| $(JSON) '$(LAST)'
	$(WGET) https://api.github.com/repos/$(ACCT)/gary-os/branches		| $(JSON) '$(TREE)'
	$(WGET) https://api.github.com/repos/$(ACCT)/gary-os/tags		| $(JSON) '$(TAGS)'
	$(WGET) https://api.github.com/repos/garybgenett/gary-os/stargazers	| $(JSON) '$(TEAM)' | sort -u
else
	$(GRIP) --clear
	$(GRIP) --export
	$(GRIP) 0.0.0.0:6419
endif

################################################################################
# End Of File
################################################################################
