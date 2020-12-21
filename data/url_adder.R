library(elastic)
library(magrittr)
library(tidyverse)

x <- connect(port = 9200)

qrels2 <- readRDS("data/qrels2.RDS")

get_source <- function(doc_id) {
  x <- docs_get(x, "wapo_demo",
           id = doc_id,
           source = c("title")) %>% 
    pluck("_source")
  
  x
}
get_source("1453752ad1fcb04af6655bf6103e373f")

stuff <- map(qrels2$doc_id, possibly(~ get_source(.), "missing_doc :("))

idx <- map_lgl(stuff, ~pluck(., "title") %>% is.null())
sum(idx)

stuff[idx] <- "missing_doc :("

# see stuff[651] for a NULL title

               
s <- unlist(stuff)

map2_lgl(stuff, s, ~unname(unlist(.x)) == .y)

qrels2$title <- unlist(stuff)

qrels2 %<>% 
  mutate(title_html = glue::glue("<a href='{url}' target='_blank'>{title}</a>"))

saveRDS(qrels2, "data/qrels2.RDS")
