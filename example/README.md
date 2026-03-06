# Example Dataset

This is a small example dataset for demonstrating the usage of the BME algorithm in scikit-bio. It consists of 770 16S rRNA gene (V4 region) sequences, each of which is 120 bp in length. The dataset is derived from the "Moving Pictures" [1] tutorial of QIIME 2 [2] verison 2026.1.

To retrieve the original sequence data:

```bash
wget https://moving-pictures-tutorial.readthedocs.io/en/2026.1/data/moving-pictures/rep-seqs.qza
unzip -j rep-seqs.qza */data/dna-sequences.fasta
mv dna-sequences.fasta movpic.fna
rm rep-seqs.qza
```

To compute a pairwise _p_-distance matrix, use the `calc_pdist.py` script under `utils/`:

```bash
python calc_pdist.py movpic.fna movpic.phy
```

## References

1. Caporaso, J. G., Lauber, C. L., Costello, E. K., Berg-Lyons, D., Gonzalez, A., Stombaugh, J., ... & Knight, R. (2011). Moving pictures of the human microbiome. Genome biology, 12(5), R50.
2. Bolyen, E., Rideout, J. R., Dillon, M. R., Bokulich, N. A., Abnet, C. C., Al-Ghalith, G. A., ... & Caporaso, J. G. (2019). Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. Nature biotechnology, 37(8), 852-857.