#!/bin/bash
# Run NJ-R-D algorithm in scikit-bio on GTDB bac120 dataset.

set -e

export OMP_PLACES=cores
export OMP_PROC_BIND=close

infile=bac120_r232.phy.gz
outdir=gtdb

reps=3

timer=$(which time)

mkdir -p $outdir
for rep in $(seq 0 $((reps - 1))); do
  $timer -a -o $outdir/full.tsv -f "nj\t%e\t%M" \
    decenttree -nt 32 -t NJ-R-D -in $infile -out $outdir/nj.$rep.nwk |\
    grep "Computing NJ-R-D tree took" | cut -f5 -d' ' |\
    sed 's/^/nj\t'$rep'\t/' >> $outdir/calc.tsv
done
