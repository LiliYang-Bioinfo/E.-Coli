library(ggtree)
library(ape)
tree_tips <- data.frame(in_tree=tree_SNP$tip.label)
tree_tips$original <- gsub('_len500.*', '', tree_tips$in_tree)
sel_tips <- unique(c(fec$sample, head(tree_tips$in_tree,2)))
meta_CC <- meta2 %>% select(new_label, hc1100) %>% filter(new_label %in% sel_tips)
meta_CC <- left_join(meta_CC, tree_tips, by =join_by(new_label==original))
mob_use <- mob_info %>% select(sample, contig, circled_contig, circled_genome, MGE_type) 
mob_use <- mob_use %>% filter(contig %in% fec$contig)
meta_CC <- left_join(meta_CC, mob_use, by =join_by(new_label==sample)) %>% unique()
sel_tips <- tree_tips$in_tree[tree_tips$original %in% sel_tips]
tree_keep <- keep.tip(tree_SNP, sel_tips)

top10 <- c("#BC80BD", "#80B1D3", "#BEBADA", "#FFED6F", "#8DD3C7",
"#FB8072", "#B3DE69", "#CCEBC5", "#FDB462", "#FCCDE5", "#A0A0A0")
names(top10) <- c(names(tail(sort(table(meta2$hc1100)),10)), 'Other')
meta_CC$top10 <- ifelse(meta_CC$hc1100 %in% names(top10), meta_CC$hc1100, 'Other')

tmp1 <- split(meta_CC$in_tree, meta_CC$top10)
pic_tmp <- ggtree(tree_keep)+geom_tiplab(size=2)
color_tree <- groupOTU(pic_tmp, tmp1, 'Top10') + aes(color=Top10) +
  scale_color_manual(values = top10)
tmp1 <- meta_CC %>% select(circled_contig, MGE_type)
rownames(tmp1) <- meta_CC$in_tree
pic_tree <- gheatmap(color_tree, tmp1)

tip_order <- pic_tmp$data$label[order(pic_tmp$data$y[pic_tmp$data$isTip], decreasing = TRUE)]
tmp1 <- tree_tips$original
names(tmp1) <- tree_tips$in_tree
use_order <- tmp1[tip_order]
fec_final$sample <- factor(fec_final$sample, levels=rev(use_order))
pic_fec <- ggplot(fec_final, aes(x=cds_ord, y=sample))+
  geom_point(aes(color=color_type), size=2.5)+
  scale_color_manual(values = my_colors, na.value = "grey50")+
  theme_cowplot()
plot_grid(pic_tree, pic_fec, nrow=1, rel_widths = c(1,2.5))
