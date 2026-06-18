###############################################################################
# Step 1. Identify antimicrobial resistance (AMR) genes
#
# Search predicted protein sequences against the CARD database using RGI.
# AMR genes are identified with DIAMOND and annotated according to CARD
# resistance models.
#
# Input:
#   - Predicted protein sequences (.faa)
#
# Output:
#   - RGI annotation files containing detected AMR genes and resistance
#     mechanisms
###############################################################################
rgi main \
  --input_sequence "${prokka_dir}/${sample}/${sample}.faa" \
  -t protein \
  --output_file "${sample}.RGI" \
  -a DIAMOND \
  --local \
  --clean

###############################################################################
# Step 2. Identify virulence factor genes
#
# Search predicted protein sequences against the VFDB (Virulence Factor
# Database) using DIAMOND BLASTP to identify putative virulence-associated
# genes.
#
# Output format:
#   qseqid   = query protein ID
#   sseqid   = VFDB reference protein ID
#   pident   = percentage identity
#   length   = alignment length
#   mismatch = number of mismatches
#   gapopen  = number of gap openings
#   qstart/qend = query alignment coordinates
#   sstart/send = subject alignment coordinates
#   evalue   = E-value
#   bitscore = bit score
#   qlen     = query sequence length
#
# Input:
#   - Predicted protein sequences (.faa)
#
# Output:
#   - Tab-delimited BLASTP alignment file (.m8)
###############################################################################
diamond blastp \
  -d VFDB_setB.dmnd \
  -q "${prokka_dir}/${sample}/${sample}.faa" \
  -o "${sample}.m8" \
  -p 16 \
  --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen
  
###############################################################################
# Step 3. Gene module annotation and pangenome analysis
#
# Construct the pangenome graph and annotate gene families/modules using
# PPanGGOLiN. The workflow clusters homologous genes across genomes,
# partitions gene families into persistent, shell, and cloud genomes,
# and generates gene module annotations.
#
# Input:
#   - Genome annotation files in GFF format (listed in "gff_list")
#
# Output:
#   - PPanGGOLiN pangenome database
#   - Gene family clustering results
#   - Gene module annotations
#   - Persistent, shell, and cloud genome partitions
###############################################################################
ppanggolin all \
  --anno gff_list \
  -c 20 \
  -o ${output_dir}