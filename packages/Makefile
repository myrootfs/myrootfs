# Free/Libre Open-Source Software Packages
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
-include $(ROOTDIR)/.config

exclude                   = Makefile Kconfig $(wildcard *~)
dir_y                     =
dir_$(CONFIG_BUSYBOX)    += busybox
dir_$(CONFIG_DROPBEAR)   += dropbear
dir_$(CONFIG_IPROUTE2)   += iproute2
dir_$(CONFIG_SMCROUTE)   += smcroute
dir_$(CONFIG_STRACE)     += strace
dir_$(CONFIG_TCPDUMP)    += tcpdump
dir_n                     =
dir_                      =
dir_all                   = $(filter-out $(exclude), $(notdir $(wildcard *)))

include $(ROOTDIR)/system/rules.mk
