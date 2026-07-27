#!/usr/bin/env python3
"""Calculate the loss function under the balanced minimum evolution criterion.

Usage:
    python me.py input.nwk input.dm

Notes:
    Given a tree topology T and a distance matrix D, the balanced minimum
    evolution (BME) criterion aims to minimize the following function L:

        L(T) = \\sum_{i \\lt j} 2^{1-p_{i,j}(T)} d_{i,j}

    In which i and j denote each pair of taxa. d(i,j) is the distance between
    them according to D, and p(i,j) is the number of branches connecting them
    according to T.

"""

from sys import argv
from skbio import TreeNode, DistanceMatrix


def main():
    tree = TreeNode.read(argv[1])
    dm = DistanceMatrix.read(argv[2])
    pm = tree.cophenet(use_length=False).filter(dm.ids)
    assert pm.ids == dm.ids
    D = dm.condensed_form()
    P = pm.condensed_form()
    L = (2 ** (1 - P) * D).sum()
    print(L)


if __name__ == '__main__':
    main()
