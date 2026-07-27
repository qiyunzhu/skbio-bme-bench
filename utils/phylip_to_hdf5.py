#!/usr/bin/env python3
"""Convert a Phylip-formatted distance matrix into binary (HDF5) format.

Usage:
    python me.py input.phy output.h5

"""

from sys import argv
from skbio import DistanceMatrix


def main():
    dm = DistanceMatrix.read(
        argv[1], format='phylip_dm', verify=False, layout='lower', strict=False
    )
    dm.write(argv[2], format='binary_dm')


if __name__ == '__main__':
    main()
