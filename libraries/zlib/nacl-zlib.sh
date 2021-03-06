#!/bin/bash
# Copyright (c) 2011 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

source pkg_info
source ../../build_tools/common.sh


CustomConfigureStep() {
  Banner "Configuring ${PACKAGE_NAME}"
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}
  # TODO: side-by-side install
  local CONFIGURE_ARGS="--prefix=${NACLPORTS_PREFIX}"
  local CFLAGS="-Dunlink=puts"
  if [ "${NACL_GLIBC}" = "1" -a $# -gt 0 ]; then
      CONFIGURE_ARGS="${CONFIGURE_ARGS} --shared"
      CFLAGS="${CFLAGS} -fPIC"
  fi
  CC=${NACLCC} AR="${NACLAR} -r" RANLIB=${NACLRANLIB} CFLAGS="${CFLAGS}" \
     LogExecute ./configure ${CONFIGURE_ARGS}
  if [ ${NACL_ARCH} = "pnacl" ]; then
    export MAKEFLAGS="EXE=.pexe"
    EXECUTABLES="minigzip.pexe example.pexe"
  else
    export MAKEFLAGS="EXE=.nexe"
    EXECUTABLES="minigzip.nexe example.nexe"
  fi
}


TestStep() {
  if [ $NACL_ARCH = "arm" ]; then
    # no sel_ldr for arm
    return
  fi

  if [ "${NACL_GLIBC}" = "1" ]; then
    # Tests do not currently run on GLIBC due to fdopen() not working
    # TODO(sbc): Remove this once glibc is fixed:
    # https://code.google.com/p/nativeclient/issues/detail?id=3362
    return
  fi

  if [ $NACL_ARCH = "pnacl" ]; then
    WriteSelLdrScript minigzip minigzip.pexe.x86-64.nexe
    WriteSelLdrScript example example.pexe.x86-64.nexe
  else
    WriteSelLdrScript minigzip minigzip.nexe
    WriteSelLdrScript example example.nexe
  fi
  export LD_LIBRARY_PATH=.
  if echo "hello world" | ./minigzip | ./minigzip -d; then
    echo '  *** minigzip test OK ***' ; \
  else
    echo '  *** minigzip test FAILED ***' ; \
    exit 1
  fi

  # This second test does not yet work on nacl (gzopen fails)
  #if ./example; then \
    #echo '  *** zlib test OK ***'; \
  #else \
    #echo '  *** zlib test FAILED ***'; \
    #exit 1
  #fi
}


CustomPackageInstall() {
  DefaultPreInstallStep
  DefaultDownloadStep
  DefaultExtractStep
  # zlib doesn't need patching, so no patch step
  CustomConfigureStep
  DefaultBuildStep
  DefaultTranslateStep
  DefaultValidateStep
  TestStep
  DefaultInstallStep
  if [ "${NACL_GLIBC}" = "1" ]; then
    CustomConfigureStep shared
    DefaultBuildStep
    Validate libz.so.1
    DefaultValidateStep
    TestStep
    DefaultInstallStep
  fi
  DefaultCleanUpStep
}


CustomPackageInstall
exit 0
