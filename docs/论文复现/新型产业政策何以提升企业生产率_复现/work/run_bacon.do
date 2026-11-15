clear all
set more off
set processors 1
set seed 824
adopath ++ "../output/local_ado"
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
log using "../output/bacon.log", text replace
quietly reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
gen esample=e(sample)
preserve
keep $xlist chainleader_l TFP chainleader stkcd year indid prv city cityname esample
xtset stkcd year
bysort stkcd: egen temp_prv=max(prv)
bysort stkcd: egen temp_indid=max(indid)
bysort stkcd: egen temp_chainleader_l=max(chainleader_l)
bysort stkcd: egen temp_city=max(city)
bysort stkcd: egen temp2_city=min(city)
replace prv=temp_prv if prv==.
replace indid=temp_indid if indid==.
replace chainleader_l=temp_chainleader_l if chainleader_l==.
replace city=temp_city if city==.
gen poschange=temp_city-temp2_city
drop if poschange~=0
// 插值
foreach var of global xlist{
by stkcd: ipolate `var' year, gen(ipo_`var') epolate
}
by stkcd: ipolate TFP year, gen(TFP_ipo) epolate
// 平衡面板
xtbalance , range(2014 2023) miss(ipo_*)
// 回归+分解
bacondecomp TFP_ipo chainleader ipo_* ,ddetail vce(r)
ereturn list
return list
capture estimates save "../output/bacon.ster", replace
graph export "../output/附图5_Goodman-Bacon分解的权重.png",replace
restore
*************************************************************
***                                                       ***
***         附图 6 平行趋势检验:异质性效应处理方法        ***
***                                                       ***
*************************************************************

display "COMPLETE_bacon"
log close
