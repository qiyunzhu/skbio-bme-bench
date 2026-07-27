# Generating extremely large distance matrices

This is a parallelized Cython program to calculate the _p_-distances between pairs of aligned sequences. It is significantly faster than scikit-bio's built-in `align_dists` function, which is serial. However, the output has slightly different precision.

Prerequisites:

```bash
pip install setuptools cython
```

Compile the Cython code:

```bash
python setup.py build_ext --inplace
```

Then you will be able to run the program with:

```bash
python calc.py input.aln output.phy
```
