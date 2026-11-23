library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(3)
v <- c("id","city_son","citycp","prov","prov_son","year","ydcom_add1","did3","treat3","ntreat")
d <- as.data.table(read_dta("data1.dta", col_select=tidyselect::all_of(v)))
d <- d[treat3==1|ntreat==1]
d[, panel:=.GRP,by=.(id,city_son)]
h <- d[,.(g0=if(any(did3==1)) min(year[did3==1]) else Inf),by=citycp]
d[h,g0:=i.g0,on="citycp"]
stopifnot(all(d$did3==as.integer(d$year>=d$g0)),!anyDuplicated(d,by=c("panel","year")))
q <- prep_data(d,list(id_var="panel",time_var="year",y_var="ydcom_add1",gvar="g0",cluster_var="citycp",xt_vars=c("prov","prov_son")))
rm(d,h)
gc()
a <- q$d
ysd <- standardize_y(a)
cat("CSA_INPUT",nrow(a),uniqueN(a$id),uniqueN(a$cl),ysd,"\n")
flush.console()
r <- csa_did(a,q$xt,q$ctrl,B=999)
fwrite(data.table(spec_id="T1_1",csa=r$est,csa_se=r$se,n=nrow(a),note=r$note),"output/project_csa_T1_1.csv")
print(r$agg)
