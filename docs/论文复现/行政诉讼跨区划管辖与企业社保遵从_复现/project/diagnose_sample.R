suppressPackageStartupMessages({library(data.table);library(jsonlite)})
source('code/R/estimators.R');fixest::setFixest_nthreads(1)
fs<-c(list.files('data/specs',full.names=TRUE,pattern='json$'),list.files('data/specs_controls',full.names=TRUE,pattern='json$'))
out<-list()
for(f in fs) {
 s<-fromJSON(f);path<-sub('^\\$CIE_RAW',Sys.getenv('CIE_RAW'),s$data_path)
 raw<-fread(path);raw<-raw[eval(parse(text=s$sample_filter))]
 p<-prep_data(raw,s);d<-p$d;m<-twfe_static(d,p$xt,p$ctrl)
 out[[length(out)+1]]<-data.table(spec=s$spec_id,input_N=nrow(d),twfe_actual_N=m$n,input_units=uniqueN(d$id),input_clusters=uniqueN(d$cl),first_year=min(d$tcal),last_year=max(d$tcal),always_rows=sum(d$g<=min(d$t)),never_rows=sum(!is.finite(d$g)),bjs_nonimputable_rows=sum(!bjs_imputable(d,p$xt)),input_singleton_units=d[, .N,by=id][N==1,.N],raw_twfe=m$est,raw_se=m$se)
}
dir.create('diagnostics',showWarnings=FALSE);fwrite(rbindlist(out),'diagnostics/sample_counts.csv')
