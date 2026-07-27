#!/usr/bin/env python3
"""Benchmark distance matrix reading in scikit-bio.

Usage:
    python me.py input.phy

"""

from sys import argv
from skbio import DistanceMatrix


infile = argv[1]


def main():
    if infile.endswith('.bin'):
        dm = DistanceMatrix.read(infile, format='binary_dm', verify=False)
    else:
        dm = DistanceMatrix.read(infile, format='phylip_dm')


if __name__ == '__main__':
    main()
