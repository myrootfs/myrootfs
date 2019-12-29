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
* [Toolchains][], which requires gawk:
  * [arm-unknown-linux-gnueabi][1]
  * [aarch64-unknown-linux-gnu][2]
  * [powerpc-unknown-linux-gnu][3]
  * [x86_64-unknown-linux-gnu][3]

Install the toolchains in `/usr/local` on your build host to match the
instructions below, or set your `$PATH` to point to the location of the
bin directory.


Building
--------

This example builds a SquashFS root file system for an x86_64 target
from a clean checkout:

    $ export PATH=/usr/local/x86_64-unknown-linux-gnu-7.3.0-1/bin:$PATH
    $ ARCH=x86_64 make x86_64_defconfig
    $ make

The resulting image file:

    $ ls -lh images/
    total 3,1M
    -rw-r--r-- 1 jocke jocke 3,1M dec 28 19:27 myrootfs.img




Bugs & Feature Requests
-----------------------

Feel free to report bugs and request features, or even submit your own
[pull requests](https://help.github.com/articles/using-pull-requests/)
at [GitHub](https://github.com/myrootfs/myrootfs).

[1]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/arm-unknown-linux-gnueabi-7.3.0-1.tar.xz
[2]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/aarch64-unknown-linux-gnu-7.3.0-1.tar.xz
[3]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/powerpc-unknown-linux-gnu-7.3.0-1.tar.xz
[4]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/x86_64-unknown-linux-gnu-7.3.0-1.tar.xz
[Toolchains]: https://github.com/myrootfs/crosstool-ng/releases
