tmp1 <- input_1m %>% select(ABCNO, HC1100) %>% rename(abcno=ABCNO)
#tmp1 <- input_1y %>% select(abcno, HC1100) 
tmp1$top <- tmp1$HC1100 %in% top10
tmp1_1 <- tmp1 %>% filter(top) %>% select(abcno)
tmp1_2 <- as.integer(unique(tmp1$abcno))
tmp1 <- data.frame(abcno=tmp1_2, top_presence=tmp1_2 %in% tmp1_1$abcno)

sel_meta_add <- left_join(sel_meta, add_data[,-3])
sel_meta_add <- left_join(sel_meta_add, breast_use[,c(3, 6:13)])
sel_meta_add$delivery <- sel_meta_add$delivery=='Normal'
#use1 <- left_join(use1, meta_exposure)
use1 <- left_join(tmp1, sel_meta_add)

dy_df <- data.frame(Var = character(), p_value = numeric(), method=character())

vars <- colnames(use1)
for (j in 3:38) {
  formula <- reformulate(vars[j], response = "top_presence")
  lm_result <- glm(formula, family = binomial, data = use1)
  lm_p <- anova(lm_result, test='Chisq')$`Pr(>Chi)`[2]
  dy_df <- rbind(dy_df, data.frame(
    Var = vars[j],
    p_value = lm_p, 
    method='glm'
  ))
}

