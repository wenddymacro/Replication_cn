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
ok <- bjs_imputable(a,q$xt)
dd <- a[ok]
point <- bjs_point(dd,q$xt,q$ctrl)
stage <- as.formula(paste("~ 0 |",fe_terms(q$xt)))
cat("START did2s with",nrow(dd),"rows\n")
flush.console()
fit <- did2s::did2s(as.data.frame(dd),yname="y",first_stage=stage,second_stage=~i(D,ref=0),
                    treatment="D",cluster_var="cl",weights="w",verbose=FALSE)
fwrite(data.table(spec_id="T1_1",point=point,did2s=unname(coef(fit)[1]),
                  did2s_se=unname(fixest::se(fit)[1]),n=nrow(dd)),"output/T1_1_bjs_did2s_validation.csv")
