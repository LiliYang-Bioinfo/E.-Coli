###############################################################################
# Demultiplexing, genome assembly, quality control, and annotation
#
# Process PacBio HiFi reads by demultiplexing barcoded samples, converting BAM
# files to FASTQ format, assembling genomes, assessing genome quality, and
# annotating genomic features for downstream analyses.
###############################################################################

# Demultiplex HiFi reads using lima.
# Barcoded reads are separated by sample using the provided barcode FASTA file.
lima Pool_1.hifi_reads.bam barcode.fasta "${sample}.demux.bam" \
  --hifi-preset SYMMETRIC \
  -j "${threads_lima}"

# Convert demultiplexed BAM reads to compressed FASTQ format.
bam2fastq "${sample}.demux.${sample}.bam" \
  -o "${sample}.demux.${sample}"

# Assemble HiFi reads with hifiasm.
# The primary contig assembly is used for downstream genome annotation.
hifiasm \
  -o "${sample}.asm" \
  -t "${threads_asm}" \
  "${sample}.demux.${sample}.fastq.gz"

# Assess genome quality using CheckM.
# Completeness and contamination estimates are generated for assembled genomes.
checkm lineage_wf \
  --tab_table \
  -f results_checkM_genome.txt \
  -t "${threads_checkm}" \
  -x fasta \
  02.fasta \
  03.checkm/

# Annotate assembled genomes using Prokka.
# Genome annotation predicts coding sequences and other genomic features,
# which are required for downstream analyses such as identifying genes
# flanking target gene modules.
prokka "${sample}.asm.bp.p_ctg.fasta" \
  --outdir "${sample}" \
  --prefix "${sample}" \
  --cpus 20 \
  --compliant

# Annotate mobile genetic element-associated genes using MobileOG-db.
# Predicted genes are screened against the MobileOG database to identify
# putative MGE-related genes in each genome.
./mobileOGs-pl-kyanite.sh \
  -i "${sample}.fasta" \
  -d mobileOG-db_beatrix-1.6.All.dmnd \
  -m mobileOG-db-beatrix-1.6-All.csv \
  -k 15 \
  -e 1e-20 \
  -p 90 \
  -q 90