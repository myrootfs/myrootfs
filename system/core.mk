TOOLCHAIN         := crosstool-ng-1.23.0-319-gaca85cb

qstrip             = $(strip $(subst ",,$(1)))
# "

# System should be configured by this point
-include $(ROOTDIR)/.config

# Check to be sure, CONFIG_DOT_CONFIG only set if include succeeeded
ifeq ($(CONFIG_DOT_CONFIG),y)
ARCH               = $(call qstrip, $(CONFIG_ARCH))
MACH               = $(call qstrip, $(CONFIG_MACH))
KERNEL_IMAGE       = $(call qstrip, $(CONFIG_LINUX_IMAGE))
KERNEL_VERSION     = $(call qstrip, $(CONFIG_LINUX_VERSION))
CROSS_COMPILE      = $(call qstrip, $(CONFIG_TOOLCHAIN_PREFIX))

# Map archs to Linux kernel archs
KERNEL_ARCH       := $(shell echo $(ARCH) | sed	\
			-e 's/ppc64/powerpc64/'	\
			-e 's/ppc/powerpc/'	\
			-e 's/aarch64/arm64/'   \
			-e 's/x86_64/x86/')

QEMU_ARCH         := $(shell echo $(ARCH) | sed	\
			-e 's/arm64/aarch64/'   \
			-e 's/x86/x86_64/'      \
			)

LXD_ARCH          := $(shell echo $(ARCH) | sed	\
			-e 's/arm64/aarch64/'   \
			-e 's/arm/armv7l/'      \
			-e 's/x86/x86_64/'      \
			)

OSNAME            := $(call qstrip, $(CONFIG_SYSTEM_NAME))
OSRELEASE_ID      := $(call qstrip, $(CONFIG_SYSTEM_ID))
OSRELEASE          = myrootfs `date --iso-8601`
OSVERSION_ID      := $(call qstrip, $(CONFIG_SYSTEM_VERSION))
OSVERSION         := $(OSVERSION_ID), $(OSRELEASE)
OSID              := "myrootfs"
OSPRETTY_NAME     := $(call qstrip, $(CONFIG_SYSTEM_PRETTY_NAME))
OSHOME_URL        := $(call qstrip, $(CONFIG_SYSTEM_HOME_URL))
DOC_URL           := $(call qstrip, $(CONFIG_SYSTEM_DOC_URL))
SUPPORT_URL       := $(call qstrip, $(CONFIG_SYSTEM_SUPPORT_URL))
BUG_REPORT_URL    := $(call qstrip, $(CONFIG_SYSTEM_BUG_REPORT_URL))
else
OSNAME            := myrootfs
OSRELEASE_ID      := myrootfs
OSRELEASE          = myrootfs `date --iso-8601`
OSVERSION_ID      := 1.0
OSVERSION         := $(OSVERSION_ID), $(OSRELEASE)
OSID              := "myrootfs"
OSPRETTY_NAME     := $(OSNAME) $(OSVERSION_ID)
OSHOME_URL        := https://github.com/myrootfs
DOC_URL           := https://github.com/myrootfs/myrootfs/blob/master/README.md
SUPPORT_URL       := https://github.com/myrootfs/myrootfs
BUG_REPORT_URL    := https://github.com/myrootfs/myrootfs/issues
endif

ifdef KERNEL_RC
KERNEL_VERSION     = $(KERNEL_VERSION).0$(KERNEL_RC)
endif
KERNEL_MODULES     = $(wildcard $(ROMFS)/lib/modules/$(KERNEL_VERSION)*)

CROSS_TARGET       = $(CROSS_COMPILE:-=)
CC                 = $(CROSS_COMPILE)gcc
CFLAGS             = -O2
#CPPFLAGS           = -U_FORTIFY_SOURCE -D_DEFAULT_SOURCE -D_GNU_SOURCE
CPPFLAGS           = -I$(STAGING)/include -I$(STAGING)/usr/include
LDLIBS             =
LDFLAGS            = -L$(STAGING)/lib -L$(STAGING)/usr/lib
STRIP              = $(CROSS_COMPILE)strip

PATH              := $(ROOTDIR)/bin:$(PATH)
PRODDIR            = $(ROOTDIR)/arch/$(ARCH)/$(MACH)
DOWNLOADS         ?= $(shell xdg-helper DOWNLOAD)
STAGING            = $(ROOTDIR)/staging
ROMFS              = $(ROOTDIR)/romfs
IMAGEDIR           = $(ROOTDIR)/images
FINIT_D_AVAILABLE := $(STAGING)/etc/finit.d/available
PKG_CONFIG_LIBDIR := $(STAGING)/lib/pkgconfig
SYSROOT           := $(shell $(CROSS_COMPILE)gcc -print-sysroot)

export ARCH MACH CROSS_COMPILE CROSS_TARGET TOOLCHAIN
export CC CFLAGS CPPFLAGS LDLIBS LDFLAGS STRIP
export PATH PRODDIR DOWNLOADS STAGING ROMFS IMAGEDIR PKG_CONFIG_LIBDIR SYSROOT
export KERNEL_ARCH KERNEL_VERSION KERNEL_MODULES
export OSNAME OSRELEASE_ID OSRELEASE OSVERSION_ID OSVERSION
export OSID OSPRETTY_NAME OSHOME_URL
