library(tidyverse)
library(MASS)

# https://www.pro-football-reference.com/about/glossary.htm#ay/a

nfl_qbr <- read_csv("nfl_qbr.csv") |>
  mutate(comp_rate = completions / attempts,
         anypa = (passing_yards + (20 * passing_tds) - (45 * passing_interceptions) - sack_yards) /
           (attempts + sacks),
         qbr_pred = -13.5  + 11.23 * anypa)

# Testing pre-established formula attempt from online
cor(nfl_qbr$qbr, nfl_qbr$qbr_pred)^2 # 45.09%


# Testing Step wise
predictors <- c("anypa", "comp_rate", "fumbles", "prop_total", "result",
                "passing_yards", "passing_tds", "passing_interceptions", "sack_yards", 
                "attempts", "sacks", "completions")
full_mod <- lm(qbr ~ ., data = nfl_qbr[, c("qbr", predictors)])
step_mod <- stepAIC(full_mod, direction = "both")

summary(step_mod) # 61.81% without completions, 62.15% with it & comp_rate