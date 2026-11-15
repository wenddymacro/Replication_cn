*********************************************************************************
* 《跨境电商平台与国内就业——基于企业和地区双重视角的考察》
* Stata version: Stata/MP 18.0
* reghdfe version: version 6.12.5 27Dec2023
********************************************************************************



clear all
clear mata
clear matrix
set more off

capture log close

* 定义数据和结果路径
global regdata = "[存储路径]/Data"
global result  = "[存储路径]/Result"
* 定义日志文件
log using "$result/正文程序运行日志.log", replace text
display "程序开始时间：$S_DATE $S_TIME"


*-------------------------------------------------------------------------------
**#                    基 准 回 归 —— 表1  
*-------------------------------------------------------------------------------
use $regdata/dataset_benchmark.dta, clear
// 统一设置
global xlist    "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global cityvar  "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
global absorb1  "absorb(id cic2_code#year) cluster(id)"
global outreg   "outreg2 using $result/table1.xls, append dec(4) ad(4)"
global option   "addtext(ctrs, yes,firm fe, yes,cic2-year fe, yes)"
// 缩尾
local vars outcome lnwage lnoutput lnklr profit leverage lnconstraints 
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
// 回归
reghdfe outcome dd, absorb(id year)
	$outreg ctitle(Employ) keep(dd) addtext(firm fe, yes,year fe, yes) adds(adjusted R2, `e(r2_a)')
reghdfe outcome dd, $absorb1
	$outreg ctitle(Employ) keep(dd) addtext(firm fe, yes,cic2-year fe, yes) adds(adjusted R2, `e(r2_a)')
reghdfe outcome dd $xlist, $absorb1
	$outreg ctitle(Employ) keep(dd) addtext(firm ctrs, yes,firm fe, yes,cic2-year fe, yes) adds(adjusted R2, `e(r2_a)')
reghdfe outcome dd $xlist $cityvar, $absorb1
	$outreg ctitle(Employ) keep(dd) $option adds(adjusted R2, `e(r2_a)')

	

*-------------------------------------------------------------------------------
**#                    内生性处理 —— 表2 
*-------------------------------------------------------------------------------
// 统一设置
global ivoption  "absorb(id cic2_code#year) cluster(id) first savefirst"
global outregs2  "outreg2 using $result/table2.xls, append dec(4) ad(4)"
global outregs1  "outreg2 using $result/table2.xls, append dec(4)"
global ivaddtext "addtext(ctrs, yes,firm fe, yes,cic2-year fe, yes)"

// IV1: Bartik 
ivreghdfe outcome (dd = iv1) $xlist $cityvar, $ivoption
	$outregs2 ctitle(Employ-2nd stage) keep(dd) adds(F-test, `e(rkf)',KP-F, `e(widstat)',KP-LM, `e(idstat)',KP-LM-p, `e(idp)') $ivaddtext
	estimates restore _ivreg2_dd  
	$outregs1 ctitle(Employ-1st stage) keep(iv1) 

// IV2: 地形坡度
ivreghdfe outcome (dd = iv2) $xlist $cityvar, $ivoption
	$outregs2 ctitle(Employ-2nd stage) keep(dd) adds(F-test, `e(rkf)',KP-F, `e(widstat)',KP-LM, `e(idstat)',KP-LM-p, `e(idp)') $ivaddtext
	estimates restore _ivreg2_dd  
	$outregs1 ctitle(Employ-1st stage) keep(iv2) 



*-------------------------------------------------------------------------------
**#                    机 制 检 验 —— 表3～表6 
*-------------------------------------------------------------------------------
**##   1. 贸易规模扩张效应 —— 表3
global outreg   "outreg2 using $result/table3.xls, append dec(4) ad(4)"

// (1) 进口企业
use $regdata/dataset_imp1.dta, clear
* 统一设置
global xlist    "soe lntariff imp_processtrade lnrer lnpercgdp lnoutput lnklr profit leverage lnconstraints"
* 缩尾
local vars outcome lnoutput lnklr profit leverage lnconstraints lnimp lntariff imp_processtrade lnrer lnpercgdp lndist
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
* 回归
reghdfe lnimp ddlist $xlist $cityvar, $absorb1 
	$outreg ctitle(Import) keep(ddlist) adds(adjusted R2, `e(r2_a)') $option
reghdfe outcome lnimp $xlist $cityvar, $absorb1 
	$outreg ctitle(Employ) keep(lnimp) adds(adjusted R2, `e(r2_a)') $option


// (2) 出口企业
use $regdata/dataset_exp.dta, clear
* 统一设置
global xlist    "soe lntariff exp_processtrade lnrer lnpercgdp lnoutput lnklr profit leverage lnconstraints"
* 缩尾
local vars outcome lnoutput lnklr profit leverage lnconstraints lnexp lntariff exp_processtrade lnrer lnpercgdp lndist
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
* 回归
reghdfe lnexp   dd $xlist $cityvar, $absorb1
	$outreg ctitle(Export) keep(dd) adds(adjusted R2, `e(r2_a)') $option
reghdfe outcome lnexp $xlist $cityvar, $absorb1
	$outreg ctitle(Employ) keep(lnexp) adds(adjusted R2, `e(r2_a)') $option


*------------------------------------
**##   2. 经营范围扩张效应 —— 表4～表5
// (1) 市场范围
global outreg   "outreg2 using $result/table4.xls, append dec(4) ad(4)"
*- 1> 内销企业开始出口
preserve
	use $regdata/dataset_benchmark.dta, clear
	* 统一设置
	global xlist    "soe lnoutput lnklr profit leverage lnconstraints"
	* 缩尾
	local vars outcome lnwage lnoutput lnklr profit leverage lnconstraints 
	foreach i of local vars {
		winsor2 `i', cut(1 99) replace
	}
	local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
	foreach i of local vars {
		winsor2 `i', cut(1 99) replace
	}
	* 回归
	drop if (firstyear_exp < start_year) & !mi(firstyear_exp)&!mi(start_year)  //剔除首次参与出口年份早于加入电商平台年份的企业
	drop if (firstyear_exp < 2007) & !mi(firstyear_exp)  //仅保留首次参与出口年份在2007年之后的企业
	gen start_exp = (firstyear_exp <= year & !mi(firstyear_exp))  //首次出口前为0，首次出口当年及以后为1
	reghdfe start_exp dd $xlist $cityvar, $absorb1
		$outreg ctitle(Start Exp) keep(dd) adds(adjusted R2, `e(r2_a)') $option
	reghdfe outcome start_exp $xlist $cityvar, $absorb1 
		$outreg ctitle(Employ) keep(start_exp) adds(adjusted R2, `e(r2_a)') $option	
restore

*- 2> 出口市场多元化
global xlist    "soe lntariff exp_processtrade lnrer lnpercgdp lnoutput lnklr profit leverage lnconstraints"
reghdfe lncoun dd $xlist $cityvar, $absorb1
	$outreg ctitle(Country num) keep(dd) adds(adjusted R2, `e(r2_a)') $option
reghdfe outcome lncoun $xlist $cityvar, $absorb1
	$outreg ctitle(Employ) keep(lncoun) adds(adjusted R2, `e(r2_a)') $option


// (2) 产品范围
global outreg   "outreg2 using $result/table5.xls, append dec(4) ad(4)"
global xlist    "soe lntariff exp_processtrade lnrer lnpercgdp lnoutput lnklr profit leverage lnconstraints"
* 出口产品种类数量
reghdfe lnhs6n dd $xlist $cityvar, $absorb1
	$outreg ctitle(HS6 num) keep(dd) adds(adjusted R2, `e(r2_a)') $option
* 差异化产品出口种类数量
reghdfe lnheten dd $xlist $cityvar, $absorb1
	$outreg ctitle(Hete HS6 num) keep(dd) adds(adjusted R2, `e(r2_a)') $option
reghdfe lnhomon dd $xlist $cityvar, $absorb1 
	$outreg ctitle(Homo HS6 num) keep(dd) adds(adjusted R2, `e(r2_a)') $option
* employ
reghdfe outcome lnhs6n $xlist $cityvar, $absorb1
	$outreg ctitle(Employ) keep(lnhs6n) adds(adjusted R2, `e(r2_a)') $option



*------------------------------------
**##   3. 生产效率提升效应 —— 表6
use $regdata/dataset_benchmark.dta, clear
// 统一设置
global xlist    "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global outreg   "outreg2 using $result/table6.xls, append dec(4) ad(4)"
// 缩尾
local vars outcome lnwage lnoutput lnklr profit leverage lnconstraints 
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
// 回归
*- LP
cap drop tfp
winsor2 tfp_lp, cut(1 99)
ren tfp_lp_w tfp
* CBEC → TFP
reghdfe tfp dd $xlist $cityvar, $absorb1
	$outreg ctitle(TFP_LP) keep(dd) adds(adjusted R2, `e(r2_a)') $option
* TFP → employ
reghdfe outcome tfp $xlist $cityvar, $absorb1
	$outreg ctitle(Employ) keep(tfp) adds(adjusted R2, `e(r2_a)') $option

*- OP
cap drop tfp
winsor2 tfp_op, cut(1 99)
ren tfp_op_w tfp
* CBEC → TFP
reghdfe tfp dd $xlist $cityvar, $absorb1
	$outreg ctitle(TFP_OP) keep(dd) adds(adjusted R2, `e(r2_a)') $option
* TFP → employ
reghdfe outcome tfp $xlist $cityvar, $absorb1 
	$outreg ctitle(Employ) keep(tfp) adds(adjusted R2, `e(r2_a)') $option




*-------------------------------------------------------------------------------
**#                    城市层面的进一步分析 —— 表7～表8
*-------------------------------------------------------------------------------
***   1. 跨境电商发展对城市就业总量的影响 —— 表7
use $regdata/dataset_city1.dta, clear
// 统一设置
global cityvar      "lnpergdp lnpopulation lncitywage structure lnperfdi internet fiscal_ratio"
global absorb_city  "absorb(citycode prov#year) cluster(citycode)"
global outreg       "outreg2 using $result/table7.xls, append dec(4) ad(4)"
global option       "addtext(ctrs, yes,city fe, yes,prov-year fe, yes)"
// 回归
xtset citycode year
reghdfe city_employment1 L.lncbec_city, $absorb_city
	$outreg ctitle(City Employ1) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') addtext(city fe, yes,prov-year fe, yes) 
reghdfe city_employment1 L.lncbec_city L.($cityvar), $absorb_city
	$outreg ctitle(City Employ1) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe city_employment2 L.lncbec_city, $absorb_city
	$outreg ctitle(City Employ2) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') addtext(city fe, yes,prov-year fe, yes)
reghdfe city_employment2 L.lncbec_city L.($cityvar), $absorb_city
	$outreg ctitle(City Employ2) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
xtset, clear


***   2. 跨境电商发展与城市内企业间的就业结构 —— 表8
global outreg   "outreg2 using $result/table8.xls, append dec(4) ad(4)"

use $regdata/dataset_city3.dta, clear
// 回归
xtset citycode year
reghdfe lnemp_cbec L.(lncbec_city $cityvar), $absorb_city 
	$outreg ctitle(CBEC Employ) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe lnemp_nocbec L.(lncbec_city $cityvar), $absorb_city 
	$outreg ctitle(nonCBEC Employ) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe pr_cbec   L.(lncbec_city $cityvar), $absorb_city 
	$outreg ctitle(CBEC Employ ratio) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe pr_emp L.(lncbec_city $cityvar), $absorb_city 
	$outreg ctitle(CBEC / nonCBEC) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option

xtset, clear




display "程序结束时间：$S_DATE $S_TIME"
log close



