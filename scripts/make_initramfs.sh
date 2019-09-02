# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env
[[ -n "$(ls -A $rootfs)" ]] || abort_empty_dir $rootfs 

src=$top_dir/$userspace/$guest_userspace
copy=${src}.tmp

echo "Making		${copy}"
cd $top_dir/$linux
usr/gen_initramfs_list.sh -o $copy $rootfs
ls -lh $src || abort_file_not_found

src=$top_dir/$userspace/$guest_userspace
echo "Renaming 	${copy} to ${src}"
mv $copy $src