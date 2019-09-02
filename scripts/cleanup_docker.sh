# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

docker rm --force $docker_container
docker rmi -f $docker_image
docker rmi -f $base_image

docker ps -a
echo " "
docker images
