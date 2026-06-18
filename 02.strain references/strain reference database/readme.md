## Steps to build the strain reference database

1. Randomly select one genome from each clonal complex (CC) to generate a representative genome set.

2. Prepare a chromosome reference set using complete E. coli genomes downloaded from NCBI.

3. Compare the CC representative genomes against the chromosome reference set and retain contigs with alignment coverage >60% and sequence identity >60%.

## Files

### `chromosome_list`
List of chromosome IDs used to build the chromosome reference set.

### `process_m8.py`
Python script used to filter sequence comparison results based on coverage and identity thresholds.