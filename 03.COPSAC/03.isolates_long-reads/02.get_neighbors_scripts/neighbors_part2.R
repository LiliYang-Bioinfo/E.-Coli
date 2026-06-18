library(dplyr)

# read input (tab-delimited)
input <- read.csv("neighbors_dup.tsv", sep = "\t", stringsAsFactors = FALSE)

# select relevant columns, drop duplicates
tmp <- input %>%
  select(genome, contig, module_id, neighbor_cds_id) %>%
  distinct() %>%                        # equivalent to unique() but more idiomatic
  arrange(genome, contig, module_id, neighbor_cds_id)

# write back as TSV
write.table(tmp,
            file = "neighbors.tsv",
            sep = "\t",
            quote = FALSE,
            row.names = FALSE)

