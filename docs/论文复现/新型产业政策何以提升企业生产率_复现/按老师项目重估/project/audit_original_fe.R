suppressPackageStartupMessages({library(data.table);library(fixest);library(jsonlite)})
setFixest_nthreads(1)
raw<-fread(file.path(Sys.getenv("CIE_RAW"),"data/analysis.csv"),encoding="UTF-8")
s<-fromJSON("data/specs_controls/cie20260904__T1_4.json")
d<-raw[sample_T1_4==1]
f<-as.formula(paste0("TFP ~ chainleader + ",paste(s$controls,collapse=" + ")," | stkcd + prv^year + indid^year"))
m<-feols(f,d,cluster=~city,notes=FALSE)
fwrite(data.table(setting="original_time_varying_industry",b=coef(m)["chainleader"],se=se(m)["chainleader"],n=nobs(m)),"output/original_fe_crosscheck.csv")
