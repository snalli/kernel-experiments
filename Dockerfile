# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

FROM fedora-updates:latest

# download x86-64 packages
## yum --downloadonly does not work; ignored by yum
RUN mkdir -p /home/repo/x86_64
WORKDIR /home/repo/x86_64
RUN yumdownloader --forcearch x86_64 --resolve --alldeps \
	glibc-static.x86_64 

# start fakeroot for mknod operations
RUN echo -e "if [[ -z \$FAKEROOTKEY ]] \nthen \n\tfakeroot \n\texit \nfi" >> /root/.bashrc

# see scripts/include.sh
RUN mkdir /home/rootfs
WORKDIR /home
