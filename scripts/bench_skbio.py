#!/usr/bin/env python3
"""Benchmark parallel BME algorithm in scikit-bio.

Usage:
    python me.py input.phy threads

"""

from sys import argv
from time import perf_counter
from os.path import dirname, basename
from threadpoolctl import threadpool_limits
from skbio import DistanceMatrix
from skbio.tree import bme


infile = argv[1]
thread = int(argv[2])


def main():
    indir = dirname(infile)
    fname = basename(infile)
    sample, seed, *_ = fname.split('.')
    if fname.endswith('.bin'):
        kwargs = dict(format='binary_dm', verify=False)
    else:
        kwargs = dict(format='phylip_dm')

    # warm-up run
    dm = DistanceMatrix.read(f'{indir}/warmup.phy.gz', format='phylip_dm')
    with threadpool_limits(limits=thread, user_api='openmp'):
        tree = bme(dm, neg_as_zero=False)

    # formal run
    dm = DistanceMatrix.read(infile, **kwargs)
    with threadpool_limits(limits=thread, user_api='openmp'):
        start = perf_counter()
        tree = bme(dm, neg_as_zero=False)
        runtime = perf_counter() - start
        print(sample, seed, thread, '{:.6f}'.format(runtime), sep='\t')

    tree.write(f'{sample}.{seed}.{thread}.nwk')


if __name__ == '__main__':
    main()
