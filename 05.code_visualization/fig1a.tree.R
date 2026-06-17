library(ape)
library(ggtree)
library(ggplot2)

tree_repre <- read.tree("tree.nwk")
tree_meta_use <- read.delim("fig1a.tab", stringsAsFactors = FALSE)

# Make sure metadata labels match tree tip labels
rownames(tree_meta_use) <- tree_meta_use$Newick_label

p3 <- ggtree(tree_repre, layout = "circular") %<+% tree_meta_use +
  geom_tippoint(aes(size = Freq, color = phylotype)) +
  theme(legend.position = "right")

# Select heatmap columns
tmp1 <- tree_meta_use[, 8:10]
rownames(tmp1) <- tree_meta_use$Newick_label

p4 <- gheatmap(
  p3,
  tmp1,
  color = NA,
  offset = 0.2
) +
  scale_fill_gradient(
    low = "grey95",
    high = "royalblue",
    na.value = "white"
  )

p4