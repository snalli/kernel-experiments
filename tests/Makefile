# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2019 Sanketh Nalli

# the compiler: gcc for C program, define as g++ for C++
CC = $(CROSS_COMPILE)gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
#  -static make a statically-linked binary
CFLAGS  = -g -Wall -static
INCLUDE = -I$(X86_64_LOCAL_INSTALL_ROOT)/usr/include \
	  -I$(X86_64_LOCAL_INSTALL_ROOT)/usr/local/include \
	  -L$(X86_64_LOCAL_INSTALL_ROOT)/usr/lib64 \
	  -B$(X86_64_LOCAL_INSTALL_ROOT)/usr/lib64

# the build target executable:
TARGET = karray_test

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(INCLUDE) $(CFLAGS) -o $(TARGET) $(TARGET).c

clean:
	$(RM) $(TEST)
