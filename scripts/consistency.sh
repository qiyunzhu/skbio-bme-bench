#!/bin/bash
# Test the consistency between scikit-bio and FastME outputs.

taxa=$1
reps=$2

fastme=fastme-2.1.6.4/src/fastme

outfile=${taxa%000}k.tsv

for s in $(seq 0 $((reps - 1))); do
  # sample sequences
  seqtk sample -s$s silva.aln $taxa > $s.aln

  # calculate distance matrix
  python utils/calc_pdist.py $s.aln $s.phy

  # scikit-bio
  # Note: branch lengths
  python utils/run_skbio.py $s.phy $s.skbio.nwk

  # FastME
  python utils/phylip_sq.py $s.phy input.phy
  $fastme -T 4 -i input.phy -m B -w B -o $s.fastme.nwk
  rm input.phy
  rm input.phy_fastme_stat.txt

  # Compare
  python utils/bme_compare.py $s.skbio.nwk $s.fastme.nwk $s.phy >> $outfile

  rm $s.phy $s.aln $s.skbio.nwk $s.fastme.nwk
done
