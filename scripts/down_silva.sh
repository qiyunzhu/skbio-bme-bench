#!/bin/bash
# Download SILVA release 138.2 SSU Ref NR 99 sequences and validate file integrity.

server=https://www.arb-silva.de/fileadmin/silva_databases/release_138.2/Exports
file=SILVA_138.2_SSURef_NR99_tax_silva_full_align_trunc.fasta.gz

curl -O $server/$file
curl -O $server/$file.doi
curl -O $server/$file.md5

md5sum -c $file.md5
