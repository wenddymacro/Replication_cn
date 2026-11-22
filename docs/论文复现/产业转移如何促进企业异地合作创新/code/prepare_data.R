suppressPackageStartupMessages({library(data.table); library(haven)})
infile <- 'input/regression.dta'
outfile <- 'input/analysis_replication.dta'
d <- as.data.table(read_dta(infile))
setorder(d, id, year)
d[, city_cluster_first := city_num[1], by = id]
# First actual policy exposure in the author's city-year DID variable.
d[, g_first_exposure := if (any(did == 1, na.rm=TRUE)) min(year[did == 1], na.rm=TRUE) else Inf, by=id]
d[, protocol_keep_exposure := !(is.finite(g_first_exposure) & year >= g_first_exposure & did == 0)]
switch_off <- d[protocol_keep_exposure == FALSE]
# Exactly define analysis samples before estimator calls so TWFE, CSA and BJS share the same rows
# and author reghdfe singleton deletion occurs after outcome/control missingness.
control1 <- c('RDSpendSum','Far','Roe','Growth','Size','Cash_as','lnpergdp','Finance1','consume1','educ','struc1')
control2 <- c('RDSpendSum_initial','Far_initial','Roe_initial','Growth_initial','Size_initial','Cash_as_initial','lnpergdp_2007','Finance1_2007','consume1_2007','educ_2007','struc1_2007')
ys <- list(
 t5_ln_new = paste0('ln','\u65b0\u5174\u4ea7\u4e1a'), t5_ln_digital = paste0('ln','\u6570\u5b57\u6838\u5fc3'),
 t5_ln_clean_energy = paste0('ln','\u6e05\u6d01\u80fd\u6e90'), t5_ln_clean_production = paste0('ln','\u6e05\u6d01\u751f\u4ea7'),
 t5_ihs_new = paste0('ihs_','\u65b0\u5174\u4ea7\u4e1a'), t5_ihs_digital = paste0('ihs_','\u6570\u5b57\u6838\u5fc3'),
 t5_ihs_clean_energy = paste0('ihs_','\u6e05\u6d01\u80fd\u6e90'), t5_ihs_clean_production = paste0('ihs_','\u6e05\u6d01\u751f\u4ea7'),
 t7_ln_enterprise = paste0('ln','\u4f01\u4e1a\u4e3b\u4f53'), t7_ln_multiple = paste0('ln','\u591a\u4e3b\u4f53\u53c2\u4e0e'),
 t7_ln_cross_industry = paste0('ln','\u8de8\u884c\u4e1a'), t7_ln_quality_mean = 'lnquality_j', t7_ln_quality_median = 'lnquality_z',
 t7_ihs_enterprise = paste0('ihs_','\u4f01\u4e1a\u4e3b\u4f53'), t7_ihs_multiple = paste0('ihs_','\u591a\u4e3b\u4f53\u53c2\u4e0e'),
 t7_ihs_cross_industry = paste0('ihs_','\u8de8\u884c\u4e1a'), t7_ihs_quality_mean = 'ihs_quality_j', t7_ihs_quality_median = 'ihs_quality_z'
)
add_sample <- function(tag, y, controls=character()) {
  vars <- unique(c(y, controls, 'id','year','did','city_num','city_cluster_first'))
  ok <- complete.cases(d[, ..vars]) & d$protocol_keep_exposure
  ids <- d[ok, .N, by=id][N > 1, id]
  flag <- paste0('keep_', tag)
  d[, (flag) := ok & id %in% ids]
}
for(y in c('lnapp','ihs_cro_app')) {
  add_sample(paste0('t1_', if(y=='lnapp') 'lnapp' else 'ihs'), y)
  add_sample(paste0('t1c1_', if(y=='lnapp') 'lnapp' else 'ihs'), y, control1)
  add_sample(paste0('t1c2_', if(y=='lnapp') 'lnapp' else 'ihs'), y, control2)
}
for(tag in names(ys)) add_sample(paste0('c_',tag), ys[[tag]], control1)
# Audit approval-minimum backdating separately; never use it to define the firm exposure cohort.
d[, g_approval_min := min(approval[approval > 0], Inf, na.rm=TRUE), by=id]
d[, approval_min_state := as.integer(is.finite(g_approval_min) & year >= g_approval_min)]
metrics <- data.table(source_rows=nrow(d), entities=uniqueN(d$id), cities=uniqueN(d$city_num), movers=d[, uniqueN(city_num), by=id][V1>1,.N], approval_varying_ids=d[, uniqueN(approval), by=id][V1>1,.N], source_treated_rows=sum(d$did==1,na.rm=TRUE), approval_min_treated_rows=sum(d$approval_min_state==1), approval_min_mismatches=sum(d$approval_min_state!=d$did,na.rm=TRUE), approval_min_false_positive=sum(d$approval_min_state==1 & d$did==0,na.rm=TRUE), first_exposure_switchoff_rows=nrow(switch_off), switchoff_entities=uniqueN(switch_off$id), duplicate_id_years=anyDuplicated(d, by=c('id','year')))
fwrite(metrics,'output/treatment_audit.csv')
fwrite(switch_off,'output/switch_off_rows.csv')
keepvars <- grep('^keep_', names(d), value=TRUE)
samp <- rbindlist(lapply(keepvars,function(v){x<-d[get(v)==TRUE]; data.table(sample=v,n=nrow(x),n_units=uniqueN(x$id),n_clusters=uniqueN(x$city_cluster_first),n_cohorts=uniqueN(x[did==1,g_first_exposure]),years=paste(range(x$year),collapse='-'))}))
fwrite(samp,'output/sample_audit.csv')
write_dta(as.data.frame(d), outfile)
print(metrics); print(samp)



