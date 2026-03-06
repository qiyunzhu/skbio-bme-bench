#!/bin/bash
# Benchmark BME algorithm in FastME on the 50k taxa datasets.
# Note: Due to the long runtime, the 50k taxa datasets were tested 3 times each
# instead of 5 as with other datasets.

set -e

indir=dm
outdir=fastme

sample=50000
seeds=(0 1 2 3 4)
reps=3

timer=$(which time)
fastme=fastme-2.1.6.4/src/fastme
$fastme -V

# warmup run
python utils/phylip_sq.py $indir/warmup.phy.gz warmup.phy
$fastme -T 4 -i warmup.phy -m B -w B -o warmup.nwk > /dev/null
rm warmup.phy warmup.nwk warmup.phy_fastme_stat.txt

# benchmark runs
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
rm input.phy_fastme_stat.txt
