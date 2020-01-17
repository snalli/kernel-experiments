# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] && abort_docker_env

docker rm --force $docker_container
docker rmi -f $docker_image

# don't cleanup base image unless really needed
if [[ $1 == "all" ]]
then
	docker rmi -f $updates_image $base_image
fi

docker ps -a
echo " "
docker images
