library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(4)
controls <- c("size","age","lev","invt","roa","fixed","cash","RD","big4","HHI","gdp","pop","ind","gdp2","pop2","ind2")
outcomes <- c("lnsubs","density","lnsubs_density","cost1","cost2","cost3")
cols <- c(outcomes, controls, "protect","id","year","hy","city_id","city_year")
d <- as.data.table(read_dta("data/data.dta", col_select=tidyselect::all_of(cols)))
fwrite(d[, .(rows=.N, years=uniqueN(year), pairs=uniqueN(id), duplicate_keys=.N-uniqueN(.SD)), .SDcols=c("id","year")], "output/pair_keys.csv")
r <- rbindlist(lapply(outcomes,function(y) {
  fit <- feols(as.formula(paste(y,"~",paste(c("protect",controls),collapse="+"),"| id + year + hy + city_id")),d,vcov=~city_year)
  s <- d[obs(fit)]
  changing <- s[, .(hy_switch=uniqueN(hy)>1L, city_switch=uniqueN(city_id)>1L), by=id]
  ct <- coeftable(fit)
  data.table(outcome=y,coef=ct["protect",1],se=ct["protect",2],n=nobs(fit),pairs_changing_industry=sum(changing$hy_switch),pairs_changing_city=sum(changing$city_switch))
}))
fwrite(r,"output/table2_pairs.csv")
