library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(2)
city <- as.data.table(read_dta("data_city_after.dta"))[!province %in% c(31,11,12,50) & between(year,2003,2018)]
province <- as.data.table(read_dta("data_province_after.dta"))
setnames(province,"event","D")
cc <- c("fiscalgap_ratio_z","fiscal_GDP_z","GDPg_z","lninvest_z","lnpop_z","workyear")
pc <- c("GDPg","fiscal_GDP","sec","lnperIndustry","lnperFinance","fiscal_ratio","weight_npl")
base <- list()
modern <- function(loc,y,d,id,ctrl) {
  f <- as.formula(paste(y,"~",paste(c("D",ctrl),collapse="+"),"|",id,"+year"))
  fit <- feols(f,d,vcov=as.formula(paste0("~",id)),notes=FALSE)
  ct <- coeftable(fit)
  base[[length(base)+1L]] <<- data.table(spec_id=loc,outcome=y,coef=ct["D",1],se=ct["D",2],t=ct["D",3],n=nobs(fit))
  fwrite(rbindlist(base),"output/table23_original.csv")
  dd <- copy(d[obs(fit)])
  g <- if("policy_year" %in% names(d)) "policy_year" else NULL
  if (!is.null(g)) {
    valid <- is.finite(dd[[g]]) & dd[[g]]>0
    if (!all(as.integer(valid & dd$year>=dd[[g]])==dd$D)) g <- NULL
  }
  q <- prep_data(dd,list(id_var=id,time_var="year",y_var=y,gvar=g,treat_var="D",cluster_var=id,controls=ctrl))
  st <- design_stats(q$d)
  support <- q$d[,.(pre=any(D==0),post=any(D==1)),by=g][is.finite(g) & pre & post,.N]
  cat(loc,nrow(q$d),st$n_cohorts,support,ifelse(is.null(g),"observed_D","policy_year"),paste(q$notes,collapse=";"),"\n")
  if(support<2 || !any(q$d$D==0 & q$d$t >= min(q$d$g))) return(invisible(NULL))
  ysd <- standardize_y(q$d)
  r <- compare_static(q$d,q$xt,q$ctrl,999)
  al <- q$d[bjs_imputable(q$d,q$xt)]
  tw <- twfe_static(al,q$xt,q$ctrl)
  fwrite(cbind(data.table(spec_id=loc,outcome=y,n=nrow(q$d),units=st$n_units,cohorts=st$n_cohorts,supported_cohorts=support,y_sd=ysd,aligned_n=nrow(al),twfe_aligned=tw$est),r),paste0("output/",loc,".csv"))
}
ys <- c("debtnew_h_l","bondnew_h_l","feibiaonew_h_l","debtold_h_l","bondold_h_l","feibiaoold_h_l")
for(i in seq_along(ys)) for(j in 0:1) modern(paste0("T2_",i,if(j==0)"_main" else "_controls"),ys[i],city,"city",if(j==1)cc else character())
for(y in c("bankloan_c_z","bankloan_d_z","debtnew_c_l","debtnew_d_l","debtold_c_l","debtold_d_l")) modern(paste0("T3_",y),y,city,"city",cc)
for(y in c("bankloan_p_z","debtnew_p_l","debtold_p_l")) modern(paste0("T3_",y),y,province,"code",pc)
