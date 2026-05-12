library(tidyverse)
library(MASS)
library(quantreg)

nfl_qbr <- read_csv("nfl_qbr.csv") 

predictors <- c(
  "completions", "attempts", "passing_yards", "passing_tds", "passing_interceptions",
  "sacks_suffered", "sack_yards_lost", "sack_fumbles", "sack_fumbles_lost", 
  "passing_air_yards", "passing_first_downs", "passing_epa", "passing_cpoe",
  "pacr", "carries", "rushing_yards", "rushing_tds", 
  "rushing_fumbles", "rushing_fumbles_lost", "rushing_first_downs", "rushing_epa",
  "rest", "roof", "surface", "pct_total")

full_mod <- lm(qbr ~ ., data = nfl_qbr[, c("qbr", predictors)])
step_mod <- stepAIC(full_mod, direction = "both")
summary(step_mod)

quantiles <- c(0.1, 0.25, 0.50, 0.75, 0.90)
qr_models <- map(quantiles, ~ rq(qbr ~ passing_yards + passing_tds + passing_interceptions + 
                                   sack_yards_lost + passing_air_yards + passing_epa + passing_cpoe + 
                                   rushing_first_downs + rushing_epa + surface + pct_total + 
                                   sack_fumbles, tau = .x, data = nfl_qbr))

qr_pinball <- function(model, data, response, tau) {
  y <- data[[response]]
  y_hat <- predict(model, newdata = data)
  
  idx <- !is.na(y) & !is.na(y_hat)
  y <- y[idx]
  y_hat <- y_hat[idx]
  
  mean(pinLoss(y, y_hat, qu = tau, add = TRUE))}

qr_pinball_table <- map_dfr(seq_along(qr_models), ~ {
  tibble(
    quantile = quantiles[.x],
    pinball_loss = qr_pinball(qr_models[[.x]], nfl_qbr, "qbr", quantiles[.x]))})

ggplot(qr_pinball_table, aes(x = factor(quantile), y = pinball_loss)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Quantile Regression Pinball Loss",
    x = "Quantile",
    y = "Pinball Loss") +
  theme_minimal()