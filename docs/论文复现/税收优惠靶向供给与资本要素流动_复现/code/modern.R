library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(3)
args <- commandArgs(TRUE)
mode <- args[1]
main <- c("T1_1","T1_4","T2_1","T2_3")
secondary <- c("T1_2","T1_3","T2_2","T2_4",paste0("T4_",1:6),paste0("T6_",c(1,3,5)),paste0("T8_",1:4))
m <- fread("models.csv")[spec %chin% c(main,secondary)]
if(mode=="small"){
  m <- m[data==2]
  d <- as.data.table(read_dta("data2.dta"))
} else {
  m <- m[data==1]
  required <- unique(unlist(lapply(seq_len(nrow(m)),function(i){
    s <- m[i]
    c(all.vars(as.formula(paste(s$y,"~",s$rhs,"|",s$fixed))),s$cluster,all.vars(parse(text=s$subset)))
  })))
  d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(unique(c(required,"idcitycp","id","city_son")))))
  d[, unit:=.GRP,by=.(id,city_son)]
  pairing <- unique(d[,.(idcitycp,unit,citycp,prov,prov_son,id)])
  print(pairing[,.(n_unique_panel=uniqueN(idcitycp),n_unique_fe=uniqueN(unit),n_combinations=.N,
      n_varying_origin_prov=pairing[,uniqueN(prov),by=unit][V1>1,.N],
      n_varying_citypair=pairing[,uniqueN(citycp),by=unit][V1>1,.N])])
  d[, panel:=unit]
  if(mode=="pilot")m <- m[spec=="T1_1"]
  if(mode=="large")m <- m[spec!="T1_1"]
}
if(mode=="small")d[,panel:=id]
for(i in seq_len(nrow(m))){
  s <- m[i]
  tryCatch({
    treatment <- strsplit(s$target," ",fixed=TRUE)[[1]][1]
    controls <- setdiff(all.vars(as.formula(paste("~",s$rhs))),treatment)
    formula <- as.formula(paste(s$y,"~",s$rhs,"|",s$fixed))
    selection <- if(nzchar(s$subset)) which(d[,eval(parse(text=s$subset))]) else seq_len(nrow(d))
    keep <- unique(c(all.vars(formula),s$cluster,"panel"))
    sampled <- d[selection,..keep]
    fw <- feols(formula,sampled,vcov=reformulate(s$cluster),notes=FALSE,warn=FALSE,
                ssc=ssc(K.fixef="nonnested",G.adj=TRUE))
    dd <- sampled[obs(fw)]
    rm(sampled,fw)
    xt <- if(s$data==2) character() else if(s$spec=="T1_4")c("id","prov_son") else c("prov","prov_son")
    if(s$data==1){
      timing <- d[selection,.(cl=citycp,year,actual=get(treatment))]
      timing <- timing[,.(d_min=min(actual),d_max=max(actual)),by=.(cl,year)]
      if(any(timing$d_min!=timing$d_max))stop("Different treatment statuses inside city-pair/year")
      timing <- timing[,.(g0=if(any(d_min==1)) min(year[d_min==1]) else Inf),by=cl]
      dd[timing,g0:=i.g0,on=.(citycp=cl)]
    } else {
      timing <- d[,.(g0=if(any(did==1))min(year[did==1]) else Inf),by=id]
      dd[timing,g0:=i.g0,on="id"]
    }
    stopifnot(all(as.integer(dd$year>=dd$g0)==dd[[treatment]]))
    if(anyDuplicated(dd,by=c("panel","year"))>0L) stop("Repeated unit-year rows in author sample")
    for(v in c(xt,s$cluster)){
      unstable <- dd[,uniqueN(get(v)),by=panel][V1!=1L,.N]
      if(unstable) stop(sprintf("Time-varying %s in %d observational units",v,unstable))
    }
    spec <- list(id_var="panel",time_var="year",y_var=s$y,gvar="g0",xt_vars=xt,
                 controls=controls,cluster_var=s$cluster)
    q <- prep_data(dd,spec)
    rm(dd)
    a <- q$d
    st <- design_stats(a)
    ct <- a[,.(both=any(D==0) && any(D==1)),by=.(id,g)]
    support <- ct[is.finite(g) & both,uniqueN(g)]
    stopifnot(support>=2,st$n==nrow(a))
    ysd <- standardize_y(a)
    tw <- twfe_static(a,q$xt,q$ctrl)
    neg <- twfe_negweights(a,q$xt,q$ctrl)
    lev <- leverage(twfe_influence(a,q$xt,q$ctrl),a$cl)
    eligible <- bjs_imputable(a,q$xt)
    aligned <- twfe_static(a[eligible],q$xt,q$ctrl)
    r <- data.table(spec_id=s$spec,n=st$n,units=st$n_units,clusters=st$n_clusters,
                    cohorts=st$n_cohorts,supported_cohorts=support,y_sd=ysd,
                    twfe=tw$est,twfe_se=tw$se,twfe_raw=tw$est*ysd,
                    twfe_bjs_aligned=aligned$est,bjs_aligned_n=sum(eligible),
                    neg_rows=neg$neg_rows,neg_abs=neg$neg_abs,
                    G_eff_twfe=lev$G_eff,L_max_twfe=lev$L_max)
    out <- paste0("output/modern_",s$spec,".csv")
    fwrite(r,out)
    cat("BASE",s$spec,nrow(a),length(unique(a$cl)),support,"\n")
    flush.console()
    if(mode=="small"){
      result <- compare_static(a,q$xt,q$ctrl,999)
      for(v in setdiff(names(result),names(r)))r[,(v):=result[[v]]]
    } else {
      # For the large panel, save imputation point estimates before the modern inference steps.
      r[,bjs:=bjs_point(a[eligible],q$xt,q$ctrl)]
      r[,bjs_note:=paste0("nonimputable_rows=",sum(!eligible))]
      fwrite(r,out)
      cat("POINT",s$spec,r$bjs,"\n")
      flush.console()
      if(mode=="pilot"){
        r[,csa_note:="did not yet run"]
        fwrite(r,out)
      }
    }
    fwrite(r,out)
  },error=function(e)cat("FAILED",s$spec,conditionMessage(e),"\n"))
  gc()
}
