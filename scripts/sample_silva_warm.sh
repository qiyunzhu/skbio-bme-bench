#!/bin/bash
# Sample 1000 sequences from SILVA for warm-up purpose.

seqtk sample -s42 silva.aln 1000 | gzip > aln/warmup.aln.gz
