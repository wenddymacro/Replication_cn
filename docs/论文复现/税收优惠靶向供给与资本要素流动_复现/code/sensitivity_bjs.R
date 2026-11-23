library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(3)
ctrl <- c("size","lev","roa","perr","dual","bigstock","lrgdp2014t","third2014t","loan2014t")
vars <- c("idcitycp","citycp","prov","prov_son","year","ydcom_add1","treat3","ntreat","did3","deep",ctrl)
d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(vars)))
d <- d[treat3==1|ntreat==1]
dates <- d[,.(g0=if(any(did3==1))min(year[did3==1])else Inf),by=citycp]
h <- fread("event_dates_by_citypair_3.csv")[compatible==TRUE]
dates[h,g0:=i.g_event,on="citycp"]
d[dates,g0:=i.g0,on="citycp"]
d <- d[deep==0]
f <- feols(as.formula(paste("ydcom_add1 ~ did3 +",paste(ctrl,collapse="+"),"| idcitycp+year^prov+year^prov_son")),d,notes=FALSE)
d <- d[obs(f)]
stopifnot(nrow(d)==337376L,all(d$did3==as.integer(d$year>=d$g0)))
q <- prep_data(d,list(id_var="idcitycp",time_var="year",y_var="ydcom_add1",gvar="g0",controls=ctrl,
                      cluster_var="citycp",xt_vars=c("prov","prov_son")))
standardize_y(q$d)
cat("START conventional BJS inference","\n")
flush.console()
r <- bjs_static(q$d,q$xt,q$ctrl)
fwrite(as.data.table(r),"output/T4_1_bjs_did2s.csv")
print(r)
