#install.packages("nflreadr")

library(nflreadr)
library(tidyverse)

qbr <- load_espn_qbr(2025, summary_type = "week")
schedules <- load_schedules(2025)
stats <- load_player_stats(2025, summary_level = "week") 

clean_stats <- stats |>
  filter(position == "QB", season_type == "REG") |>
  rename(player = player_display_name, sacks = sacks_suffered, fumbles = sack_fumbles,
         sack_yards = sack_yards_lost) |>
  dplyr::select(-headshot_url)
  select(player, week, team, opponent_team, completions, attempts, passing_yards,
         passing_tds, passing_interceptions, sacks, sack_yards, fumbles) 

clean_qbr <- qbr |>
  filter(season_type == "Regular") |>
  rename(player = name_display, qbr = qbr_total, week = game_week) 

clean_qbr <- clean_qbr |>
  dplyr::select(week, player, qbr, qb_plays)

clean_schedules <- schedules |>
  filter(game_type == "REG") |>
  rename(team = home_team) |>
  dplyr::select(week, team, away_team, away_score, home_score, result, total) |>
  mutate(pct_total = (home_score / total) * 100)

home_teams <- clean_schedules |>
  dplyr::select(week, team, pct_total, result)

away_teams <- clean_schedules |>
  dplyr::select(week, away_team, home_score, away_score, total) |>
  mutate(pct_total = (away_score / total) * 100, result = away_score - home_score) |>
  rename(team = away_team) |>
  dplyr::select(week, team, pct_total, result)

team_stats <- bind_rows(home_teams, away_teams)

nfl_qbr <- clean_qbr |>
  left_join(clean_stats, by = c("week", "player")) |>
  left_join(team_stats, by = c("week", "team"))

write_csv(nfl_qbr, "nfl_qbr.csv")

# Notes: 
# - nfl_qbr has no missing values. 
# - clean_stats has 81 unique QBs, but clean_qbr only reports QBR for 65 of them,
#   so the final nfl_qbr dataset contains 65 players with player stats and qbr data.