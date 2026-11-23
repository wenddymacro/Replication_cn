library(data.table)
library(haven)
setFixest <- FALSE
v <- c("ydcom_add1","did1","did2","did3","treat1","treat2","treat3","ntreat","year","citycp",
       "size","lev","roa","perr","dual","bigstock","lrgdp2014","third2014","loan2014",
       as.vector(outer(c(paste0("pre_",4:1),paste0("post_",0:3)),c("y","by","b"),paste,sep="_")))
d <- as.data.table(read_dta("data1.dta",col_select=tidyselect::all_of(v)))
stats <- function(ds,panel,vars){
  rbindlist(lapply(vars,function(v){
    x <- ds[[v]]
    data.table(panel,variable=v,n=sum(!is.na(x)),mean=mean(x,na.rm=TRUE),sd=sd(x,na.rm=TRUE),min=min(x,na.rm=TRUE),max=max(x,na.rm=TRUE))
  }))
}
a <- stats(d[treat3==1],"A",c("ydcom_add1","did3"))
b <- stats(d[treat1==1],"B",c("ydcom_add1","did1"))
c <- stats(d[treat2==1],"C",c("ydcom_add1","did2"))
dd <- stats(d[ntreat==1],"D","ydcom_add1")
e <- stats(d[treat1==1|treat2==1|treat3==1|ntreat==1],"E",c("size","lev","roa","perr","dual","bigstock","lrgdp2014","third2014","loan2014"))
fwrite(rbind(a,b,c,dd,e),"output/descriptive_A1.csv")
for(k in 1:3){
  did <- paste0("did",k)
  treatment <- paste0("treat",k)
  suffix <- c("by","b","y")[k]
  vs <- paste(c(paste0("pre_",4:1),paste0("post_",0:3)),suffix,sep="_")
  s <- d[get(treatment)==1,.SD,.SDcols=c("year","citycp",did,vs)]
  s[,g:=if(any(get(did)==1))min(year[get(did)==1])else Inf,by=citycp]
  anchors <- c(-3,-2,0,1,2)
  check <- rbindlist(lapply(anchors,function(e){
      v <- paste0(if(e<0)"pre_"else"post_",abs(e),"_",suffix)
      unique(s[get(v)==1,.(citycp,anchored=year-e)])
  }))
  candidates <- check[,.(n_date=uniqueN(anchored),g_event=min(anchored)),by=citycp]
  h <- unique(s[,.(citycp,g)])[candidates,on="citycp"]
  h[, compatible:=n_date==1 & (g==g_event | !is.finite(g) | g>g_event)]
  print(h[, .N, by=.(n_date,compatible,same=g==g_event)][order(n_date,compatible,same)])
  s[h,g_candidate:=i.g_event,on="citycp"]
  print(s[!is.na(g_candidate),.(mismatch=sum(as.integer(year>=g_candidate)!=get(did)),n=.N)])
  fwrite(h,paste0("output/event_dates_by_citypair_",k,".csv"))
  s[,relative:=year-g]
  result <- rbindlist(lapply(vs,function(v){
    s[get(v)==1,.(term=v,min_rel=min(relative),max_rel=max(relative),n=.N)]
  }))
  fwrite(result,paste0("output/event_support_",k,".csv"))
}
files <- paste0("output/F3_",1:3,".csv")
plot_data <- rbindlist(lapply(files,fread))
plot_data[, event:=as.integer(tstrsplit(term,"_",fixed=TRUE)[[2]])]
plot_data[startsWith(term,"pre"),event:=-event]
plot_data[is.na(coef) & event==-1, `:=`(coef=0,se=0)]
plot_data[,critical:=qt(.95,df_t)]
plot_data[, `:=`(lo=coef-critical*se,hi=coef+critical*se)]
fwrite(plot_data,"output/event_F3_90ci.csv")
png("output/appendix_F3.png",width=1700,height=575,res=145)
par(mfrow=c(1,3),mar=c(4.2,4.5,2.9,1.0))
for(k in 1:3){
  s <- plot_data[spec_id==paste0("F3_",k)][order(event)]
  plot(s$event,s$coef,type="n",ylim=range(s$lo,s$hi,0),xlab="Years relative to treatment",ylab="Coefficient",
       main=c("Destination only","Both cities","Origin only")[k],xaxt="n")
  axis(1,at=-4:3)
  abline(h=0,v=-1,lty=2,col="gray62")
  segments(s$event,s$lo,s$event,s$hi,col="#67819A")
  lines(s$event,s$coef,col="#174568")
  points(s$event,s$coef,pch=19,col="#174568")
}
dev.off()
