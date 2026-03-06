from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy as np
import sys

if sys.platform == "darwin":
    # macOS + Apple Clang needs brew-installed libomp
    omp_compile = ["-Xpreprocessor", "-fopenmp"]
    omp_link    = ["-lomp"]
else:
    omp_compile = ["-fopenmp"]
    omp_link    = ["-fopenmp"]

ext = Extension(
    "_pdist",
    sources=["_pdist.pyx"],
    include_dirs=[np.get_include()],
    extra_compile_args=["-O3", "-march=native"] + omp_compile,
    extra_link_args=omp_link,
)

setup(
    name="_pdist",
    ext_modules=cythonize([ext]),
)
