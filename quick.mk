$(addsuffix -build,$(TARGETS)):
	@echo "  BUILD   $(patsubst %-build,%,$@)"
	+@$(MAKE) -C $(patsubst %-build,%,$@) all

$(addsuffix -install,$(TARGETS)):
	@echo "  INSTALL $(patsubst %-install,%,$@)"
	+@$(MAKE) -C $(patsubst %-install,%,$@) install

$(addsuffix -clean,$(TARGETS)):
	@echo "  CLEAN   $(patsubst %-clean,%,$@)"
	-+@$(MAKE) -C $(patsubst %-clean,%,$@) clean

$(addsuffix -distclean,$(TARGETS)):
	@echo "  REMOVE  $(patsubst %-distclean,%,$@)"
	-+@$(MAKE) -C $(patsubst %-distclean,%,$@) distclean

$(addsuffix -menuconfig,$(TARGETS)):
	@echo "  CONFIG  $(patsubst %-menuconfig,%,$@)"
	@$(MAKE) -C $(patsubst %-menuconfig,%,$@) menuconfig

$(addsuffix -saveconfig,$(TARGETS)):
	@echo "  SAVING  $(patsubst %-saveconfig,%,$@)"
	@$(MAKE) -C $(patsubst %-saveconfig,%,$@) saveconfig
