# Separate diagnostic, never overwrite upstream literal-input estimates.
# Fixed-baseline features are recovered from the actual supplied interaction
# columns. At each g-1 their five active columns span the same numeric space;
# redundant zero year-columns are not passed to the OR regression.
options(warn=1)
suppressPackageStartupMessages({library(data.table);library(jsonlite)})
source('code/R/estimators.R');setFixest_nthreads(1)
dir.create('diagnostics',showWarnings=FALSE)
files<-c(list.files('data/specs',pattern='json$',full.names=TRUE),list.files('data/implementation',pattern='json$',full.names=TRUE));out<-list();design<-list()
base<-c('popdensity2006','agriareaper2006','consratio2006','lnindp2006','jinrong2006')
for(f in files){
 s<-fromJSON(f);raw<-fread(sub('^\\$CIE_RAW',Sys.getenv('CIE_RAW'),s$data_path));raw<-raw[eval(parse(text=s$sample_filter))]
 cc<-character()
 if(length(s$controls))for(i in seq_along(base)){
  v<-paste0('basis_',i);raw[,(v):=rowSums(as.matrix(raw[,paste0(base[i],'yr',1:10),with=FALSE]))];cc<-c(cc,v)
 }
 sd<-s;s$controls<-cc;P<-prep_data(raw,s);d<-P$d;ysd<-standardize_y(d)
 if(s$static_or_event=='static'){
  z<-tryCatch(csa_did(d,P$xt,P$ctrl),error=function(e)list(est=NA_real_,se=NA_real_,note=conditionMessage(e)))
  at<-z$attgt
  valid<-total<-NA_integer_
  if(!is.null(at)){
   cells<-data.table(group=at$group,time=at$t,att=at$att,se=at$se)
   fwrite(cells,paste0('diagnostics/',s$spec_id,'_basis_CSA_cells.csv'))
   valid<-cells[time>=group & is.finite(att),.N];total<-cells[time>=group,.N]
  }
  out[[length(out)+1]]<-data.table(spec_id=s$spec_id,window='static',n=nrow(d),unbalanced=is_unbal(d),y_sd=ysd,csa=z$est,csa_se=z$se,valid_post_cells=valid,total_post_cells=total,note=z$note%||%'')
 }else{
  S<-event_bins(d,s$event_structure);d<-S$d;S$pre<-s$reported_pre;S$post<-s$reported_post
  z<-tryCatch(csa_event(d,P$xt,P$ctrl,S),error=function(e)list(post=list(est=NA_real_,se=NA_real_),pre=list(est=NA_real_,se=NA_real_),note=conditionMessage(e)))
  for(win in c('post','pre'))out[[length(out)+1]]<-data.table(spec_id='F1',window=win,n=nrow(d),unbalanced=is_unbal(d),y_sd=ysd,csa=z[[win]]$est,csa_se=z[[win]]$se,valid_post_cells=NA_integer_,total_post_cells=NA_integer_,note=z$note%||%'')
 }
 # Prove the baseline interaction column-space claim for this input. Rank may
 # still be below the number of columns due to province support in some cells.
 if(length(cc)){
  old<-prep_data(raw,sd)$d
  for(g0 in sort(unique(d$g[is.finite(d$g)]))){
   b<-g0-1;ix<-which(d$t==b & d$g>g0)
   if(!length(ix))next
   pf<-if(uniqueN(d[ix]$xt_prov_id)>1)'factor(xt_prov_id)' else character()
   X0<-model.matrix(as.formula(paste('~',paste(c(pf,sd$controls),collapse='+'))),as.data.frame(old[ix]))
   X1<-model.matrix(as.formula(paste('~',paste(c(pf,cc),collapse='+'))),as.data.frame(d[ix]))
   design[[length(design)+1]]<-data.table(spec_id=s$spec_id,group=g0,baseline=b,n_control=length(ix),literal_columns=ncol(X0),literal_rank=qr(X0)$rank,reduced_columns=ncol(X1),reduced_rank=qr(X1)$rank,combined_rank=qr(cbind(X0,X1))$rank)
  }
 }
 cat(s$spec_id,'diagnostic complete\n');flush.console()
}
fwrite(rbindlist(out,fill=TRUE),'diagnostics/csa_baseline_basis_comparisons.csv')
fwrite(rbindlist(design),'diagnostics/csa_baseline_columnspace.csv')
