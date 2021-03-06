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
include core.mk

# usr/lib usr/share usr/bin usr/sbin
STAGING_DIRS = mnt proc sys lib share bin sbin tmp var home host

dep:
	@check-toolchain $(CROSS_COMPILE)gcc $(TOOLCHAIN)

staging:
	@printf "  STAGING Root file system ... "
	@mkdir -p $(IMAGEDIR)
	@mkdir -p $(STAGING)
	@mkdir -p $(ROMFS)
	@for dir in $(STAGING_DIRS); do    \
		mkdir -p $(STAGING)/$$dir; \
	done
	@cp -a skeleton/* $(STAGING)/
	@if [ "x$(SYSROOT)" != "x" ]; then		\
		cp -fan $(SYSROOT)/* $(STAGING)/;	\
	fi
	@chmod -R u+w $(STAGING)
	@echo "NAME=\"$(OSNAME)\""                     > $(STAGING)/etc/os-release
	@echo "VERSION=\"$(OSVERSION)\""               >>$(STAGING)/etc/os-release
	@echo "ID=\"$(OSID)\""                         >>$(STAGING)/etc/os-release
	@echo "PRETTY_NAME=\"$(OSPRETTY_NAME)\""       >>$(STAGING)/etc/os-release
	@echo "VERSION_ID=\"$(OSVERSION_ID)\""         >>$(STAGING)/etc/os-release
	@echo "HOME_URL=\"$(OSHOME_URL)\""             >>$(STAGING)/etc/os-release
	@echo "DOCUMENTATION_URL=\"$(DOC_URL)\""       >>$(STAGING)/etc/os-release
	@echo "SUPPORT_URL=\"$(SUPPORT_URL)\""         >>$(STAGING)/etc/os-release
	@echo "BUG_REPORT_URL=\"$(BUG_REPORT_URL)\""   >>$(STAGING)/etc/os-release
	@echo "$(OSPRETTY_NAME)"                       > $(STAGING)/etc/version
	@echo "\\S \\\\n \\l"                          > $(STAGING)/etc/issue
	@echo "\\S"                                    > $(STAGING)/etc/issue.net
	@echo "$(OSRELEASE_ID)"                        > $(STAGING)/etc/hostname
	@sed -i 's/HOSTNAME/$(OSRELEASE_ID)/' $(STAGING)/etc/hosts

	@printf "\
architecture: $(LXD_ARCH)\n\
creation_date: $(shell date +%s)\n\
properties:\n\
  os: $(OSID)\n\
  release: $(OSRELEASE_ID)\n\
  description: $(OSPRETTY_NAME)\n"                     > $(STAGING)/metadata.yaml
	@printf "OK\n"

# The install phase removes unnecessary files from the sysroot
# The prune phase removes doc/man/include files and static libraries
# The strip phase strips libraries and executables
romfs:
	@echo "  POPUL8  Creating root filesystem from $(STAGING)"
	@$(CROSS_COMPILE)populate -f -s $(STAGING) -d $(ROMFS)
	-@rm -f $(ROMFS)/sbin/sln
	-@rm -f $(ROMFS)/sbin/ldconfig
	-@rm -rf $(ROMFS)/usr/lib/gconv
	-@rm -rf $(ROMFS)/usr/share/i18n
	-@rm -rf $(ROMFS)/usr/share/locale
	-@rm -rf $(ROMFS)/var/db/Makefile
	@echo "  PRUNE   Cleaning $(ROMFS)"
	-@rm -rf                    $(ROMFS)/usr/share/info
	-@rm -rf $(ROMFS)/share/doc $(ROMFS)/usr/share/doc
	-@rm -rf $(ROMFS)/share/man $(ROMFS)/usr/share/man
	-@rm -rf $(ROMFS)/include   $(ROMFS)/usr/include
	@find $(ROMFS)/ -name '*.a'  -delete
	@find $(ROMFS)/ -name '*.la' -delete
	@echo "  STRIP   Optimizing $(ROMFS)"
	@for file in `find $(ROMFS) -executable -type f`; do		\
		file $$file | grep 'not stripped' 2>&1 >/dev/null;	\
		if [ $$? -eq 0 ]; then					\
			$(STRIP) $$file;				\
		fi;							\
	done
	@chmod -R u+w $(ROMFS)

.PHONY: dep romfs staging
