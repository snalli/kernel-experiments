# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env

rm -fr $rootfs/*
cd $rootfs

gunzip --stdout $top_dir/$userspace/$guest_userspace | cpio -i
