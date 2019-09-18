/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Copyright 2019 Sanketh Nalli
 */

#ifndef _KARRAY_H_
#define _KARRAY_H_

#include <linux/atomic.h>
#include <linux/cdev.h>
#include <linux/spinlock.h>
#include <linux/types.h>

#include "kactl.h"

#define KA_MINOR 0
#define KA_NR_DEVS 1

/*****************************************************************************/
/* in-memory data structures 												 */
/*****************************************************************************/

struct ka_descr_t {
	bool char_dev_added;
	char *volume_virt_addr;
	phys_addr_t volume_phys_addr;
	ssize_t volume_size_bytes;
	struct cdev char_dev;
};

#define ERROR "ERROR"
#define INFO "INFO"
#define DEBUG "DEBUG"

#endif /* _KARRAY_H_ */
