###############################################################################
# Short-read quality control and host/background read removal
#
# Process paired-end short reads by removing adapters, trimming low-quality
# reads, and retaining unmapped clean reads for downstream analyses.
###############################################################################

# Remove adapter sequences and trim low-quality bases from the right end.
# The first 3 bases are also removed from each read to reduce potential
# sequencing bias.
bbduk.sh \
  in1="${sample}_1.fastq.gz" \
  in2="${sample}_2.fastq.gz" \
  out1="${sample}.no_adapt_1.fastq.gz" \
  out2="${sample}.no_adapt_2.fastq.gz" \
  ktrim=r \
  k=23 \
  mink=11 \
  hdist=1 \
  hdist2=0 \
  forcetrimleft=3 \
  tpe \
  tbo \
  2> "${sample}.bbduk.log"

# Perform quality trimming of paired-end reads using Sickle.
# Reads shorter than 50 bp after trimming are discarded.
sickle pe \
  --qual-type sanger \
  -f "${sample}.no_adapt_1.fastq.gz" \
  -r "${sample}.no_adapt_2.fastq.gz" \
  -o "${sample}.qc_1.fastq.gz" \
  -p "${sample}.qc_2.fastq.gz" \
  -s /dev/null \
  -l 50 \
  2> "${sample}.sickle.log"

# Remove reads mapping to the reference/background genome using BBMap.
# Only unmapped paired reads are retained as clean reads.
bbmap.sh \
  qin=33 \
  threads=40 \
  in="${sample}.qc_1.fastq.gz" \
  in2="${sample}.qc_2.fastq.gz" \
  outu1="${sample}.clean_1.fastq.gz" \
  outu2="${sample}.clean_2.fastq.gz" \
  -Xmx50g \
  2> "${sample}.bbmap.log"
  
###############################################################################
# K-merize clean reads for strain tracking
#
# Convert quality-controlled reads into a k-mer profile for downstream strain
# identification and tracking using StrainGE. The resulting HDF5 file stores
# the k-mer counts and serves as input for strain matching against the
# reference database.
###############################################################################

straingst kmerize \
  -k 23 \
  -o "${sample}.hdf5" \
  "${sample}.clean_1.fastq.gz" \
  "${sample}.clean_2.fastq.gz"
  
###############################################################################
# Strain identification and tracking using StrainGE
#
# Compare the sample k-mer profile against the E. coli strain reference
# database to identify the closest matching strains present in the sample.
# StrainGE reports strain matches and their relative abundance based on
# k-mer similarity.
###############################################################################

straingst run \
  -O \
  -o "${sample}" \
  Ecoli_pan-genome-db.hdf5 \
  "${sample}.hdf5"