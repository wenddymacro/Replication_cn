library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(4)
models <- fread("models.csv")
which_data <- as.integer(commandArgs(TRUE)[1])
models <- models[data==which_data]
variables <- unique(unlist(lapply(seq_len(nrow(models)),function(i){
  s <- models[i]
  formula <- as.formula(paste(s$y,"~",s$rhs,"|",s$fixed))
  c(all.vars(formula),s$cluster,if(nzchar(s$subset))all.vars(parse(text=s$subset)))
})))
variables <- unique(c(variables,if(which_data==1)c("idcitycp","id","city_son","did1","did2","did3","treat1","treat2","treat3","ntreat") else "did"))
d <- as.data.table(read_dta(paste0("data",which_data,".dta"),col_select=tidyselect::all_of(variables)))
cat("LOADED",nrow(d),ncol(d),"\n")
model_rows <- vector("list",nrow(models))
for (i in seq_len(nrow(models))){
  s <- models[i]
  tryCatch({
    formula <- as.formula(paste(s$y,"~",s$rhs,"|",s$fixed))
    selection <- if(nzchar(s$subset)) which(d[,eval(parse(text=s$subset))]) else seq_len(nrow(d))
    required <- unique(c(all.vars(formula),s$cluster))
    sample <- d[selection, ..required]
    f <- feols(formula,sample,vcov=reformulate(s$cluster),notes=FALSE,warn=FALSE,
               ssc=ssc(K.fixef="nonnested",G.adj=TRUE))
    metrics <- fitstat(f,c("r2","ar2"))
    co <- coeftable(f)
    targets <- strsplit(s$target," ",fixed=TRUE)[[1]]
    r <- data.table(spec_id=s$spec,outcome=s$y,term=targets,
                    coef=NA_real_,se=NA_real_,p=NA_real_,n=nobs(f),r2=metrics$r2,ar2=metrics$ar2,
                    clusters=uniqueN(sample[[s$cluster]][obs(f)]),df_t=degrees_freedom(f,"t"))
    present <- intersect(targets,rownames(co))
    r[term %in% present,c("coef","se","p"):=list(co[term,1],co[term,2],co[term,4])]
    fwrite(r,paste0("output/",s$spec,".csv"))
    cat("FINISHED",s$spec,nobs(f),r$coef[1],r$se[1],"\n")
    rm(sample,f)
  },error=function(e)cat("FAILED",s$spec,conditionMessage(e),"\n"))
  if(i%%4==0) gc()
}
if(which_data==2){
  h <- d[,.(g0=if(any(did==1)) min(year[did==1]) else Inf,
             reversal=any(diff(did[order(year)])<0),duplicate_year=anyDuplicated(year)>0),by=id]
  fwrite(h[, .N, by=.(g0,reversal,duplicate_year)][order(g0)],"output/data2_treatment_audit.csv")
  d[h,g0:=i.g0,on="id"]
  saveRDS(d,"output/panel2.rds")
} else {
  for (k in 1:3){
    var <- paste0("did",k)
    subset <- d[get(paste0("treat",k))==1 | ntreat==1, .(idcitycp,citycp,year,D=get(var))]
    by_city <- subset[,.(differing=uniqueN(D)>1L,ds=min(D)),by=.(citycp,year)]
    a <- by_city[order(year),.(g=if(any(ds==1)) min(year[ds==1]) else Inf,
      reversal=any(diff(ds)<0), pre=any(ds==0), conflict=any(differing)),by=citycp]
    fwrite(a[, .N, by=.(g,reversal,pre,conflict)][order(g)],paste0("output/data1_treatment_",k,".csv"))
  }
}
