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
a[, pattern:=sum(2^(t-1)),by=id]
a[, bjs_ok:=ok]
compact <- a[,.(y=mean(y),w=.N,g=g[1],xt_prov=xt_prov[1],xt_prov_son=xt_prov_son[1],
                 bjs_ok=all(bjs_ok)),by=.(t,D,pattern,cl)]
compact[,id:=.GRP,by=.(cl,pattern)]
stopifnot(all(compact$w>=1),sum(compact$w)==nrow(a),sum(compact[bjs_ok==TRUE,w])==sum(ok))
bench <- function(d,valid){
  c(twfe=twfe_static(d,q$xt,q$ctrl)$est,bjs=bjs_point(d[valid],q$xt,q$ctrl))
}
base <- bench(a,ok)
reduced <- bench(compact,compact$bjs_ok)
print(rbind(base,reduced,diff=base-reduced),digits=14)
cat("COMPRESSED",nrow(compact),"from",nrow(a),"\n")
print(rbind(base,reduced))
keys <- unique(a$cl)
tw <- match(a$cl,keys)
cw <- match(compact$cl,keys)
w0 <- compact$w
set.seed(123367)
mult <- rexp(length(keys))
a[,w:=mult[tw]]
compact[,w:=w0*mult[cw]]
check <- max(abs(bench(a,ok)-bench(compact,compact$bjs_ok)))
print(c(weighted_check=check),digits=14)
rm(a)
gc()
draw <- function(){
  compact[,w:=w0*rexp(length(keys))[cw]]
  c(twfe=coef(feols(y~D|id+t^xt_prov+t^xt_prov_son,compact,weights=~w,notes=FALSE))[[1]],
    bjs=bjs_point(compact[bjs_ok==TRUE],q$xt,q$ctrl))
}
set.seed(20261123)
start <- proc.time()[[3]]
draws <- replicate(5,draw())
sec <- proc.time()[[3]]-start
cat("BOOT_SECONDS_PER_DRAW",sec/5,"\n")
fwrite(data.table(compressed_rows=nrow(compact),check_error=check,seconds_per_draw=sec/5),
       "output/boot_benchmark.csv")
if(max(abs(base-reduced),check)<1e-7){compact[,w:=w0];saveRDS(compact,"output/bootstrap_main_input.rds")}


