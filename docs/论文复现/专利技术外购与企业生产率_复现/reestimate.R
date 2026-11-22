library(haven)
library(data.table)
source("code/estimators.R")
setFixest_nthreads(3)
raw <- as.data.table(read_dta("input.dta"))
ctrl <- c("ownership","firmsize","firmage","capex_labor","lnPatent_before85","perGDP_growth","lnCityPatent85","lnHtechfirm","lnHzone")
run <- function(loc,y,x,g) {
  fit <- feols(as.formula(paste(y,"~",paste(c(x,ctrl),collapse="+"),"| firm_id + indyear")),raw,vcov=~firm_id,notes=FALSE)
  dd <- raw[obs(fit)]
  dd[, g_complete := { v <- get(g); v <- v[is.finite(v) & v > 0]; if(length(v)) min(v) else Inf },by=firm_id]
  mismatch <- dd[,sum((year >= g_complete) != get(x))]
  if (mismatch > 0) stop(loc, " treatment timing mismatch: ", mismatch)
  fe_map <- dd[,.(expected=uniqueN(paste(ind_id,year))),by=indyear][expected>1,.N]
  fe_map_reverse <- dd[,uniqueN(indyear),by=.(ind_id,year)][V1>1,.N]
  stopifnot(fe_map==0,fe_map_reverse==0)
  changes <- dd[,uniqueN(ind_id),by=firm_id][V1>1,.N]
  spec <- list(id_var="firm_id",time_var="year",y_var=y,gvar="g_complete",cluster_var="firm_id",xt_vars="ind_id",controls=ctrl)
  q <- prep_data(dd,spec)
  qd <- q$d
  sd <- standardize_y(qd)
  ti <- design_stats(qd)
  support <- qd[,.(pre=any(D==0),post=any(D==1)),by=g][is.finite(g) & pre & post,.N]
  cat(loc," N=",nrow(qd)," changing industries=",changes," supported cohorts=",support,"\n")
  flush.console()
  result <- compare_static(qd,q$xt,q$ctrl,999)
  cbind(data.table(spec_id=loc,outcome=y,treatment=x,author_twfe=coef(fit)[[x]],y_sd=sd,n=ti$n,n_units=ti$n_units,n_cohorts=ti$n_cohorts,supported_cohorts=support,industry_levels=uniqueN(qd$xt_ind_id),industry_switchers=changes,notes=paste(q$notes,collapse=";")),result)
}
specs <- data.table(loc=c("T1_c1","T1_c2","T1_c3","T2_c1","T2_c3"),y=c(rep("tfp_acf",3),"RD_expense","RD_labor"),x=c("DID_buyall_own","DID_buydom_own","DID_buyfor_own","DID_buyall_own","DID_buyall_own"),g=c("first_buyyear_own","first_buyyeardom_own","first_buyyearfor_own","first_buyyear_own","first_buyyear_own"))
for(k in seq_len(nrow(specs))) {
  s <- specs[k]
  tryCatch(fwrite(run(s$loc,s$y,s$x,s$g),paste0("output/",s$loc,".csv")),error=function(e) cat(s$loc,conditionMessage(e),"\n"))
}
