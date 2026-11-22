library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(3)
d <- as.data.table(read_dta("input.dta"))
ctrl <- c("ownership","firmsize","firmage","capex_labor","lnPatent_before85","perGDP_growth","lnCityPatent85","lnHtechfirm","lnHzone")
one <- "DID_buyall_own"
two <- c("DID_buydom_own","DID_buyfor_own")
m <- copy(d)
m[is.na(DID_buydom_own) & !is.na(DID_buyfor_own),DID_buydom_own:=0]
m[is.na(DID_buyfor_own) & !is.na(DID_buydom_own),DID_buyfor_own:=0]
estimate <- function(y,x,dd) feols(as.formula(paste(y,"~",paste(c(x,ctrl),collapse="+"),"| firm_id + indyear")),dd,vcov=~firm_id)
extract <- function(f,i,y,x) {
  ct <- coeftable(f)
  data.table(column=i,outcome=y,treatment=x,coef=ct[x,1],se=ct[x,2],n=nobs(f))
}
t2 <- rbindlist(lapply(1:4,function(j) {
  dd <- copy(if(j<=2) d else m)
  x <- if(j<=2) one else two
  y <- if(j%%2==1) "RD_expense" else "RD_labor"
  first <- estimate(y,x,dd)
  b <- coef(first)
  dd[, fitted_xb:=as.numeric(as.matrix(.SD) %*% b),.SDcols=names(b)]
  second <- estimate("tfp_acf","fitted_xb",dd)
  rbind(extract(first,2*j-1,y,x),extract(second,2*j,"tfp_acf","fitted_xb"))
}))
fwrite(t2,"output/table2.csv")
suffixes <- list(c("all_process","all_product"),c("dom_process","for_process","dom_product","for_product"),c("all_sameind","all_unsameind"),c("dom_sameind","for_sameind","dom_unsameind","for_unsameind"))
fwrite(rbindlist(lapply(seq_along(suffixes),function(j) {
  x <- paste0("DID_buy",suffixes[[j]])
  extract(estimate("tfp_acf",x,d),j,"tfp_acf",x)
})),"output/table3.csv")
outcomes <- c("sale","tax_ratio","subsidy_ratio","export_value","domestic_sale")
fwrite(rbindlist(lapply(seq_along(outcomes),function(j) {
  y <- outcomes[j]
  extract(estimate(y,two,if(j>=4) m[year<2017] else m),j,y,two)
})),"output/table4.csv")
