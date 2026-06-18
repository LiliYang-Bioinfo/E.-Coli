# Demultiplex HiFi reads
lima Pool_1.hifi_reads.bam barcode.fasta "${sample}.demux.bam" \
  --hifi-preset SYMMETRIC \
  -j "${threads_lima}"

# Convert BAM to FASTQ
bam2fastq "${sample}.demux.${sample}.bam" \
  -o "${sample}.demux.${sample}"

# Assemble with hifiasm
hifiasm \
  -o "${sample}.asm" \
  -t "${threads_asm}" \
  "${sample}.demux.${sample}.fastq.gz"

# Run CheckM
checkm lineage_wf \
  --tab_table \
  -f results_checkM_genome.txt \
  -t "${threads_checkm}" \
  -x fasta \
  02.fasta \
  03.checkm/
  
# Genome annotation
prokka ${sample}.asm.bp.p_ctg.fasta \
    --outdir ${sample} \
    --prefix ${sample} \
    --cpus 20 \
    --compliant