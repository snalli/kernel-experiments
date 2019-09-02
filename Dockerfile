# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

FROM fedora:latest

RUN yum -y install \
	bc \
	bison \
	cpio \
	elfutils-libelf-devel \
	file \
	findutils \
	flex \
	gcc \
	glibc-static \
	hostname \
	kernel-devel \
	less \
	make \
	ncurses-devel \
	openssl-devel \
	python3-pip.noarch \
	python36.x86_64 \
	vim

RUN pip3 install argparse

ENV DOCKER=yes

# See scripts/include.sh
RUN mkdir /home/rootfs