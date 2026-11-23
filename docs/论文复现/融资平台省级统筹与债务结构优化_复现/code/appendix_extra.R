Sys.setlocale("LC_CTYPE", ".UTF-8")
library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(2)
args <- commandArgs(TRUE)
set.seed(0L)
d <- as.data.table(read_dta("firm.dta"))
setnames(d,"上划year","policy")
setorder(d,id,year)
controls <- c("Size","Level","Roa","Turn","Liquidity","Quick","Cashratio","Age","Lngdp","Structure","Lnincome","Lnoutcome")
fit <- function(y,x,dt,vcov=~id){
  feols(as.formula(paste(y,"~",paste(c(x,controls),collapse=" + "),"| id + year")),
        data=dt,vcov=vcov,notes=FALSE,warn=FALSE)
}
if(args[1]=="A7"){
  d[, cohort:=if(any(Integ==1)) min(year[Integ==1]) else Inf,by=id]
  d[, rel:=pmax(-6,pmin(3,year-cohort))]
  d[!is.finite(cohort),rel:=NA_real_]
  d[, cell:=ifelse(is.na(rel) | rel==-1,"base",paste0("g",cohort,"e",rel))]
  f <- fit("Str",'i(cell, ref="base")',d,vcov="hetero")
  used <- d[obs(f)]
  v <- vcov(f)
  b <- coef(f)
  es <- rbindlist(lapply(setdiff(-6:3,-1),function(k){
    cnt <- used[rel==k,.N,by=cell]
    nm <- paste0("cell::",cnt$cell)
    keep <- nm %in% names(b)
    nm <- nm[keep]
    w <- cnt$N[keep]/sum(cnt$N[keep])
    data.table(event=k,coef=sum(w*b[nm]),se=sqrt(drop(crossprod(w,v[nm,nm,drop=FALSE]%*%w))),cohorts=length(nm),n=nobs(f))
  }))
  es[, author_plot_coef:=coef-mean(coef[event<0])]
  fwrite(es,"output/appendix_A7_sa.csv")
} else {
  mode <- args[1]
  treated <- d[!is.na(policy) & policy<2025]
  controls_data <- d[is.na(policy) | policy>2025]
  control_ids <- unique(controls_data$id)
  possible <- d[,.(year,eligible=seq_len(.N)>1),by=id][eligible==TRUE,.(year=list(year)),by=id]
  res <- rbindlist(lapply(seq_len(1000),function(j){
    if(mode=="A6"){
      x <- "Integ"
      sample_data <- rbind(controls_data[id %in% sample(control_ids,407)],treated)
    } else {
      x <- "placebo"
      sample_date <- possible[sample.int(nrow(possible),407)]
      sample_date[, date:=vapply(year,function(ys)ys[sample.int(length(ys),1)],numeric(1))]
      sample_data <- copy(d)
      sample_data[sample_date,date:=i.date,on="id"]
      sample_data[,placebo:=as.integer(!is.na(date)&year>=date)]
    }
    f <- fit("Str",x,sample_data)
    m <- coeftable(f)
    data.table(draw=j,coef=m[x,1],se=m[x,2],p=m[x,4])
  }))
  fwrite(res,paste0("output/appendix_",mode,"_draws_R.csv"))
}

