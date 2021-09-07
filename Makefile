#!/usr/bin/make --makefile
################################################################################
# GaryOS :: Primary Makefile
################################################################################

override GARYOS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
override GARYOS_TTL := gary-os

########################################

ifneq ($(wildcard $(GARYOS_DIR)/.bashrc),)
export HOME	:= $(GARYOS_DIR)
endif

override CHROOT	:= -g
override C	?= $(GARYOS_DIR)
override S	?= $(GARYOS_DIR)/sources
override O	?= $(GARYOS_DIR)/build
override A	?= $(GARYOS_DIR)/artifacts
override P	?= $(GARYOS_TTL)

#>>>override ROOTFS	?=
override DOMODS	?=
override DOREDO	?=
#>>>override DOFAST	?=
override DOTEST	?=

override V	?=
override Q	:= -q
ifneq ($(V),)
override Q	:=
endif

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
override PRINTF	:= printf "$(TITLE)%-45.45s$(RESET) $(HOWTO)%s$(NOTES)%s$(STATE)%s$(RESET)\n"

########################################

#NOTE: KEEP THIS OUTPUT TO LESS THAN 80 CHARACTERS WIDE
#>>>	@$(ECHO) "$(STATE)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$(RESET)\n"

.PHONY: usage
usage:
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> GARYOS BUILD SYSTEM <<<$(RESET)\n"
	@$(MARKER)
	@$(ECHO) "\n"
	@$(PRINTF) "Reset Current Configuration:"		"$(MAKE) reset"
	@$(PRINTF) "Update Current System:"			"$(MAKE) update"
	@$(PRINTF) "Upgrade Current System (Interactively):"	"$(MAKE) upgrade"
	@$(ECHO) "\n"
	@$(PRINTF) "Information Lookup (Package Data):"		"$(MAKE) {packages}" "" " <[category%]name>"
	@$(PRINTF) "Information Lookup (Package Search):"	"$(MAKE) {searches}"
	@$(PRINTF) "Information Lookup (Gentoo Bug URL):"	"$(MAKE) {bug_ids}"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Build (Initial):"			"$(MAKE) init"
	@$(PRINTF) "Chroot Build (Update Only):"		"$(MAKE) doit"
	@$(PRINTF) "Chroot Build (Complete Rebuild):"		"$(MAKE) redo"
	@$(PRINTF) "Chroot Build (Configuration):"		"$(MAKE) edit"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Shell (Bash):"			"$(MAKE) shell"
	@$(PRINTF) "Chroot Complete (Unmount Cleanup):"		"$(MAKE) umount"
	@$(ECHO) "\n"
	@$(PRINTF) "Initramfs Build (Chroot Reset):"		"$(MAKE) clean"
	@$(PRINTF) "Initramfs Build (Chroot Create):"		"$(MAKE) release"
	@$(PRINTF) "Initramfs Build (Chroot Root):"		"$(MAKE) rootfs"
	@$(PRINTF) "Initramfs Build (Chroot Fetch):"		"$(MAKE) fetch"
	@$(ECHO) "\n"
	@$(PRINTF) "Initramfs System (Live Reset):"		"$(MAKE) O=/ clean"
	@$(PRINTF) "Initramfs System (Live Create):"		"$(MAKE) O=/ release"
	@$(PRINTF) "Initramfs System (Live Root):"		"$(MAKE) O=/ rootfs"
	@$(PRINTF) "Initramfs System (Live Unpack):"		"$(MAKE) O=/ unpack"
	@$(PRINTF) "Initramfs System (Live Install):"		"$(MAKE) O=/ install"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Helper wrappers for system inspection and development:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Chroot Validation (Reverse Dependencies):"	"depends-"	"[category%]name"
	@$(PRINTF) "Chroot Validation (Dependency Graph):"	"depgraph-"	"[category%]name"
	@$(PRINTF) "Chroot Validation (Package Ownership):"	"belongs-"	"{file|/|%}"
	@$(PRINTF) "Chroot Configuration (Overlay Helper):"	"overlay-"	"[category%]name"
	@$(PRINTF) "Chroot Configuration (Overlay Downloader):"	"overlay-"	"[category%]name^file[^commit]"
	@$(PRINTF) "Chroot Emerge Command"			"emerge-"	"[category%]name"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Use these variables to change the directories and packages:$(RESET)\n"
	@$(ECHO) "$(HOWTO)(...) = $(GARYOS_DIR)$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Configuration Directory:"			"C=" "$(subst $(GARYOS_DIR),(...),$(C))"
	@$(PRINTF) "Sources Directory:"				"S=" "$(subst $(GARYOS_DIR),(...),$(S))"
	@$(PRINTF) "Output Directory:"				"O=" "$(subst $(GARYOS_DIR),(...),$(O))"
	@$(PRINTF) "Artifacts Directory:"			"A=" "$(subst $(GARYOS_DIR),(...),$(A))"
	@$(PRINTF) "Package List:"				"P=" "$(subst $(GARYOS_DIR),(...),$(P))"
	@$(ECHO) "\n"
