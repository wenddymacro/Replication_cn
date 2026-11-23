Sys.setlocale("LC_CTYPE", ".UTF-8")
library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(3)
rename <- c(ln非标准债务="nonstandard",ln城投债余额="standard",ln有息债务="debt",政府应收账款数量占比="receive_count",政府应收账款金额占比="receive_value",城投业务占比="market_ratio",市场化业务1="market_probability",ln土地资产="land",ln政府补助="subsidy",平台评级="rating",政府干预="intervention",市场化程度="marketization",城投行政级别="admin",股东性质="shareholder",债券期限1年内占比="short",债券期限1_3年占比="medium",债券期限3年以上占比="long",上划year="policy_year")
getdata <- function(f) {
  d <- as.data.table(read_dta(f))
  ii <- intersect(names(rename),names(d)); setnames(d,ii,unname(rename[ii]))
  d
}
firm <- getdata("firm.dta"); bond <- getdata("bond.dta")
controls_firm <- c("Size","Level","Roa","Turn","Liquidity","Quick","Cashratio","Age")
controls <- c(controls_firm,"Lngdp","Structure","Lnincome","Lnoutcome")
cat("firm rows",nrow(firm),"IDs",uniqueN(firm$id),"duplicates",anyDuplicated(firm,by=c("id","year")),"\n")
history <- firm[,.(adoption=if(any(Integ==1,na.rm=TRUE))as.numeric(min(year[Integ==1],na.rm=TRUE)) else Inf, p=if(all(is.na(policy_year))) Inf else min(policy_year,na.rm=TRUE),reversal=any(diff(Integ[order(year)])<0,na.rm=TRUE)),by=id]
print(history[, .N,by=.(adoption,p,reversal)][order(adoption,p)])
for(nm in c("firm","bond")){
  d <- get(nm)
  if(!("policy_year" %in% names(d))) d[,policy_year:=NA_real_]
  d[history,full_adoption:=i.adoption,on="id"]
  assign(nm,d)
}
queue <- list()
add <- function(loc,y,d=firm,x="Integ",cc=controls) queue[[length(queue)+1]] <<- list(loc=loc,y=y,d=d,x=x,cc=cc)
add("T1_1","Str",cc=character())
add("T1_2","Str",cc=controls_firm)
add("T1_3","Str")
for(i in 1:3)add(paste0("T2_",i),c("nonstandard","standard","debt")[i])
for(i in 1:4)add(paste0("T3_A",i),c("receive_count","receive_value","market_ratio","market_probability")[i])
for(i in 1:3)add(paste0("T3_B",i),c("land","subsidy","rating")[i])
add("T3_B4","CS",d=bond)
for(i in 1:4){
  var <- if(i<3)"intervention" else "marketization"
  add(paste0("T4_",i),"Non_Stand",firm[get(var)==as.integer(i%%2==1)])
}
firm[, `:=`(CityInteg=as.integer(admin=="地市级" & Integ==1),CountyInteg=as.integer(admin=="区县级" & Integ==1),GovInteg=as.integer(shareholder=="政府" & Integ==1),FirmInteg=as.integer(shareholder=="省属国企" & Integ==1))]
add("T5_1","Bond",firm[!(admin=="区县级" & Integ==1)],"CityInteg")
add("T5_2","Bond",firm[!(admin=="地市级" & Integ==1)],"CountyInteg")
add("T5_3","Bond",firm[is.na(shareholder)|shareholder!="省属国企"],"GovInteg")
add("T5_4","Bond",firm[is.na(shareholder)|shareholder!="政府"],"FirmInteg")
for(i in 1:3)add(paste0("T6_",i),c("short","medium","long")[i])
samples <- vector("list",length(queue))
rows <- lapply(seq_along(queue),function(i) {
  s <- queue[[i]]
  f <- feols(as.formula(paste(s$y,"~",paste(c(s$x,s$cc),collapse="+"),"| id+year")),s$d,vcov=~id,notes=FALSE)
  samples[[i]] <<- s$d[obs(f)]
  ct <- coeftable(f)
  data.table(spec_id=s$loc,outcome=s$y,treatment=s$x,coef=ct[s$x,1],se=ct[s$x,2],n=nobs(f),r2=fitstat(f,"r2")[[1]],adj_r2=fitstat(f,"ar2")[[1]])
})
fwrite(rbindlist(rows),"output/body.csv")
saveRDS(list(queue=lapply(queue,function(s)s[c("loc","y","x","cc")]),samples=samples),"prepared.rds")
e <- copy(firm)
lev <- setdiff(-6:3,-1)
e[, event:=pmax(-6,pmin(3,year-policy_year))]
ev <- paste0("event_",seq_along(lev))
for(j in seq_along(lev)) e[,(ev[j]):=as.integer(!is.na(event)&policy_year<2025&event==lev[j])]
f <- feols(as.formula(paste("Str~",paste(c(ev,controls),collapse="+"),"|id+year")),e,vcov=~id,notes=FALSE)
ct <- coeftable(f)
offset <- mean(ct[ev[lev<0],1])
fwrite(data.table(event=lev,coef=ct[ev,1],se=ct[ev,2],author_plot_coef=ct[ev,1]-ifelse(lev==-6,0,offset),n=nobs(f)),"output/appendix_A5.csv")


