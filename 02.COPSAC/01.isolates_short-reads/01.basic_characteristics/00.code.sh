###############################################################################
# Step 1. Trim adapters and low-quality bases from paired-end reads
# - Run FastQC before/after trimming
# - Save trimmed reads to Reads/${genome}/Trimmed
# - Write log file to Log/Trimming/${genome}.log
###############################################################################

trim_galore \
    --stringency 3 \
    --fastqc \
    --paired \
    --basename "${genome}" \
    -o "${HERE}/Reads/${genome}/Trimmed" \
    "${HERE}/Reads/${genome}/${genome}_"* \
    > "${HERE}/Log/Trimming/${genome}.log" 2>&1


###############################################################################
# Step 2. Assemble the genome using SPAdes
# - Input: trimmed paired-end reads
# - Output: assembly files in Assemblies/${genome}
# remove contigs less than 500bp after the assembling
###############################################################################

spades.py \
    --isolate \
    -t 40 \
    -m 180 \
    -1 "${HERE}/Reads/${genome}/Trimmed/${genome}_val_1.fq.gz" \
    -2 "${HERE}/Reads/${genome}/Trimmed/${genome}_val_2.fq.gz" \
    -o "${HERE}/Assemblies/${genome}"


###############################################################################
# Step 3. Assign taxonomy using GTDB-Tk
# - Input: assembled genome(s)
# - Output: taxonomic classification results in GTDBtk/${genome}
###############################################################################

gtdbtk classify_wf \
    --cpus 40 \
    --genome_dir "${HERE}/Assemblies/${genome}" \
    --out_dir "${HERE}/GTDBtk/${genome}"


###############################################################################
# Step 4. Assess genome completeness and contamination with CheckM
# - Input: assembled genome(s)
# - Output: quality assessment results in CheckM/${genome}
###############################################################################

checkm lineage_wf \
    --tab_table \
    -f "${HERE}/CheckM/${genome}/results_checkM.txt" \
    -t 10 \
    -x fasta \
    "${HERE}/Assemblies/${genome}" \
    "${HERE}/CheckM/${genome}"


###############################################################################
# Step 5. Determine Escherichia coli phylogroup using EzClermont
# - Input: assembled genome FASTA file
# - Output: phylogroup assignment for ${genome}
###############################################################################

ezclermont \
    "${HERE}/Assemblies/${genome}/${genome}.fasta" \
    > "${HERE}/EzClermont/${genome}_phylogroup.txt"