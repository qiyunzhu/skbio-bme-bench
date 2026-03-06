#!/bin/bash
# Download, patch and compile FastME for benchmarking purpose.

# FastME 2.1.6.3 is the latest release available on Bioconda.
# FastMe 2.1.6.4 (released on 9/15/2022) is available for download from GitLab:
wget -O fastme-2.1.6.4.tar.gz https://gite.lirmm.fr/atgc/FastME/-/raw/master/tarball/fastme-2.1.6.4.tar.gz?ref=08e21504
tar xf fastme-2.1.6.4.tar.gz

# Patch the source code to achieve two objectives:
# 1. The elapsed time of the tree computing algorithm will be recorded. This
#    excludes distance matrix reading, tree writing, and other overheads.
# 2. When `-c` is specified, FastME will exit immediately after reading the
#    distance matrix. This helps to assess the time and memory required for
#    distance matrix alone.
patch fastme-2.1.6.4/src/fastme.c < utils/fastme.c.patch

# Compile the patched source code.
cd fastme-2.1.6.4
./configure
make
cd ..

# Test if FastME runs.
fastme-2.1.6.4/src/fastme --version
