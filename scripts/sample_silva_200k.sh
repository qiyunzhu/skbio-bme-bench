#!/bin/bash
# Sample 200,000 sequences from SILVA.

n=200000
s=0
seqtk sample -s$s silva.aln $n | gzip > aln/$n.$s.aln.gz
