# Simulated staggered-adoption panel for testing the pipeline (data/example/sim_panel.csv).
# 300 firms in 60 cities, 2008-2020; cities adopt a pilot policy in three batches (2011, 2014, 2017) or never.
# Effects grow with time since adoption and are larger for early cohorts, so static TWFE is biased by
# forbidden comparisons (early adopters used as controls for late adopters).
library(data.table)
set.seed(42)
cities <- data.table(city = 1:60, province = rep(1:12, each = 5),
                     pilot_year = sample(c(2011, 2014, 2017, NA), 60, replace = TRUE, prob = c(.25, .25, .25, .25)))
firms <- data.table(firm = 1:300, city = sample(1:60, 300, replace = TRUE), a = rnorm(300))
d <- CJ(firm = 1:300, year = 2008:2020)[firms, on = "firm"][cities, on = "city", nomatch = 0]
d[, did := as.integer(!is.na(pilot_year) & year >= pilot_year)]
d[, e := ifelse(did == 1, year - pilot_year, NA)]
slope <- c(`2011` = 0.30, `2014` = 0.10, `2017` = -0.05)
d[, tau := ifelse(did == 1, slope[as.character(pilot_year)] * (e + 1), 0)]
d[, lnrd := 1 + a + 0.05 * (year - 2008) + 0.02 * province * (year - 2008) / 12 + tau + rnorm(.N, sd = 0.5)]
d[, size := rnorm(.N, 5 + 0.1 * (year - 2008))]
# unbalanced: drop 5% of firm-years at random
d <- d[runif(.N) > 0.05]
d[, c("a", "e", "tau") := NULL]
dir.create("data/example", showWarnings = FALSE, recursive = TRUE)
fwrite(d[order(firm, year)], "data/example/sim_panel.csv")
cat("wrote data/example/sim_panel.csv:", nrow(d), "rows\n")
