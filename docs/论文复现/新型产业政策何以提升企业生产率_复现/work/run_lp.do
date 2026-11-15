clear all
set more off
set processors 1
set seed 824
adopath ++ "../output/local_ado"
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
log using "../output/lp.log", text replace
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
xtset stkcd year
// new_treat=1 只在企业首次进入处理的当年出现
gen new_treat = D.chainleader
matrix lpdid_b = J(1, 8, 0)
matrix lpdid_v = J(8, 8, 0)
matrix colnames lpdid_b = pre4 pre3 pre2 pre1 post0 post1 post2 post3
matrix rownames lpdid_v = pre4 pre3 pre2 pre1 post0 post1 post2 post3
matrix colnames lpdid_v = pre4 pre3 pre2 pre1 post0 post1 post2 post3
// 事前安慰剂：Y_(t-h)-Y_(t-1)，h=4,3,2
foreach h in 4 3 2 {
gen dy_m`h' = L`h'.TFP - L.TFP
reghdfe dy_m`h' new_treat L.($xlist)  if new_treat == 1 | chainleader == 0,  absorb(prv#year indid#year) vce(cluster city)
local p = 5 - `h'
matrix lpdid_b[1, `p'] = _b[new_treat]
matrix lpdid_v[`p', `p'] = _se[new_treat]^2
}
// 事后动态效应：Y_(t+h)-Y_(t-1)，h=0,1,2,3
forvalues h = 0/3 {
if `h' == 0 {
gen dy_p0 = TFP - L.TFP
local clean "chainleader == 0"
}
else {
gen dy_p`h' = F`h'.TFP - L.TFP
local clean "F`h'.chainleader == 0"
}
reghdfe dy_p`h' new_treat L.($xlist)  if new_treat == 1 | (`clean'),  absorb(prv#year indid#year) vce(cluster city)
local p = `h' + 5
matrix lpdid_b[1, `p'] = _b[new_treat]
matrix lpdid_v[`p', `p'] = _se[new_treat]^2
}

matrix bb=lpdid_b
matrix vv=lpdid_v
postfile coef str40 term double b se using "../output/lp.dta", replace
local terms : colnames bb
local j=0
foreach term of local terms {
local ++j
post coef ("`term'") (bb[1,`j']) (sqrt(vv[`j',`j']))
}
postclose coef
preserve
use "../output/lp.dta", clear
export delimited using "../output/lp.csv", replace
restore

display "COMPLETE_lp"
log close
