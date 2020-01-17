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
updates_docker_file=$top_dir/Dockerfile_updates
docker_container=fedora
base_image=fedora
updates_image=fedora-updates:latest
docker_image=fedora-sandbox:latest

# See Dockerfile
container_home=/home
rootfs=$container_home/rootfs
rootwd=root
tracer=tracer

# linux
linux_file=linux-5.1.15.tar.gz
linux_url=https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/$linux_file

# linux internal
linux=linux-5.1.15
device=karray
driver=drivers/$device
module=$device
modules=lib/modules
setup=setup_${module}.sh
remove=remove_${module}.sh
test_bin=${module}_test
test=test_${module}.sh
tests=tests

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

# cross-compiler for x86_64
X86_64="x86_64"
install=install
install_x86_64=$install/$X86_64
X86_64_LOCAL_REPO=local
X86_64_LOCAL_REPO_ROOT=$container_home/repo/x86_64
X86_64_LOCAL_INSTALL_ROOT=$container_home/$install_x86_64
X86_64_LOCAL_REPO_FILE=$X86_64_LOCAL_REPO_ROOT/x86_64-local.repo
X86_64_LOCAL_REPO_CONFIG="["${X86_64_LOCAL_REPO}"] \nname=x86_64-local \nbaseurl=file://"${X86_64_LOCAL_REPO_ROOT}" \nenabled=1 \ngpgcheck=0"
NATIVE_ARCH=`arch`
if [[ $NATIVE_ARCH != $X86_64 ]]
then
	export ARCH=x86_64
	export CROSS_COMPILE=x86_64-linux-gnu-
fi

abort_non_docker_env() {
	echo "launch docker container"
	exit -1
}

abort_docker_env() {
	echo "exit docker container"
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

abort_x86_64() {
	echo "not required since arch is "$X86_64
	exit -4
}
