#!/bin/bash
# Copyright (c) 2011 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#

# nacl-FreeImage-3.14.1.sh
#
# usage:  nacl-FreeImage-3.14.1.sh
#
# This script downloads, patches, and builds FreeImage for Native Client
# See http://freeimage.sourceforge.net/ for more details.
#

# This list of files needs to have CRLF (Windows)-style line endings translated
# to LF (*nix)-style line endings prior to applying the patch.  This list of
# files is taken from nacl-FreeImage-3.14.1.patch.
readonly -a CRLF_TRANSLATE_FILES=(
    "Makefile"
    "Source/LibOpenJPEG/opj_includes.h"
    "Source/LibRawLite/dcraw/dcraw.c"
    "Source/LibRawLite/internal/defines.h"
    "Source/LibRawLite/libraw/libraw.h"
    "Source/LibRawLite/src/libraw_cxx.cpp"
    "Source/OpenEXR/Imath/ImathMatrix.h"
    "Source/Utilities.h")

source pkg_info

# The FreeImage zipfile, unlike other naclports contains a folder
# called FreeImage rather than FreeImage-X-Y-Z, so we set a customr
# PACKAGE_DIR here.
PACKAGE_DIR=FreeImage

source ../../build_tools/common.sh

CustomDownloadStep() {
  cd ${NACL_PACKAGES_TARBALLS}
  # If matching tarball already exists, don't download again
  if ! Check ; then
    Fetch ${URL} ${PACKAGE_NAME}.zip
    if ! Check ; then
       Banner "${PACKAGE_NAME} failed checksum!"
       exit -1
    fi
  fi
}

CustomExtractStep() {
  Banner "Unzipping ${PACKAGE_NAME}"
  ChangeDir ${NACL_PACKAGES_REPOSITORY}
  Remove ${PACKAGE_DIR}
  unzip ${NACL_PACKAGES_TARBALLS}/${PACKAGE_NAME}.zip
  # FreeImage uses CRLF for line-endings.  The patch file has LF (Unix-style)
  # line endings, which means on some versions of patch, the patch fails. Run a
  # recursive tr over all the sources to remedy this.
  # Setting LC_CTYPE is a Mac thing.  The locale needs to be set to "C" so that
  # tr interprets the '\r' string as ASCII and not UTF-8.
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_DIR}
  export
  for crlf in ${CRLF_TRANSLATE_FILES[@]}; do
    echo "tr -d '\r' < ${crlf}"
    LC_CTYPE=C tr -d '\r' < ${crlf} > .tmp
    mv .tmp ${crlf}
  done
}

CustomConfigureStep() {
  Banner "Configuring ${PACKAGE_NAME}"
  # export the nacl tools
  export CC=${NACLCC}
  export CXX=${NACLCXX}
  export AR=${NACLAR}
  export RANLIB=${NACLRANLIB}
  export PATH=${NACL_BIN_PATH}:${PATH};
  export INCDIR=${NACLPORTS_INCLUDE}
  export INSTALLDIR=${NACLPORTS_LIBDIR}
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_DIR}
}

CustomBuildStep() {
  # assumes pwd has makefile
  LogExecute make OS=nacl clean
  LogExecute make OS=nacl -j${OS_JOBS}
}

CustomInstallStep() {
  # assumes pwd has makefile
  make OS=nacl install
  DefaultTouchStep
}

CustomPackageInstall() {
   DefaultPreInstallStep
   CustomDownloadStep
   CustomExtractStep
   DefaultPatchStep
   CustomConfigureStep
   CustomBuildStep
   CustomInstallStep
   DefaultCleanUpStep
}

CustomPackageInstall
exit 0
