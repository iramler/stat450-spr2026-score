library(tidyverse)
library(MASS)
library(quantreg)

# https://www.pro-football-reference.com/about/glossary.htm#ay/a

# (Adjusted Net Yards Per Attempt (ANY/A))

nfl_qbr <- read_csv("nfl_qbr.csv") |>
  mutate(comp_rate = (completions / attempts) * 100)

# Testing step wise regression
predictors <- c("comp_rate", "fumbles", "pct_total", "result",
                "passing_yards", "passing_tds", "passing_interceptions", "sack_yards", 
                "attempts", "sacks")
full_mod <- lm(qbr ~ ., data = nfl_qbr[, c("qbr", predictors)])
step_mod <- stepAIC(full_mod, direction = "both")
summary(step_mod)


# Testing with less things deleted
predictors <- c("qb_plays", "comp_rate", "attempts", "passing_yards", "passing_tds", "passing_interceptions",
"sacks", "sack_yards", "fumbles", "sack_fumbles_lost", "passing_air_yards", "passing_yards_after_catch",
"passing_first_downs", "carries", "rushing_yards", 
"rushing_tds", "rushing_fumbles", "rushing_fumbles_lost", "rushing_first_downs", "rushing_epa", 
"receptions", "targets", "receiving_yards", "receiving_tds", "receiving_fumbles", "pct_total", "result")
full_mod2 <- lm(qbr ~ ., data = nfl_qbr[, c("qbr", predictors)])
step_mod2 <- stepAIC(full_mod, direction = "both")
summary(step_mod) 

# Testing quantile regression
quantiles <- c(0.1, 0.25, 0.50, 0.75, 0.90)
qr_models <- map(quantiles, ~ rq(qbr ~ comp_rate + fumbles + pct_total + passing_yards + 
                                   passing_tds + passing_interceptions + sack_yards + attempts, tau = .x, data = nfl_qbr))
map(qr_models, summary)


qr_rsq <- function(model) {
  rho <- function(u, tau) tau * u * (u >= 0) + (tau - 1) * u * (u < 0)
  y <- model$model$qbr
  ss_res <- sum(rho(y - fitted(model), model$tau))
  ss_tot <- sum(rho(y - median(y), model$tau))
  1 - ss_res/ss_tot}
pseudo_r2 <- map_dfr(qr_models, ~ data.frame(tau = .x$tau, r2 = qr_rsq(.x)), 
                     .id = "model")

print(pseudo_r2) 

ggplot(pseudo_r2, aes(x = factor(tau), y = r2)) +
  geom_col(width = 0.5, fill = "darkgreen") +
  labs(
    x = "Tau",
    y = "Pseudo R^2",
    title = "Pseudo R^2 by Quantile") +
  theme_minimal(base_family = "Garamond") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 12, family = "Garamond"),
    axis.text.x = element_text(size = 10, family = "Garamond"),
    axis.text.y = element_text(size = 10, family = "Garamond"),
    axis.title.x = element_text(size = 12, family = "Garamond"),
    axis.title.y = element_text(size = 12, family = "Garamond"))

# Most accurate for top 10% of QB ratings, okay for lower scores but tough to predict middle
# Maybe middle is more inconsistent