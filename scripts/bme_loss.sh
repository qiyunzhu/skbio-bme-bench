#!/bin/bash
# Calculate BME loss function of trees.

set -e

dmdir=dm

samples=(10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 100000 200000)
seeds=(0 1 2 3 4)

for sample in ${samples[@]}; do
  for seed in ${seeds[@]}; do
    dmfile=$dmdir/$sample.$seed.phy.gz
    treefile=fastme/$sample.$seed.nwk
    if [ -f "$treefile" ]; then
      res=$(python utils/bme_loss.py $treefile $dmfile)
      echo $sample$'\t'$seed$'\t'$res >> fastme.loss
    fi
    treefile=skbio/$sample.$seed.1.nwk
    if [ -f "$treefile" ]; then
      res=$(python utils/bme_loss.py $treefile $dmfile)
      echo $sample$'\t'$seed$'\t'$res >> skbio.loss
    fi
    treefile=nj/$sample.$seed.1.nwk
    if [ -f "$treefile" ]; then
      res=$(python utils/bme_loss.py $treefile $dmfile)
      echo $sample$'\t'$seed$'\t'$res >> nj.loss
    fi
  done
done
