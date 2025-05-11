# app.R

library(shiny)
library(tidyverse)
library(tidytext)
library(ggplot2)
library(textdata)
library(stringr)
library(tm)

# Load data
tweets <- read.csv("trump_tweets.csv")
tweets$date <- as.Date(tweets$date)
tweets <- tweets %>% mutate(row_id = row_number())

# Clean text
clean_tweets <- tweets %>%
  select(row_id, text) %>%
  mutate(
    text = str_to_lower(text),
    text = str_replace_all(text, "http\\S+|@\\w+|[^a-z\\s]", ""),
    text = stripWhitespace(text)
  )

# Tokenize and remove stop words
data("stop_words")
tweet_words <- clean_tweets %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

# Sentiment tagging
bing <- tweet_words %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  left_join(tweets %>% select(row_id, date), by = "row_id")

afinn <- tweet_words %>%
  inner_join(get_sentiments("afinn"), by = "word") %>%
  left_join(tweets %>% select(row_id, date), by = "row_id")

# ==== UI ====
ui <- fluidPage(
  titlePanel("Trump Tweet Sentiment Dashboard"),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Select a date",
                value = min(tweets$date),
                min = min(tweets$date),
                max = max(tweets$date))
    ),
    mainPanel(
      h4("BING Sentiment Score"),
      plotOutput("bingPlot"),
      h4("AFINN Sentiment Score"),
      plotOutput("afinnPlot")
    )
  )
)

# ==== SERVER ====
server <- function(input, output) {
  
  output$bingPlot <- renderPlot({
    df <- bing %>%
      filter(date == input$date) %>%
      count(sentiment)
    
    if (nrow(df) == 0) {
      ggplot(data.frame(x = 1, y = 1), aes(x = x, y = y)) +
        geom_text(label = "No data for this date", size = 6) +
        theme_void()
    }
    else {
      ggplot(df, aes(x = sentiment, y = n, fill = sentiment)) +
        geom_col() +
        labs(title = paste("BING Score -", input$date),
             y = "Word Count", x = "") +
        theme_minimal()
    }
  })
  
  output$afinnPlot <- renderPlot({
    df <- afinn %>%
      filter(date == input$date) %>%
      summarise(score = sum(value, na.rm = TRUE))
    
    if (nrow(df) == 0) {
      ggplot(data.frame(x = 1, y = 1), aes(x = x, y = y)) +
        geom_text(label = "No data for this date", size = 6) +
        theme_void()
    }
    else {
      ggplot(df, aes(x = input$date, y = score)) +
        geom_col(fill = "purple") +
        labs(title = paste("AFINN Score -", input$date),
             y = "Total Score", x = "") +
        theme_minimal()
    }
  })
}

# ==== RUN APP ====
shinyApp(ui = ui, server = server)
