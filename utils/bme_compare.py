#!/usr/bin/env python3
"""Calculate the BME losses of two trees and their Robinson-Foulds distance.

Usage:
    python me.py tree1.nwk tree2.nwk input.dm

"""

from sys import argv
from skbio import TreeNode, DistanceMatrix


def main():
    t1 = TreeNode.read(argv[1])
    t2 = TreeNode.read(argv[2])

    res = []
    dm = DistanceMatrix.read(argv[3])
    for tree in (t1, t2):
        pm = tree.cophenet(use_length=False).filter(dm.ids)
        assert pm.ids == dm.ids
        D = dm.condensed_form()
        P = pm.condensed_form()
        L = (2 ** (1 - P) * D).sum()
        res.append(L)

    rf = t1.compare_rfd(t2)
    res.append(rf)
    print('\t'.join(map(str, res)))


if __name__ == '__main__':
    main()
