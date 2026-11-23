library(data.table)
library(jsonlite)
source("estimators.R")
setFixest_nthreads(2)
z <- readRDS("prepared.rds")
d <- copy(z$samples[[14]])
stopifnot(d[,all(uniqueN(Integ)==1),by=.(id,year)][,all(V1)])
h <- d[,.(g0=if(any(Integ==1)) min(year[Integ==1]) else Inf,
          reversal=any(diff(Integ[order(year)])<0)),by=id]
print(h[, .N, by=.(g0,reversal)][order(g0)])
stopifnot(!any(h$reversal))
d[h,g0:=i.g0,on="id"]
s <- z$queue[[14]]
q <- prep_data(d,list(id_var="id",time_var="year",y_var=s$y,gvar="g0",controls=s$cc,cluster_var="id"))
ysd <- standardize_y(q$d)
tw <- twfe_static(q$d,q$xt,q$ctrl)
bj <- bjs_static(q$d,q$xt,q$ctrl)
a <- q$d[bjs_imputable(q$d,q$xt)]
al <- twfe_static(a,q$xt,q$ctrl)
aux <- as.data.frame(did_ids(q$d)[,row_id:=.I])
set.seed(20261109)
att <- did::att_gt(yname="y",tname="t",idname="row_id",gname="g0",xformla=reformulate(s$cc),data=aux,panel=FALSE,clustervars="cl_num",control_group="notyettreated",est_method="reg",bstrap=TRUE,biters=999,cband=FALSE)
ag <- did::aggte(att,type="simple",na.rm=TRUE,bstrap=TRUE,biters=999,cband=FALSE)
fwrite(data.table(n=nrow(q$d),units=uniqueN(q$d$id),cohorts=uniqueN(h[is.finite(g0),g0]),y_sd=ysd,twfe=tw$est,twfe_se=tw$se,csa=ag$overall.att,csa_se=ag$overall.se,bjs=bj$est,bjs_se=bj$se,aligned_n=nrow(a),twfe_aligned=al$est,bjs_note=bj$note),"output/bond_sensitivity.csv")
