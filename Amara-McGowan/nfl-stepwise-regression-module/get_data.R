# install.packages("nflreadr")

library(nflreadr)
library(tidyverse)

nfl_qbr <- load_espn_qbr(summary_type = "week")
schedules <- load_schedules(2025)
player_stats <- load_player_stats(2025) 

clean_stats <- player_stats |>
  filter(position == "QB") |>
  select(player_display_name, season, week, team, opponent_team, completions,
         attempts, passing_yards, passing_tds, passing_interceptions, sacks_suffered,
         sack_fumbles) |>
  rename(player_name = player_display_name, sacks = sacks_suffered, fumbles = sack_fumbles)

clean_qbr <- nfl_qbr |>
  select(season, game_week, name_display, qbr_total) |>
  rename(player_name = name_display, qbr = qbr_total, week = game_week)

clean_schedules <- schedules |>
  select(season, week, home_team, away_team, result) |>
  rename(opponent_team = away_team, team = home_team)

qbr <- clean_stats |>
  left_join(clean_qbr, by = c("season", "week", "player_name")) |>
  left_join(clean_schedules, by = c("season", "week", "team", "opponent_team"))
  
View(qbr)  