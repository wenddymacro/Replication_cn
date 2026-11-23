Sys.setlocale("LC_CTYPE",".UTF-8")
library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(1)
j <- as.integer(commandArgs(TRUE)[1])
z <- readRDS("prepared.rds")
full <- as.data.table(read_dta("firm.dta", col_select=tidyselect::all_of(c("id","year","Integ","上划year"))))
setnames(full,"上划year","recorded")
audit <- full[,{
  vals <- unique(recorded[!is.na(recorded) & recorded>0 & recorded<2025])
  first <- if(any(Integ==1)) as.numeric(min(year[Integ==1])) else Inf
  official <- if(length(vals)==1 && all(Integ==as.integer(year>=vals[1]))) as.numeric(vals[1]) else first
  .(g_official=official)
},by=id]
modern <- function(i){
  s <- z$queue[[i]]
  dd <- copy(z$samples[[i]])
  dd[audit,g0:=i.g_official,on="id"]
  dd[, actual:=get(s$x)]
  if (s$x!="Integ") dd[,g0:=if(any(actual==1)) g0 else Inf,by=id]
  # Use full-firm timing only where it reproduces the published treatment indicator.
  check <- dd[,.(consistent=uniqueN(g0)==1L && !anyNA(g0) && all(as.integer(year>=g0)==actual),
                  reversal=any(diff(actual[order(year)])<0)),by=id]
  mism <- sum(!check$consistent)
  rev <- sum(check$reversal)
  cat(s$loc,"mismatch_units",mism,"reversal_units",rev,"\n")
  if(rev>0 || mism>0) return(invisible(NULL))
  spec <- list(id_var="id",time_var="year",y_var=s$y,gvar="g0",controls=s$cc,cluster_var="id")
  q <- prep_data(dd,spec)
  a <- q$d
  st <- design_stats(a)
  support <- a[,.(pre=any(D==0),post=any(D==1)),by=g][is.finite(g)&pre&post,.N]
  if(support<2) return(invisible(NULL))
  ysd <- standardize_y(a)
  r <- compare_static(a,q$xt,q$ctrl,999)
  al <- a[bjs_imputable(a,q$xt)]
  tw <- twfe_static(al,q$xt,q$ctrl)
  fwrite(cbind(data.table(spec_id=s$loc,n=st$n,units=st$n_units,cohorts=st$n_cohorts,supported_cohorts=support,y_sd=ysd,aligned_n=nrow(al),twfe_aligned=tw$est),r),paste0("output/",s$loc,".csv"))
  if (is_rc(a)) {
    aux <- as.data.frame(did_ids(a)[,row_id:=.I])
    set.seed(20261109)
    att <- did::att_gt(yname="y",tname="t",idname="row_id",gname="g0",xformla=reformulate(s$cc),data=aux,panel=FALSE,clustervars="cl_num",control_group="notyettreated",est_method="reg",bstrap=TRUE,biters=999,cband=FALSE)
    ag <- did::aggte(att,type="simple",na.rm=TRUE,bstrap=TRUE,biters=999,cband=FALSE)
    fwrite(data.table(spec_id=s$loc,csa=ag$overall.att,csa_se=ag$overall.se),paste0("output/rc_",s$loc,".csv"))
  }
}
for(i in seq(j,length(z$queue),by=4)){
  tryCatch(modern(i),error=function(e)cat("ERROR",z$queue[[i]]$loc,conditionMessage(e),"\n"))
}
