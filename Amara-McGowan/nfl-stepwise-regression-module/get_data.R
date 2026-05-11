#install.packages("nflreadr")

library(nflreadr)
library(tidyverse)

qbr <- load_espn_qbr(2025, summary_type = "week") |>
  filter(season_type == "Regular") |>
  rename(player = name_display, qbr = qbr_total, week = game_week) |>
  select(player, qbr, week)

schedules <- load_schedules(2025) |>
  filter(game_type == "REG")

home_schedule <- schedules |>
  rename(team = home_team, opponent_team = away_team, rest = home_rest) |>
  mutate(pct_total = (home_score / total) * 100) |>
  select(week, team, opponent_team, rest, roof, surface, pct_total, result)

away_schedule <- schedules |>
  rename(team = away_team, opponent_team = home_team, rest = away_rest) |>
  mutate(pct_total = (away_score / total) * 100) |>
  select(week, team, opponent_team, rest, roof, surface, pct_total, result)

stats <- load_player_stats(2025, summary_level = "week") |>
  filter(position == "QB", season_type == "REG") |>
  rename(player = player_display_name) |>
  select(player, week, team, opponent_team, completions, attempts, passing_yards, 
         passing_tds, passing_interceptions, sacks_suffered, sack_yards_lost, sack_fumbles, 
         sack_fumbles_lost, passing_air_yards, passing_first_downs, passing_epa, passing_cpoe,
         pacr, carries, rushing_yards, rushing_tds, rushing_fumbles, rushing_fumbles_lost, 
         rushing_first_downs, rushing_epa)

joined_schedules <- home_schedule |>
  full_join(away_schedule)

nfl_qbr <- qbr |>
  left_join(stats, by = c("week", "player")) |>
  left_join(joined_schedules, by = c("week", "team", "opponent_team")) 

colSums(is.na(nfl_qbr))

# To address 42 missing rushing_epa values, I put in zeros

nfl_qbr <- nfl_qbr |> 
  mutate(rushing_epa = ifelse(is.na(rushing_epa), 0, rushing_epa)) |>
  select(-team, -opponent_team, -result, week, everything())

write_csv(nfl_qbr, "nfl_qbr.csv")

colnames(nfl_qbr)