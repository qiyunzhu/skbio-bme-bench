#!/bin/bash
# Benchmark BME algorithm in FastME.

set -e

indir=dm
outdir=fastme

samples=(10 20 50 100 200 500 1000 2000 5000 10000 20000)
seeds=(0 1 2 3 4)
reps=5

timer=$(which time)
fastme=fastme-2.1.6.4/src/fastme
$fastme -V

# Note: FastME can parallelize but its BME algorithm doesn't. `-T 4` is set as
# a placeholder here.

# warmup run
python utils/phylip_sq.py $indir/warmup.phy.gz warmup.phy
$fastme -T 4 -i warmup.phy -m B -w B -o warmup.nwk > /dev/null
rm warmup.phy warmup.nwk warmup.phy_fastme_stat.txt

# benchmark runs
mkdir -p $outdir
for sample in ${samples[@]}; do
  for seed in ${seeds[@]}; do
    python utils/phylip_sq.py $indir/$sample.$seed.phy.gz input.phy
    for rep in $(seq 0 $((reps - 1))); do
      prefix="$sample\t$seed\t$rep"
      $timer -a -o $outdir/read.tsv -f "$prefix\t%e\t%M" \
        $fastme -T 4 -i input.phy -c > /dev/null
      $timer -a -o $outdir/full.tsv -f "$prefix\t%e\t%M" \
        $fastme -T 4 -i input.phy -m B -w B -o output.nwk |\
        grep ^Elapsed | cut -f2 | sed "s/^/$prefix\t/" >> $outdir/calc.tsv
    done
    rm input.phy
    mv output.nwk $outdir/$sample.$seed.nwk
  done
done
rm input.phy_fastme_stat.txt
