source('code/R/analysis.R')
z<-load_dir('specs_controls')
if(!is.null(z))fwrite(to_long(z),file.path(Sys.getenv('OUT_DIR'),'controls_comparisons.csv'))
