Introduction
------------

myrootfs is a BusyBox based root file system that can be used as a way
to build a very small containers for Linux.


Requirements
------------

The build environment currently requires at least the following tools,
tested on Ubuntu 16.04 (x86_64):

* build-essential (gcc, make, etc.) libssl-dev (to build kernel)
* automake autoconf libtool pkg-config flex bison wget quilt
* bc lzop device-tree-compiler (arm + powerpc) u-boot-tools (mkimage)
* libelf-dev (x86)
* Toolchains, which requires gawk:
  * [arm-unknown-linux-gnueabi][2]
  * [aarch64-unknown-linux-gnu][3]
  * [powerpc-unknown-linux-gnu][4]
  * [x86_64-unknown-linux-gnu][5]
* probably more, gzip?


Building
--------

To get a squashfs root file system for x86_64 targets:

    make distclean
    ARCH=x86_64 make x86_64_defconfig
    make



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
