# Trump Tweet Sentiment Analysis

This project analyzes the sentiment of Donald Trump's tweets using natural language processing (NLP) techniques in R.

It includes:

- Cleaning and preprocessing tweet text
- Sentiment scoring using BING and AFINN lexicons
- Daily sentiment score visualization
- Positive/negative word clouds
- Interactive Shiny dashboard for date-based exploration
- A reproducible HTML report via RMarkdown

## Files

- main.R: Script for complete sentiment analysis and visualization
- TrumpTweet.Rmd: RMarkdown report file, knit to HTML
- app.R: Shiny dashboard app to explore tweets interactively
- trump_tweets.csv: Source dataset containing Trump???s tweets

## Installation

Install required packages in R:

install.packages(c("tidyverse", "tidytext", "ggplot2", "wordcloud", "textdata", "tm", "shiny"))

## Usage

To run the dashboard locally:

shiny::runApp("app.R")

To generate the report:

1. Open TrumpTweet.Rmd in RStudio
2. Click Knit to HTML

## Acknowledgment

This project was created with guidance from OpenAI's ChatGPT during the learning process. All code was written, applied, and understood by the author as part of hands-on NLP practice.

## License

MIT
