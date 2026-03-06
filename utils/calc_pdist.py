#!/usr/bin/env python3
"""Calculate pairwise p-distances within a multiple sequence alignment.

Usage:
    python me.py input.fasta output.phy

Notes:
    Input is a multiple sequence alignment in FASTA format.
    Output is a distance matrix in Phylip format with lower triangular layout.

"""

from sys import argv

import numpy as np

from skbio.sequence import DNA
from skbio.alignment import TabularMSA, align_dists
from skbio.stats.distance import DistanceMatrix


infile = argv[1]
outfile = argv[2]
metric = 'pdist'


def main():
    aln = TabularMSA.read(infile, format='fasta', constructor=DNA)
    dm = align_dists(aln, metric, shared_by_all=False)
    data = dm.data.round(5).astype('float32')
    np.nan_to_num(data, copy=False, nan=1.0)
    dm = DistanceMatrix(data, dm.ids, validate=False)
    dm.write(outfile, format='phylip_dm', layout='lower')


if __name__ == '__main__':
    main()
