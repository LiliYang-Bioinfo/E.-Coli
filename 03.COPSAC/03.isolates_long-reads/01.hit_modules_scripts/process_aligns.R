#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(dplyr))

# Usage: Rscript script.R <input.tsv> <module_info.tsv> <output.tsv> <count_output.tsv> [pval_threshold]
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) stop("Usage: Rscript script.R <input.tsv> <module_info.tsv> <output.tsv> <count_output.tsv> [pval_threshold]")

in_path      <- args[1]
mod_path     <- args[2]
out_path     <- args[3]
count_path   <- args[4]
thr          <- if (length(args) >= 5) as.numeric(args[5]) else 1e-10

# Read files
input <- read.delim(in_path, header = FALSE, stringsAsFactors = FALSE)
module_info <- read.delim(mod_path, header = FALSE, stringsAsFactors = FALSE,
                          col.names = c("module", "gene"))

# Ensure numeric V12
if (!is.numeric(input$V12)) input$V12 <- suppressWarnings(as.numeric(input$V12))

# Filter, join, keep largest V12 per V2
result <- input %>%
  filter(V11 < thr) %>%
  left_join(module_info, by = c("V2" = "gene")) %>%
  group_by(V2) %>%
  slice_max(order_by = V12, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  relocate(module, .after = V2)

# Create counts data frame with file name column
module_counts <- result %>%
  count(module, name = "row_count") %>%
  mutate(file_name = basename(in_path)) %>%
  select(file_name, everything())

# Write outputs
write.table(result, file = out_path, sep = "\t", quote = FALSE,
            row.names = FALSE, col.names = FALSE)

write.table(module_counts, file = count_path, sep = "\t", quote = FALSE,
            row.names = FALSE, col.names = TRUE)

