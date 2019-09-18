/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Copyright 2019 Sanketh Nalli
 */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "kactl.h"

#define KARRAY "/dev/"KA_DEV_NAME

int main(int argc, char **argv)
{
	printf("\n");
	printf("%s:%s()\n", argv[0], __func__);
	printf("\n");

	int err;

	/* open karray */
	printf("open(%s) = ", KARRAY);
	int fd = open(KARRAY, O_RDWR);
	if (fd < 0) {
		printf("failed to open %s\n", KARRAY);
		err = fd;
		goto open_fail;
	}
	printf("%d\n", fd);

	/* ioctl karray */
	unsigned int request = 42;
	printf("ioctl(fd = %d, request = %d) = ", fd, request);
	err = ioctl(fd, request);
	if (err) {
		printf("failed to ioctl %s\n", KARRAY);
		goto exit;
	}
	printf("%d\n", err);

	/* read from karray */
	char rd_buf[32];
	int rd_count = sizeof(rd_buf);
	int rd_offset = 43;
	printf("pread(fd = %d, buf = [], count = %d, offset = %d) = ", fd, rd_count, rd_offset);
	err = pread(fd, rd_buf, rd_count, rd_offset);
	if (err) {
		printf("failed to read. err = %d\n", err);
		goto exit;
	}
	printf("%d\n", err);

	/* write to karray */
	const char wrt_buf[] = "this is a test message";
	int wrt_count = strlen(wrt_buf) + 1;
	int wrt_offset = 44;
	printf("pwrite(fd = %d, buf = \"%s\", count = %d, offset = %d) = ", fd, wrt_buf, wrt_count, wrt_offset);
	err = pwrite(fd, wrt_buf, wrt_count, wrt_offset);
	if (err) {
		printf("failed to write. err = %d\n", err);
		goto exit;
	}
	printf("%d\n", err);

exit:
	/* close karray */
	printf("close(fd = %d) = ", fd);
	err = close(fd);
	printf("%d\n", err);

open_fail:
	printf("\n");
	return err;
}
