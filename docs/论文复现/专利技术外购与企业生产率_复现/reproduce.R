library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(3)
d <- as.data.table(read_dta("input.dta"))
print(grep("ind|first|buy.*own",names(d),value=TRUE))
print(d[1:5, .(firm_id,year,indyear)])
ctrl <- c("ownership","firmsize","firmage","capex_labor","lnPatent_before85","perGDP_growth","lnCityPatent85","lnHtechfirm","lnHzone")
all <- "DID_buyall_own"
dom <- "DID_buydom_own"
foreign <- "DID_buyfor_own"
fit <- function(col,y,x,dd) {
  f <- feols(as.formula(paste(y,"~",paste(c(x,ctrl),collapse="+"),"| firm_id + indyear")),dd,vcov=~firm_id)
  ct <- coeftable(f)
  data.table(column=col, outcome=y, treatment=x, coef=ct[x,1],se=ct[x,2],n=nobs(f))
}
m <- copy(d)
m[is.na(DID_buydom_own) & !is.na(DID_buyfor_own),DID_buydom_own:=0]
m[is.na(DID_buyfor_own) & !is.na(DID_buydom_own),DID_buyfor_own:=0]
fwrite(rbindlist(list(fit(1,"tfp_acf",all,d),fit(2,"tfp_acf",dom,d),fit(3,"tfp_acf",foreign,d),fit(4,"tfp_acf",c(dom,foreign),m))),"output/table1.csv")
fwrite(rbindlist(lapply(c("RD_expense","RD_labor"), function(y) fit(if(y=="RD_expense") 1 else 3,y,all,d))),"output/table2_single.csv")
for(x in c(all,dom,foreign)){
  a <- d[!is.na(get(x)),.(start=if(any(get(x)==1)) min(year[get(x)==1]) else Inf, reversal=any(diff(get(x)[order(year)])<0)),by=firm_id]
  print(a[,.N,by=start][order(start)])
  print(a[,sum(reversal)])
}
