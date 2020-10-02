library(tidyverse)
library(tidytext)
library(ggplot2)
library(tm)
library(stringr)
library(igraph)
library(ggraph)
library(widyr)

# read in csv file as tibble/data frame
scrape.data <- read.csv(file='gboro_patch.csv', stringsAsFactors=FALSE)

# make tibble/data.frame
scrape.data <- as_tibble(scrape.data)

# removes carrige returns and new lines from text
scrape.data$text <- gsub("\r?\n|\r", " ", scrape.data$text)
# removes punctuation
scrape.data$text <- gsub("[[:punct:]]", "", scrape.data$text)
# forces entire corpus to lowercase
scrape.data$text <- tolower(scrape.data$text)
#removes numbers from text
scrape.data$text <- removeNumbers(scrape.data$text)
# remove stop words
scrape.data$text <- removeWords(scrape.data$text, stopwords("SMART"))
# remove additional words
other.words <- c("pm","greensboro", "city", "release", "press", "pieces", "happening", "moment", "loading", "expressed", "views", "authors", "produced", "post", "information", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")
scrape.data$text <- removeWords(scrape.data$text, other.words)

# removes additional remaining whitespace
scrape.data$text <- stripWhitespace(scrape.data$text)

# transform table into one-word-per-line tidytext format
clean.data <- scrape.data %>%
  unnest_tokens(word, text)

# most frequent words across corpus
clean.data <- clean.data %>%
  count(word, sort = TRUE)

# preprocessing for tf-idf Chapter 3.1
url.words <- scrape.data %>%
    unnest_tokens(word, text) %>%
    count(url, word, sort = TRUE)

total.words <- url.words %>%
    group_by(url) %>%
    summarize(total = sum(n))

url.words <- left_join(url.words, total.words)

# tf-idf from Chapter 3.3
url.words <- url.words %>%
  bind_tf_idf(word, url, n)

url.words <- url.words %>%
  select(-total) %>%
  arrange(desc(tf_idf))

# compare tf-idf to gross frequency
unique(url.words$word[1:30])
clean.data$word[1:30]

# chapter 4.1 bigrams
url.bigrams <- scrape.data %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

url.bigrams %>%
    count(bigram, sort = TRUE)

##########################################################
# Skip 4.1.1 and move to tf-idf example in 4.1.2
##########################################################

bigrams.separated <- url.bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigram.tf.idf <- url.bigrams %>%
    count(url, bigram) %>%
    bind_tf_idf(bigram, url, n) %>%
    arrange(desc(tf_idf))

# explore
clean.data$word[1:30]
unique(url.words$word[1:30])
bigram.tf.idf$bigram[1:30]

#############################################
# visualize bigram relationships
# chapter 4.1.5
#############################################
count_bigrams <- function(dataset) {
  dataset %>%
    unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
    separate(bigram, c("word1", "word2"), sep = " ") %>%
    filter(!word1 %in% stop_words$word,
           !word2 %in% stop_words$word) %>%
    count(word1, word2, sort = TRUE)
}

visualize_bigrams <- function(bigrams) {
  set.seed(2016)
  a <- grid::arrow(type = "closed", length = unit(.15, "inches"))

  bigrams %>%
    graph_from_data_frame() %>%
    ggraph(layout = "fr") +
    geom_edge_link(aes(edge_alpha = n), show.legend = FALSE, arrow = a) +
    geom_node_point(color = "lightblue", size = 5) +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_void()
}

viz.bigrams <- scrape.data %>%
  count_bigrams()

# filter out rare combinations, as well as digits and produce graph
viz.bigrams %>%
  filter(n > 9,
         !str_detect(word1, "\\d"),
         !str_detect(word2, "\\d")) %>%
  visualize_bigrams()


###############################
# From Chapter 4.2.2
# word correlations
###############################

# count words co-occuring within urls
clean.data2 <- scrape.data %>%
  unnest_tokens(word, text)

word_cors <- clean.data2 %>%
  group_by(word) %>%
  filter(n() >= 20) %>%
  pairwise_cor(word, url, sort = TRUE)

# explore top word correlations
word_cors

# explore specific word correlations
# try a couple different words for fun
word_cors %>%
  filter(item1 == "covid")

# produce graph comparing 4 words of importance to their most correlated words
word_cors %>%
  filter(item1 %in% c("covid", "parks", "council", "police")) %>%
  group_by(item1) %>%
  top_n(6) %>%
  ungroup() %>%
  mutate(item2 = reorder(item2, correlation)) %>%
  ggplot(aes(item2, correlation)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ item1, scales = "free") +
  coord_flip()

# create a graph showing relationship clusters using pairwise correlation scores
set.seed(2016)

word_cors %>%
  # you may need to change .50 to something lower or higher, depending on the top correlating scores
  filter(correlation > .50) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = correlation), show.legend = FALSE) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), repel = TRUE) +
  theme_void()
