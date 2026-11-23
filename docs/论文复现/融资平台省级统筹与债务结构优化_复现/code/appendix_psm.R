Sys.setlocale("LC_CTYPE", ".UTF-8")
library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(2)
d <- as.data.table(read_dta("firm.dta"))
setnames(d,"上划year","policy")
cc <- c("Size","Level","Roa","Turn","Liquidity","Quick","Cashratio","Age","Lngdp","Structure","Lnincome","Lnoutcome")
d <- d[complete.cases(d[,c("Str",cc),with=FALSE])]
d[, treated:=as.integer(!is.na(policy)&policy<2024)]
m <- glm(reformulate(cc,"treated"),data=d,family=binomial())
d[, score:=fitted(m)]
bounds <- d[,.(lo=min(score),hi=max(score)),by=treated]
scored <- copy(d)
d <- d[score>=max(bounds$lo) & score<=min(bounds$hi)]
a <- which(d$treated==1)
b <- which(d$treated==0)
neighbors <- function(from,to){
  scores <- d$score[to]
  for(i in from){
    distance <- abs(scores-d$score[i])
    nearest[to[distance==min(distance)]] <<- TRUE
  }
}
nearest <- rep(FALSE,nrow(d))
neighbors(a,b)
neighbors(b,a)
opposite_distance <- function(index,other){
  vapply(d$score[index],function(x) min(abs(x-d$score[other])),numeric(1))
}
distance <- numeric(nrow(d))
distance[a] <- opposite_distance(a,b)
distance[b] <- opposite_distance(b,a)
# The original kernel command uses ATT, while nearest neighbor and radius use ATE.
kernel <- scored[treated==0 | (score>=bounds[treated==0,lo] & score<=bounds[treated==0,hi])]
kernel_t <- kernel[treated==1,score]
kernel_c <- kernel[treated==0,score]
kernel <- kernel[c(which(treated==1)[vapply(kernel_t,function(x) any(abs(x-kernel_c)<0.06),logical(1))],
                   which(treated==0)[vapply(kernel_c,function(x) any(abs(x-kernel_t)<0.06),logical(1))])]
samples <- list(nearest=d[nearest],radius=d[distance<=0.01],kernel=kernel)
results <- rbindlist(lapply(names(samples),function(key){
  f <- feols(as.formula(paste("Str ~ Integ +",paste(cc,collapse=" + "),"| id + year")),samples[[key]],vcov=~id,notes=FALSE)
  co <- coeftable(f)
  data.table(method=key,coef=co["Integ",1],se=co["Integ",2],n=nobs(f),r2=fitstat(f,"r2")[[1]])
}))
fwrite(results,"output/appendix_A9_psm_R.csv")


