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
source("csa_rank.R")
r <- did_ids(a)
set.seed(20261109)
at <- did::att_gt(yname="y",tname="t",idname="id_num",gname="g0",data=as.data.frame(r),
    xformla=~factor(xt_prov)+factor(xt_prov_son),panel=TRUE,allow_unbalanced_panel=TRUE,
    control_group="notyettreated",clustervars=c("id_num","cl_num"),est_method=support_reg_did,
    bstrap=TRUE,biters=999,cband=FALSE)
cells <- data.table(g=at$group,t=at$t,att=at$att,se=at$se)
fwrite(cells,"output/rank_csa_T1_1_cells.csv")
ag <- did::aggte(at,type="simple",na.rm=TRUE,bstrap=TRUE,biters=999,cband=FALSE)
fwrite(data.table(spec_id="T1_1",csa=ag$overall.att,csa_se=ag$overall.se,
    post_cells=sum(cells$t>=cells$g),supported=sum(cells$t>=cells$g&is.finite(cells$att))),
    "output/rank_csa_T1_1.csv")
