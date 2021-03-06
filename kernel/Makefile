# Glue for cross compiling the Linux kernel
#
# Copyright (c) 2014-2016  Joachim Nilsson <troglobit@gmail.com>
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
.PHONY: all defconfig oldconfig saveconfig headers_install modules_install clean distclean

PKGVER         ?= $(KERNEL_VERSION)
PKGBASEVER      = $(shell echo $(PKGVER) | sed 's/\([0-9]*\.[0-9]*\).*/\1/')
PKG             = linux-$(PKGVER)
PKGNAME        := kernel
PKGSUFFIX      := tar.xz
PKGTARGETS     := build-kernel
PKGPATCHES      = patches/$(PKGBASEVER)/*.patch patches/$(PKGBASEVER)/series
ifdef CONFIG_LINUX_RC
RC_PATH         = testing/
endif
PKGURL          = http://cdn.kernel.org/pub/linux/kernel/v4.x/$(RC_PATH)$(PKGTAR)
CONFIG          = $(PRODDIR)/linux.config-$(PKGBASEVER)
IMAGE           = $(if $(filter linux,$(KERNEL_IMAGE)), \
			$(PKG)/linux, \
			$(PKG)/arch/$(KERNEL_ARCH)/boot/$(KERNEL_IMAGE))

include $(ROOTDIR)/system/pkg.mk
unexport KBUILD_KCONFIG

$(PKG)/.config::
	@if [ ! -s $@ ]; then								\
		echo "  CONFIG  $@ from $(patsubst $(srctree)/%,%,$(CONFIG))";		\
		if [ -f $(CONFIG) ]; then						\
			cp $(CONFIG) $@;						\
			$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) oldconfig;		\
		else									\
			$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) $(MACH)_defconfig;	\
		fi;									\
		echo "  PREPARE $(PKG)";						\
		$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) prepare scripts;			\
	else										\
		echo "  NO-OP   $@ already installed.";					\
	fi

defconfig:
	@$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) $(MACH)_defconfig

oldconfig:: $(PKG)/.config
	@$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) oldconfig

saveconfig:
	@echo -n "  SAVING  "
	@cp -v $(PKG)/.config $(CONFIG)

menuconfig: $(PKG)/.config
	@echo "  CONFIG  $(PKG)"
	@$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) menuconfig

$(IMAGE): $(PKG)/.config
	@echo "  BUILD   kernel/$(PKG)"
	+@$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) $(KERNEL_IMAGE)

kernel: $(IMAGE)

modules: $(PKG)/.config
	@echo "  MODULES kernel/$(PKG)"
	+@$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH) modules

headers_install: $(PKG)/.config
	@echo "  HEADERS kernel/$(PKG)"
	+$(MAKE) -C $(PKG) $@ ARCH=$(KERNEL_ARCH) INSTALL_HDR_PATH=$(STAGING)

modules_install: modules
	@echo "  MODINST kernel/$(PKG)"
	@. $(PKG)/.config;						\
	if [ "$$CONFIG_MODULES" = "y" ]; then				\
		if [ ! -d $(STAGING)/lib/modules ]; then		\
			mkdir -p $(STAGING)/lib/modules;		\
		fi;							\
		$(MAKE) -C $(PKG) ARCH=$(KERNEL_ARCH)			\
				  INSTALL_MOD_PATH=$(STAGING)		\
				  INSTALL_MOD_STRIP=--strip-all		\
				  $@;					\
	fi

ifdef CONFIG_LINUX_BUILD_IMAGE
build-kernel: kernel modules modules_install $(if $(filter-out linux,$(KERNEL_IMAGE)),headers_install)

install::
	@echo "  INSTALL kernel/$(PKG)"
	@cp -v $(IMAGE) $(IMAGEDIR)
	@if [ "$(ARCH)" = "arm" -o "$(ARCH)" = "arm64" ]; then		\
		echo "  DTBINST kernel/$(PKG)";				\
		INSTALL_DTBS_PATH=$(IMAGEDIR) ARCH=$(KERNEL_ARCH) 	\
			$(MAKE) -C $(PKG) dtbs dtbs_install; 		\
	fi

else ifdef CONFIG_LINUX_BUILD_HEADERS
build-kernel: headers_install

install::
	@true
endif

distclean::
	-@$(RM) -rf linux-*
