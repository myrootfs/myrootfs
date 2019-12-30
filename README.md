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
* automake autoconf libtool pkg-config flex bison wget quilt
* GCC v7.3, GLIBC based, [toolchains][], which requires gawk:
  * [arm-unknown-linux-gnueabi][1]
  * [aarch64-unknown-linux-gnu][2]
  * [powerpc-unknown-linux-gnu][3]
  * [x86_64-unknown-linux-gnu][3]

Install the toolchains in `/usr/local` on your build host to match the
instructions below, or set your `$PATH` to point to the location of the
bin directory.

Experimental GCC v9.2 toolchains, based on GLIBC or uClibc-ng, are also
available.  Change the `CONFIG_TOOLCHAIN_PREFIX` in your myrootfs
`.config`, manually or using `make menuconfig`.  For download, see
the [crosstool-NG releases][[toolchains]] page.


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


LXC config
----------

Having built your first application image using myrootfs.  Create a
Linux container with LXC using:

``` sh
$ sudo mkdir -p /var/lib/lxc/images/
$ sudo mkdir -p /var/lib/lxc/foo
$ sudo cp images/myrootfs.img /var/lib/lxc/images/foo.img
```

The LXC `config` file might need some tweaking, in particular if you use
different path to the `.img` file.  The host bridge you probably want to
change as well.  Here we have used `lxcbr0`:

```
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

``` sh
$ sudo lxc-start -n foo
```

To see what actually happens when it starts up, append `-F`.  Connect to
the container's `/dev/console` with:

``` sh
$ sudo lxc-console -n foo -t 0
```


Bugs & Feature Requests
-----------------------

Feel free to report bugs and request features, or even submit your own
[pull requests](https://help.github.com/articles/using-pull-requests/)
at [GitHub](https://github.com/myrootfs/myrootfs).

[1]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/arm-unknown-linux-gnueabi-7.3.0-1.tar.xz
[2]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/aarch64-unknown-linux-gnu-7.3.0-1.tar.xz
[3]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/powerpc-unknown-linux-gnu-7.3.0-1.tar.xz
[4]: https://github.com/myrootfs/crosstool-ng/releases/download/troglobit%2F7.3.0-1/x86_64-unknown-linux-gnu-7.3.0-1.tar.xz
[toolchains]:  https://github.com/myrootfs/crosstool-ng/releases
[uClibc-ng]:   https://uclibc-ng.org/
