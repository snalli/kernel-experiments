---
description: All notable changes to this project will be documented in this file.
---

# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[0.2.1\] - 2020-01-17

### Added

* scripts to cross-compile on ARM for x86_64

## \[0.2.0\] - 2019-09-17

### Added

* article on how to utilize detachable memory in qemu
* `karray` linux kernel module and associated scripts and tests

### Changed

* improved scripts to test execution environment before proceeding

## \[0.1.0\] - 2019-08-31

### Added

* .gitignore in all folders
* CHANGELOG to serve as an evolving example of a standardized open source project CHANGELOG.
* COPYING containing a copy GNU GPLv2 license
* Dockerfile to build fedora image
* hotplug/ to hold backing file for hot-plugged memory
* klogs/ to hold qemu and kernel logs including dmesg, ftrace
* linux-5.1.5/.config
* README.md explaining how to use scripts/
* scripts/ to automate setup of kernel development environment
* userspace/ containing guest\_userspace.gz

