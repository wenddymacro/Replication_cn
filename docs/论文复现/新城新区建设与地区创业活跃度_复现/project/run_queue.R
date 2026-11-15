a<-commandArgs(TRUE);q<-as.integer(a[1]);B<-as.integer(a[2])
files<-c(list.files('data/specs',pattern='json$',full.names=TRUE),list.files('data/implementation',pattern='json$',full.names=TRUE))
files<-files[(seq_along(files)-1)%%4+1==q];R<-file.path(R.home('bin'),'Rscript.exe');status<-data.frame()
for(f in files){
 Sys.setenv(OUT_DIR=if(grepl('/implementation/',f))'implementation_output' else 'output')
 script<-if(grepl('__F1.json$',f))'run_event_reported.R' else 'run_one.R'
 cat(format(Sys.time()),'START',f,'\n');flush.console()
 log<-file.path('../logs',paste0(basename(f),'.log'))
 rc<-system2(R,c('--vanilla',script,f,as.character(B)),stdout=log,stderr=log)
 status<-rbind(status,data.frame(spec=basename(f),rc=rc));write.csv(status,paste0('../logs/queue_',q,'_status.csv'),row.names=FALSE)
 cat(format(Sys.time()),'END',f,'rc',rc,'\n');flush.console()
}
