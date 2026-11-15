suppressPackageStartupMessages({library(data.table);library(jsonlite)})
source('code/R/estimators.R')
fixest::setFixest_nthreads(1)
dir.create('diagnostics',showWarnings=FALSE)
rows<-list()
for(sid in c('T2_1','T2_2','T2_3','T2_4','T2_5')) {
 s<-fromJSON(paste0('data/specs_controls/cie117612__',sid,'.json'))
 raw<-fread(file.path(Sys.getenv('CIE_RAW'),'data/city_analysis.csv'))
 raw<-raw[eval(parse(text=s$sample_filter))]
 p<-prep_data(raw,s);d<-p$d;ysd<-standardize_y(d)
 z<-csa_did(d,p$xt,p$ctrl)
 at<-z$attgt
 fwrite(data.table(group=at$group,time=at$t,att=at$att,se=at$se),paste0('diagnostics/',sid,'_cells.csv'))
 saveRDS(z,paste0('diagnostics/',sid,'_fit.rds'))
 # Untreated baseline design diagnostics for each identified ATT(g,t) pair.
 for(g in sort(unique(at$group))) for(t in sort(unique(at$t[at$group==g]))) {
  b<-if(t>=g)g-1 else t
  tt<-if(t>=g)t else t+1
  base<-d[t==b & g>max(tt,b)]
  post<-d[t==tt & g>max(tt,b)]
  X<-model.matrix(as.formula(paste('~',paste(p$ctrl,collapse='+'))),data=base)
  Xpost<-model.matrix(as.formula(paste('~',paste(p$ctrl,collapse='+'))),data=post)
  r<-qr(X)$rank
  rows[[length(rows)+1]]<-data.table(spec=sid,group=g,time=t,base=b,n_control=nrow(base),n_control_post=nrow(post),rank=r,rank_post=qr(Xpost)$rank,n_columns=ncol(X),condition=kappa(X),condition_post=kappa(Xpost),att=at$att[at$group==g & at$t==t],y_sd=ysd)
 }
 cat(sid,'ATT',z$est,'SE',z$se,'\n')
}
fwrite(rbindlist(rows),'diagnostics/csa_design.csv')
writeLines(capture.output(sessionInfo()),'diagnostics/sessionInfo.txt')
