# Copyright (c) 2011 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Makefile for the Photo example.

.PHONY: all carpe clean

NACLPORTS_ROOT = ../../..
INSTALL_DIR ?= $$HOME/Sites/photo

# $(OBJDIR) is an optional variable in nacl_build.mk, it is the directory
# that holds all the .o's.  Note that a rule to create this dir is built into
# common_build_scripts/nacl_build.mk
OBJDIR = obj

HFILES = callback.h \
         fastmath.h \
         geturl_handler.h \
         photo.h \
         scripting_bridge.h \
         surface.h

CCFILES = geturl_handler.cc \
          loader.cc \
          photo.cc \
          scripting_bridge.cc \
          surface.cc
CARPE_FILES = default.css slider.js

OBJECTS_X86_32 = $(patsubst %,${OBJDIR}/%,$(CFILES:%.c=%_x86_32.o))
OBJECTS_X86_32 += $(patsubst %,${OBJDIR}/%,$(CCFILES:%.cc=%_x86_32.o))
OBJECTS_X86_64 = $(patsubst %,${OBJDIR}/%,$(CFILES:%.c=%_x86_64.o))
OBJECTS_X86_64 += $(patsubst %,${OBJDIR}/%,$(CCFILES:%.cc=%_x86_64.o))

CFLAGS = -flax-vector-conversions -Wall -Wno-long-long -pthread -Werror
INCLUDES = -I$(NACL_SDK_ROOT)/include -I$(NACLPORTS_ROOT)

# PLEASE NOTE: If you are using a NaCl SDK version 0.1 you must use
# -lgoogle_nacl_platform instead of -lplatform
LDFLAGS = -lppruntime \
          -lppapi_cpp \
          -lplatform \
          -lgio \
          -lpthread \
          -ljpeg \
          -lsrpc \
          $(ARCH_FLAGS)

OPT_FLAGS = -O3 \
            -mfpmath=sse \
            -msse3 \
            -funroll-loops \
            -fomit-frame-pointer

PHOTO_MODULES = photo_x86_32.nexe photo_x86_64.nexe

APPLICATION_FILES = $(CARPE_FILES) \
                    photo.html \
                    photo.nmf \
                    spear.jpg \
                    sunspots.jpg \
                    $(PHOTO_MODULES)

all: all_photo

# nacl_build.mk has rules to build .o files from .cc files.
-include $(NACLPORTS_ROOT)/common_build_scripts/nacl_build.mk

LIB_JPEG_32 = $(NACL_SDK_ROOT)/$(NACL_TOOLCHAIN_DIR)/i686-nacl/usr/lib/libjpeg.a
LIB_JPEG_64 = $(NACL_SDK_ROOT)/$(NACL_TOOLCHAIN_DIR)/x86_64-nacl/usr/lib/libjpeg.a
BOOST_SMART_PTR_32 = \
  $(NACL_SDK_ROOT)/$(NACL_TOOLCHAIN_DIR)/i686-nacl/usr/include/boost/scoped_ptr.hpp
BOOST_SMART_PTR_64 = \
  $(NACL_SDK_ROOT)/$(NACL_TOOLCHAIN_DIR)/x86_64-nacl/usr/include/boost/scoped_ptr.hpp

PACKAGES = $(LIB_JPEG_32) \
           $(LIB_JPEG_64) \
           $(BOOST_SMART_PTR_32) \
           $(BOOST_SMART_PTR_64) \
           $(CARPE_FILES)

all_photo: check_variables $(PACKAGES) $(OBJDIR) $(PHOTO_MODULES)

$(OBJECTS_X86_32) $(OBJECTS_X86_64):: $(HFILES)

photo_x86_32.nexe: $(OBJECTS_X86_32)
	$(CPP) -m32 $^ $(LDFLAGS) -o $@
	$(NACL_STRIP) $@ -o $@

photo_x86_64.nexe: $(OBJECTS_X86_64)
	$(CPP) -m64 $^ $(LDFLAGS) -o $@
	$(NACL_STRIP) $@ -o $@

install: $(APPLICATION_FILES) $(INSTALL_DIR)
	install $(APPLICATION_FILES) $(INSTALL_DIR)

$(INSTALL_DIR):
	mkdir -p $@

clean:
	-rm -rf $(OBJDIR) $(PHOTO_MODULES)

# Build the required packages.
$(LIB_JPEG_32):
	(cd $(NACLPORTS_ROOT)/libraries/jpeg; \
	export NACL_ARCH=i686; \
	./nacl-jpeg.sh)

$(LIB_JPEG_64):
	(cd $(NACLPORTS_ROOT)/libraries/jpeg; \
	export NACL_ARCH=x86_64; \
	./nacl-jpeg.sh)

$(BOOST_SMART_PTR_32):
	(cd $(NACLPORTS_ROOT)/libraries/boost; \
	export NACL_ARCH=i686; \
	./nacl-boost.sh)

$(BOOST_SMART_PTR_64):
	(cd $(NACLPORTS_ROOT)/libraries/boost; \
	export NACL_ARCH=x86_64; \
	./nacl-boost.sh)

# Download and patch the Carpe sliders.
$(CARPE_FILES):
	/bin/bash photo_tool.sh
