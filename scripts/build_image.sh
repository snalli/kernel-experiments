# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

docker rmi -f $docker_image
docker build -f $docker_file \
	--force-rm \
	--pull \
	-t $docker_image \
	$top_dir
docker images
