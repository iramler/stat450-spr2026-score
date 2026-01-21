#Scraping the table from Wikipedia

install.packages("rvest")
library(rvest)
install.packages("dplyr")
library(dplyr)
library(here)

url <- "https://en.wikipedia.org/wiki/Nathan%27s_Hot_Dog_Eating_Contest"

page <- read_html(url)

tables <- page |> html_table(fill = TRUE)

length(tables)

head(tables[[3]])

hotdog_table <- tables[[3]]

names(hotdog_table)

#---------------------------
# Cleaning table 
hotdog_table_clean <- hotdog_table %>%
  select(`Year`, `Winner(and date, if prior to permanently moving all contests to Independence Day in 1997)`,
         `Hot dogs and buns(HDB)`, `Contest duration`) |>
  rename(
    year = `Year`,
    winner = `Winner(and date, if prior to permanently moving all contests to Independence Day in 1997)`,
    dogs = `Hot dogs and buns(HDB)`,
    time = `Contest duration`)


write.csv(hotdog_table_clean, "table.csv", row.names = FALSE) # this one worked

clean_hotdog <- read.csv("hotdogs/hotdog_clean.csv") # relative path


