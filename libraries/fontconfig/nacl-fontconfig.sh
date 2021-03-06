#!/bin/bash
# Copyright (c) 2011 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# nacl-fontconfig-2.7.3.sh
#
# usage:  nacl-fontconfig-2.7.3.sh
#
# this script downloads, patches, and builds fontconfig for Native Client.
#

source pkg_info
source ../../build_tools/common.sh

MAKEFILE_PATCH_FILE=nacl-fontconfig.Makefile.patch

# fontconfig with-arch to be set for cross compiling
export with_arch=i686


CustomPatchStep() {
  ############################################################################
  # Recreation of configure/Makefile.in/config.sub/etc.
  # Will ask for autotools.
  ############################################################################
  # ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}
  # ./autogen.sh --without-subdirs
  # make distclean
  ############################################################################
  # apply a small patch to generated config.sub to add nacl host type
  DefaultPatchStep
  chmod a+x ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}/{pseudo-gcc,configure,ltmain.sh}
}


CustomConfigureStep() {
  Banner "Configuring ${PACKAGE_NAME}"
  # export the nacl tools
  export CC=${NACLCC}
  export CXX=${NACLCXX}
  export AR=${NACLAR}
  export RANLIB=${NACLRANLIB}
  export PKG_CONFIG_PATH=${NACLPORTS_LIBDIR}/pkgconfig
  export PKG_CONFIG_LIBDIR=${NACLPORTS_LIBDIR}
  export PATH=${NACL_BIN_PATH}:${NACLPORTS_PREFIX}/bin:${PATH};
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}
  chmod a+x install-sh
  cd ${PACKAGE_NAME}-build
  # We'll not build host anyway
  CC_FOR_BUILD=${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}/pseudo-gcc \
  ../configure \
    --host=nacl \
    --disable-docs \
    --prefix=${NACLPORTS_PREFIX} \
    --exec-prefix=${NACLPORTS_PREFIX} \
    --libdir=${NACLPORTS_LIBDIR} \
    --oldincludedir=${NACLPORTS_INCLUDE} \
    --with-http=off \
    --with-html=off \
    --with-ftp=off \
    --with-x=no \
    --with-arch=x86
}


CustomPatchMakefileStep() {
  # fontconfig wants to build executable tools.  These tools aren't needed
  # for Native Client.  This function will patch the generated Makefile
  # to remove them.  (Use fontconfig tools on your build machine instead.)
  echo "CustomPatchMakefileStep"
  Patch ${PACKAGE_NAME} ${MAKEFILE_PATCH_FILE}
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}/${PACKAGE_NAME}-build
}


CustomPackageInstall() {
  DefaultPreInstallStep
  DefaultDownloadStep
  DefaultExtractStep
  CustomPatchStep
  CustomConfigureStep
  CustomPatchMakefileStep
  DefaultBuildStep
  DefaultInstallStep
  DefaultCleanUpStep
}


CustomPackageInstall
exit 0
