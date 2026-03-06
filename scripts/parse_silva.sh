#!/bin/bash
# Pase SILVA sequences.
# This command will strip taxonomy, linearize sequences, replace "U" with "T", and
# replace "." with "-".

zcat SILVA_138.2_SSURef_NR99_tax_silva_full_align_trunc.fasta.gz | cut -f1 -d' ' |\
  awk '/^>/ {print (NR==1 ? "" : "\n") $0; next} {printf "%s", $0} END {print ""}' |\
  sed '/^[^>]/s/U/T/g' | sed '/^[^>]/s/\./-/g' > silva.aln
