---
description: >-
  This article describes how to utilize kernel memory hot-plug feature and
  detachable memory.
---

# How to utilize detachable memory in QEMU

A solution for many problems with a computer is to "turn it off and on again" or "add more memory or RAM". But little did I realize that one can add more memory to a computer without turning it off and on again. Linux kernel's memory hot-plug feature allows a computer's memory to grow or shrink while it is powered on and functioning! This is useful in discarding defective memory modules of a computer without powering it down. Conversely, it's useful in keeping up with increasing memory demand on a computer without powering it down.

**version 0.2.0** is available for [download](downloads.md).

## How to attach memory to QEMU​‌

Scripts introduced in a [previous article](https://kdump-1.gitbook.io/my-kernel-dump/) automate attaching memory to qemu and start a guest kernel. This can be verified by dropping down to qemu monitor once guest kernel boots and guest shell awaits a command.

```bash
<in guest>

guest$ <ctrl-a c>
<switch to qemu monitor>

(qemu) info memory-devices
Memory device [dimm]: "hp_dimm0"
  addr: 0x100000000
  slot: 0
  node: 0
  size: 2147483648
  memdev: /objects/mem1
  hotplugged: false
  hotpluggable: true

(qemu) <ctrl-a c>
<switch to guest shell>

guest$
```

This shows that I attached a memory device named `hp_dimm0` of size 2 gigabytes. It is `hotpluggable`. It is not `hotplugged` because I attached it **during** guest kernel boot which is technically a cold-plug. A true hot-plug requires dropping down to qemu monitor **after** guest kernel boots and typing in commands to attach memory. Nonetheless, the memory device can be detached **while** guest kernel is powered on or in other words, **hot-removed**. An important field here is `addr` which is physical address at which memory is attached to qemu. The kernel maps memory at `addr` to an arbitrary kernel virtual address for normal use.

## How to attach memory to guest kernel

I created a simple kernel module following lessons from [ldd3](https://lwn.net/Kernel/LDD3/) to utilize hot-plugged memory. Since memory is an array of pages, I call the module `karray`, where k stands for kernel. It maps hot-plugged memory to an arbitrary kernel virtual address during initialization. After a successful initialization, hot-plugged memory is available for use as device memory. I chose to keep it separate from regular system memory or "RAM" to explore device memory. `karray` un-maps it during exit.

### How to compile guest-kernel module

* `compile_karray.sh`
  * compiles `karray` module and copies it to guest rootfs
  * creates `setup_karray.sh` , `remove_karray.sh` in guest rootfs
* `assemble_test.sh`
  * compiles `karray_test` binary and copies it to guest rootfs
  * creates `test_karray.sh` in guest rootfs

```bash
<in docker container>

docker$ cd /home

docker$ ./scripts/extract_rootfs.sh
<extracts guest userspace in /home/rootfs>

docker$ ./scripts/compile_karray.sh
<compiles karray and copies it to guest rootfs>

docker$ ./scripts/assemble_test.sh
<compiles tests for karray and copies them to guest rootfs>

docker$ ./scripts/make_initramfs.sh
<makes guest userspace>
```

### How to run guest-kernel module

* `setup_karray.sh` inserts `karray` module into guest kernel
* `test_karray.sh` runs tests against `karray` module
* `remove_karray.sh` removes `karray` module from guest kernel

```bash
<in guest>

guest$ cd /root
guest$ ls
karray_test       remove_karray.sh  setup_karray.sh   test_karray.sh

guest$ ./setup_karray.sh
<insmod karray>

guest$ ./test_karray.sh

./karray_test:main()

open(/dev/karray) = 3
ioctl(fd = 3, request = 42) = 0
pread(fd = 3, buf = [], count = 32, offset = 43) = 0
pwrite(fd = 3, buf = "this is a test message", count = 23, offset = 44) = 0
close(fd = 3) = 0

test exit code = 0

guest$ ./remove_karray.sh
<rmmod karray>
```

You can view guest kernel's activity in realtime when it inserts, tests and removes `karray` module.

```bash
<in host>

host$ cd $top_dir
host$ tail -f klogs/ftrace/ftrace.log

# tracer: function
#
# entries-in-buffer/entries-written: 0/0   #P:1
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
          ...
          insmod-249   [000] ....     3.870055: init_module: [INFO]: device memory mapped from 0x100000000
          insmod-249   [000] ....     3.870055: init_module: [INFO]: device memory mapped at 0xffffc90040000000
          insmod-249   [000] ....     3.870056: init_module: [INFO]: device memory size = 2147483648 bytes
          insmod-249   [000] ....     3.870056: init_module: [INFO]: device major num = 251
          insmod-249   [000] ....     3.870056: init_module: [INFO]: device minor num = 0
          insmod-249   [000] ....     3.870056: init_module: [INFO]: num of devices   = 1
          ...
     karray_test-259   [000] ....     8.353930: ka_open: [INFO]: opened karray
     ...
     karray_test-259   [000] ....     8.354622: ka_ioctl: [INFO]: request = 42
     ...
     karray_test-259   [000] ....     8.366571: ka_read: [INFO]: rd_buf_sz = 32, rd_offset = 43
     ...
     karray_test-259   [000] ....     8.367842: ka_write: [INFO]: wrt_msg = "this is a test message", wrt_buf_sz = 23, wrt_offset = 44
     ...
     karray_test-259   [000] ....     8.369472: ka_release: [INFO]: closed karray
     ...
           rmmod-261   [000] ....     9.714527: 0xffffffffa0002122: [INFO]: exit karray
```
