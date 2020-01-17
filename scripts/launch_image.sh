# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] && abort_docker_env

docker rm --force $docker_container

mkdir -p $top_dir/$install_x86_64

docker run \
	--mount type=bind,src=$top_dir/$linux,dst=$container_home/$linux \
	--mount type=bind,src=$top_dir/$scripts,dst=$container_home/$scripts,readonly \
	--mount type=bind,src=$top_dir/$userspace,dst=$container_home/$userspace \
	--mount type=bind,src=$top_dir/$tests,dst=$container_home/$tests \
	--mount type=bind,src=$top_dir/$install_x86_64,dst=$container_home/$install_x86_64 \
	--name $docker_container \
	-t \
	-i $docker_image \
	$docker_cmd

docker rm --force $docker_container
docker ps -a
