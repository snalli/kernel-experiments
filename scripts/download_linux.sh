# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0 
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] && abort_docker_env

curl $linux_url -o $linux_file
[[ $? == 0 ]] || abort_file_not_found
tar --keep-newer-files -xvf $linux_file
