Introduction
------------

myrootfs is a BusyBox based root file system that can be used to build
very small containers for Linux.

The default x86_64 build weighs in at 3.1 MiB with a full GLIBC and
BusyBox install.  With a [uClibc-ng][] based toolchain the image is no
more than 1.3 MiB, in total.


Requirements
------------

The build environment currently requires *at least* the following tools,
tested on Ubuntu 16.04 (x86_64):

* build-essential (gcc, make, etc.)
* automake autoconf libtool pkg-config flex bison wget quilt libssl-dev
* GCC v7.3, GLIBC based, [toolchains][], which requires gawk:
  * [arm-unknown-linux-gnueabi][1]
  * [aarch64-unknown-linux-gnu][2]
  * [powerpc-unknown-linux-gnu][3]
  * [x86_64-unknown-linux-gnu][4]

Install the toolchains in `/usr/local` on your build host to match the
instructions below, or set your `$PATH` to point to the location of the
bin directory.

Experimental GCC v9.2 toolchains, based on GLIBC or uClibc-ng, are also
available.  Change the `CONFIG_TOOLCHAIN_PREFIX` in your myrootfs
`.config`, manually or using `make menuconfig`.  For download, see
our [crosstool-NG releases][toolchains] page.


Troubleshooting
---------------

When something does not build it can be hard to see what went wrong, so
there are several shortcuts and other tricks in the build system to help
you.  For instance, verbose mode:

```sh
$ make V=1
```

This is  what you are  probably used to  from other build  systems.  But
what if you only want to rebuild a single package?

```sh
$ make V=1 packages/busybox-build
```

This builds only BusyBox, with verbose mode enabled.  Other useful
shortcuts are:

```sh
$ make packages/busybox-clean
$ make packages/busybox-distclean
$ make packages/busybox-install
```

To tweak the kernel the following build shortcuts are available:

```sh
$ make kernel
$ make kernel_menuconfig
$ make kernel_saveconfig
```

There are a few more, see the Makefile for details.

> **Note:** debugging Makefiles can be a bit of a hassle.  To see what is
> *really* going on you can used `make --debug=FLAGS V=1`, or even try
> `make SHELL='sh -x' --debug=FLAGS V=1`.  Consult the GNU make man
> page for help with the debug FLAGS.


LXC config
----------

Having built your first application image using myrootfs.  Create a
Linux container with LXC using:

```sh
$ sudo mkdir -p /var/lib/lxc/images/
$ sudo mkdir -p /var/lib/lxc/foo
$ sudo cp images/myrootfs.img /var/lib/lxc/images/foo.img
```

The LXC `config` file might need some tweaking, in particular if you use
different path to the `.img` file.  The host bridge you probably want to
change as well.  Here we have used `lxcbr0`:

```sh
$ sudo sh -c "cat >>/var/lib/lxc/foo/config" <<-EOF
	lxc.uts.name = foo
	lxc.tty.max = 4
	lxc.pty.max=1024
	lxc.rootfs.path = loop:/var/lib/lxc/images/foo.img
	lxc.rootfs.options = -t squashfs
	lxc.mount.auto = cgroup:mixed proc:mixed sys:mixed
	lxc.mount.entry=run run tmpfs rw,nodev,relatime,mode=755 0 0
	lxc.mount.entry=shm dev/shm tmpfs rw,nodev,noexec,nosuid,relatime,mode=1777,create=dir 0 0
	lxc.net.0.type = veth
	lxc.net.0.flags = up
	lxc.net.0.link = lxcbr0

	#lxc.seccomp.profile = /usr/share/lxc/config/common.seccomp
	lxc.apparmor.profile = lxc-container-default-with-mounting
EOF
```

The last two lines are needed on systems with Seccomp and/or AppArmor.
Uncomment the one you need, see the host's dmesg when `lxc-start` fails
with mysterious error messages.  For convenience the Debian/Ubuntu is
uncommented already.

> **Note:** you may have to add the following two lines to your AppArmor
> profile to enable writable /etc, /var, /home, and /root directories.
> The file is in `/etc/apparmor.d/lxc/lxc-default-with-mounting`:
> ```
> mount fstype=tmpfs,
> mount fstype=overlay,
> ```

Start your container with:

```sh
$ sudo lxc-start -n foo
```

To see what actually happens when it starts up, append `-F`.  Attach to
the container's `/dev/console` with:

```sh
$ sudo lxc-console -n foo -t 0 -e '^p'
```

The last `-e '^p` remaps the control key sequence to detach from your
container and return to your host: Ctrl-p q


Building
--------

This example builds a SquashFS root file system for an x86_64 target
from a clean checkout:

```sh
$ export PATH=/usr/local/x86_64-unknown-linux-gnu-7.3.0-1/bin:$PATH
$ ARCH=x86_64 make x86_64_defconfig
$ time make -j5
real    1m17,908s
user    2m13,820s
sys     0m37,100s
```

The resulting image file:

```sh
$ ls -lh images/
total 3,1M
-rw-r--r-- 1 jocke jocke 3,1M dec 28 19:27 myrootfs.img
```

> **Note:** parallel builds (`-j5` above) can be very hard to debug
> since the output of many different components is mixed.  To avoid
> this and maintain your sanity, add `--output-sync=recurse` to
> your `make` commands.


Bugs & Feature Requests
-----------------------

Feel free to report bugs and request features, or even submit your own
[pull requests](https://help.github.com/articles/using-pull-requests/)
at [GitHub](https://github.com/myrootfs/myrootfs).


Licensing & References
----------------------

With the exceptions listed below, myrootfs is distributed under the
terms of the [ISC License][]¹.  myrootfs is the build system, or glue,
that ties the various Open Source components together.  Some files have
a different license statement, e.g. kconfig.  Those files are licensed
under the license contained in the file itself.

myrootfs bundles patch files, which are applied to the sources of the
various Open Source packages.  Those patches are not covered by the
license of myrootfs.  Instead, they are covered by the license of the
software to which the patches are applied, when said software comes
available under multiple licenses, sometimes as alternative commercial
licenses, the patches are provided under the publicly available Open
Source licenses.

----
¹ "... functionally equivalent to the [simplified BSD][] and [MIT][]
   licenses, but without language deemed unnecessary following the
   [Berne Convention][]."  --[Theo de Raadt][]

[1]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/arm-unknown-linux-gnueabi-7.3.0-1.tar.xz
[2]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/aarch64-unknown-linux-gnu-7.3.0-1.tar.xz
[3]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/powerpc-unknown-linux-gnu-7.3.0-1.tar.xz
[4]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/x86_64-unknown-linux-gnu-7.3.0-1.tar.xz
[simplified BSD]:   https://en.wikipedia.org/wiki/BSD_licenses#2-clause
[MIT]:              https://en.wikipedia.org/wiki/MIT_License
[Berne Convention]: https://en.wikipedia.org/wiki/Berne_Convention
[Theo de Raadt]:    https://marc.info/?l=openbsd-misc&m=120618313520730&w=2
[toolchains]:  https://github.com/myrootfs/crosstool-ng/releases
[uClibc-ng]:   https://uclibc-ng.org/
[ISC License]: https://en.wikipedia.org/wiki/ISC_license
