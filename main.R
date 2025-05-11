# ???? Paketleri y??kle
install.packages("tidyverse")
install.packages("tidytext")
install.packages("ggplot2")
install.packages("wordcloud")
install.packages("textdata")
install.packages("tm")

# ???? K??t??phaneleri ??a????r
library(tidyverse)
library(tidytext)
library(ggplot2)
library(wordcloud)
library(textdata)
library(tm)
library(stringr)

# ???? Veriyi oku
tweets <- read.csv("trump_tweets.csv")
tweets$date <- as.Date(tweets$date) # tarih kolonunu d??zenle

# Row ID ekle (her tweet'e bir ID veriyoruz)
tweets <- tweets %>%
  mutate(row_id = row_number())

# Ayn?? row_id'yi kelimelere da????tmak i??in clean_tweets'e de ekle
clean_tweets <- tweets %>%
  select(row_id, text) %>%
  mutate(
    text = str_to_lower(text),
    text = str_replace_all(text, "http\\S+", ""),
    text = str_replace_all(text, "@\\w+", ""),
    text = str_replace_all(text, "[^a-z\\s]", ""),
    text = stripWhitespace(text)
  )

# Tokenize ve stop words ????kar
data("stop_words")
tweet_words <- clean_tweets %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

# Row_id ile kelime e??le??mesi yap??lm???? oldu. ??imdi duygu analizi:
bing_lexicon <- get_sentiments("bing")

tweet_sentiment <- tweet_words %>%
  inner_join(bing_lexicon, by = "word") %>%
  left_join(tweets %>% select(row_id, date), by = "row_id")

# ???? G??nl??k duygu skoru hesapla
daily_sentiment <- tweet_sentiment %>%
  count(date, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(sentiment_score = positive - negative) %>%
  filter(!is.na(date), is.finite(sentiment_score))

# ???? Grafikle
ggplot(daily_sentiment, aes(x = date, y = sentiment_score)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray") +
  labs(
    title = "Trump Tweetlerinde G??nl??k Duygu Skoru",
    x = "Tarih",
    y = "Duygu Skoru (Pozitif - Negatif)"
  ) +
  theme_minimal()

# ?????? Kelime Bulutu
top_sentiment_words <- tweet_sentiment %>%
  count(word, sentiment, sort = TRUE)

# Genel wordcloud
wordcloud(
  words = top_sentiment_words$word,
  freq = top_sentiment_words$n,
  min.freq = 5,
  max.words = 100,
  random.order = FALSE,
  colors = c("darkgreen", "red")
)

# Pozitif ve negatif ayr?? ayr??
positive_words <- subset(top_sentiment_words, sentiment == "positive")
negative_words <- subset(top_sentiment_words, sentiment == "negative")

wordcloud(
  words = positive_words$word,
  freq = positive_words$n,
  min.freq = 3,
  max.words = 100,
  colors = "darkgreen"
)

wordcloud(
  words = negative_words$word,
  freq = negative_words$n,
  min.freq = 3,
  max.words = 100,
  colors = "red",
  scale = c(3, 0.5),
  random.order = FALSE,
  rot.per = 0  # d??nd??rme yok, daha iyi yerle??im
)


