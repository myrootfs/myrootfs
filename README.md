Introduction
------------

myrootfs is a BusyBox based root file system that can be used to build
very small containers for Linux.  The default x86_64 build weighs in at
3.1 MiB with a full GLIBC and BusyBox install.


Requirements
------------

The build environment currently requires *at least* the following tools,
tested on Ubuntu 16.04 (x86_64):

* build-essential (gcc, make, etc.)
* automake autoconf libtool pkg-config flex bison wget quilt
* Toolchains, which requires gawk:
  * [arm-unknown-linux-gnueabi][2]
  * [aarch64-unknown-linux-gnu][3]
  * [powerpc-unknown-linux-gnu][4]
  * [x86_64-unknown-linux-gnu][5]


Building
--------

This example builds a squashfs root file system for x86_64 targets from
a clean checkout:

    $ export PATH=/usr/local/x86_64-unknown-linux-gnu-7.3.0-1/bin:$PATH
    $ ARCH=x86_64 make x86_64_defconfig
    $ make

The resulting image file:

    $ ls -lh images/
    total 3,1M
    -rw-r--r-- 1 jocke jocke 3,1M dec 28 19:27 image.bin


Bugs & Feature Requests
-----------------------

Feel free to report bugs and request features, or even submit your own
[pull requests](https://help.github.com/articles/using-pull-requests/)
using [GitHub](https://github.com/myrootfs/myrootfs)

Cheers!  
-- Joachim

[1]: https://github.com/crosstool-ng/crosstool-ng
[2]: https://ftp.troglobit.com/pub/Toolchains/arm-unknown-linux-gnueabi-7.3.0-1.tar.xz
[3]: https://ftp.troglobit.com/pub/Toolchains/aarch64-unknown-linux-gnu-7.3.0-1.tar.xz
[4]: https://ftp.troglobit.com/pub/Toolchains/powerpc-unknown-linux-gnu-7.3.0-1.tar.xz
[5]: https://ftp.troglobit.com/pub/Toolchains/x86_64-unknown-linux-gnu-7.3.0-1.tar.xz
