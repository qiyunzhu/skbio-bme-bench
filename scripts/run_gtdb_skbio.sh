#!/bin/bash
# Run parallel BME algorithm in scikit-bio on GTDB bac120 dataset.

set -e

export OMP_NUM_THREADS=32
export OMP_PLACES=cores
export OMP_PROC_BIND=close

infile=bac120_r232.phy.gz
outdir=gtdb

reps=3

timer=$(which time)

mkdir -p $outdir
for rep in $(seq 0 $((reps - 1))); do
  $timer -a -o $outdir/full.tsv -f "skbio\t%e\t%M" \
    python scripts/run_skbio.py $infile $outdir/skbio.$rep.nwk |\
    sed 's/^/skbio\t'$rep'\t/' >> $outdir/calc.tsv
done
