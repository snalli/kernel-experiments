# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env
[[ -n "$(ls -A $rootfs)" ]] || abort_empty_dir $rootfs

src=$top_dir/$linux/$driver
make -C $top_dir/$linux M=$src modules
[[ $? == 0 ]] || exit 0

dst=$rootfs/$modules/$linux/$driver
echo "Copying $src to $dst..."
mkdir -p $dst
cp -r $src/* $dst
[[ $? == 0 ]] || exit 0

echo " "
echo " "
ka_setup=$rootfs/$rootwd/$setup
rm $ka_setup
echo "
#!/bin/sh

tracing_off=0
tracing_on=1
tracefs=/sys/kernel/tracing

echo \"*module*\" > \$tracefs/set_ftrace_filter

echo \$tracing_on > \$tracefs/tracing_on
insmod /${modules}/${linux}/${driver}/${module}.ko
echo \$tracing_off > \$tracefs/tracing_on

lsmod | grep ${module}
if [[ \$? != 0 ]]
then
	echo \"failed to load ${module}.ko\"
	exit 1
fi

echo \":mod:${module}\" >> \$tracefs/set_ftrace_filter

major=\`grep ${device} /proc/devices | cut -d \" \" -f 1\`
[[ -n \$major ]] || exit 1

mknod /dev/${device} c \$major 0
ls -l /dev/${device}

" > $ka_setup

chmod +x $ka_setup
ls -l $ka_setup
cat $ka_setup

echo " "
echo " "
ka_remove=$rootfs/$rootwd/$remove
rm $ka_remove
echo "
#!/bin/sh

tracing_off=0
tracing_on=1
tracefs=/sys/kernel/tracing

echo \$tracing_on > \$tracefs/tracing_on
rmmod ${module}
rmmod_status=\$?
echo \$tracing_off > \$tracefs/tracing_on

[[ \$rmmod_status == 0 ]] && rm /dev/${device}

" > $ka_remove

chmod +x $ka_remove
ls -l $ka_remove
cat $ka_remove
