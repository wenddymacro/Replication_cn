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
  fwrite(rbindlist(base),"output/table45_modern_original.csv")
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
pair <- city[,.(actual=if(any(D==1))min(year[D==1]) else Inf, policy={v<-policy_year[!is.na(policy_year)&policy_year>0];if(length(v))min(v)else Inf}),by=city]
print(pair[, .N, by=.(actual,policy)][order(actual,policy)])
print(names(province)[grepl("year|time|event|policy", names(province))])
print(province[, .(actual=if(any(D==1,na.rm=TRUE))min(year[D==1],na.rm=TRUE) else Inf),by=code][,.N,by=actual][order(actual)])
z <- fread("table5_city_input.csv")
modern("T5_A","debt_h_new_zs",z,"city",c("fiscalgap_ratio_z","GDPg_z","lninvest_z","lnpop_z"))
b <- as.data.table(read_dta("data_bond.dta"))
level_name <- intToUtf8(c(22478,25237,34892,25919,31561,32423))
setnames(b,match(level_name,names(b)),"admin_level")
groups <- lapply(c(intToUtf8(c(22320,24066)),intToUtf8(c(21306,21439)),intToUtf8(30465)),function(x)c(x,paste0(x,"(",intToUtf8(c(24320,21457,21306)),")")))
bc <- c("duration","amount","group1","group3","lnasset","lev","group2","ROETTM","oldbond","profit","longdebt","fiscalgap_ratio","fiscal_GDP","GDPg")
# Infer city adoption before restricting bond samples; irregular issuance can hide the first treated year.
hist <- b[,.(date=if(any(D==1,na.rm=TRUE))min(year[D==1],na.rm=TRUE)else Inf),by=city]
hist[pair[is.finite(actual)],date:=i.actual,on="city"]
b[hist,policy_year:=i.date,on="city"]
for(i in 1:4){
  q <- if(i==1) b else b[b$admin_level %in% groups[[i-1]]]
  tryCatch(modern(paste0("T4_",i),"bondrate",q,"city",bc),error=function(e)cat(i,conditionMessage(e),"\n"))
}
