# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2020 Sanketh Nalli

script=$0
script_dir="$(cd "$(dirname $script)"; pwd -P)"
include=$script_dir/include.sh

source $include

[[ $DOCKER == "yes" ]] || abort_non_docker_env
[[ $NATIVE_ARCH != $X86_64 ]] || abort_x86_64

echo " "
if [[ ! -d $X86_64_LOCAL_REPO_ROOT/repodata ]]
then
	createrepo --repo=$X86_64_LOCAL_REPO $X86_64_LOCAL_REPO_ROOT
fi

SRC=$X86_64_LOCAL_REPO_FILE
DST=$X86_64_LOCAL_INSTALL_ROOT/etc/yum.repos.d/`basename $X86_64_LOCAL_REPO_FILE`
if [[ -f $DST ]]
then 
	yum-config-manager --add-repo $DST
else
	echo -e ${X86_64_LOCAL_REPO_CONFIG} >> $SRC
	yum-config-manager --add-repo $SRC
fi

yum -y \
	--forcearch x86_64 \
	--installroot $X86_64_LOCAL_INSTALL_ROOT \
	--nodocs \
	--nogpgcheck \
	--repo $X86_64_LOCAL_REPO \
	install glibc-static
glibc_install_status=$?

[[ -f $DST ]] || mv $SRC $DST

echo " "
echo " "
echo "glibc install status : "$glibc_install_status

echo " "
echo "unpacking glibc-headers"
cd $X86_64_LOCAL_REPO_ROOT
rpm --nodeps --nodigest --nosignature --notriggers \
	--noscripts --ignorearch --ignoreos \
	--nofiles --nofiledigest \
	--root=$X86_64_LOCAL_INSTALL_ROOT \
	--install glibc-headers-2.30-8.fc31.x86_64.rpm 
