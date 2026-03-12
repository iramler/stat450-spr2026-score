library(tidyverse)
library(MASS)

nfl_qbr <- read_csv("nfl_qbr.csv") |>
  mutate(comp_rate = completions / attempts,
         passing_rate = passing_yards / attempts)

predictors <- c("comp_rate", "attempts", "passing_rate", "passing_tds",
                "passing_interceptions", "sacks", "fumbles", "prop_total", "result")

full_mod <- lm(qbr ~ ., data = nfl_qbr[, c("qbr", predictors)])

step_mod <- stepAIC(full_mod, direction = "both")

summary(step_mod)