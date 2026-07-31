#!/usr/bin/env python3
"""Calculate normalized Robinson-Foulds distance between two trees.

Usage:
    python me.py tree1.nwk tree2.nwk

"""

from sys import argv
from skbio import TreeNode


def main():
    t1 = TreeNode.read(argv[1])
    t2 = TreeNode.read(argv[2])
    nrf = t1.compare_rfd(t2, proportion=True, rooted=False)
    print(nrf)


if __name__ == '__main__':
    main()
