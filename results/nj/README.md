# Benchmarks of the NJ-R-D algorithm in DecentTree

The first four columns of each table are sample size, random seed, thread count, and replicate.

`calc.tsv`: Elapsed time (sec) of the NJ tree-building algorithm, reported by DecentTree.

`full.tsv`: Elapsed time (sec) and maximum resident set size (KB) of the entire run, including distance matrix reading, tree building and output writing, reported by GNU time.
