clear all
set more off
set processors 1
adopath ++ "../output/local_ado"
log using "../output/bootstrap_g_clus1.log", text replace
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
xtset city
bdiff, group(g_clus1) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
return list
matrix list r(P)
file open result using "../output/bootstrap_g_clus1.txt", write replace
file write result "bdiff=" (r(bdiff)) " p=" (r(p)) _n
file close result
display "COMPLETE_bootstrap_g_clus1"
log close
