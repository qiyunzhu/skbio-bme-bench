# cython: language_level=3, boundscheck=False, wraparound=False, cdivision=True

import numpy as np
from cython.parallel import prange
from libc.math cimport round


def _pdist_all(const unsigned char[:, ::1] seqs,
               const unsigned char[:, ::1] mask):
    """Compute full lower-triangular p-distance matrix (parallel).

    Parameters
    ----------
    seqs : ndarray of uint8, shape (n, m)
        Aligned sequences as ASCII codes, C-contiguous.
    mask : ndarray of uint8, shape (n, m)
        Valid-nucleotide indicator (1 = valid, 0 = gap / degenerate),
        C-contiguous.

    Returns
    -------
    dmat : ndarray of float32, shape (n, n)
        Lower-triangular distance matrix.  ``dmat[i, j]`` for *i > j*
        is the p-distance between sequences *i* and *j*, rounded to
        5 decimal places.  Pairs that share no valid site receive 1.0.

    """
    cdef:
        Py_ssize_t n = seqs.shape[0]
        Py_ssize_t m = seqs.shape[1]
        Py_ssize_t i, j, k
        int diff, valid, bv
        double raw
        float[:, ::1] dmat

    res = np.zeros((n, n), dtype=np.float32)
    dmat = res

    for i in prange(n, nogil=True, schedule='dynamic'):
        for j in range(i):
            diff  = 0
            valid = 0
            for k in range(m):
                bv    = <int>mask[i, k] & <int>mask[j, k]
                valid = valid + bv
                diff  = diff + (bv & <int>(seqs[i, k] != seqs[j, k]))
            if valid == 0:
                dmat[i, j] = 1.0
            else:
                raw = <double>diff / <double>valid
                dmat[i, j] = <float>(round(raw * 1e5) / 1e5)

    return res
