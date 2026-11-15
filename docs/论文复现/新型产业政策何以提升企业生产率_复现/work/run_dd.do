clear all
set more off
set processors 1
set seed 824
adopath ++ "../output/local_ado"
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
log using "../output/dd.log", text replace
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
did_multiplegt_old TFP stkcd year chainleader, controls($xlist) robust_dynamic placebo(3) dynamic(3) breps(200) cluster(city)
matrix dd_b = e(estimates)
matrix dd_v = e(variances)

ereturn list
matrix list dd_b
matrix list dd_v

matrix bb=dd_b'
matrix vv=dd_v'
postfile coef str40 term double b se using "../output/dd.dta", replace
local terms : colnames bb
local j=0
foreach term of local terms {
local ++j
post coef ("`term'") (bb[1,`j']) (sqrt(vv[1,`j']))
}
postclose coef
preserve
use "../output/dd.dta", clear
export delimited using "../output/dd.csv", replace
restore

display "COMPLETE_dd"
log close
