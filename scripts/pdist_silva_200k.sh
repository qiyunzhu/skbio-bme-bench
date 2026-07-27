#!/bin/bash
# Calculate a p-distance matrix of 200,000 sequences subsampled from SILVA.

n=200000
s=0
python utils/calc_pdist_cy/calc.py aln/$n.$s.aln.gz dm/$n.$s.phy
gzip dm/$n.$s.phy
