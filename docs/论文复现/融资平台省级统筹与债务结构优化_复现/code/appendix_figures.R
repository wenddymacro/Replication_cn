library(data.table)
plot_event <- function(key){
  d <- fread(if(key=="A5") "output/appendix_A5.csv" else "output/appendix_A7_sa.csv")
  d <- rbind(d,data.table(event=-1,author_plot_coef=0,se=0),fill=TRUE)
  setorder(d,event)
  d[, lower:=author_plot_coef-qnorm(.975)*se]
  d[, upper:=author_plot_coef+qnorm(.975)*se]
  png(paste0("output/appendix_figure_",key,".png"),width=950,height=630,res=130)
  par(mar=c(4.6,4.8,3,1))
  plot(d$event,d$author_plot_coef,type="n",xaxt="n",ylim=range(d$lower,d$upper),
       xlab="Years relative to treatment",ylab="Estimate",main=paste(key,"event-study coefficients"))
  axis(1,at=-6:3,labels=c("<= -6",-5:2,">= 3"))
  abline(h=0,v=-1,col="gray62",lty=2)
  segments(d$event,d$lower,d$event,d$upper,col="#607F9C")
  lines(d$event,d$author_plot_coef,col="#0B375E",lwd=1.7)
  points(d$event,d$author_plot_coef,pch=19,col="#0B375E")
  dev.off()
}
plot_draws <- function(key){
  d <- fread(paste0("output/appendix_",key,"_draws_R.csv"))
  dens <- density(d$coef)
  png(paste0("output/appendix_figure_",key,".png"),width=950,height=630,res=130)
  par(mar=c(4.6,4.8,3,4.8))
  xr <- range(c(dens$x,-0.0422987))
  plot(dens,xlim=xr,col="#0B375E",lwd=2,xlab="Estimate",ylab="Density",
       main=if(key=="A6") "A6 control-group resampling" else "A10 placebo test")
  abline(v=-0.0422987,col="#B41E3D",lty=2)
  if(key=="A10"){
    par(new=TRUE)
    plot(d$coef,d$p,pch=1,cex=.4,col=adjustcolor("gray25",.65),xlim=xr,ylim=c(0,1),
         axes=FALSE,xlab="",ylab="")
    axis(4)
    mtext("p-value",side=4,line=2.5)
    abline(h=.1,col="#B41E3D",lty=2)
  }
  dev.off()
}
for(k in c("A5","A7")) plot_event(k)
for(k in c("A6","A10")) plot_draws(k)
