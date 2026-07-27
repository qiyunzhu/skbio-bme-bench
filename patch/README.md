# Patch of the FastME program

This patch achieves two objectives:

1. The elapsed time of the tree computing algorithm will be recorded. This excludes distance matrix reading, tree writing, and other overheads.
2. When `-c` is specified, FastME will exit immediately after reading the distance matrix. This helps to assess the time and memory required for distance matrix alone.

FastME is licensed under [GPL-3.0](https://opensource.org/license/GPL-3.0) ([source](https://anaconda.org/channels/bioconda/packages/fastme/overview)). Therefore, this patch is also licensed under GPL-3.0.

FastMe 2.1.6.4 (released on Sep. 15, 2022) is available for download from GitLab:

```bash
url=https://gite.lirmm.fr/atgc/FastME/-/raw/master/tarball/fastme-2.1.6.4.tar.gz?ref=08e21504
wget -O fastme-2.1.6.4.tar.gz $url
tar xf fastme-2.1.6.4.tar.gz
```

Apply the patch:

```bash
patch fastme-2.1.6.4/src/fastme.c < fastme.c.patch
```

Compile the source code:

```bash
cd fastme-2.1.6.4
./configure
make
cd ..
```

Then you will be able to run the patched FastME with:

```bash
fastme-2.1.6.4/src/fastme
```
