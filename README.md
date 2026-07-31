# skbio-bme-bench

Benchmarking the parallel balanced minimum evolution (BME) algorithm implemented in scikit-bio.

The software code hosted in this repo is licensed under [BSD 3-Clause](LICENSE), except for a [patch](patch) for the FastME program, which is licensed under [GPL-3.0](patch/LICENSE).


## Installation

Have Python installed in your system. Execute the following command:

```bash
pip install -I git+https://github.com/qiyunzhu/scikit-bio.git@parame
```

This command installs a specific branch of the scikit-bio package that houses the optimized BME algorithm. It was later merged into the upstream main branch, and shipped in [scikit-bio 0.7.3](https://github.com/scikit-bio/scikit-bio/releases/tag/0.7.3). To install the standard release of scikit-bio, refer to this [guideline](https://scikit.bio/install.html).

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


## Illustration

Execute [`diagram.ipynb`](diagram.ipynb) for a walk-through of the BME algorithm using a dummy dataset.


## Benchmarks

This section details how the benchmarks of the optimized BME algorithm were generated.


### SILVA

We generated test datasets of varying sizes by subsampling the SSU Ref NR 99 sequences of [SILVA](https://www.arb-silva.de/) release 138.2 (_n_ = 510,495),

Download the sequences from the SILVA server and process them.

```bash
bash scripts/down_silva.sh
bash scripts/parse_silva.sh
```

Subsample varying numbers of sequences from the complete SILVA sequence file. This will randomly sample 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10k, 20k, 50k, 100k and 200k sequences. For each number, 5 replicates with different random seeds (0 to 4) are generated, with the exception of 200k, with which only 1 replicate is generated considering the large size of the subsequent distance matrix file. Additionally, a set of 1000 sequences is sampled with seed = 42 for program warm-up purpose.

```bash
mkdir -p aln
bash scripts/sample_silva.sh
bash scripts/sample_silva_200k.sh
bash scripts/sample_silva_warm.sh
```

The outputs are gzipped FASTA-formatted multiple sequence alignments under the `aln` directory.

Compute distance matrices from subsampled sequences. The following commands use scikit-bio's built-in `align_dists` function for samples to 100k sequences, and uses a custom, parallel Cython program for the sample of 200k sequences, such that we don't need to wait for days. Follow the [instruction](utils/calc_pdist_cy) to compile the Cython code. If you want to further save time, you may use this Cython program to calculate distances for all samples.

```bash
mkdir -p dm
bash scripts/pdist_silva.sh
bash scripts/pdist_silva_200k.sh
bash scripts/pdist_silva_warm.sh
```

The outputs are gzipped Phylip-formatted distance matrices under the `dm` directory.

Note that the distance matrix files can be huge when there are many sequences, because they are _O_(_n_<sup>2</sup>). The code already attempts to reduce file size (lower triangular layout, 5 decimal places, gzipping), but it could still be a consideration if your disk space is running low. For example, a file with 100k taxa takes about 12 GB.


### FastME

Our implementation of the BME algorithm was compared with the original implementation in the [FastME](https://gite.lirmm.fr/atgc/FastME/) package ([Lefort et al., _Mol Biol Evol_, 2015](https://academic.oup.com/mbe/article/32/10/2798/1212138)).

Follow the [instruction](patch) to retrieve the FastME source code, patch it to enable additional reporting, and compile it in your machine.

Benchmark the BME algorithm implemented in FastME. The algorithm will run five times on every sample under 50k, and three times on the 50k samples (to save time). Note that this program cannot parallelize.

```bash
mkdir -p fastme
bash scripts/bench_fastme.sh
bash scripts/bench_fastme_50k.sh
```

The FastME command run by these scripts is:

```bash
fastme -T 4 -i input.phy -m B -w B -o output.nwk
```

The outputs are Newick-formatted phylogenetics trees, and tabular summary of runtimes and memory consumptions, under the `fastme` directory.


### scikit-bio

For samples with 100k or more taxa, convert the distance matrices into a binary format to reduce loading time.

```bash
bash scripts/phylip_to_hdf5.sh
```

Benchmark the parallel BME algorithm implemented in scikit-bio.

```bash
mkdir -p skbio
bash scripts/bench_skbio.sh
bash scripts/bench_skbio_100k.sh
bash scripts/bench_skbio_200k.sh
```

The outputs are similar to above, under the `skbio` directory.


### Neighbor-joining (NJ)

We compared the taxon-addition BME algorithm with neighbor-joining (NJ), which is essentially also a heuristic for the BME problem using agglomerative clustering. We chose the "NJ-R-D" algorithm in [DecentTree](https://github.com/iqtree/decenttree) ([Wang et al., _Bioinformatics_, 2023](https://academic.oup.com/bioinformatics/article/39/9/btad536/7257068)) for the test.

Install DecentTree from Bioconda:

```bash
conda install bioconda::decenttree
```

Benchmark the NJ-R-D algorithm.

```bash
mkdir -p nj
bash scripts/bench_nj.sh
bash scripts/bench_nj_100k.sh
```

The outputs are similar to above, under the `nj` directory.


### BME loss calculation

We accessed the quality of output trees by caculating the balanced tree length -- the loss function of the balanced minimum evolution framework. Smaller is better.

```bash
mkdir -p nj
bash scripts/bme_loss.sh
```

The outputs are `fastme.loss`, `skbio.loss` and `nj.loss`.


### Consistency test

We compared the consistency between scikit-bio- and FastME-generated trees by testing 1000 random samples of 1000 or 10k sequences.

```bash
reps=1000
for taxa in 1000 10000; do
  bash scripts/consistency.sh $taxa $reps
done
```

The outputs are `1k.tsv`, `10k.tsv`.


## Case study

### GTDB analysis

We applied the tree-building methods to the [GTDB](https://gtdb.ecogenomic.org/) release RS232 bac120 dataset (_n_ = 189,801).

Download the dataset and reference phylogeny from the GTDB server.

```bash
bash scripts/down_gtdb.sh
```

Generate a JC20 (like JC69 but for the 20 canonical amino acids) distance matrix using DecentTree.

```bash
bash scripts/jc20_gtdb.sh
```

Run scikit-bio's BME algorithm and DecentTree's NJ-R-D algorithm on this distance matrix.

```bash
bash scripts/run_gtdb_skbio.sh
bash scripts/run_gtdb_nj.sh
```

The outputs are trees and benchmarks under `gtdb`.

Evaluate the output trees. This will calculate:

1. Normalized Robinson-Foulds distance from the reference tree, smaller is more congruent.
2. BME loss (balanced tree length), smaller is better

```bash
bash scripts/evaluate_gtdb.sh
```


## Plotting

Execute [`analysis.ipynb`](analysis.ipynb) to analyze raw results and generate plots.
