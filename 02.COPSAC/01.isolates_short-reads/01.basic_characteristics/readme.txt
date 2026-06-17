## Files

### `00.code.sh`
Shell script for bacterial genome analysis, including:
- Read trimming and quality control using Trim Galore and FastQC
- Genome assembly using SPAdes
- Genome quality assessment using CheckM
- Taxonomic classification using GTDB-Tk
- *Escherichia coli* phylogroup assignment using EzClermont

### `01.genome_quality.txt`
Summary table of genome quality and typing results for downstream genome selection, including:
- Genome completeness and contamination estimates (CheckM)
- Taxonomic classification (GTDB-Tk)
- *E. coli* phylogroup assignment (EzClermont)
- Clonal complex (CC) identification