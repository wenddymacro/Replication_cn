library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(3)
controls <- c("size","lev","roa","perr","dual","bigstock","lrgdp2014t","third2014t","loan2014t")
vars <- c("id","idcitycp","citycp","prov","prov_son","year","treat3","ntreat","did3","ydcom_add1","ydcom_dum1","Fpoor","deep",controls)
d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(vars)))
d <- d[treat3==1 | ntreat==1]
d[,origin:=.GRP,by=.(year,prov)]
d[,destination:=.GRP,by=.(year,prov_son)]
k <- uniqueN(d$idcitycp)
a <- uniqueN(d$origin)
b <- uniqueN(d$destination)
links <- unique(d[,.(origin,dest=destination+a)])
parent <- seq_len(a+b)
find <- function(i){
  while(parent[i]!=i)i <- parent[i]
  i
}
for(j in seq_len(nrow(links))){
  i <- find(links$origin[j])
  l <- find(links$dest[j])
  parent[l] <- i
}
mobility <- length(unique(vapply(seq_len(a+b),find,integer(1))))
m <- feols(as.formula(paste("Fpoor ~ did3*ydcom_dum1 +",paste(controls,collapse="+"),"| origin+destination+idcitycp")),d,vcov=~citycp)
stopifnot(nobs(m)==2890738L,d[,uniqueN(citycp),by=idcitycp][V1!=1,.N]==0L,
          d[,uniqueN(citycp),by=origin][V1>1,.N]>0L,d[,uniqueN(citycp),by=destination][V1>1,.N]>0L)
df_resid <- nobs(m) - (k+a+b-1L-mobility) - length(coef(m))
r2 <- fitstat(m,"r2")[[1]]
ar2_stata <- 1-(1-r2)*(nobs(m)-1)/df_resid
fwrite(data.table(spec_id="T7_1",mobility_groups=mobility,df_resid_reghdfe=df_resid,
                  adjusted_r2_fixest=fitstat(m,"ar2")[[1]],adjusted_r2_reghdfe=ar2_stata),"output/dof_audit_T7_1.csv")
group_audit <- d[,.(distinct_values=uniqueN(deep,na.rm=TRUE)),by=idcitycp][,.N,by=distinct_values]
fwrite(group_audit,"output/deep_audit.csv")

# The appendix diagnostic uses unit and year effects, following its separate Stata command.
m <- feols(as.formula(paste("did3 ~",paste(controls,collapse="+"),"| idcitycp+year")),d,notes=FALSE,fixef.rm="none")
w <- resid(m)[d$did3==1]
normalized <- w/sum(w)
fwrite(data.table(n_treated=length(w),n_negative=sum(w < -1e-9),negative_row_share=mean(w < -1e-9),
                  negative_abs_share=-sum(normalized[w < -1e-9])/sum(abs(normalized)),
                  negative_signed_sum=sum(normalized[w < -1e-9])),"output/author_appendix_weights.csv")
