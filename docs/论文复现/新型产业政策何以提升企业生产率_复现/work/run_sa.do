clear all
set more off
set processors 1
set seed 824
adopath ++ "../output/local_ado"
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
log using "../output/sa.log", text replace
//生成动态效应的变量
local num1=4
local num2=3
replace chainleader_l=. if chainleader_l==0
gen event=year-chainleader_l
gen setup_mis=chainleader_l
replace setup_mis=0 if setup_mis==.
tab event
replace event=-`num1' if event<=-`num1'
replace event=`num2' if event>=`num2'
forvalues i=`num1'(-1)1{
gen pre`i'=0
replace pre`i'=1 if event==-`i'
}
forvalues i=0(1)`num2'{
gen post`i'=0
replace post`i'=1 if event==`i'
}
gen cohort=chainleader_l
eventstudyinteract TFP pre4-pre2 post0 post1-post3 pre1, cohort(cohort) control_cohort(no_treat) covariates($xlist) absorb(i.stkcd i.indid#i.year i.prv#i.year) vce(cluster city)

matrix list e(b_iw)
matrix list e(V_iw)

matrix bb=e(b_iw)
matrix vv=e(V_iw)
postfile coef str40 term double b se using "../output/sa.dta", replace
local terms : colnames bb
local j=0
foreach term of local terms {
local ++j
post coef ("`term'") (bb[1,`j']) (sqrt(vv[`j',`j']))
}
postclose coef
preserve
use "../output/sa.dta", clear
export delimited using "../output/sa.csv", replace
restore

display "COMPLETE_sa"
log close
