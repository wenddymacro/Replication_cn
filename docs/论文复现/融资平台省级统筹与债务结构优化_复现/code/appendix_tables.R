Sys.setlocale("LC_CTYPE", ".UTF-8")
library(haven)
library(data.table)
source("estimators.R")
setFixest_nthreads(2)
d <- as.data.table(read_dta("firm.dta"))
controls <- c("Size","Level","Roa","Turn","Liquidity","Quick","Cashratio","Age","Lngdp","Structure","Lnincome","Lnoutcome")
desc <- function(x) c(N=sum(!is.na(x)),mean=mean(x,na.rm=TRUE),median=median(x,na.rm=TRUE),sd=sd(x,na.rm=TRUE),min=min(x,na.rm=TRUE),max=max(x,na.rm=TRUE))
fwrite(rbindlist(lapply(c("Str","Integ",controls),function(v) as.list(c(variable=v,desc(d[[v]]))))),"output/appendix_table_A3.csv")
fit <- function(s,y,dt=d,cc=controls,fe="id + year",terms="Integ"){
  f <- feols(as.formula(paste0("`",y,"` ~ ",paste(c(terms,cc),collapse=" + ")," | ",fe)),dt,vcov=~id,notes=FALSE)
  co <- coeftable(f)[terms,,drop=FALSE]
  data.table(spec_id=s,outcome=y,term=terms,coef=co[,1],se=co[,2],n=nobs(f),r2=fitstat(f,"r2")[[1]])
}
a <- copy(d)
setorder(a,id,year)
a[, time_index:=match(year,sort(unique(year)))]
a[,(controls):=lapply(.SD,function(x) rep(x[1],.N)),.SDcols=controls,by=id]
for(k in 1:3) a[,(paste0(controls,"_t",k)):=lapply(.SD,function(x)x*time_index^k),.SDcols=controls]
rows <- lapply(1:3,function(k)fit(paste0("A4_",k),"Str",a,unlist(lapply(seq_len(k),function(j)paste0(controls,"_t",j)))))
rows <- c(rows,list(fit("A5_1","银行贷款占比"),fit("A5_2","非标债务占比")))
sources <- c("万德","银保监会","企业预警通","华泰固收","华西固收")
rows <- c(rows,lapply(seq_along(sources),function(k)fit(paste0("A6_",k),"Str",d[which(get(sources[k])==1)])))
rows <- c(rows,list(fit("A7_1","Str",terms=c("Integ","Exit"))))
effects <- c("year^Pro","year^City","year^Ind","year^City + year^Pro + year^Ind")
rows <- c(rows,lapply(seq_along(effects),function(k)fit(paste0("A7_",k+1),"Str",fe=paste("id +",effects[k]))))
rows <- c(rows,list(fit("A8_1","Str1",cc=controls[1:8]),fit("A8_2","Str1")))
fwrite(rbindlist(rows),"output/appendix_tables_A4_A8.csv")
for (v in c("政府干预","市场化程度","城投行政级别","股东性质")) {
  cat(v,"firms with varying nonmissing classification",d[,uniqueN(get(v),na.rm=TRUE),by=id][V1>1,.N],"\n")
}
