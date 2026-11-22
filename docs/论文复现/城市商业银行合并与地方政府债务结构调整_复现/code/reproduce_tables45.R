library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(2)
fit <- function(loc,y,core,controls,fe,d) {
  f <- feols(as.formula(paste(y,"~",paste(c(core,controls),collapse="+"),"|",fe)),d,vcov=~city,notes=FALSE)
  ct <- coeftable(f)
  data.table(spec_id=loc,outcome=y,term=core,coef=ct[core,1],se=ct[core,2],t=ct[core,3],n=nobs(f))
}
b <- as.data.table(read_dta("data_bond.dta"))
bc <- c("duration","amount","group1","group3","lnasset","lev","group2","ROETTM","oldbond","profit","longdebt","fiscalgap_ratio","fiscal_GDP","GDPg")
level_name <- intToUtf8(c(22478,25237,34892,25919,31561,32423))
stopifnot(level_name %in% names(b))
setnames(b,match(level_name,names(b)),"admin_level")
groups <- lapply(c(intToUtf8(c(22320,24066)),intToUtf8(c(21306,21439)),intToUtf8(30465)),function(x)c(x,paste0(x,"(",intToUtf8(c(24320,21457,21306)),")")))
q <- c(list(b),lapply(groups,function(x)b[b$admin_level %in% x]))
fwrite(rbindlist(lapply(seq_along(q),function(i)fit(paste0("T4_",i),"bondrate","D",bc,"city+year",q[[i]]))),"output/table4.csv")
rm(b); gc()
cc <- c("fiscalgap_ratio_z","GDPg_z","lninvest_z","lnpop_z")
fc <- c("lnage_z","lev_z","lnsize_z","profit_z")
cols <- c("city","year","debt_h_new","D","inv1","panelid","ownership",cc,fc)
d <- as.data.table(read_dta("data_firm_after.dta",col_select=tidyselect::all_of(cols)))[year>=2003]
d[, `:=`(debt_h_new_zs=as.numeric(scale(debt_h_new)),inv1_zs=as.numeric(scale(inv1)))]
z <- unique(d,by=c("city","year"))
fwrite(z[,c("city","year","debt_h_new_zs","D",cc),with=FALSE],"output/table5_city_input.csv")
r <- list(fit("T5_A","debt_h_new_zs","D",cc,"city+year",z))
for(i in 1:3){
  q <- switch(i,d,d[ownership==1],d[is.na(ownership)|ownership!=1])
  r[[length(r)+1L]] <- fit(paste0("T5_B",i),"inv1_zs","debt_h_new_zs",c(fc,cc),"city+year+panelid",q)
  r[[length(r)+1L]] <- fit(paste0("T5_C",i),"inv1_zs",c("D","debt_h_new_zs"),c(fc,cc),"city+year+panelid",q)
}
fwrite(rbindlist(r),"output/table5.csv")
d <- d[,.(changing_city=uniqueN(city)>1L),by=panelid]
print(d[,sum(changing_city)])

