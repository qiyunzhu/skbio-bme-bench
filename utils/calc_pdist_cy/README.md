# Generating extremely large distance matrices

This is a parallelized Cython program to calculate the _p_-distances between pairs of aligned sequences. It is significantly faster than scikit-bio's built-in `align_dists` function, which is serial. However, the output has slightly different precision.

Installation:

```bash
python setup.py build_ext --inplace
```
