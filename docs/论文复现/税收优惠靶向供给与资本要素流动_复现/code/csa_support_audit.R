library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(3)

# With province dummies in both margins, the treated covariate contrast is
# identified only if its origin and destination masses match in each connected
# component of the controls' bipartite support graph.
supported <- function(control,target,n_orig,n_dest){
  if(!nrow(control)||!nrow(target))return(FALSE)
  parent <- seq_len(n_orig+n_dest)
  root <- function(i){
    while(parent[i]!=i)i <- parent[i]
    i
  }
  edges <- unique(control[,.(origin,destination)])
  for(i in seq_len(nrow(edges))){
    x <- root(edges$origin[i])
    y <- root(n_orig+edges$destination[i])
    parent[y] <- x
  }
  labels <- vapply(seq_len(n_orig+n_dest),root,integer(1))
  mass <- rbind(
    target[,.(mass=sum(n)),by=.(component=labels[origin])],
    target[,.(mass=-sum(n)),by=.(component=labels[n_orig+destination])]
  )
  all(mass[,sum(mass),by=component]$V1==0)
}
m <- fread("models.csv")[spec %chin% c(paste0("T1_",1:3),paste0("T2_",1:4),paste0("T4_",1:6),paste0("T6_",c(1,3,5)))]
needed <- unique(unlist(lapply(seq_len(nrow(m)),function(i){
    s <- m[i]
    c(all.vars(as.formula(paste(s$y,"~",s$rhs,"|",s$fixed))),s$cluster,all.vars(parse(text=s$subset)))
})))
d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(needed)))
n_orig <- uniqueN(d$prov)
n_dest <- uniqueN(d$prov_son)
audit <- list()
for(i in seq_len(nrow(m))){
  s <- m[i]
  rhs <- strsplit(s$target," ",fixed=TRUE)[[1]][1]
  dd <- d[which(d[,eval(parse(text=s$subset))])]
  dates <- dd[,.(g=if(any(get(rhs)==1))min(year[get(rhs)==1])else Inf),by=citycp]
  h <- fread(paste0("event_dates_by_citypair_",substring(rhs,4),".csv"))[compatible==TRUE]
  dates[h,g:=i.g_event,on="citycp"]
  dd[dates,g:=i.g,on="citycp"]
  f <- feols(as.formula(paste(s$y,"~",s$rhs,"|",s$fixed)),dd,notes=FALSE)
  v <- dd[obs(f),.N,by=.(year,g,prov,prov_son)]
  setnames(v,"N","n")
  v[,origin:=match(prov,unique(d$prov))]
  v[,destination:=match(prov_son,unique(d$prov_son))]
  audit[[i]] <- rbindlist(lapply(sort(unique(v[is.finite(g),g])),function(batch){
    b <- batch-1
    rbindlist(lapply(sort(unique(v[year>=batch,year])),function(t){
      a <- v[g==batch & year %in% c(b,t)]
      c <- v[g>t & year %in% c(b,t)]
      data.table(spec_id=s$spec,g=batch,t=t,treated_pre=sum(a[year==b,n]),treated_post=sum(a[year==t,n]),
        province_support_base=supported(c[year==b],a,n_orig,n_dest),
        province_support_post=supported(c[year==t],a,n_orig,n_dest))
    }))
  }))
  cat("AUDITED",s$spec,nobs(f),sum(audit[[i]]$province_support_base&audit[[i]]$province_support_post),"\n")
  flush.console()
  rm(dd,f)
  gc()
}
fwrite(rbindlist(audit),"output/csa_full_support_audit.csv")
