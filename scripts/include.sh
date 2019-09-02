# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

__script=$0 
__script_dir="$(cd "$(dirname $__script)"; pwd -P)"

top_dir=$__script_dir/..

# DEBUG
# set -x

# common
today=`date "+%Y-%m-%d"`
now=`date "+%Y-%m-%d-%H:%M:%S"`
klog=$top_dir/klogs

# docker cmds & args
docker_cmd=/bin/bash
docker_file=$top_dir/Dockerfile
docker_container=fedora
base_image=fedora
docker_image=linux-build:$base_image

# See Dockerfile
rootfs=/home/rootfs
rootwd=root

# linux
linux_file=linux-5.1.15.tar.gz
linux_url=https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/$linux_file

# linux internal
linux=linux-5.1.15

# qemu
hotplug=hotplug
scripts=scripts
userspace=userspace
guest_userspace=guest_userspace.gz
qlog=qemu/qemu.log
qlog_archive=qemu/qemu.$today.log

# kernel logs
dmesg=dmesg/dmesg.log
dmesg_archive=dmesg/dmesg.$today.log
ftrace=ftrace/ftrace.log
ftrace_archive=ftrace/ftrace.$today.log

abort_non_docker_env() {
	echo "not in a docker container"
	exit -1
}

abort_empty_dir() {
	echo "empty dir $1"
	exit -2
}

abort_file_not_found() {
	echo "file not found"
	exit -3
}
