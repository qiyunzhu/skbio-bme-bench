# skbio-bme-bench

Benchmarking the parallel balanced minimum evolution (BME) algorithm implemented in scikit-bio.


## Installation

Have Python installed in your system. Execute the following command:

```bash
pip install -I git+https://github.com/qiyunzhu/scikit-bio.git@parame
```

This command installs a specific branch of the scikit-bio package that houses the optimized BME algorithm. It will eventually be merged into the upstream main branch. In install the standard release of scikit-bio, refer to this [guideline](https://scikit.bio/install.html).

We recommend that you experiment this in a sandbox environment, managed by e.g., `venv`, `uv` or `conda`.

Some scripts in this repo depend on the `threadpoolctl` package to control the multi-threading behavior of the BME algorithm. Install it with:

```bash
pip install threadpoolctl
```


## Usage

This section introduces how to use the optimized BME algorithm in scikit-bio as a typical evolutionary biologist user.

In brief, the [`bme`](https://scikit.bio/docs/latest/generated/skbio.tree.bme.html) function consumes a distance matrix as input and generates a phylogenetic tree as output.

The distance matrix file may be in [Phylip format](https://scikit.bio/docs/latest/generated/skbio.io.format.phylip_dm.html) (square or triangular, with strict or relaxed sequence IDs), [plain TSV or CSV format](https://scikit.bio/docs/latest/generated/skbio.io.format.lsmat.html), or an [HDF5 binary format](https://scikit.bio/docs/latest/generated/skbio.io.format.binary_dm.html). Read the file:

```python
from skbio.stats.distance import DistanceMatrix
dm = DistanceMatrix.read('input.dm')
```

The default floating-point data type is `float64`. If needed, you may specify `dtype='float32'` inside `read` to save half of the memory and some compute, at the cost of (slightly) reduced arithmetic precision.

If you begin with a multiple sequence alignment file, read it and compute a distance matrix using the [`align_dists`](https://scikit.bio/docs/latest/generated/skbio.alignment.align_dists.html) function:

```python
from skbio.sequence import DNA  # replace `DNA` with `Protein` when needed
from skbio.alignment import TabularMSA, align_dists
aln = TabularMSA.read('input.fasta', constructor=DNA)
dm = align_dists(aln, 'pdist', shared_by_all=False)
```

`pdist` refers to _p_-distance, a simple genetic distance metric that is the raw proportion of differing sites between two aligned sequences. In addition, scikit-bio offers a range of common distance metrics, such as `jc69`, `k2p`, `tn93` and `logdet`. See [a complete list](https://scikit.bio/docs/latest/generated/skbio.sequence.distance.html) of them.

`shared_by_all=False` corresponds to "pairwise deletion" in the phylogenetics jargon. Remove it to trigger "complete deletion".

(Optional) save the distance matrix to a file. The following code writes a Phylip-formatted distance matrix in square layout (a valid input format for FastME), but scikit-bio also supports writing in any of the format mentioned above.

```python
dm.write('input.dm', format='phylip_dm', layout='square')
```

With a distance matrix, one can execute the `bme` function to compute a phylogenetic tree:

```python
from skbio.tree import bme
tree = bme(dm)
```

`tree` is a [`TreeNode`](https://scikit.bio/docs/latest/generated/skbio.tree.TreeNode.html) object, a core data structure of scikit-bio that offers a wide variety of phylogenetic tree operations.

By default, negative branch lengths will be converted into zero. To keep negative branch lengths, add `neg_as_zero=False` to the `bme` function call.

Parallelization is automatic and uses all available threads in the system. If you intend to specify how many threads (e.g., 8) should be used by the algorithm, you may set an environment variable prior to entering Python:

```bash
export OMP_NUM_THREADS=8
python script.py ...
```

Alternatively, you may dynamically control this behavior inside a Python program on a per-code block base:

```python
from threadpoolctl import threadpool_limits
with threadpool_limits(limits=8, user_api='openmp'):
    tree = bme(dm)
```

Once the tree is computed, write it into a [Newick-formatted](https://scikit.bio/docs/latest/generated/skbio.io.format.newick.html) file:

```python
tree.write('output.nwk')
```

To summarize, a simple one-liner usage of the BME algorithm is:

```python
bme(DistanceMatrix.read('input.dm')).write('output.nwk')
```

This process corresponds to the FastME command:

```bash
fastme -i input.dm -m B -w B -o output.nwk
```

In which `-m B` refers to "TaxAdd_BalME" for tree topology reconstruction, `-w B` refers to "BalLS" for branch length estimation. The input file should be a Phylip-formatted matrix in square layout.
