#!/bin/bash
# Benchmark parallel BME algorithm in scikit-bio.

set -e

# Bind threads to specific physical cores.
export OMP_PLACES=cores

# Bind worker threads to cores physically close to the parent thread.
export OMP_PROC_BIND=close

# Note: Command `numactl -N 0 -m 0` pins the program to the CPU cores and
# memory of the first socket in a multi-socket system. It is not necessary
# for single-socket systems.

indir=dm  # adjust as needed
outdir=skbio

samples=(10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 100000)
seeds=(0 1 2 3 4)
threads=(1 2 3 4 6 8 12 16 24 32)
reps=5

timer=$(which time)

mkdir -p $outdir
for sample in ${samples[@]}; do
  for seed in ${seeds[@]}; do
    infile=$indir/$sample.$seed.phy.gz

    # reading only
    for rep in $(seq 0 $((reps - 1))); do
      $timer -a -o $outdir/read.tsv -f "$sample\t$seed\t$rep\t%e\t%M" \
        numactl -N 0 -m 0 python scripts/bench_skbio_read.py $infile > /dev/null
    done

    # tree-building
    for thread in ${threads[@]}; do
      for rep in $(seq 0 $((reps - 1))); do
        $timer -a -o $outdir/full.tsv -f "$sample\t$seed\t$thread\t$rep\t%e\t%M" \
          numactl -N 0 -m 0 python scripts/bench_skbio.py $infile $thread >> $outdir/calc.tsv
      done
      mv $sample.$seed.$thread.nwk $outdir/
    done

  done
done
