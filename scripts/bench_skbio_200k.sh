#!/bin/bash
# Benchmark parallel BME algorithm in scikit-bio on 200k taxa.

# Note: NUMA pinning is not used here because 200k taxa analysis consumes more
# memory than is available on a single socket.

set -e

export OMP_PLACES=cores
export OMP_PROC_BIND=close

indir=dm  # adjust as needed
outdir=skbio

sample=200000
seed=0
threads=(1 8 32)
reps=1

timer=$(which time)

mkdir -p $outdir
infile=$indir/$sample.$seed.bin

for rep in $(seq 0 $((reps - 1))); do
  $timer -a -o $outdir/read.tsv -f "$sample\t$seed\t$rep\t%e\t%M" \
    python scripts/bench_skbio_read.py $infile > /dev/null
done
for thread in ${threads[@]}; do
  for rep in $(seq 0 $((reps - 1))); do
    $timer -a -o $outdir/full.tsv -f "$sample\t$seed\t$thread\t$rep\t%e\t%M" \
      python scripts/bench_skbio.py $infile $thread >> $outdir/calc.tsv
  done
  mv $sample.$seed.$thread.nwk $outdir/
done
