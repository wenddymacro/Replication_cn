library(data.table);library(jsonlite);source('code/R/estimators.R');fixest::setFixest_nthreads(1)
s<-fromJSON('data/specs_controls/cie20240307__B2.json');raw<-fread(sub('^\\$CIE_RAW',Sys.getenv('CIE_RAW'),s$data_path));raw<-raw[eval(parse(text=s$sample_filter))]
p<-prep_data(raw,s);d<-p$d;ids<-d[,.N,by=id][N==uniqueN(d$t),id];d<-d[id%in%ids]
ys<-standardize_y(d);ans<-compare_static(d,p$xt,p$ctrl,999)
ans[,`:=`(label='SUPPLEMENT_complete_panel_changed_sample_NOT_author_baseline',n=nrow(d),units=uniqueN(d$id),y_sd=ys,unbalanced=is_unbal(d))]
fwrite(ans,'diagnostics/balanced_B2_supplement.csv')
