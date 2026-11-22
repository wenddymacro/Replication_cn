library(data.table);library(jsonlite);source('code/R/estimators.R');fixest::setFixest_nthreads(1)
s<-fromJSON('data/specs/cie20240307__B1.json');raw<-fread(sub('^\\$CIE_RAW',Sys.getenv('CIE_RAW'),s$data_path))
p<-prep_data(raw,s);d<-p$d;S<-event_bins(d,list(pre_min=-6,post_max=4,ref=-1,ends='bin'))
m<-fixest::feols(as.formula(paste0('y~i(ebin,ref=',NEVER,')|id+t')),data=S$d,weights=~w,cluster=~cl)
fwrite(data.table(term=names(coef(m)),b=coef(m),se=fixest::se(m)),'diagnostics/corrected_g_event.csv')
# Supplemental only: author event dummies use incomplete action and time-varying Treat;
# corrected-g event cannot be silently substituted for the author's published event path.
ys<-standardize_y(d)
res<-compare_event(d,p$xt,p$ctrl,list(pre_min=-6,post_max=4,ref=-1,ends='bin'))$res
res[,`:=`(label='SUPPLEMENT_corrected_policy_dates_NOT_author_event_path',y_sd=ys)]
fwrite(res,'diagnostics/corrected_g_event_modern_supplement.csv')
