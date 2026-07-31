#!/bin/bash
# Download GTDB release 232.0 bac120 phylogenomic dataset.

server=https://data.ace.uq.edu.au/public/gtdb/data/releases/release232/232.0

curl -sL $server/auxillary_files/gtdbtk_package/full_package/gtdbtk_r232_data.tar.gz |\
  tar -xvf - --strip-components=2 release232/msa/gtdb_r232_bac120.faa
curl -O $server/bac120_r232.tree.gz
