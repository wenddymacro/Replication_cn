clear all
set more off
set processors 1
set seed 824
adopath ++ "../output/local_ado"
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
log using "../output/cs.log", text replace
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
csdid TFP $xlist, ivar(stkcd) time(year) gvar(setup_mis) method(dripw) long2 cluster(city)
estat event, window(-3 3) post
estimates store cs_est
estimates restore cs_est
matrix cs_b = e(b)
matrix cs_v = e(V)
// long2下-1期为基期、不单独估计；若结果中无Tm1，则补0
if missing(colnumb(cs_b, "Tm1")) {
local cn : colnames cs_b
matrix cs_b = cs_b, (0)
matrix colnames cs_b = `cn' Tm1
local k = colsof(cs_v)
matrix cs_v = (cs_v, J(`k', 1, 0)) \ J(1, `k' + 1, 0)
matrix colnames cs_v = `cn' Tm1
matrix rownames cs_v = `cn' Tm1
}

estimates save "../output/cs.ster", replace

matrix bb=cs_b
matrix vv=cs_v
postfile coef str40 term double b se using "../output/cs.dta", replace
local terms : colnames bb
local j=0
foreach term of local terms {
local ++j
post coef ("`term'") (bb[1,`j']) (sqrt(vv[`j',`j']))
}
postclose coef
preserve
use "../output/cs.dta", clear
export delimited using "../output/cs.csv", replace
restore

display "COMPLETE_cs"
log close
