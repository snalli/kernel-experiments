/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Copyright 2019 Sanketh Nalli
 */

#include <linux/atomic.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/gfp.h>
#include <linux/init.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/types.h>
#include <uapi/asm-generic/errno-base.h>

#include "karray.h"

MODULE_AUTHOR("Sanketh Nalli");
MODULE_LICENSE("GPL");

char *volume_phys_addr = (char *)0x100000000;
const unsigned int MAX_MAP_SIZE = (1 << 31) >> 31; /* 2^32 - 1 = 4GB */
const unsigned int MIN_MAP_SIZE = MAX_MAP_SIZE >> 4; /* 0.25GB */
static struct ka_descr_t ka_descr;
static struct ka_descr_t *kd = &ka_descr;
unsigned int volume_size_bytes = 2147483648 /* 2GB */;

// seems like busybox insmod doesn't pass args !
module_param(volume_phys_addr, charp, 0);
module_param(volume_size_bytes, int, 0);

int ka_init(void);
int ka_open(struct inode *, struct file *);
int ka_release(struct inode *, struct file *);
long ka_ioctl(struct file *, unsigned int, unsigned long);
ssize_t ka_read(struct file *, char __user *, size_t, loff_t *);
ssize_t ka_write(struct file *, const char __user *, size_t, loff_t *);
static void init_cdev(struct cdev *);
void ka_exit(void);

struct file_operations ka_dev_fops = {
	.owner = THIS_MODULE,
	.open = ka_open,
	.read = ka_read,
	.release = ka_release,
	.unlocked_ioctl = ka_ioctl,
	.write = ka_write,
};

void ka_exit(void)
{
	struct cdev *char_dev = &kd->char_dev;

	/* Get rid of our char dev entries */
	if (kd->char_dev_added) {
		cdev_del(&kd->char_dev);
	}

	/* return major number to kernel */
	unregister_chrdev_region(char_dev->dev, char_dev->count);

	/* unmap volume */
	if (kd->volume_virt_addr) {
		memunmap((void *)kd->volume_virt_addr);
	}

	trace_printk("[%s]: exit karray\n", INFO);
}

int ka_init(void)
{
	int err = 0;
	char *volume_virt_addr = 0;
	dev_t dev_num;
	struct cdev *char_dev = &kd->char_dev;

	if (volume_size_bytes < MIN_MAP_SIZE ||
	    volume_size_bytes > MAX_MAP_SIZE) {
		trace_printk(
			"[%s]: memmap size = %d bytes (min = %d, max = %d)\n",
			ERROR, volume_size_bytes, MIN_MAP_SIZE, MAX_MAP_SIZE);
		err = -ENOMEM;
		goto fail;
	}

	memzero_explicit(kd, sizeof(struct ka_descr_t));
	kd->volume_phys_addr = (phys_addr_t)volume_phys_addr;
	kd->volume_size_bytes = (ssize_t)volume_size_bytes;
	init_cdev(&kd->char_dev);

	/* get a major num from the kernel */
	err = alloc_chrdev_region(&dev_num, KA_MINOR, KA_NR_DEVS,
				     KA_DEV_NAME);
	if (err) {
		trace_printk("[%s]: failed to alloc major number\n", ERROR);
		return err;
	}

	/* map volume containing kernel array */
	volume_virt_addr = memremap((resource_size_t)volume_phys_addr,
				    volume_size_bytes, MEMREMAP_WT);
	if (!volume_virt_addr) {
		trace_printk("[%s]: failed to map hotplugged memory\n", ERROR);
		err = -ENXIO;
		goto fail;
	}

	kd->volume_virt_addr = volume_virt_addr;

	err = cdev_add(char_dev, dev_num, KA_NR_DEVS);
	if (err) {
		trace_printk("[%s]: errno = %d adding char device\n", ERROR,
			     err);
		goto fail;
	}

	kd->char_dev_added = true;

	trace_printk("[%s]: device memory mapped from 0x%llx\n", INFO,
		     (unsigned long long)kd->volume_phys_addr);
	trace_printk("[%s]: device memory mapped at 0x%llx\n", INFO,
		     (unsigned long long)kd->volume_virt_addr);
	trace_printk("[%s]: device memory size = %lld bytes\n", INFO,
		     (unsigned long long)kd->volume_size_bytes);
	trace_printk("[%s]: device major num = %d\n", INFO, MAJOR(char_dev->dev));
	trace_printk("[%s]: device minor num = %d\n", INFO, MINOR(char_dev->dev));
	trace_printk("[%s]: num of devices   = %d\n", INFO, char_dev->count);

	return err; /* succeed */

fail:
	ka_exit();
	return err;
}

long ka_ioctl(struct file *filp, unsigned int request, unsigned long arg)
{
	long err = 0;
	trace_printk("[%s]: request = %d\n", INFO, request);
	return err;
}

static void init_cdev(struct cdev *char_dev)
{
	cdev_init(char_dev, &ka_dev_fops);
	char_dev->owner = THIS_MODULE;
}

int ka_open(struct inode *inode, struct file *filp)
{
	trace_printk("[%s]: opened %s\n", INFO, KA_DEV_NAME);
	return 0;
}

ssize_t ka_read(struct file *filp, char __user *buf, size_t buf_sz, loff_t *off)
{
	int ret = 0;
	trace_printk("[%s]: rd_buf_sz = %lu, rd_offset = %lld\n", INFO, buf_sz, *off);
	return ret;
}

int ka_release(struct inode *inode, struct file *filp)
{
	trace_printk("[%s]: closed %s\n", INFO, KA_DEV_NAME);
	return 0;
}

ssize_t ka_write(struct file *filp, const char __user *buf, size_t buf_sz,
		 loff_t *off)
{
	int ret = 0;
	trace_printk("[%s]: wrt_msg = \"%s\", wrt_buf_sz = %lu, wrt_offset = %lld\n", INFO, buf, buf_sz, *off);
	return ret;
}

module_init(ka_init);
module_exit(ka_exit);
