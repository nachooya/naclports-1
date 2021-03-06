# Copyright (c) 2011 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Makefile for the MesaGL example.

NACLPORTS_ROOT ?= ../../..

CFLAGS = -Wall -Wno-long-long -pthread -DXP_UNIX -Werror -DGL_GLEXT_PROTOTYPES
INCLUDES = -I$(NACL_SDK_ROOT)/include -I$(NACLPORTS_ROOT)
# Note that the OpenGL libraries are NOT included.  We use Mesa for rendering.
LDFLAGS = -lppruntime \
          -lppapi_cpp \
          -lplatform \
          -lgio \
          -lpthread \
          -lsrpc \
          -lOSMesa
OPT_FLAGS = -O2

# Define this target first so that any targets in nacl_build.mk do not become
# the default.
all: all_mesagl

# nacl_build.mk has rules to build .o files from .cc files.
-include $(NACLPORTS_ROOT)/common_build_scripts/nacl_build.mk

LIBMESA = $(NACL_SDK_ROOT)/$(NACL_TOOLCHAIN_DIR)/$(NACL_ARCH)-nacl/usr/lib/libOSMesa.a

# The check_variables target is in nacl_build.mk.
all_mesagl: check_variables $(LIBMESA) mesagl_x86_32.nexe mesagl_x86_64.nexe

mesagl_x86_32.nexe: mesagl.cc
	$(CPP) $(CFLAGS) -m32 $(INCLUDES) $(OPT_FLAGS) $< $(LDFLAGS) -o $@

mesagl_x86_64.nexe: mesagl.cc
	$(CPP) $(CFLAGS) -m64 $(INCLUDES) $(OPT_FLAGS) $< $(LDFLAGS) -o $@

$(LIBMESA):
	(cd $(NACLPORTS_ROOT)/libraries/Mesa; ./nacl-Mesa.sh)

clean:
	-rm mesagl_x86_32.nexe mesagl_x86_64.nexe
