#!/usr/bin/env python3
"""Convert distance matrix to square layout Phylip format.

FastME requires Phylip-formatted distance matrix (square layout) as input,
whereas the stock distance matrices are in Phylip (lower-triangular layout)
format. This script converts the latter into the former.

Usage:
    python me.py input.dm output.sq.phy

"""

from sys import argv

from skbio import DistanceMatrix


infile = argv[1]
outfile = argv[2]


def main():
    DistanceMatrix.read(
        infile, format='phylip_dm', verify=False, layout='lower'
    ).write(
        outfile, format='phylip_dm', layout='square'
    )


if __name__ == '__main__':
    main()
