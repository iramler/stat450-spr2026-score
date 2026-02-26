# install.packages("remotes")
# remotes::install_github("jthomasmock/espnscrapeR")

library(espnscrapeR)

seasons <- 2004:2025
all_qbr <- map_df(seasons, ~espnscrapeR::get_college_qbr(season = .x))
