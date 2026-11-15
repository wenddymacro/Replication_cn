# Glue only: invoke unchanged upstream estimator functions, retaining the full
# regression bins but averaging the event periods actually displayed in Fig.1.
options(warn=1)
suppressPackageStartupMessages({library(data.table);library(jsonlite)})
source('code/R/estimators.R');setFixest_nthreads(1)
spec<-fromJSON(commandArgs(TRUE)[1]);root<-Sys.getenv('CIE_RAW')
raw<-fread(sub('^\\$CIE_RAW',root,spec$data_path));raw<-raw[eval(parse(text=spec$sample_filter))]
P<-prep_data(raw,spec);d<-P$d;y_sd<-standardize_y(d);st<-design_stats(d)
S<-event_bins(d,spec$event_structure);d<-S$d;S$pre<-spec$reported_pre;S$post<-spec$reported_post
failed<-function(e)list(post=list(est=NA_real_,se=NA_real_),pre=list(est=NA_real_,se=NA_real_),lev=list(G_eff=NA_real_,L_max=NA_real_),note=conditionMessage(e))
tw<-tryCatch(twfe_event(d,P$xt,P$ctrl,S),error=failed)
bj<-tryCatch(bjs_event(d,P$xt,P$ctrl,S),error=failed)
cs<-tryCatch(csa_event(d,P$xt,P$ctrl,S),error=failed)
nw<-twfe_negweights(d,P$xt,P$ctrl)
row<-function(win)data.table(paper_id=spec$paper_id,spec_id=spec$spec_id,journal='cie',static_or_event='event',controls=TRUE,window=win,twfe=tw[[win]]$est,twfe_se=tw[[win]]$se,csa=cs[[win]]$est,csa_se=cs[[win]]$se,bjs=bj[[win]]$est,bjs_se=bj[[win]]$se,neg_rows=nw$neg_rows,neg_abs=nw$neg_abs,G_eff_twfe=tw$lev$G_eff,L_max_twfe=tw$lev$L_max,G_eff_csa=NA_real_,L_max_csa=NA_real_,G_eff_bjs=bj$lev$G_eff,L_max_bjs=bj$lev$L_max,csa_note=cs$note%||%'',bjs_note=bj$note%||%'',twfe_note=tw$note%||%'',twfe_raw=NA_real_,y_sd=y_sd,published_coef=NA_real_,published_se=NA_real_,n=st$n,n_units=st$n_units,n_clusters=st$n_clusters,n_cohorts=st$n_cohorts,share_never=st$share_never,share_always=st$share_always,unbalanced=st$unbalanced,repeated_cs=st$repeated_cs,prep_notes=paste(P$notes,collapse=';'),preferred=FALSE,in_abstract_intro=FALSE,reports_modern_estimator=TRUE,reported_window_wrapper=TRUE)
r<-rbind(row('post'),row('pre'));out<-file.path(Sys.getenv('OUT_DIR'),'specs_controls',paste0(spec$paper_id,'__F1.csv'));dir.create(dirname(out),recursive=TRUE,showWarnings=FALSE);fwrite(r,out);print(r[,.(window,twfe,csa,bjs,csa_note,bjs_note)])
