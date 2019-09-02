# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

script=$0
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

#qemu opts
accel=hvf
base=utc
clock=host
cpu=qemu64
initrd=$top_dir/$userspace/$guest_userspace
kernel=$top_dir/$linux/arch/x86/boot/bzImage
mem_size=2048M
max_mem_size=4096M
name=tc
n_slot=2
hp_mem_size=$mem_size
hp_mem_dev=mem1
hp_mem_path=$top_dir/$hotplug/hp_mem.bin
hp_dimm_id=hp_dimm0

#kernel opts
append+="acpi=off "
append+="apparmor=0 "
append+="console=ttyS1 "
append+="cpufreq.off=1 "
append+="cpuidle.off=1 "
append+="loglevel=7 "
append+="mem=$mem_size "
append+="noclflush "
append+="nokaslr "
append+="nompx "
append+="nopku "
append+="nopti "
append+="nosmp "
append+="nr_cpus=1 "
append+="numa_balancing=disable "
append+="selinux=0 "
append+="trace_clock=local "
append+="tsc=unstable "

mkdir -p `dirname $klog/$dmesg` || exit 1
mkdir -p `dirname $klog/$ftrace` || exit 1
mkdir -p `dirname $klog/$qlog` || exit 1

printf "\n\n reboot $kernel at $now \n\n" >> $klog/$dmesg_archive
printf "\n\n reboot $kernel at $now \n\n" >> $klog/$ftrace_archive
printf "\n\n reboot $kernel at $now \n\n" >> $klog/$qlog_archive

qemu-system-x86_64 \
	-accel $accel \
	-append "$append" \
	-chardev file,id=ttyS1_logfile,path=$klog/$dmesg,mux=off \
	-chardev file,id=ttyS2_logfile,path=$klog/$ftrace,mux=off \
	-cpu $cpu \
	-device pc-dimm,id=$hp_dimm_id,memdev=$hp_mem_dev \
	-D $klog/$qlog \
	-initrd $initrd \
	-kernel $kernel \
	-m $mem_size,slots=$n_slot,maxmem=$max_mem_size  \
	-machine pc \
	-name $name \
	-nographic \
	-no-reboot \
	-object memory-backend-file,id=$hp_mem_dev,share=on,mem-path=$hp_mem_path,size=$hp_mem_size \
	-rtc base=$base,clock=$clock \
	-serial mon:stdio \
	-serial chardev:ttyS1_logfile \
	-serial chardev:ttyS2_logfile \
	-show-cursor

cat $klog/$dmesg >> $klog/$dmesg_archive
cat $klog/$ftrace >> $klog/$ftrace_archive
cat $klog/$qlog >> $klog/$qlog_archive
