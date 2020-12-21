library(elastic)
library(magrittr)
library(tidyverse)

x <- connect(port = 9200)

dat <- read_csv("data/topics2020.csv") %>% 
  rename(doc_id = query)

get_source <- function(doc_id) {
  x <- docs_get(x, "wapo_demo",
                id = doc_id,
                source = c("title")) %>% 
    pluck("_source")
  
  x
}
get_source("1453752ad1fcb04af6655bf6103e373f")

stuff <- map(dat$doc_id, possibly(~ get_source(.), "missing_doc :("))

idx <- map_lgl(stuff, ~pluck(., "title") %>% is.null())
sum(idx)

stuff[idx] <- "missing_doc :(" # 889

s <- unlist(stuff)
map2_lgl(stuff, s, ~unname(unlist(.x)) == .y)

dat %>% 
  mutate(title = unlist(stuff),
         title_html = glue::glue("<a href='{url}' target='_blank'>{title}</a>")) %>% 
  saveRDS("data/topics2020.RDS")

