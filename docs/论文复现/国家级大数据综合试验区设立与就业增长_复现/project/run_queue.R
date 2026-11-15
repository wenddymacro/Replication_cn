args0 <- commandArgs(trailingOnly=TRUE)
q <- as.integer(args0[1]); B0 <- as.integer(args0[2])
files <- c(list.files('data/specs',full.names=TRUE,pattern='json$'),list.files('data/specs_controls',full.names=TRUE,pattern='json$'))
files <- files[(seq_along(files)-1) %% 4 + 1 == q]
R <- file.path(R.home('bin'),'Rscript.exe'); status <- data.frame()
for (f in files) {
 cat(format(Sys.time()),'START',f,'\n');flush.console()
 log <- file.path('../logs',paste0(basename(f),'.log'))
 rc <- system2(R,c('--vanilla','run_one.R',f,as.character(B0)),stdout=log,stderr=log)
 status <- rbind(status,data.frame(spec=basename(f),rc=rc));write.csv(status,paste0('../logs/queue_',q,'_status.csv'),row.names=FALSE)
 cat(format(Sys.time()),'END',f,'rc',rc,'\n');flush.console()
}
if(q==4) {
 Sys.setenv(OUT_DIR='sensitivity_output')
 rc <- system2(R,c('--vanilla','run_one.R','data/sensitivity/cie117612__STABLE_CITY.json',as.character(B0)),stdout='../logs/sensitivity.log',stderr='../logs/sensitivity.log')
 write.csv(data.frame(spec='STABLE_CITY',rc=rc),'../logs/sensitivity_status.csv',row.names=FALSE)
}
