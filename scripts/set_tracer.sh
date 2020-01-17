# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env
[[ -n "$(ls -A $rootfs)" ]] || abort_empty_dir $rootfs 

avlb_tracers=("function" "nop")

for t in "${avlb_tracers[@]}"
do
	if [[ $1 == $t ]]
	then
		echo $1 > $rootfs/$rootwd/$tracer
		cat $rootfs/$rootwd/$tracer
		exit 0
	fi
done

echo "invalid tracer $1"
echo "available tracers: ${avlb_tracers[@]}"
