library(readr)
library(dplyr)

# Filter the (sample, module) combos you care about
keep_pairs <- read_tsv("01.sample_module_count", show_col_types = FALSE) %>%
  filter(ratio > 0.5) %>%
  distinct(sample, module)

# Read m8 (no header), keep needed cols, and keep only matched pairs
m8_use2 <- read_tsv(
  "00.all_filtered.m8",
  col_names = c("sample", "query", "target", "module"),
  show_col_types = FALSE
) %>%
  select(sample, query, target, module) %>%
  semi_join(keep_pairs, by = c("sample", "module"))

write_tsv(m8_use2, "m8.filtered_by_modules.tsv")
