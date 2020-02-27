# Handles Qemu target (run), image creation, and other arch specifics
#
# Copyright (c) 2014-2020  Joachim Nilsson <troglobit@gmail.com>
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
.PHONY: image $(addprefix lxd-,prepare sync import create run delete)

# Source configured settings for this arch
include $(ROOTDIR)/system/core.mk

# If we're launching a container of a foreign architecture, make sure
# to include an LXD profile that will mount the qemu-user-static
# binary inside the container, which in turns allows the binfmt_misc
# magic to do its thing.
qemu-profile := $(if $(filter $(QEMU_ARCH),$(shell uname -m)),,qemu-$(QEMU_ARCH)-static)

# Allow user override to support multiple concurrent instances.
LXD_NAME ?= $(CONFIG_LXD_NAME)
LXD_ALIAS ?= $(CONFIG_LXD_ALIAS)
LXD_PROFILES ?= $(addprefix myrootfs.,\
	$(qemu-profile) \
	$(call qstrip,$(CONFIG_LXD_PROFILES)) \
	$(call qstrip,$(CONFIG_LXD_NET)))

squash-image := $(IMAGEDIR)/myrootfs.img
lxd-inputs := $(IMAGEDIR)/metadata.tar.gz $(squash-image)
lxd-deps   := $(lxd-inputs) lxd-sync

image: $(squash-image)

lxd-prepare:
	@echo "  LXD     Prepare ($(ARCH))"
	@lxd-prepare $(QEMU_ARCH)

lxd-sync:
	@lxd-prepare $(QEMU_ARCH) >/dev/null 2>/dev/null || { \
		echo "LXD dependencies missing, run 'make lxd-prepare' for more information"; \
		exit 1; \
	}

lxd-import: $(lxd-deps)
	@echo "  LXD     Importing $(LXD_ALIAS)"
	@lxd-helper -IX $(LXD_ALIAS) $(lxd-inputs)

lxd-create: $(lxd-deps)
	@echo "  LXD     Creating $(LXD_NAME)"
	@lxd-helper -IX -p "$(LXD_PROFILES)" -c $(LXD_NAME) $(LXD_ALIAS) $(lxd-inputs)
	@echo "Done, run 'lxc start $(LXD_NAME)' to start your container"

lxd-run: $(lxd-deps)
	@echo "  LXD     Starting $(LXD_NAME)"
	@lxd-helper -IX -p "$(LXD_PROFILES)" -e $(LXD_NAME) $(LXD_ALIAS) $(lxd-inputs)

lxd-delete:
	@echo "  LXD     Removing $(LXD_NAME)"
	@lxc stop $(LXD_NAME) 2>/dev/null || true
	@lxc delete $(LXD_NAME)
	@echo "Done"


$(squash-image): $(ROMFS)
	@echo "  SQUASH  Creating SquasFS image"
	@mksquashfs $(ROMFS)/* $(squash-image) -noappend -no-xattrs -comp xz -all-root -b 128k


$(IMAGEDIR)/metadata.tar.gz: $(ROMFS)/metadata.yaml
	@tar caf $@ -C $(dir $<) $(notdir $<)

