# Benchmarks of the parallel BME algorithm in scikit-bio

The first three columns are sample size, random seed, and thread count.

`calc.tsv`: Elapsed time (sec) of the BME tree-building algorithm (`bme`), reported by `perf_counter`.

The first four columns of are sample size, random seed, thread count, and replicate.

`read.tsv`: Elapsed time (sec) and maximum resident set size (KB) of reading the distance matrix alone, reported by GNU time.

`full.tsv`: Elapsed time (sec) and maximum resident set size (KB) of the entire run, including distance matrix reading, tree building and output writing, reported by GNU time.
