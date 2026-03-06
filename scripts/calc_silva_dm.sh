#!/bin/bash
# Calculate p-distance matrices of subsampled alignments from SILVA.

for n in 10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 100000; do
  for s in 0 1 2 3 4; do
    python utils/calc_pdist.py aln/$n.$s.aln.gz dm/$n.$s.phy
    gzip dm/$n.$s.phy
  done
done
