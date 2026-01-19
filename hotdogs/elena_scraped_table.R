Scraping the table from Wikipedia


install.packages("rvest")
library(rvest)
install.packages("dplyr")
library(dplyr)

url <- "https://en.wikipedia.org/wiki/Nathan%27s_Hot_Dog_Eating_Contest"

page <- read_html(url)


tables <- page |> html_table(fill = TRUE)

length(tables)

head(tables[[3]])

hotdog_table <- tables[[3]]

names(hotdog_table)

