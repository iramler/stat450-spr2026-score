install.packages("nflreadr")

library(nflreadr)

nfl_qbr <- load_espn_qbr(summary_type = "week")
# Connect w/ names + teams + week, before adding qbr

schedules <- load_schedules(2025)
# important for game scores

player_stats <- load_player_stats(2025)
# This has the stats (like comp) per week per player