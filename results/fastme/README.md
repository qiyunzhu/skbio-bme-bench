# Benchmarks of the BME algorithm in FastME

The first three columns of each table are sample size, random seed, and replicate.

`calc.tsv`: Elapsed time (sec) of the BME tree-building algorithm, reported by the patched FastME program.

`read.tsv`: Elapsed time (sec) and maximum resident set size (KB) of reading the distance matrix alone, reported by GNU time.

`full.tsv`: Elapsed time (sec) and maximum resident set size (KB) of the entire run, including distance matrix reading, tree building and output writing, reported by GNU time.
