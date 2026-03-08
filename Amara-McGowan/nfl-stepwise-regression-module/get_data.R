# install.packages("nflreadr")

library(nflreadr)
library(tidyverse)

qbr <- load_espn_qbr(2025, summary_type = "week")
schedules <- load_schedules(2025)
stats <- load_player_stats(2025, summary_level = "week") 

clean_stats <- stats |>
  filter(position == "QB", season_type == "REG") |>
  rename(player = player_display_name, sacks = sacks_suffered, fumbles = sack_fumbles) |>
  select(player, week, team, opponent_team, completions, attempts, passing_yards,
         passing_tds, passing_interceptions, sacks, fumbles) 

clean_qbr <- qbr |>
  filter(season_type == "Regular") |>
  rename(player = name_display, qbr = qbr_total, week = game_week) |>
  select(week, player, qbr)

clean_schedules <- schedules |>
  filter(game_type == "REG") |>
  rename(team = home_team, opponent_team = away_team, opp_score = away_score) |>
  select(week, team, opponent_team, opp_score, home_score, result, total) |>
  mutate(prop_total = home_score / total)

nfl_stats <- clean_stats |>
  left_join(clean_qbr, by = c("week", "player"))

# TODO: Have to add in the clean schedules data, but still have to rep every team
# Regular Regression (just for me) "Quantile Regression - Median" (for the module)