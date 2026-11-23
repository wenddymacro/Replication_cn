Sys.setlocale("LC_CTYPE", ".UTF-8")
library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(2)
z <- readRDS("prepared.rds")
bond <- copy(z$samples[[14]])
cat("Bond source columns",names(read_dta("bond.dta",n_max=0)),"\n")
firm <- as.data.table(read_dta("firm.dta", col_select=tidyselect::all_of(c("id","year","Integ","上划year"))))
setnames(firm,"上划year","recorded")
history <- firm[, {
  dates <- unique(recorded[!is.na(recorded) & recorded>0 & recorded<2025])
  first <- if(any(Integ==1)) min(year[Integ==1]) else Inf
  .(g0=if(length(dates)==1 && all(Integ==as.integer(year>=dates))) dates[1] else first)
}, by=id]
bond[history, firm_g:=i.g0,on="id"]
cat("Bond rows",nrow(bond),"firms",uniqueN(bond$id),"excess rows per firm-year",nrow(bond)-uniqueN(bond,by=c("id","year")),"\n")
print(bond[,.(firm_source=any(!is.na(firm_g)),treated=any(Integ==1),
              contradict=any(Integ!=as.integer(year>=firm_g),na.rm=TRUE)),by=id][,.N,by=.(firm_source,treated,contradict)])
d <- copy(z$samples[[3]])
d[history,g0:=i.g0,on="id"]
s <- z$queue[[3]]
q <- prep_data(d,list(id_var="id",time_var="year",y_var=s$y,gvar="g0",controls=s$cc,cluster_var="id"))
ysd <- standardize_y(q$d)
es <- list(pre_min=-6,post_max=3,ref=-1,ends="bin")
event <- compare_event(q$d,q$xt,q$ctrl,es)
fwrite(cbind(data.table(y_sd=ysd),event$res),"output/modern_A5.csv")
