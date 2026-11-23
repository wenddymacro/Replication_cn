library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(2)
dsets <- lapply(setNames(c("city17_22","county17_22","city10_22"),c("city17_22","county17_22","city10_22")),function(x)as.data.table(read_dta(paste0(x,".dta"))))
for(k in names(dsets)){
  d <- dsets[[k]]
  if ("digit_gov" %in% names(d)) print(d[,.(source=k,n=.N,values=uniqueN(digit_gov,na.rm=TRUE),min=min(digit_gov,na.rm=TRUE),max=max(digit_gov,na.rm=TRUE))])
}
for(x in c("did2","did3")){
  d <- dsets$city10_22
  print(d[,.(g=if(any(get(x)==1,na.rm=TRUE)) as.numeric(min(year[get(x)==1],na.rm=TRUE)) else Inf,reversal=any(diff(get(x)[order(year)])<0,na.rm=TRUE)),by=citycode][,. (units=.N,reversals=sum(reversal)),by=g][order(g)])
}
lines <- trimws(readLines("author.do",encoding="UTF-8"))
dataset <- NULL
section <- "initial"
rows <- list()
expand <- function(tok,d){
  if(!grepl("-",tok,fixed=TRUE)) return(tok)
  v <- strsplit(tok,"-",fixed=TRUE)[[1]]
  names(d)[seq.int(match(v[1],names(d)),match(v[2],names(d)))]
}
for(i in seq_along(lines)){
  L <- lines[i]
  if(grepl("^use ",L)) dataset <- sub("^use +([[:alnum:]_]+).*","\\1",L)
  if(grepl("^\\*.*[0-9]",L)) section <- L
  if(!grepl("^(reg|reghdfe|ivreghdfe) ",L)) next
  id <- dataset
  tryCatch({
    d <- dsets[[id]]
    L <- sub("//.*$","",L)
    spl <- strsplit(L,",",fixed=TRUE)[[1]]
    core <- spl[1]; options <- paste(spl[-1],collapse=",")
    if(grepl(" if ",core,fixed=TRUE)){
      condition <- sub("^.* if ","",core)
      stopifnot(grepl("^[a-zA-Z0-9_ .<>=&|]+$",condition))
      d <- d[eval(parse(text=condition))]
      core <- sub(" if .*$","",core)
    }
    core <- gsub("$citycons","lngdp-lnhighway",core,fixed=TRUE)
    iv <- regmatches(core,regexpr("\\([^)]*=[^)]*\\)",core))
    if(length(iv)) core <- sub("\\([^)]*=[^)]*\\)","",core)
    v <- strsplit(trimws(core),"[[:space:]]+")[[1]]
    if (identical(v[2],"dmerge") && !("dmerge" %in% names(d)) && identical(grep("^dmerge",names(d),value=TRUE),"dmerger")) v[2] <- "dmerger"
    rhs <- unlist(lapply(v[-c(1,2)],expand,d=d))
    opt <- function(pattern) {
      mt <- regmatches(options,regexec(pattern,options))[[1]]
      if(length(mt)) mt[2] else ""
    }
    fe <- opt("absorb\\(([^)]*)\\)")
    cl <- opt("cluster\\(([^)]*)\\)")
    fs <- if(nzchar(fe)) paste(strsplit(trimws(fe)," +")[[1]],collapse="+") else ""
    fs <- gsub("#","^",fs,fixed=TRUE)
    f <- as.formula(paste(v[2],"~",if(length(rhs)) paste(rhs,collapse="+") else "1",
      if(nzchar(fs)) paste("|",fs) else if(length(iv)) "| 0" else "",
      if(length(iv)) paste("|",chartr("=","~",substring(iv,2,nchar(iv)-1))) else ""))
    fit <- feols(f,d,vcov=as.formula(paste0("~",cl)),notes=FALSE)
    ct <- coeftable(fit)
    rows[[length(rows)+1]] <- data.table(line=i,section=section,dataset=id,method=if(length(iv))"IV"else"OLS",outcome=v[2],term=rownames(ct),coef=ct[,1],se=ct[,2],n=nobs(fit),adj_r2=fitstat(fit,"ar2")[[1]])
  },error=function(e)cat("FAILED",i,conditionMessage(e),"\n"))
}
fwrite(rbindlist(rows),"output/estimates.csv")

