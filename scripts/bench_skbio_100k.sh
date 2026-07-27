#!/bin/bash
# Benchmark parallel BME algorithm in scikit-bio on 100k taxa.

set -e

export OMP_PLACES=cores
export OMP_PROC_BIND=close

indir=dm  # adjust as needed
outdir=skbio

sample=100000
seeds=(0 1 2 3 4)
threads=(1 2 3 4 6 8 12 16 24 32)
reps=5

timer=$(which time)

mkdir -p $outdir
for seed in ${seeds[@]}; do
  infile=$indir/$sample.$seed.bin
  for rep in $(seq 0 $((reps - 1))); do
    $timer -a -o $outdir/read.tsv -f "$sample\t$seed\t$rep\t%e\t%M" \
      numactl -N 0 -m 0 python scripts/bench_skbio_read.py $infile > /dev/null
  done
  for thread in ${threads[@]}; do
    for rep in $(seq 0 $((reps - 1))); do
      $timer -a -o $outdir/full.tsv -f "$sample\t$seed\t$thread\t$rep\t%e\t%M" \
        numactl -N 0 -m 0 python scripts/bench_skbio.py $infile $thread >> $outdir/calc.tsv
    done
    mv $sample.$seed.$thread.nwk $outdir/
  done
done
