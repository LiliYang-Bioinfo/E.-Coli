# Files

### `00.New_hc1100.txt`
Generated in this study by integrating complete *Escherichia coli* genomes from NCBI, representative HC1100 genomes from EnteroBase, and the isolates analyzed in this work. This file contains the newly inferred HC1100 cluster assignments derived from cgMLST-based clustering analysis.

### `00.code.sh`
Shell script implementing the analysis pipeline used to generate the newly defined HC1100 clusters described in this study.

# Folders

### `01.EnteroBase`
Contains files downloaded from EnteroBase that were used for data preprocessing, strain classification, and construction of the strain-level reference database for metagenomic strain-tracking analyses.

### `02.COPSAC`
Contains data generated from the COPSAC cohort, including short-read isolate genomes, long-read isolate genomes, and metagenomic sequencing datasets.

### `03.cross-env_modules`
Contains results describing genomic modules identified in both COPSAC isolates and publicly available representative genomes from the corresponding clonal complexes (CCs).

### `04.cross-cohorts-metagenomes`
Contains metagenomic strain-tracking results generated using the same strain-level reference database applied to the COPSAC metagenomes. These analyses were performed across independent cohorts to evaluate the reproducibility of strain dominance patterns.

### `05.code_visualization`
Contains scripts, processed data, and intermediate files used to generate the figures and visualizations presented in the manuscript.