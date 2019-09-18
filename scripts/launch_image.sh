# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] && abort_docker_env

docker rm --force $docker_container

docker run \
	--mount type=bind,src=$top_dir/$linux,dst=/home/$linux \
	--mount type=bind,src=$top_dir/$scripts,dst=/home/$scripts \
	--mount type=bind,src=$top_dir/$userspace,dst=/home/$userspace \
	--mount type=bind,src=$top_dir/$tests,dst=/home/$tests \
	--name $docker_container \
	-t \
	-i $docker_image \
	$docker_cmd

docker rm --force $docker_container
docker ps -a
