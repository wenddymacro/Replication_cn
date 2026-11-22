pk <- c('data.table','fixest','did','did2s','DRDID','jsonlite','haven')
for (p in pk) { suppressPackageStartupMessages(library(p,character.only=TRUE)); cat(p,as.character(packageVersion(p)),'\n') }
sessionInfo()
