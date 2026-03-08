library(readr)
library(tidyverse)
hotdog_clean <- read_csv("hotdogs/hotdog_clean.csv")
View(hotdog_clean)
hotdog_men <- hotdog_clean |> filter(Sex == 1)
hotdog_women <- hotdog_clean |> filter(Sex == 0)

hotdog_men |> 
  mutate("Dogs/Minute" = Dogs/Time)

hotdog_women |> 
  mutate("Dogs/Minute" = Dogs/Time)

Data Summary:
  
  1. Why might it be difficult to compare earlier winners to most recent winners? 
  
  2. Create a standard variable to compare winners across time by dividing the hotdog variable by the time variable to get "Hotdogs_per_minute".

3. Create a histogram of the Amount of Hotdogs consumed per minute by year.

4. What do you notice about the amount of hotdogs consumed per minute in 2001? 
  
  5. Who was the winner in 2001?