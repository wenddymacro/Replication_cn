suppressPackageStartupMessages({library(haven); library(fixest); library(data.table)})
d <- as.data.table(read_dta('input/regression.dta'))
control1 <- c('RDSpendSum','Far','Roe','Growth','Size','Cash_as','lnpergdp','Finance1','consume1','educ','struc1')
initial <- c('RDSpendSum_initial','Far_initial','Roe_initial','Growth_initial','Size_initial','Cash_as_initial','lnpergdp_2007','Finance1_2007','consume1_2007','educ_2007','struc1_2007')
ctrl2 <- paste0('i(year, ', initial, ')')
rows <- list()
add <- function(id, tab, y, controls, pub_b, pub_t, pub_n) {
  rhs <- if (length(controls)) paste('+',paste(controls,collapse='+')) else ''
  d[, ytmp := as.numeric(get(y))]
  f <- as.formula(paste('ytmp ~ did',rhs,intToUtf8(124),'id + year'))
  m <- feols(f,data=d,vcov=~city_num)
  rows[[length(rows)+1]] <<- data.table(spec_id=id,table=tab,y=y,coef=unname(coef(m)['did']),se=unname(se(m)['did']),t=unname(tstat(m)['did']),n=nobs(m),published_coef=pub_b,published_t=pub_t,published_n=pub_n,exact_round4=round(unname(coef(m)['did']),4)==pub_b && round(unname(tstat(m)['did']),4)==pub_t && nobs(m)==pub_n)
}
add('T1_c1_lnapp','Table 1','lnapp',character(),.2625,2.4718,15997)
add('T1_c2_lnapp','Table 1','lnapp',control1,.2833,2.4000,15579)
add('T1_c3_lnapp','Table 1','lnapp',ctrl2,.2829,2.0570,15722)
add('T1_c4_ihs','Table 1','ihs_cro_app',character(),.3292,2.5437,15997)
add('T1_c5_ihs','Table 1','ihs_cro_app',control1,.3522,2.4644,15579)
add('T1_c6_ihs','Table 1','ihs_cro_app',ctrl2,.3530,2.0972,15722)
yvars <- list(t5_ln_new=paste0('ln','\u65b0\u5174\u4ea7\u4e1a'),t5_ln_digital=paste0('ln','\u6570\u5b57\u6838\u5fc3'),t5_ln_energy=paste0('ln','\u6e05\u6d01\u80fd\u6e90'),t5_ln_clean=paste0('ln','\u6e05\u6d01\u751f\u4ea7'),t5_ihs_new=paste0('ihs_','\u65b0\u5174\u4ea7\u4e1a'),t5_ihs_digital=paste0('ihs_','\u6570\u5b57\u6838\u5fc3'),t5_ihs_energy=paste0('ihs_','\u6e05\u6d01\u80fd\u6e90'),t5_ihs_clean=paste0('ihs_','\u6e05\u6d01\u751f\u4ea7'))
vals <- c(.2539,.2466,.1946,.1516,.3215,.3171,.2412,.1954)
ts <- c(2.7096,2.4164,1.5979,1.7311,2.7008,2.4412,1.6088,1.7358)
for(i in seq_along(yvars)) add(names(yvars)[i],'Table 5',yvars[[i]],control1,vals[i],ts[i],15579)
res <- rbindlist(rows)
fwrite(res,'output/author_source_checks.csv')
print(res[,.(spec_id,coef,t,n,exact_round4)])

