suppressPackageStartupMessages({library(data.table); library(jsonlite)})
source("code/R/estimators.R")
setFixest_nthreads(1)
raw <- fread(file.path(Sys.getenv("CIE_RAW"),"data/analysis.csv"),encoding="UTF-8")
files <- c(list.files("data/specs",pattern="^cie20260904.*json$",full.names=TRUE),list.files("data/specs_controls",pattern="^cie20260904.*json$",full.names=TRUE))
rows <- lapply(files,function(f){
 s<-fromJSON(f); z<-raw[eval(parse(text=s$sample_filter))]; P<-prep_data(z,s);d<-P$d
 tw<-twfe_static(d,P$xt,P$ctrl);ok<-bjs_imputable(d,P$xt)
 data.table(spec_id=s$spec_id,n_author_sample=nrow(z),n_protocol_input=nrow(d),n_twfe_effective=tw$n,n_bjs_imputable=sum(ok),n_bjs_treated=sum(ok & d$D==1),n_treated=sum(d$D==1),max_xt_levels=if(length(P$xt))max(sapply(P$xt,function(v)uniqueN(d[[v]])))else 0,prep_notes=paste(P$notes,collapse=";"))
})
fwrite(rbindlist(rows),"output/design_audit.csv")
