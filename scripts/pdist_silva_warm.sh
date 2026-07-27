#!/bin/bash
# Calculate a p-distance matrix of 1000 sequences for warm-up purpose.

python utils/calc_pdist.py aln/warmup.aln.gz dm/warmup.phy
gzip dm/warmup.phy
