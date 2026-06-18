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