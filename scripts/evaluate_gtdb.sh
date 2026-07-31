#!/bin/bash
# Evaluate output trees from the GTDB bac120 dataset.

set -e

refdist=bac120_r232.phy.gz
reftree=bac120_r232.tree.gz
outdir=gtdb

reps=3

mkdir -p $outdir
for key in skbio nj; do
  for rep in $(seq 0 $((reps - 1))); do
    intree=$outdir/$key.$rep.nwk
    python utils/bme_loss.py $intree $refdist |\
      sed 's/^/'$key'\t'$rep'\t/' >> $outdir/loss.tsv
    python utils/calc_nrf.py $intree $reftree |\
      sed 's/^/'$key'\t'$rep'\t/' >> $outdir/nrf.tsv
  done
done
