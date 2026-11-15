suppressPackageStartupMessages({library(data.table);library(jsonlite)})
source('code/R/estimators.R');fixest::setFixest_nthreads(1)
out<-list()
for(sid in c('T2_3','T2_5')) {
 s<-fromJSON(paste0('data/specs_controls/cie117612__',sid,'.json'))
 raw<-fread(file.path(Sys.getenv('CIE_RAW'),'data/city_analysis.csv'))
 raw<-raw[eval(parse(text=s$sample_filter))]
 p<-prep_data(raw,s);d<-p$d;standardize_y(d)
 for(v in c('upstream_original','no_covariates','controls_fixed_first_observation','complete_panel_only')) {
  dd<-copy(d);cc<-p$ctrl
  if(v=='no_covariates')cc<-character()
  if(v=='controls_fixed_first_observation') {
   setorder(dd,id,t)
   for(x in cc)dd[,(x):=get(x)[1],by=id]
  }
  if(v=='complete_panel_only') {ids<-dd[,.(nt=uniqueN(t)),by=id][nt==max(dd$t),id];dd<-dd[id %in% ids]}
  z<-tryCatch(csa_did(dd,p$xt,cc),error=function(e)list(est=NA,se=NA,note=conditionMessage(e)))
  out[[length(out)+1]]<-data.table(spec=sid,variant=v,n=nrow(dd),n_units=uniqueN(dd$id),unbalanced=is_unbal(dd),est=z$est,se=z$se,note=z$note)
 }
}
fwrite(rbindlist(out),'diagnostics/csa_variants.csv')
