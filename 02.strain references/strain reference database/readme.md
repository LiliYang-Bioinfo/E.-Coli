## Steps to Build the Strain Reference Database

1. Randomly select one genome from each clonal complex (CC) to generate a set of representative genomes.

2. Construct a chromosome reference set using complete *Escherichia coli* genomes downloaded from NCBI.

3. Compare the CC representative genomes against the chromosome reference set and retain contigs with alignment coverage >60% and sequence identity >60%.

4. Build the strain reference database from the retained contigs of each representative genome using StrainGE.

> **Note:** The standard StrainGE workflow begins by clustering reference genomes based on average nucleotide identity (ANI; e.g., 99.9% ANI) to reduce redundancy. In our framework, this step was omitted because clonal complexes (CCs) were used to define strains. To minimize within-strain redundancy, only one representative genome was selected from each CC. The resulting representative genomes were then processed following the remaining StrainGE database construction workflow.

## Files

### `chromosome_list`

List of chromosome accession IDs used to construct the chromosome reference set.

### `process_m8.py`

Python script used to filter genome-to-chromosome alignment results based on sequence identity and alignment coverage thresholds.