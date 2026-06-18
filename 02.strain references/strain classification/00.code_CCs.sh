###############################################################################
# Step 0. Genome taxonomic classification and quality control
#
# Verify the taxonomic identity of assembled genomes using GTDB-Tk and assess
# genome quality using CheckM. This step confirms whether assemblies belong
# to Escherichia coli and evaluates their completeness and contamination to
# ensure suitability for downstream analyses.
#
# Input:
#   - Assembled genomes
#
# Output:
#   - GTDB taxonomic classifications
#   - Phylogenetic placement results
#   - Genome completeness and contamination estimates
#   - Genome quality assessment reports
###############################################################################

# Taxonomic classification using GTDB-Tk
gtdbtk classify_wf \
    --genome_dir "${genome_dir}" \
    -x fna \
    --cpus 30 \
    --out_dir GTDBtk_out

# Genome quality assessment using CheckM
checkm lineage_wf \
    --tab_table \
    -f results_checkM.txt \
    -t 10 \
    -x fasta \
    "${genome}" \
    "${CheckM}/"

###############################################################################
# Step 1. Generate cgMLST profiles using EToKi
# - Input: genome FASTA file
# - Reference: cgMLST reference FASTA
# - Output: genome-specific cgMLST allele profile and HierCC input files
###############################################################################

python EToKi.py MLSType \
    -i "${genome}.fa" \
    -r "cgMLST_ref.fasta" \
    -k "${genome}_hiercc" \
    -o "${genome}_hiercc" \
    -d "cgMLST_convert.tab"


###############################################################################
# Step 2. Convert non-numeric allele IDs into numeric IDs
# - Some generated allele IDs contain characters instead of numbers
# - This script replaces character-based IDs with numeric IDs
# - Output: formatted cgMLST profile suitable for pHierCC
###############################################################################

Rscript 00.replace_chars.R


###############################################################################
# Step 3. Assign HierCC clusters using pHierCC
# - Input: formatted cgMLST profile
# - Output: HierCC clustering results for E. coli genomes
###############################################################################

pHierCC \
    -p "Ecoli.cgMLST.profile" \
    -o "Ecoli.cgMLST.HierCC"