library(qrels)

subs <- dir("../submission/", "txt", full.names = T) %>% 
  map_df(~ read_table(., col_names = F)) %>% 
  separate(X3, c("doc_id", "rank", "score", "run"), sep = " ") %>% 
  mutate(run = gsub(".*_", "", run))

qrels <- readRDS("data/qrels2.RDS") %>% 
  mutate(topic = as.numeric(topic))

subs %>% 
  select(rank, topic = X1, doc_id, run) %>% 
  left_join(qrels) %>% 
  saveRDS("data/submissions.RDS")


