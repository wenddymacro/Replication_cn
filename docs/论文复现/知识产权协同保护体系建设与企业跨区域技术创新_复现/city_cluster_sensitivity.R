library(data.table)
library(haven)
source("estimators.R")
setFixest_nthreads(2)
raw <- as.data.table(read_dta("data_3.dta"))
res <- rbindlist(lapply(c("Penalty","Percase","Win"),function(y) {
  fit <- feols(as.formula(paste(y,"~ protect + gdp + pop + ind | city_id + year")), raw, vcov = ~city_year, notes = FALSE)
  spec <- list(id_var="city_id",time_var="year",y_var=y,treat_var="protect",cluster_var="city_id",controls=c("gdp","pop","ind"))
  p <- prep_data(raw, spec)
  keep <- raw[obs(fit), .(city_id,year)]
  d <- p$d[paste(id,t) %in% paste(keep$city_id,match(keep$year,sort(unique(raw$year))))]
  stopifnot(nrow(d)==nobs(fit))
  y_sd <- standardize_y(d)
  ans <- compare_static(d,p$xt,p$ctrl,999)
  cbind(data.table(outcome=y,n=nrow(d),y_sd=y_sd),ans)
}))
fwrite(res,"output/city_cluster_sensitivity.csv")
