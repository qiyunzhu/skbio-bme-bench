#!/usr/bin/env python3
"""Run the BME algorithm in scikit-bio on a distance matrix.

Usage:
    python me.py input.phy output.nwk

"""

from sys import argv
from skbio import DistanceMatrix
from skbio.tree import bme


def main():
    dm = DistanceMatrix.read(argv[1], format='phylip_dm', dtype='float64')
    tree = bme(dm, neg_as_zero=False, parallel=True)
    tree.write(argv[2])


if __name__ == '__main__':
    main()
