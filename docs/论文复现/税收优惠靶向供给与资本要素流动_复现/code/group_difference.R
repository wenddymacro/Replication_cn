library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(3)
ctrl <- c("size","lev","roa","perr","dual","bigstock","lrgdp2014t","third2014t","loan2014t")
needed <- c("idcitycp","citycp","prov","prov_son","year","ydcom_add1","treat3","ntreat","did3","deep",ctrl)
d <- as.data.table(read_dta("data1.dta", col_select=tidyselect::all_of(needed)))
fits <- lapply(0:1,function(k){
  ds <- d[(treat3==1|ntreat==1) & deep==k]
  fx <- paste(paste(ctrl,collapse="+"),"| idcitycp+year^prov+year^prov_son")
  m <- feols(as.formula(paste("ydcom_add1 ~ did3 +",fx)),ds,vcov=~citycp,notes=FALSE)
  ds <- ds[obs(m)]
  rt <- resid(feols(as.formula(paste("did3 ~",fx)),ds,fixef.rm="none",notes=FALSE))
  scores <- ds[,.(citycp)]
  scores[,score:=rt*resid(m)/sum(rt*ds$did3)]
  scores <- scores[,.(score=sum(score)),by=citycp]
  se0 <- se(m)[["did3"]]
  scores[,score:=score*se0/sqrt(sum(score^2))]
  list(beta=coef(m)[["did3"]],se=se0,score=scores,n=nobs(m))
})
u <- merge(fits[[1]]$score,fits[[2]]$score,by="citycp",all=TRUE)
u[is.na(score.x),score.x:=0]
u[is.na(score.y),score.y:=0]
delta <- fits[[2]]$beta-fits[[1]]$beta
se_delta <- sqrt(sum((u$score.y-u$score.x)^2))
fwrite(data.table(n_extensive=fits[[1]]$n,n_intensive=fits[[2]]$n,
  beta_extensive=fits[[1]]$beta,beta_intensive=fits[[2]]$beta,
  citypair_score_cov=sum(u$score.x*u$score.y),difference=delta,se=se_delta,
  p_two_sided=2*pt(-abs(delta/se_delta),df=nrow(u)-1)),
  "output/T4_group_difference_citypair.csv")
