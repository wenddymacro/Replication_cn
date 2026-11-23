library(haven)
library(data.table)
source("csa_rank.R")
cols <- c("idcitycp","citycp","prov","prov_son","year","ydcom_add1","ntreat","did1","treat1")
d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(cols)))
d <- d[treat1==1|ntreat==1]
dates <- d[,.(g=if(any(did1==1))min(year[did1==1])else Inf),by=citycp]
anchor <- fread("event_dates_by_citypair_1.csv")[compatible==TRUE]
dates[anchor,g:=i.g_event,on="citycp"]
d[dates,g:=i.g,on="citycp"]
stopifnot(all(as.integer(d$year>=d$g)==d$did1))
d[, y:=ydcom_add1/sqrt(mean((ydcom_add1-mean(ydcom_add1))^2))]
units <- d[,.(units=uniqueN(idcitycp)),by=.(g,citycp)]
cohort_size <- units[,.(size=sum(units)),by=g]
ds <- d[,.(w=.N,y=mean(y)),by=.(citycp,year,g,prov,prov_son)]
rm(d)
pairs <- fread("csa_full_support_audit.csv")[spec_id=="T2_1"]
scores <- list()
for(i in seq_len(nrow(pairs))){
  p <- pairs[i]
  if(!p$province_support_base || !p$province_support_post)next
  gh <- p$g
  th <- p$t
  s <- ds[year %in% c(gh-1,th) & (g==gh|g>th)]
  s[,post:=as.integer(year==th)]
  s[,D:=as.integer(g==gh)]
  m <- model.matrix(~factor(prov)+factor(prov_son),s)
  ans <- support_reg_did(s$D,m,s$w,TRUE,s$y,s$post)
  stopifnot(is.finite(ans$ATT))
  s[,score:=ans$att.inf.func/nrow(s)]
  pairs[i,att:=ans$ATT]
  n_group <- cohort_size[g==gh,size]
  scores[[length(scores)+1L]] <- s[,.(weighted_score=sum(score)*n_group),by=citycp]
}
estimated <- pairs[!is.na(att)]
estimated[cohort_size,group_weight:=i.size,on="g"]
total <- sum(estimated$group_weight)
att <- weighted.mean(estimated$att,estimated$group_weight)
infl <- rbindlist(scores)[,.(score=sum(weighted_score)),by=citycp]
# Variation of cohort weights in the simple post-cell average.
cohort_adjust <- estimated[,.(adjustment=sum(att)-.N*weighted.mean(estimated$att,estimated$group_weight)),by=g]
share <- units[cohort_adjust,on="g"]
share <- share[,.(weight_score=sum(units*adjustment)),by=citycp]
infl <- merge(infl,share,by="citycp",all=TRUE)
infl[is.na(weight_score),weight_score:=0]
infl[is.na(score),score:=0]
influence <- (infl$score+infl$weight_score)/total
stopifnot(abs(sum(influence))<1e-9)
set.seed(20261124)
draws <- replicate(999,sum(rnorm(length(influence))*influence))
fwrite(data.table(spec_id="T2_1",csa=att,csa_se=sd(draws),
                  post_cells=nrow(pairs),supported=nrow(estimated)),"output/anchored_compact_T2_1.csv")
fwrite(estimated,"output/anchored_compact_T2_1_cells.csv")

