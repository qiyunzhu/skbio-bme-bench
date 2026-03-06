#!/usr/bin/env python3
"""Calculate pairwise p-distances within a multiple sequence alignment.

This script uses a parallel Cython program instead of scikit-bio's built-in
NumPy code to accelerate calculation for extremely large datasets.

Usage:
    python me.py input.fasta output.phy

"""

from sys import argv

import numpy as np

from skbio.sequence import DNA
from skbio.alignment import TabularMSA
from skbio.sequence.distance import _char_hash
from _pdist import _pdist_all


infile = argv[1]
outfile = argv[2]


def main():
    msa = TabularMSA.read(infile, constructor=DNA)
    ids = msa.index.tolist()
    seqs = np.vstack([seq._bytes for seq in msa])
    mask = _char_hash('canonical', DNA)[seqs]
    n = seqs.shape[0]

    dm = _pdist_all(seqs, mask)

    with open(outfile, 'w') as fh:
        print(n, file=fh)
        print(ids[0], file=fh)
        for i in range(1, n):
            print(ids[i], *dm[i, :i], sep='\t', file=fh)


if __name__ == '__main__':
    main()
