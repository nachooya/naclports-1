#!/usr/bin/env python
# Copyright (c) 2011 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Script to synchronise the naclports mirror of upstream archives.

This script verifies that the URL for every package is mirrored on
commondatastorage.  If it finds missing URLs it downloads them to the local
machine and then pushes them up using gsutil.

gsutil is required the run this script and if any mirroring operations are
required then the correct gsutil credentials will be required.
"""

import optparse
import os
import shlex
import subprocess
import sys
import urllib
import urlparse

import naclports

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MIRROR_GS = 'gs://nativeclient-mirror/nacl'


def main(args):
  parser = optparse.OptionParser()
  parser.add_option('-n', '--dry-run', action='store_true',
                    help="Don't actually upload anything")
  options, _ = parser.parse_args(args)

  ports_root = os.path.dirname(SCRIPT_DIR)
  listing = subprocess.check_output(['gsutil', 'ls', MIRROR_GS])
  listing = listing.splitlines()
  listing = [os.path.basename(l) for l in listing]

  def CheckMirror(package):
    basename = package.GetArchiveFilename()
    if basename in listing:
      # already mirrored
      return

    # Download upstream URL
    print 'Downloading: %s' % package.URL
    remote = urllib.urlopen(package.URL)
    with open(basename, 'w') as tmp:
      tmp.write(remote.read())

    # Upload to gs
    url = '%s/%s' % (MIRROR_GS, basename)
    print "Uploading to mirror: %s" % url
    cmd = ['gsutil', 'cp', '-a', 'public-read', basename, url]
    if options.dry_run:
      print cmd
    else:
      subprocess.check_call(cmd)

  for package in naclports.PackageIterator():
    CheckMirror(package)

  return 0

if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