ifeq ($(findstring help,$(MAKECMDGOALS)),)
	@$(ECHO) "$(STATE)For more options and build tools: $(NOTES)$(MAKE) help$(RESET)\n"
else
	@$(MARKER)
ifeq ($(DOTEST),true)
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Environment variables to control build behaviore (true / false):$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Undocumented (Development Only):"		"ROOTFS=\"`SETDIR="$(C)" ROOTFS="$(ROOTFS)" $(C)/gentoo/_system -v $(CHROOT) ROOTFS && echo -en "$$$ROOTFS"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOMODS=\"`SETDIR="$(C)" DOMODS="$(DOMODS)" $(C)/gentoo/_system -v $(CHROOT) DOMODS && echo -en "$$$DOMODS"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOREDO=\"`SETDIR="$(C)" DOREDO="$(DOREDO)" $(C)/gentoo/_system -v $(CHROOT) DOREDO && echo -en "$$$DOREDO"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOFAST=\"`SETDIR="$(C)" DOFAST="$(DOFAST)" $(C)/gentoo/_system -v $(CHROOT) DOFAST && echo -en "$$$DOFAST"`\""
	@$(PRINTF) "Undocumented (Development Only):"		"DOTEST=\"`SETDIR="$(C)" DOTEST="$(DOTEST)" $(C)/gentoo/_system -v $(CHROOT) DOTEST && echo -en "$$$DOTEST"`\""
endif
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Build script pass-through targets, for advanced use:$(RESET)\n"
	@$(ECHO) "\n"
	@$(PRINTF) "Distribution Prepare (Internal Only):"	"_prepare_*"
	@$(PRINTF) "Distribution Release (Internal Only):"	"_release_*"
	@$(PRINTF) "Distribution Release (Internal Only):"	"_publish_*"
	@$(ECHO) "\n"
	@$(ECHO) "$(STATE)Below is information on using the \"_system\" script directly.$(RESET)\n"
	@$(ECHO) "$(STATE)It is important to use the variables shown, at a minimum.$(RESET)\n"
endif
	@$(ECHO) "\n"
	@$(MARKER)
	@$(ECHO) "$(NOTES)>>> HAPPY HACKING! <<<$(RESET)\n"
	@$(MARKER)

########################################

.PHONY: help
help: usage
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system -v $(Q) $(CHROOT)

########################################

.DEFAULT_GOAL := usage
.DEFAULT:
	@$(MARKER)
	@$(ECHO) "$(HOWTO)>>> CURRENT SYSTEM PACKAGE LOOKUP: $(subst %,/,$(@)) <<<$(RESET)\n"
	@$(MARKER)
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) -l "$(subst %,/,$(@))"
	@$(ECHO) "\n"
	@$(MARKER)
	@$(ECHO) "$(HOWTO)>>> CHROOT SYSTEM PACKAGE LOOKUP: $(subst %,/,$(@)) <<<$(RESET)\n"
	@$(MARKER)
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -l "$(subst %,/,$(@))"

################################################################################

.PHONY: reset
reset:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="/" ARTDIR="$(A)" GOSPKG="_$(P)" $(C)/gentoo/_system $(CHROOT) -r -!

.PHONY: update
update:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="/" ARTDIR="$(A)" GOSPKG="_$(P)" $(C)/gentoo/_system -U

.PHONY: upgrade
upgrade:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="/" ARTDIR="$(A)" GOSPKG="_$(P)" $(C)/gentoo/_system -u

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

.PHONY: depends-%
depends-%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -y -j depends $(subst %,/,$(*))

.PHONY: depgraph-%
depgraph-%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -y -j depgraph $(subst %,/,$(*))

.PHONY: belongs-%
belongs-%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -y -j belongs $(subst %,/,$(*))

.PHONY: overlay-%
overlay-%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -o $(subst ^, ,$(subst %,/,$(*)))

.PHONY: emerge-%
emerge-%:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -a -s -e $(subst %,/,$(*))

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

.PHONY: devel
devel:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_devel

.PHONY: check
check:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(CHROOT) _release_review

