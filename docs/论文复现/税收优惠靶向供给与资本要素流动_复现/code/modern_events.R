library(haven)
library(data.table)
source("estimators.R")
source("inference_large.R")
setFixest_nthreads(3)
HAS_DID2S <- FALSE
models <- fread("models.csv")[startsWith(spec,"F3_")]
terms <- unique(unlist(strsplit(models$target," ")))
ctrl <- c("size","lev","roa","perr","dual","bigstock","lrgdp2014t","third2014t","loan2014t")
v <- c("idcitycp","citycp","prov","prov_son","year","ydcom_add1","ntreat",
       paste0("did",1:3),paste0("treat",1:3),ctrl,terms)
d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(v)))
for(i in seq_len(nrow(models))){
  tryCatch({
    m <- models[i]
    k <- c(3,1,2)[i]
    vars <- strsplit(m$target," ")[[1]]
    vv <- c("idcitycp","citycp","prov","prov_son","year","ydcom_add1",ctrl,vars,paste0("did",k))
    a <- d[which(d[,eval(parse(text=m$subset))]),..vv]
    dd <- paste0("did",k)
    dates <- a[,.(g0=if(any(get(dd)==1))min(year[get(dd)==1])else Inf),by=citycp]
    h <- fread(paste0("event_dates_by_citypair_",k,".csv"))[compatible==TRUE]
    dates[h,g0:=i.g_event,on="citycp"]
    a[dates,g0:=i.g0,on="citycp"]
    stopifnot(all(a[[dd]]==as.integer(a$year>=a$g0)))
    q <- prep_data(a,list(id_var="idcitycp",time_var="year",y_var="ydcom_add1",gvar="g0",cluster_var="citycp",
                          controls=ctrl,xt_vars=c("prov","prov_son")))
    t <- q$d
    ysd <- standardize_y(t)
    a[,unit:=idcitycp]
    tw <- feols(as.formula(paste("ydcom_add1 ~",m$rhs,"| unit+year^prov+year^prov_son")),
                  a,vcov=~citycp,notes=FALSE)
    stopifnot(nobs(tw)==nrow(t))
    levels <- as.integer(tstrsplit(vars,"_",fixed=TRUE)[[2]])*ifelse(startsWith(vars,"pre"),-1,1)
    p <- rbindlist(lapply(c("pre","post"),function(w){
      use <- if(w=="pre")which(levels< -1)else which(levels>=0)
      keep <- intersect(vars[use],names(coef(tw)))
      av <- lincomb(coef(tw),vcov(tw),setNames(rep(1/length(keep),length(keep)),keep))
      data.table(window=w,twfe=av$est/ysd,twfe_se=av$se/ysd)
    }))
    S <- list(pre=c(-4,-3,-2),post=0:3)
    t[,ebin:=ifelse(is.finite(g),pmax(-4,pmin(3,t-g)),NEVER)]
    derived <- vapply(seq_along(vars),function(j){
      if(levels[j]==-1)return(NA_integer_)
      sum(as.integer(t$ebin==levels[j])!=a[[vars[j]]])
    },integer(1))
    fwrite(data.table(term=vars,different_rows=derived),paste0("output/event_bin_audit_",i,".csv"))
    eligible <- bjs_imputable(t,q$xt)
    b <- bjs_event(t,q$xt,q$ctrl,S)
    # did2s uses a large sparse regression; the project helper returns a missing SE if it fails.
    p[, `:=`(bjs=c(b$pre$est,b$post$est),bjs_se=c(b$pre$se,b$post$se),bjs_note=b$note)]
    fwrite(p,paste0("output/modern_event_",i,".csv"))
    event_inference <- tryCatch(infer_bjs(t,q$xt,q$ctrl,eligible,event_bins="ebin"),
      error=function(e){p[window=="post",bjs_note:=paste(bjs_note,conditionMessage(e))];NULL})
    if(!is.null(event_inference)){
      stopifnot(abs(event_inference$estimate-b$post$est)<1e-7)
      p[window=="post",bjs_se:=event_inference$bjs_se]
    }
    o <- paired_csa(t,ctrl,event=TRUE)
    if(!is.null(o)){
      setnames(o$average,c("estimate","se","bins_used"),c("csa_overlap","csa_overlap_se","csa_bins_used"))
      p <- merge(p,o$average,by="window",all.x=TRUE)
      fwrite(o$point,paste0("output/event_overlap_bins_",i,".csv"))
    }
    p[, `:=`(spec_id=m$spec,n=nrow(t),y_sd=ysd,bjs_aligned_n=sum(eligible))]
    fwrite(p,paste0("output/modern_event_",i,".csv"))
    cat("FINISHED",m$spec,"\n")
  },error=function(e)cat("FAILED",models$spec[i],conditionMessage(e),"\n"))
  gc()
}


