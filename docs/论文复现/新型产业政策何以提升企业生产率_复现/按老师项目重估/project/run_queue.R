args <- commandArgs(TRUE)
group <- as.integer(args[1])
files <- sort(list.files("data/specs_controls",pattern="^cie20260904.*json$",full.names=TRUE))
files <- files[(seq_along(files)-1)%%4+1==group]
status <- data.frame(spec=character(),rc=integer())
for(f in files){
  tag <- tools::file_path_sans_ext(basename(f))
  cat("START",tag,format(Sys.time()),"\n")
  rc <- system2(file.path(R.home("bin"),"Rscript.exe"),c("--vanilla","run_one.R",f,Sys.getenv("BOOT_B","999")),stdout=paste0("../logs/",tag,".log"),stderr=paste0("../logs/",tag,".log"))
  status <- rbind(status,data.frame(spec=tag,rc=rc))
  write.csv(status,paste0("../logs/queue_",group,"_status.csv"),row.names=FALSE)
  cat("END",tag,rc,format(Sys.time()),"\n")
}
