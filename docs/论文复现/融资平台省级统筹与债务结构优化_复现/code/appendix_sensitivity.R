Sys.setlocale("LC_CTYPE", ".UTF-8")
library(haven)
library(data.table)
library(fixest)
setFixest_nthreads(2)

d <- as.data.table(read_dta("firm.dta"))
controls <- c("Size","Level","Roa","Turn","Liquidity","Quick","Cashratio","Age","Lngdp","Structure","Lnincome","Lnoutcome")
fit <- function(lhs, rhs, data) {
  feols(as.formula(paste(lhs,"~",paste(rhs,collapse=" + "),"| id + year")),
        data,vcov="iid",fixef.rm="none",notes=FALSE)
}
outcome_model <- fit("Str",c("Integ",controls),d)
sample_data <- d[obs(outcome_model)]
treatment_model <- fit("Integ",controls,sample_data)
df <- degrees_freedom(outcome_model,"resid",vcov="iid")
df_treatment <- degrees_freedom(treatment_model,"resid",vcov="iid")
original <- coef(outcome_model)[["Integ"]]
original_se <- se(outcome_model)[["Integ"]]
partial_r2 <- function(t,df) t^2/(t^2+df)
# Cinelli and Hazlett partial-R-squared benchmark bounds and bias adjustment.
adjust <- function(r2d,r2y){
  est <- original + original_se * sqrt(df * r2y * r2d/(1-r2d))
  se <- original_se * sqrt((1-r2y)/(1-r2d)*df/(df-1))
  list(est=est,se=se,t=est/se)
}
all_bounds <- rbindlist(lapply(c("Size","Lngdp"),function(v){
  k <- 1:3
  r_d <- partial_r2(coeftable(treatment_model)[v,3],df_treatment)
  r_y <- partial_r2(coeftable(outcome_model)[v,3],df)
  r2d <- k * r_d/(1-r_d)
  calibrated <- k*r_d^2/((1-k*r_d)*(1-r_d))
  r2y <- (sqrt(k)+sqrt(calibrated))^2/(1-calibrated)*r_y/(1-r_y)
  adj <- adjust(r2d,r2y)
  data.table(benchmark=v,multiplier=k,r2_treatment=r2d,r2_outcome=r2y,
             coef=adj$est,se=adj$se,t=adj$t,p=2*pt(-abs(adj$t),df-1))
}))
fwrite(all_bounds,"output/appendix_A8_A9_sensitivity.csv")
for(v in c("Size","Lngdp")){
  b <- all_bounds[benchmark==v]
  png(paste0("output/appendix_sensitivity_",v,".png"),width=1320,height=620,res=140)
  par(mfrow=c(1,2),mar=c(4.5,4.7,3.2,1.2))
  for(mode in c("est","t")){
    axis_max <- if(v=="Size" && mode=="est") 0.15 else 0.08
    x <- seq(0,axis_max,length.out=180)
    z <- outer(x,x,function(a,b) adjust(a,b)[[mode]])
    contour(x,x,z,nlevels=9,col="gray45",xlab="Partial R-squared with treatment",
            ylab="Partial R-squared with outcome",main=paste(v, if(mode=="est") "coefficient" else "t statistic"))
    threshold <- if(mode=="est") 0 else -qt(.975,df-1)
    contour(x,x,z,levels=threshold,add=TRUE,col="#B41E3D",lwd=2,drawlabels=FALSE)
    points(b$r2_treatment,b$r2_outcome,pch=19,col="#0B375E")
    text(b$r2_treatment,b$r2_outcome,paste0(b$multiplier,"x"),pos=4,col="#0B375E",cex=.82)
  }
  dev.off()
}
