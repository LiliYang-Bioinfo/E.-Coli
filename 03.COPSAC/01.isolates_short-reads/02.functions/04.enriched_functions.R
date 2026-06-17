# Load necessary libraries
library(dplyr)
library(caret)
library(ggtree)
library(aricode)

# Function to calculate Fisher's exact test p-value
calculate_fisher <- function(true_labels, predicted_labels) {
  true_labels <- as.logical(true_labels)
  predicted_labels <- as.logical(predicted_labels)
  
  # Create a contingency table
  mat <- as.matrix(table(true_labels, predicted_labels))
  p_fisher <- NA
  p_direction <- NA
  
  # Check if the matrix is 2x2 and calculate Fisher's exact test
  if (all(dim(mat) == c(2, 2))) {
    if(mat['TRUE', 'TRUE'] > 10 && mat['FALSE', 'TRUE'] / sum(mat['FALSE',]) < 0.7){
    p_fisher <- fisher.test(mat)$p.value
    tmp1 <- mat[, 'TRUE'] / rowSums(mat)
    p_direction <- ifelse(tmp1['FALSE'] < tmp1['TRUE'], TRUE, FALSE)
    }
    } 
  return(list(p_fisher = p_fisher, p_direction = p_direction))
}

# Function to process Fisher's exact test for each module
process_fisher <- function(mod_use, meta_use) {
  # Sample 15 genomes from the top10 group and combine with the rest
  sampled_top10 <- meta_use %>% filter(top10 == TRUE) %>% group_by(hc1100) %>% sample_n(15, replace = TRUE)
  non_top10 <- meta_use %>% filter(top10 == FALSE)
  selected_meta <- bind_rows(sampled_top10, non_top10)
  mod_use_filtered <- mod_use[selected_meta$genome, ]
  
  # Initialize vectors for storing p-values and direction
  p_fisher <- numeric(ncol(mod_use_filtered))
  p_direction <- logical(ncol(mod_use_filtered))
  
  # Calculate Fisher's exact test p-value for each module
  for (i in seq_len(ncol(mod_use_filtered))) {
    predicted_labels <- mod_use_filtered[, i]
    res <- calculate_fisher(selected_meta$top10, predicted_labels)
    p_fisher[i] <- res$p_fisher
    p_direction[i] <- res$p_direction
  }
  
  # Create a data frame with module names, p-values, and direction
  fisher_res <- data.frame(module = colnames(mod_use_filtered), p_fisher = p_fisher, p_direction = p_direction)
  return(fisher_res)
}

# Filter meta data based on specific conditions
meta2 <- meta %>% filter(phylotype == "B2")
meta3 <- meta %>%
  filter(phylotype != "B2", hc1100 != 'CC_1', hc1100 != 'CC_68')

# Process Fisher's exact test for the filtered data
res_B2 <- process_fisher(mod_use, meta2)
res_NotB2 <- process_fisher(mod_use, meta3)
colnames(res_NotB2)[2:3] <- c('p_fisher_notB2', 'p_direction_notB2')

res_B2 <- res_B2 %>% filter(!(is.na(p_fisher)))
res_NotB2 <- res_NotB2 %>% filter(!(is.na(p_fisher_notB2)))
res_B2$p_adj <- p.adjust(res_B2$p_fisher, method='fdr')
res_NotB2$p_adj_notB2 <- p.adjust(res_NotB2$p_fisher_notB2, method='fdr')
res_B2 <- res_B2 %>% filter(p_adj<0.05)
res_NotB2 <- res_NotB2 %>% filter(p_adj_notB2<0.05)

# Combine and filter results
combined_results <- inner_join(res_B2, res_NotB2, by = "module") %>%
  filter(p_fisher < 0.05, p_fisher_notB2 < 0.05, p_direction == p_direction_notB2, p_direction==TRUE) %>%
  arrange(p_fisher)

# Select and order the modules for clustering
selected_modules <- mod_use[, combined_results$module]
hc_result <- hclust(dist(t(selected_modules)))
ordered_modules <- names(selected_modules)[hc_result$order]
selected_modules_ordered <- selected_modules[, ordered_modules]


#nmi_res <- sapply(selected_modules,function(x){NMI(meta$top10, x)})

# Visualize results with ggtree
gheatmap(pic_tree2, selected_modules_ordered, color = NA)

library(dendextend)
# Convert hclust to a dendrogram object
dend <- as.dendrogram(hc_result)
plot(dend, main = "Colored Hierarchical Clustering Dendrogram")
