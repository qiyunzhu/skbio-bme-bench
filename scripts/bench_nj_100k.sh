#!/bin/bash
# Benchmark NJ-R-D algorithm in DecentTree on 100k taxa.

set -e

export OMP_PLACES=cores
export OMP_PROC_BIND=close

algorithm=NJ-R-D

indir=dm  # adjust as needed
outdir=nj

samples=(100000)
seeds=(0 1 2 3 4)
threads=(1 8 32)
reps=1

timer=$(which time)

# warmup run
decenttree -nt 4 -t NJ-R-D -in $indir/warmup.phy.gz -out warmup.nwk > dt.info
rm warmup.nwk

mkdir -p $outdir
for sample in ${samples[@]}; do
  for seed in ${seeds[@]}; do
    infile=$indir/$sample.$seed.phy.gz
    for thread in ${threads[@]}; do
      for rep in $(seq 0 $((reps - 1))); do
        prefix="$sample\t$seed\t$thread\t$rep"
        $timer -a -o $outdir/full.tsv -f "$prefix\t%e\t%M" \
          numactl -N 0 -m 0 decenttree -nt $thread -t $algorithm \
          -in $infile -out $sample.$seed.$thread.nwk |\
          grep "Computing $algorithm tree took" | cut -f5 -d' ' |\
          sed "s/^/$prefix\t/" >> $outdir/calc.tsv
      done
      mv $sample.$seed.$thread.nwk $outdir/
    done
  done
done
