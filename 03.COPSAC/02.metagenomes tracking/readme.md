## Files

### `00.code.sh`

Shell script implementing the strain-tracking analysis pipeline, including preprocessing and quality control of metagenomic sequencing data, generation of clean reads, construction of sample k-mer profiles, and downstream strain identification and tracking using StrainGE.

### `01.strain_tracking_results.xlsx`

Results of the strain-tracking analysis based on metagenomic sequencing data. The file contains strain identification results for samples collected at the 1-month and 1-year follow-up time points, including detected strains and their estimated relative abundances.

### `02.exposures_tests.R`

R script used to evaluate associations between environmental exposure variables and the presence of the ten most prevalent *Escherichia coli* strains identified in the strain-tracking analysis.