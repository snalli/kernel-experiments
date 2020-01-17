# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env

echo " "
echo " "
echo " "
make -C $top_dir/$linux -j4
[[ $? == 0 ]] || exit 0
