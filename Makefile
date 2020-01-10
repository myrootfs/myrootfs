# Top level Makefile
#
# Copyright (c) 2014-2017  Joachim Nilsson <troglobit@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
# IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
.PHONY: help world staging kernel lib packages romfs ramdisk clean distclean image

OSNAME            := myrootfs
OSRELEASE_ID      := myrootfs
OSRELEASE          = myrootfs `date --iso-8601`
OSVERSION_ID      := 1.0
OSVERSION         := $(OSVERSION_ID), $(OSRELEASE)
OSID              := "myrootfs"
OSPRETTY_NAME     := $(OSNAME) $(OSVERSION_ID)
OSHOME_URL        := https://github.com/myrootfs
SUPPORT_URL       := https://github.com/myrootfs/myrootfs
BUG_REPORT_URL    := https://github.com/myrootfs/myrootfs/issues

ROOTDIR           := $(shell pwd)
PATH              := $(ROOTDIR)/bin:$(PATH)
srctree           := $(ROOTDIR)

# usr/lib usr/share usr/bin usr/sbin
STAGING_DIRS       = mnt proc sys lib share bin sbin tmp var home host

# Include .config variables, unless calling Kconfig
noconfig_targets  := menuconfig nconfig gconfig xconfig config oldconfig	\
		     defconfig %_defconfig allyesconfig allnoconfig distclean

ifdef V
  ifeq ("$(origin V)", "command line")
    KBUILD_VERBOSE = $(V)
  endif
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE   = 0
endif
KBUILD_DEFCONFIG   = defconfig
ifeq ($(KBUILD_VERBOSE),1)
MAKEFLAGS          =
else
MAKEFLAGS          = --silent --no-print-directory
endif

export OSNAME OSRELEASE_ID OSRELEASE OSVERSION_ID OSVERSION
export OSID OSPRETTY_NAME OSHOME_URL
export PATH ROOTDIR srctree STAGING_DIRS
export SUPPORT_URL BUG_REPORT_URL
export KBUILD_VERBOSE MAKEFLAGS

ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
ifeq (.config, $(wildcard .config))
include $(ROOTDIR)/.config
all: dep staging kernel world romfs image			## Build all the things
else
all: error
endif
endif

dep:
	+@make -C system $@

# Linux Kconfig, menuconfig et al
include kconfig/config.mk

staging:							## Initialize staging area
	+@$(MAKE) -C system $@

romfs:								## Create stripped down romfs/ from staging/
	+@$(MAKE) -C system $@

ramdisk:							## Build ramdisk of romfs/ dir
	@echo "  INITRD  $(OSNAME) $(OSVERSION_ID)"
	@touch romfs/etc/version
	@$(MAKE) -f ramdisk.mk $@

image:								## Build image, with dependency checking
	+@$(MAKE) -C arch $@

kernel:								## Build configured Linux kernel
	+@$(MAKE) -C kernel all

kernel-menuconfig:						## Linux menuconfig
	@$(MAKE) -C kernel menuconfig

kernel-oldconfig:						## Linux oldconfig
	@$(MAKE) -C kernel oldconfig

kernel-defconfig:						## Linux defconfig for the selected target platform
	@$(MAKE) -C kernel defconfig

kernel-saveconfig:						## Save Linux-VER.REV/.config to kernel/config-VER
	@$(MAKE) -C kernel saveconfig

kernel-install:							## Install Linux device tree
	+@$(MAKE) -C kernel dtbinst

world:								## Build everything, in sequence
	+@for dir in lib packages user; do			\
		$(MAKE) -C $$dir all;				\
		$(MAKE) -C $$dir install;			\
	done

TARGETS=$(shell find lib -maxdepth 1 -mindepth 1 -type d)
include system/quick.mk

TARGETS=$(shell find packages -maxdepth 1 -mindepth 1 -type d)
include system/quick.mk

TARGETS=$(shell find user -maxdepth 1 -mindepth 1 -type d)
include system/quick.mk

clean:								## Clean build tree, excluding menuconfig
	-+@for dir in user packages lib kernel; do		\
		echo "  CLEAN   $$dir";				\
		$(MAKE) -C $$dir $@;				\
	done

distclean:							## Really clean, as if started from scratch
	-+@for dir in user packages lib kernel kconfig; do 	\
		echo "  PURGE   $$dir";				\
		$(MAKE) -C $$dir $@;				\
	done
	-+@for file in .config staging romfs images; do		\
		echo "  PURGE   $$file";			\
		$(RM) -rf $$file;				\
	done

error:
	@echo "  FAIL    No .config found, see the README for help on download and set up."
	@exit 1

help:
	@grep -hP '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)	\
	| sort | awk 'BEGIN {FS = ":.*?## "}; 			\
			    {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo

# Disable parallel build in this Makefile only, to ensure execution
# of 'image' *after* 'world' --J
.NOTPARALLEL:
