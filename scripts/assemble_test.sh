# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env
[[ -n "$(ls -A $rootfs)" ]] || abort_empty_dir $rootfs

src=$top_dir/$tests
make -C $src
[[ $? == 0 ]] || exit 0

dst=$rootfs/$rootwd
echo " "
echo "Copying $src/$test_bin to $dst ..."
cp $src/$test_bin $dst
[[ $? == 0 ]] || exit 0

echo "Setting exec perm on $dst/$test_bin ..."
chmod +x $dst/$test_bin

echo " "
echo " "
ka_test=$dst/$test
rm $ka_test
echo "
#!/bin/sh

tracing_off=0
tracing_on=1
tracefs=/sys/kernel/tracing

abort_no_dev() {
	echo \"device \$1 not found\"
	exit 1
}

[[ -n \"\$(ls -l /dev/${device})\" ]] || abort_no_dev $device

echo \$tracing_on > \$tracefs/tracing_on
./$test_bin
test_exit_code=\$?
echo \$tracing_off > \$tracefs/tracing_on

echo \"test exit code = \$test_exit_code\"

" > $ka_test

chmod +x $ka_test
ls -l $ka_test
cat $ka_test
