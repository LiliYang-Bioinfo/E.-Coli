import pandas as pd
import subprocess
import tempfile
import os
import sys
from Bio import SeqIO

def read_filter_and_create_bed_intervals(input_file):
    # Read the input file
    df = pd.read_csv(input_file, sep='\t', header=None)
    # Filter rows where the third column is greater than 0.6
    filtered_df = df[df[2] > 0.6]
    # Create a DataFrame for BED intervals
    bed_intervals_df = pd.DataFrame({
        'chrom': filtered_df[0],
        'start': filtered_df[[6, 7]].min(axis=1),
        'end': filtered_df[[6, 7]].max(axis=1)
    })
    # Create a DataFrame with unique sorted values for chromosome and length, columns named "chrom" and "length"
    chrom_len_df = df[[0, 12]].drop_duplicates().sort_values(by=0)
    chrom_len_df.columns = ['chrom', 'length']
    return bed_intervals_df, chrom_len_df

def sort_and_merge_bed_intervals(bed_intervals_df):
    # Sort the BED intervals DataFrame
    sorted_bed_intervals_df = bed_intervals_df.sort_values(by=['chrom', 'start'])

    # Save the sorted intervals to a temporary file
    with tempfile.NamedTemporaryFile(delete=False, mode='w', suffix='.bed') as tmp_sorted_bed:
        sorted_bed_intervals_df.to_csv(tmp_sorted_bed.name, sep='\t', header=False, index=False)
        tmp_sorted_bed_path = tmp_sorted_bed.name

    # Call bedtools merge and redirect the output to another temporary file
    with tempfile.NamedTemporaryFile(delete=False, mode='w', suffix='.bed') as tmp_merged_bed:
        tmp_merged_bed_path = tmp_merged_bed.name

    subprocess.run(['bedtools', 'merge', '-i', tmp_sorted_bed_path], stdout=open(tmp_merged_bed_path, 'w'), check=True)

    # Read the merged intervals back into a DataFrame
    merged_bed_df = pd.read_csv(tmp_merged_bed_path, sep='\t', header=None)

    # Remove the temporary files
    os.remove(tmp_sorted_bed_path)
    os.remove(tmp_merged_bed_path)

    return merged_bed_df

def calculate_ratios_and_save(merged_bed_df, chrom_len_df, output_prefix):
    # Merge with unique chromosome values DataFrame
    merged_df = pd.merge(merged_bed_df, chrom_len_df, left_on=0, right_on='chrom')

    # Calculate the length of each merged interval
    merged_df['interval_length'] = merged_df[2] - merged_df[1] + 1

    # Group by chromosome and calculate the sum of interval lengths
    chrom_sum_len_df = merged_df.groupby('chrom').agg(sum_len=('interval_length', 'sum')).reset_index()

    # Merge the sum lengths back to the merged DataFrame
    final_df = merged_df.merge(chrom_sum_len_df, on='chrom')

    # Select the required columns and drop duplicates
    output_df = final_df[['chrom', 'length', 'sum_len']].drop_duplicates()

    # Calculate the ratio of the sum of interval lengths to the length column
    output_df['ratio'] = output_df['sum_len'] / output_df['length']

    # Save the final result to the output file
    output_df.to_csv(f"{output_prefix}.bed", sep='\t', index=False, header=False, quoting=False)

    return output_df

def extract_target_contigs(output_df, fasta_file, output_prefix):
    # Filter for rows where the ratio is greater than 0.6
    target_contigs = output_df[output_df['ratio'] > 0.6]['chrom'].unique()

    # Extract sequences of target contigs from the FASTA file
    sequences = []
    for record in SeqIO.parse(fasta_file, "fasta"):
        if record.id in target_contigs:
            sequences.append(record)
    
    # Write the target sequences to a new FASTA file
    with open(f"{output_prefix}_hitChro.fasta", "w") as fasta_output:
        SeqIO.write(sequences, fasta_output, "fasta")

def process_file(input_file, output_prefix, fasta_file):
    bed_intervals_df, chrom_len_df = read_filter_and_create_bed_intervals(input_file)
    merged_bed_df = sort_and_merge_bed_intervals(bed_intervals_df)
    output_df = calculate_ratios_and_save(merged_bed_df, chrom_len_df, output_prefix)
    extract_target_contigs(output_df, fasta_file, output_prefix)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_file> <output_prefix> <fasta_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_prefix = sys.argv[2]
    fasta_file = sys.argv[3]
    process_file(input_file, output_prefix, fasta_file)

