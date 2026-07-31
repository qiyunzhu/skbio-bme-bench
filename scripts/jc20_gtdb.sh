#!/bin/bash
# Calculate a JC-like distance matrix of GTDB bac120 sequences.

decenttree -nt 16 -fasta release232/msa/gtdb_r232_bac120.faa -dist-out bac120_r232.phy \
  -out-format lower -no-out -no-matrix -t NONE -alphabet ACDEFGHIKLMNPQRSTVWY -unknown '-X' -not-dna
gzip bac120_r232.phy
