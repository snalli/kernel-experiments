---
description: >-
  This article describes a process of setting up an environment to compile,
  execute and experiment with Linux kernel on Mac.
---

# How to experiment with Vanilla Linux kernel on Mac

I am fascinated by [Linux](https://www.kernel.org) kernel due to a high degree of insight it gives me into internals of an operating system and a vast community of expert developers I can count on for help. I could experiment with it on sacrificial machines during internships and [graduate school](http://pages.cs.wisc.edu/~sankey/homepage.html). All I have now is a personal laptop to experiment with.

This [article](https://kdump-1.gitbook.io/my-kernel-dump/) describes a process of setting up an environment to compile, execute and experiment with Linux kernel on Mac. It is good for understanding kernel internals in action but not for performance testing.

**version 0.1.0** is available for [download](downloads.md).

## How to setup environment on host

```text
host  = Mac
guest = Linux
```

The first challenge before experimenting with the kernel is to create a reliable **compilation environment** to compile it. The second challenge is to create a reliable and sandboxed **execution environment** to run the kernel. I considered several options to solve both challenges.

|  | **Compilation env** | **Exec env** |
| :--- | :--- | :--- |
| Dual-boot Linux and host OS on host machine | Linux or host OS | Host machine |
| Use virtual machine \(VM\) | Linux in VM | VM |
| Buy cloud-based VM | Linux in VM | VM |
| [Usermode Linux or UML](http://user-mode-linux.sourceforge.net/) | UML or host OS | Host machine |
| [Raspberry Pi](https://www.raspberrypi.org/) or BeagleBone | OS on Raspberry Pi or [BeagleBone](https://beagleboard.org/) | Raspberry Pi or BeagleBone |
| Use Docker and qemu | [Docker](https://www.docker.com/) | [qemu](https://www.qemu.org/) |

I've dual-booted Linux with Windows and it does not end well. Sooner or later, I lost access to both operating systems. Compiling Linux kernel on a non-Linux environment is clumsy. Popular virtual machines cost money. When free, they didn't work reliably enough for me. Cloud instances cost money too and are accessible only over a network. UML was not a good experience. Raspberry Pi was just too slow and required purchasing peripherals. I realized I can use docker to create a compilation environment and `qemu` for execution environment, as shown below.

```text
    compilation env                                    execution env
   __________________                              _____________________
  |                  |                            |                     |   
  | docker container |                            | qemu with busybox   |
  | with Fedora      |                            | userspace, linux    |
  | userspace image. |                 ---------> | modules & binary.   | <-----
  | compile linux    |                |           | run linux kernel    |       |
  | src & modules,   |                |           | here.               |       |
  | make initramfs.  |                |           |                     |       |
  |                  |                |           |                     |       |
   ------------------                 |            ---------------------        |
      A       |                       |               |              |          |
      |       | 2. initramfs,         | 3. initramfs  | 4. dmesg     |          |
      |       | vmlinuz & modules     |               | on ttyS0     |          |
      |       |              _________________        |              |          |
      |       |             |                 |       |              |          |
      |       |             | disk on host    |       |              |          |
      |        -----------> | stores linux    | <-----               |          |
      |                     | src, initramfs, | <--------------------           |     
       -------------------- | logs & vmlinuz  |   5. ftrace on ttyS1            |   
           1. linux src     |                 | -------------------------------- 
                             -----------------    6. file-backed hot-plug memory

                                   host
```

### Prerequisites

* Docker
* QEMU
* Setup-code. [Download here.](downloads.md)

I use Docker to create a containerized compilation environment on my host OS to compile the kernel. Docker is free and easy to use. The container runs in isolation with respect to environment on host OS and can be terminated at will.

I use Quick Emulator or `qemu` to create a virtual machine to run the kernel as a guest kernel on the host OS. `qemu` is free, open-source, "easy" to use and runs as a _process_ that can be terminated at will.

### Installation

Following actions should be executed and in order. Each action is elaborated later including scripts to easily execute each one.

First time after downloading setup-code,

1. **Download Linux kernel source code**
2. **Build docker image**
3. **Launch docker container.** This starts a containerized compilation environment.
4. **Compile guest kernel.** This compiles kernel and tools to create guest userspace.
5. **Extract guest userspace** to make modifications to it including adding kernel modules or other scripts to guest filesystem.
6. **Make guest userspace** to build initramfs from which the userspace boots.
7. **Start qemu and guest kernel.** This starts a sandboxed execution environment.

Thereafter,

1. **Launch docker container.** This starts a containerized compilation environment.
2. **Compile guest kernel and modules, if any**
3. **Extract guest userspace** to make modifications to it including adding kernel modules or other scripts to guest filesystem.
4. **Make guest userspace** to build initramfs from which the userspace boots.
5. **Start qemu and guest kernel.** This starts a sandboxed execution environment.

### How to run scripts on host

* `build_image.sh` builds a docker image with Fedora userspace
* `cleanup_docker.sh` removes docker container and images
* `download_linux.sh` downloads linux source and un-tars it
* `launch_image.sh` launches a docker container with mounted volumes including Linux source code and files or folders shared with `qemu`
* `reboot_kernel.sh` starts `qemu` to run guest OS

#### How to download linux

```bash
host$ cd $top_dir

host$ ./scripts/download_linux.sh
<downloads & un-tars linux-X.Y.Z.tar.gz>
```

#### How to build docker image

```bash
host$ cd $top_dir

host$ ./scripts/build_image.sh
```

#### How to launch and exit docker container

```bash
host$ cd $top_dir

host$ ./scripts/launch_image.sh
docker$ <in docker container>
...

docker$ exit
host$ <back in host>
```

#### How to clean up docker container and image

```bash
host$ cd $top_dir

host$ ./scripts/cleanup_docker.sh
```

## How to setup guest Linux kernel

I configured the guest kernel to include minimal code required to boot it in `qemu`. It is configured to boot on virtual hardware and not on real hardware. This drastically reduces kernel compilation time, although I don't compile it often.

Using `make menuconfig` I disabled networking support, all filesystems, graphics, power managers, ASLR, ACPI, SELinux, SMP support, NUMA support and lot of drivers for hardware I don't possess or intend to use with `qemu` including mouse or keyboard. The kernel config is available here for [download](downloads.md).

The guest kernel receives inputs and sends output via serial console `ttyS0`. Since I disabled networking in the guest kernel, I had to disable guest userspace components that depend on it including `udevadm`. I disabled all filesystems because Tinycore's Busybox userspace boots off of `initramfs` in-memory filesystem obtained by decompressing a [cpio](https://en.wikipedia.org/wiki/Cpio) archive. No modifications to the filesystem are persisted to the archive ensuring a pristine boot each time. However, I configured support for ftrace, memory hot-plug and kernel modules. The kernel config is available for [download](downloads.md).

#### ftrace

`ftrace` is a [function tracer in Linux kernel](https://lwn.net/Articles/370423/) that helps visualize its control flow. As shown in the figure above, the guest kernel emits `ftrace` output to the host via serial console `ttyS1` that is connected to a log file on the host OS. A similar setup collects `dmesg` from the guest kernel in a log file on the host OS. I can then view guest kernel's activity in realtime by tailing both log files or save them for inspection later.

#### Memory hot-plug

[Memory hot-plug](https://www.kernel.org/doc/html/latest/admin-guide/mm/memory-hotplug.html) is a feature of Linux kernel that allows inserting memory modules into a computer and expanding its core memory while the kernel is running. I share just a small slice of host OS's memory with the guest OS so that it does not deprive other processes on host. Once the guest OS boots successfully, I expand its core memory by hot-plugging more memory. `qemu` allows allocating hot-plugged guest memory from a file on the host OS. I decided to use this option since I have significantly more storage area on host OS than memory.

#### How to compile guest kernel

```bash
<in docker container>

docker$ cd /home/linux-X.Y.Z

docker$ make -j4
<compiles kernel>
```

#### How to start guest kernel

```bash
<in host>

host$ cd $top_dir

host$ ./scripts/reboot_kernel.sh
...

guest$ <in guest shell>
```

#### How to tail guest kernel's logs

```bash
<in host>

host$ cd $top_dir

host$ tail -f klogs/ftrace/ftrace.log
<see kernel control flow in realtime>
...

host$ tail -f klogs/dmesg/dmesg.log
<see kernel messages in realtime>
```

All logs are archived with date in klogs folder. Or in other words, logs are rotated on a daily basis.

#### How to tail qemu's logs

```bash
<in host>

host$ cd $top_dir

host$ tail -f klogs/qemu/qemu.log
<see qemu log in realtime>
```

All logs are archived with date in klogs folder. Or in other words, logs are rotated on a daily basis.

#### How to stop guest kernel

```bash
<in host>
host$ kill `pgrep qemu`
```

## How to setup guest userspace

#### _busybox_ guest userspace boot sequence

```text
<guest linux kernel>
...
/init
    /sbin/init
        /etc/inittab                   <modified>
            /etc/init.d/rcS
                /etc/init.d/tc-config  <modified>
            /sbin/getty
                /sbin/autologin        <modified>
                    /root/.profile     <modified>
...
<guest shell>
```

I wanted the smallest possible userspace devoid of GUI for the guest to avoid slowing down other processes on the host OS. I found [Tinycore](https://distro.ibiblio.org/tinycorelinux/) Linux and decided to use its [Busybox](https://busybox.net) userspace after some modifications including disabling `udevadm` and starting a background process immediately after booting the guest to emit `ftrace` to `ttyS1`. [`debootstrap`](https://wiki.debian.org/Debootstrap) is another alternative. The guest userspace is available for [download](downloads.md).

#### How to make guest userspace

* `extract_rootfs.sh` extracts a cpio archive including Busybox userspace into docker container
* `make_initramfs.sh`  builds initramfs as a cpio archive including Busybox userspace

```bash
<in docker container>

docker$ cd /home

docker$ ./scripts/extract_rootfs.sh
<extracts guest userspace to /home/rootfs>

docker$ cd /home/rootfs
<make changes>

docker$ cd /home
docker$ ./scripts/make_initramfs.sh
<compresses guest userspace to /home/userspace>
```

