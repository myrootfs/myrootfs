TOOLCHAIN         := crosstool-ng-1.23.0-319-gaca85cb

qstrip             = $(strip $(subst ",,$(1)))
# "
noconfig_targets  := menuconfig nconfig gconfig xconfig config oldconfig	\
		     defconfig %_defconfig allyesconfig allnoconfig		\
		     distclean

#ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
-include $(ROOTDIR)/.config
#endif

ifeq ($(CONFIG_DOT_CONFIG),y)
ARCH               = $(call qstrip, $(CONFIG_ARCH))
MACH               = $(call qstrip, $(CONFIG_MACH))
KERNEL_VERSION     = $(call qstrip, $(CONFIG_LINUX_VERSION))
else
#ARCH              ?= arm
#MACH              ?= versatile
#KERNEL_VERSION     = 4.8.7
endif

# Map archs to Linux kernel archs
KERNEL_ARCH       := $(shell echo $(ARCH) | sed	\
			-e 's/ppc64/powerpc64/'	\
			-e 's/ppc/powerpc/'	\
			-e 's/aarch64/arm64/'   \
			-e 's/x86_64/x86/')

ifdef KERNEL_RC
KERNEL_VERSION     = $(KERNEL_VERSION).0$(KERNEL_RC)
endif
KERNEL_MODULES     = $(wildcard $(ROMFS)/lib/modules/$(KERNEL_VERSION)*)
KERNELRELEASE      = $(shell test -d $(KERNEL_MODULES)/build && $(MAKE) -s -C $(KERNEL_MODULES)/build CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(KERNEL_ARCH) kernelrelease)

include $(ROOTDIR)/arch/$(ARCH)/config.mk

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
export KERNEL_ARCH KERNEL_VERSION KERNEL_MODULES KERNELRELEASE