.PHONY: gendir
gendir:
	SETDIR="$(C)" SOURCE="$(S)" GOSDIR="$(O)" ARTDIR="$(A)" GOSPKG="$(P)" $(C)/gentoo/_system $(Q) $(CHROOT) -!

########################################

export COMPOSER		?= $(GARYOS_DIR)/.composer/Makefile
export MARKDOWN_OUTPUT	:= GaryOS-Readme.md
export COMPOSER_TARGETS	:= GaryOS-Readme.html GaryOS-Readme.pdf
export COMPOSER_DEBUGIT	:= 1
#>>>export CSS		:= css_alt
export TOC		:= 6
export OPT		:= --metadata title="GaryOS Readme"

override GREP	?= grep --color=auto -E
override SED	?= sed -r
override RM	?= rm -fv

.PHONY: readme
readme:
	@$(GREP) "^[#*|-]"							$(GARYOS_DIR)/README.md
ifeq ($(DOTEST),true)
	@$(ECHO) "\n"; $(MARKER); $(GREP) -e "^[#*-]" -e "^[[][^]]+[]][:]"	$(GARYOS_DIR)/README.md
	@$(ECHO) "\n"; $(MARKER); $(GREP) "^[#*-]"				$(GARYOS_DIR)/LICENSE.md
endif

.PHONY: readme-clean
readme-clean:
	@$(MAKE) --directory="$(GARYOS_DIR)" --makefile="$(COMPOSER)"		clean
	@$(RM)									$(GARYOS_DIR)/$(MARKDOWN_OUTPUT)

.PHONY: readme-all
readme-all:
	@$(SED) -r \
		-e "s|^([[]v)([0-9]+)[.]([0-9]+)([ ][X0-9]{4}-[X0-9]{2}-[X0-9]{2}[]]:[ ][#]v)[0-9]+([-][0-9]{4})|\1\2.\3\4\2.\3\5|g" \
		-e "s|^([[]v)([0-9]+)[.]([0-9]+)([]]:[ ][#]v)[0-9]+([-][0-9]{4})|\1\2.\3\4\2.\3\5|g" \
		README.md							>$(GARYOS_DIR)/$(MARKDOWN_OUTPUT)
	@$(MAKE) --directory="$(GARYOS_DIR)" --makefile="$(COMPOSER)"		$(COMPOSER_TARGETS)

########################################

override TOKN ?=
ifeq ($(findstring @,$(USER)),)
override USER := me@garybgenett.net
override ACCT := garybgenett
endif
override WGET := $(if $(WGET_C),$(WGET_C),wget) --output-document=- --auth-no-challenge --user="$(USER)" $(if $(TOKN),--password="$(TOKN)",--ask-password)
override GRIP := grip --title="" --user="$(USER)" $(if $(TOKN),--pass="$(TOKN)")
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

override BEG := 2014-02-28
override END := 2038-01-19
override PRD := monthly
ifeq ($(DOREDO),)
override BEG := $(shell expr `date +%s` - \( \( 60 \* 60 \* 24 \) \* 30 \))
override BEG := $(shell date --iso --date='@$(BEG)')
override PRD := daily
endif
override URI := start_date=$(BEG)&end_date=$(END)&period=$(PRD)

override ARCH := generic_64
override VERS := .[].name | select(test("^v[1-9]"))
override TOTL := .total

override LIST_JSON = ( \
		[( $(1) \
			| select(.[1] != null) \
			| { \
				key: (.[0] | tostring | sub(" 00:00:00"; "")), \
				value: .[1], \
			} \
		)] \
		| sort_by(.$(if $(2),$(2),value)) \
		| reverse \
		$(if $(3),| .[0:$(3)],) \
		| from_entries \
	)
override LIST_PRINT = ( \
		$(1) \
		| to_entries \
		| [( \
			.[] \
			| [ (.key | tostring), (.value | tostring) ] \
			| join(": ") \
		)] \
	)
override LIST_PARSE = ( \
		([($(1) | keys | .[])] | unique | .[]) as $$index | [ \
			($$index), ( \
				[($(1) | indices($$index)) | select(. != null)] | \
				add \
			) \
		] \
	)

override SHOW := { \
	description:		.description, \
	homepage:		.homepage, \
	branch:			.default_branch, \
	watchers:		.watchers, \
	forks:			.forks, \
	fork:			.fork, \
	}
override LAST := { \
	message:		.[0].commit.message, \
	commit:			.[0].sha, \
	author:			.[0].commit | { \
		author_name:	.author.name, \
		author_date:	.author.date, \
		commit_name:	.committer.name, \
		commit_date:	.committer.date, \
		} \
	}
