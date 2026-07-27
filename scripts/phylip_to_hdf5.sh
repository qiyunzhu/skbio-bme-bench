#!/bin/bash
# Convert Phylip-formatted distance matrices into binary (HDF5) format for samples with
# 100k or more taxa for faster loading.
# Note that the HDF5 files are larger than the gzipped Phylip files, so you may delete
# them after the analysis to save space.

n=200000
s=0
python utils/phylip_to_hdf5.py dm/$n.$s.phy.gz dm/$n.$s.bin

n=100000
for s in 0 1 2 3 4; do
  python utils/phylip_to_hdf5.py dm/$n.$s.phy.gz dm/$n.$s.bin
done
