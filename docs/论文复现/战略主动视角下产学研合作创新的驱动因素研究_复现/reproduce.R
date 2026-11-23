library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(3)
d <- as.data.table(read_dta("input.dta"))
vars <- c("tshock3","list","listyear","stkcd","year","province","ind")
d[, geo_ind:=interaction(province,ind,drop=TRUE)]
print(d[, .(rows=.N,units=uniqueN(stkcd),duplicates=.N-uniqueN(.SD)),.SDcols=c("stkcd","year")])
print(d[list==1, .(first=min(listyear,na.rm=TRUE)),by=stkcd][,.N,by=first][order(first)])
print(d[order(year), .(reversal=any(diff(tshock3)<0,na.rm=TRUE)),by=stkcd][,sum(reversal)])
print(d[,sum(tshock3!=as.integer(list==1 & year>=listyear),na.rm=TRUE)])
ctl <- "Size:year + BM:year + ROA + TobinQ + Growth + AssetGrowth"
rows <- list(c("1","rinsitinum","1","year+geo_ind"),c("1","rinsitinum",ctl,"year+geo_ind"),c("1","rinsitinum",ctl,"year+geo_ind+stkcd"))
ys <- list(c("rinsitinum","runi","rres","rinsitinum_inv","rinsitinum_use","rinsitinum_design"),c("supply_mane_number","other_number","totalnumber","supply_mane_ratio","other_ratio","totalratio"),c("amount_gov","tax","iddum"),c("FixedAssetGrowth","TotalProfitGrowth","OperatingProfitGrowth","RevenueGrowth","NetProfit","TotalProfit"))
for(i in seq_along(ys))for(y in ys[[i]])rows[[length(rows)+1L]]<-c(as.character(i+1),y,ctl,"year+geo_ind+stkcd")
count <- integer(5)
fit <- function(s) {
  i <- as.integer(s[1]);count[i]<<-count[i]+1L
  f <- feols(as.formula(paste(s[2],"~ tshock3 +",s[3],"|",s[4])),d,vcov=~stkcd)
  x <- d[obs(f)]
  ct <- coeftable(f)
  data.table(table=i,column=count[i],outcome=s[2],coef=ct["tshock3",1],se=ct["tshock3",2],n=nobs(f),adj_r2=fitstat(f,"ar2")[[1]],firms_changing_geo_ind=x[,uniqueN(geo_ind),by=stkcd][V1>1,.N])
}
fwrite(rbindlist(lapply(rows,fit)),"output/body.csv")
e <- copy(d)
e[, event:=pmax(-4,pmin(4,year-listyear))]
e[list!=1,event:=NA_real_]
levels <- setdiff(-4:4,-1)
names <- paste0("ev",seq_along(levels))
for(j in seq_along(levels))e[,(names[j]):=as.integer(!is.na(event)&event==levels[j])]
f <- feols(as.formula(paste("rinsitinum ~",paste(names,collapse="+"),"+",ctl,"|year+geo_ind+stkcd")),e,vcov=~stkcd)
ct <- coeftable(f)
fwrite(data.table(event=levels,coef=ct[names,1],se=ct[names,2],n=nobs(f)),"output/figure1.csv")
