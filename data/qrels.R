library(tidyverse)

kv_decode <- c("0" = 0, "2" = 1, "4" = 2, "8" = 3, "16" = 4)

x <- read_tsv("../trec_eval/qrels.background",
         col_names = F) %>% 
  separate(X1, c("topic", "drop", "doc_id", "grade"), sep = " ") %>% 
  mutate(grade = kv_decode[grade]) %>% 
  select(-drop)

saveRDS(x, "data/qrels.RDS")

# exploratory -------------------------------------------------------------


table(x$grade)
  
x %>% 
  filter(grade != 0) %>% 
  ggplot(aes(grade)) +
  geom_histogram() +
  facet_wrap(~topic)
