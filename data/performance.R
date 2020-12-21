library(tidyverse)

us <- dir("trec2020newstrackbackgroundlinkingresults/", "trec_eval", full.names = T) %>% 
  set_names(gsub(".*results\\//(.*)\\..*", "\\1", .)) %>% 
  map_df(~read_tsv(., col_names = F), .id = "run") %>% 
  filter(!is.na(X2)) %>% # overall stats
  filter(X1 == "ndcg_cut_5") %>% 
  select(-X1) %>% 
  mutate(X3 = as.numeric(X3),
         run = gsub("tune_ners_embed", "mlt_tune_ners_sbert", run)) %>% 
  rename(
    topic = X2,
    val = X3
  ) %>% 
  mutate(run = gsub("mlt_", "", run) %>% 
           factor(levels = c("base", "tune", "ners", "embed")))

saveRDS(us, "run_explorer/data/osc_run_explorer_data.RDS")


us %>% 
  group_by(run) %>% 
  summarise(y = mean(val),
            lbl = round(y, 3)) -> lbls

ggplot(us, aes(run, val, color = run)) +
  ggbeeswarm::geom_quasirandom(size = 4, alpha = .5, width = .15) +
  stat_summary(geom = "crossbar", fun.data = mean_cl_normal, show.legend = F) +
  geom_label(data = lbls, aes(y = lbl, label = lbl), size = 5, show.legend = F) +
  scale_color_brewer(palette = "Dark2", name = NULL) +
  theme(axis.text.x = element_blank()) +
  labs(y = "nDCG@5")


