#!/usr/bin/env bash
# Usage:
#   ./neighbors.sh input.tsv > neighbors.tsv
#
# Input columns (tab-separated):
#   1 genome
#   2 contig
#   3 cds_id           (e.g., prefix_000123 -> order=123, width=6)
#   4 contig_length    (max CDS order on this contig)
#   5 gene_name        (in the module)
#   6 module_id
#
# Output columns (tab-separated, with header):
#   genome  contig  module_id  focal_gene  focal_cds_id  neighbor_offset  neighbor_cds_order  neighbor_cds_id  direction

awk -F'\t' 'BEGIN{
  OFS = "\t";
  print "genome","contig","module_id","focal_gene","focal_cds_id","neighbor_offset","neighbor_cds_order","neighbor_cds_id","direction";
}
NR==1 && $1=="genome" { next }  # skip header if present
{
  genome=$1; contig=$2; cds=$3; maxord=$4; gene=$5; module=$6;

  # Split cds_id on underscore; the 2nd token is the order
  n = split(cds, parts, "_");
  if (n < 2) next;

  prefix = parts[1];              # keep the prefix as-is
  order_str = parts[2];           # e.g., 000123
  width = length(order_str);      # zero-padding width
  order = order_str + 0;          # numeric

  for (delta=-20; delta<=20; delta++) {
    if (delta==0) continue;
    ord2 = order + delta;

    # Boundaries: valid orders are 1..maxord
    if (ord2 < 1) continue;
    if (maxord != "" && ord2 > maxord) continue;

    # Rebuild zero-padded order string
    fmt = "%0" width "d";
    ord2str = sprintf(fmt, ord2);

    neighbor_id = prefix "_" ord2str;
    dir = (delta < 0 ? "upstream" : "downstream");
    off = (delta > 0 ? "+" delta : delta);

    print genome, contig, module, gene, cds, off, ord2, neighbor_id, dir;
  }
}' "${1:-/dev/stdin}"