override TREE := $(call LIST_JSON,(.[] | [ .name, .commit.sha ]),key,)
override TAGS := $(call LIST_JSON,(.[] | [ .name, .commit.sha ]),key,)
#>>>override TEAM := { watchers:	([.[].html_url] | sort) }
override TEAM := { watchers:	([.[].login] | sort) }
override DOWN := { \
		messages:	.messages, \
		total:		.total, \
		downloads:	$(call LIST_PRINT,$(call LIST_JSON,.downloads[],key,10)), \
		countries:	$(call LIST_PRINT,$(call LIST_JSON,.countries[],,10)), \
		systems:	$(call LIST_PRINT,$(call LIST_JSON,$(call LIST_PARSE,.oses_by_country[]))), \
	}

.PHONY: readme-github
readme-github:
	@$(ECHO) "USER: $(USER)\n" 1>&2
	@$(ECHO) "ACCT: $(ACCT)\n" 1>&2
	@$(ECHO) "TOKN: $(TOKN)\n" 1>&2
ifeq ($(DOMODS),true)
	@$(ECHO) '['
	$(WGET) https://api.github.com/repos/$(ACCT)/$(GARYOS_TTL)			| $(JSON) '$(SHOW)'; $(ECHO) ','
	$(WGET) https://api.github.com/repos/$(ACCT)/$(GARYOS_TTL)/commits		| $(JSON) '$(LAST)'; $(ECHO) ','
	$(WGET) https://api.github.com/repos/$(ACCT)/$(GARYOS_TTL)/branches		| $(JSON) '$(TREE)'; $(ECHO) ','
	$(WGET) https://api.github.com/repos/$(ACCT)/$(GARYOS_TTL)/tags			| $(JSON) '$(TAGS)'; $(ECHO) ','
	$(WGET) 'https://sourceforge.net/projects/gary-os/files/stats/json?$(URI)'	| $(JSON) '$(DOWN)'; $(ECHO) ','
	$(if $(DOTEST),,@) \
		$(shell $(ECHO) '{') \
		$(ECHO) '{"versions":['; \
		$(shell $(ECHO) '{') \
		$(foreach FILE,$(shell $(subst @,,$(WGET)) https://api.github.com/repos/$(ACCT)/$(GARYOS_TTL)/tags | $(JSON) '$(VERS)'),\
			$(ECHO) '"$(FILE):'; \
			$(ECHO) ' k('; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(GARYOS_TTL)-$(FILE)-$(ARCH).kernel/stats/json?$(URI)'			| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ','; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(FILE)/$(GARYOS_TTL)-$(FILE)-$(ARCH).kernel/stats/json?$(URI)'		| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ')'; \
			$(ECHO) ' t('; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(GARYOS_TTL)-$(FILE)-$(ARCH).tiny.kernel/stats/json?$(URI)'		| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ','; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(FILE)/$(GARYOS_TTL)-$(FILE)-$(ARCH).tiny.kernel/stats/json?$(URI)'	| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ')'; \
			$(ECHO) ' r('; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(GARYOS_TTL)-$(FILE)-$(ARCH).rootfs/stats/json?$(URI)'			| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ','; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(FILE)/$(GARYOS_TTL)-$(FILE)-$(ARCH).rootfs/stats/json?$(URI)'		| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ')'; \
			$(ECHO) ' b('; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(GARYOS_TTL)-$(FILE)-$(ARCH).grub/stats/json?$(URI)'			| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ','; \
				$(subst @,,$(WGET)) 'https://sourceforge.net/projects/gary-os/files/$(FILE)/$(GARYOS_TTL)-$(FILE)-$(ARCH).grub/stats/json?$(URI)'		| ($(GREP) '.' || $(ECHO) '{}') | $(JSON) '$(TOTL) // 0' | tr '\n' ')'; \
			$(ECHO) '",'; \
		) \
			$(shell $(ECHO) '}') \
			| sed 's|,$$||g'; \
		$(ECHO) ']}\n'; \
		$(shell $(ECHO) '}') \
		| $(JSON)
	@$(ECHO) ','
	$(WGET) https://api.github.com/repos/$(ACCT)/$(GARYOS_TTL)/stargazers		| $(JSON) '$(TEAM)'; #>>> $(ECHO) ','
	@$(ECHO) ']\n'
else
	@iptables -I INPUT 1 --proto tcp --dport 6419 -j ACCEPT
	$(GRIP) --clear
	$(GRIP) --export $(GARYOS_DIR) $(firstword $(COMPOSER_TARGETS))
	$(GRIP) 0.0.0.0:6419
endif

################################################################################
# End Of File
################################################################################
