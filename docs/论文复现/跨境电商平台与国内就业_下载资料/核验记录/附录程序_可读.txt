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
log using "$result/附录程序运行日志.log", replace text
display "程序开始时间：$S_DATE $S_TIME"


*-------------------------------------------------------------------------------
**#                    一、描述性统计 —— 附表1
*-------------------------------------------------------------------------------
use $regdata/dataset_benchmark.dta, clear
// 统一设置
global xlist    "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global cityvar  "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
// 缩尾
local vars outcome lnwage lnoutput lnklr profit leverage lnconstraints 
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
// 描述性统计结果
asdoc sum dd outcome $xlist $cityvar, dec(4), save($result/appendix-table1-描述性统计.doc) title("附表1描述性统计")



*-------------------------------------------------------------------------------
**#                    二、特征事实分析 —— 附图1
*-------------------------------------------------------------------------------
preserve
	collapse (mean) w_emp_cbec w_emp_noncbec s_emp_cbec s_emp_noncbec, by(year)
	
	* 画图
	graph set window fontface "Times New Roman"
	graph set window fontfacesans "宋体"
	set scheme cleanplots
	twoway ( line w_emp_cbec    year, lp(solid) lc(black) )     ///
	       ( line w_emp_noncbec year, lp(dash)  lc(black) )     ///
		   ( line s_emp_cbec    year, lp(solid) lc(navy)  )     /// 
		   ( line s_emp_noncbec year, lp(dash)  lc(navy)  ) ,   ///
	       legend(label(1 "{stSans:CBEC企业(加权平均)}") label(2 "{stSans:非CBEC企业(加权平均)}")   ///
				  label(3 "{stSans:CBEC企业(简单平均)}") label(4 "{stSans:非CBEC企业(简单平均)}") row(4) size(*0.9) ring(1) position(7))
	graph export $result/appendix-附图1_不同类型企业的平均就业人数变化趋势.png, replace
restore



*-------------------------------------------------------------------------------
**#                    三、工具变量的有效性讨论 —— 附表2～3
*-------------------------------------------------------------------------------
// 统一设置
global xlist     "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global cityvar   "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
global absorb1   "absorb(id cic2_code#year) cluster(id)"
global option    "addtext(ctrs, yes,firm fe, yes,cic2-year fe, yes)"
global ivoption  "absorb(id cic2_code#year) cluster(id) first savefirst"
global ivaddtext "addtext(ctrs, yes,firm fe, yes,cic2-year fe, yes)"

// (1) IV对其他城市层面变量的回归
global outregs2  "outreg2 using $result/appendix-table2.xls, append dec(4) ad(4)"
preserve
	sort  year  id
	gduplicates drop year citycode, force
	
	reghdfe lnpergdp     iv1 lnpopulation lncitywage structure lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(lnpergdp-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')
	reghdfe lnpopulation iv1 lnpergdp lncitywage structure lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(population-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')
	reghdfe lncitywage   iv1 lnpergdp lnpopulation structure lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(lncitywage-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')
	reghdfe structure    iv1 lnpergdp lnpopulation lncitywage lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(structure-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')
	reghdfe lnperfdi     iv1 lnpergdp lnpopulation lncitywage structure lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(lnperfdi-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')
	reghdfe lninternet   iv1 lnpergdp lnpopulation lncitywage structure lnperfdi gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(internet-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')
	reghdfe gov          iv1 lnpergdp lnpopulation lncitywage structure lnperfdi lninternet, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(fiscal_ratio-iv1) keep(iv1) adds(adjusted R2, `e(r2_a)')

	reghdfe lnpergdp     iv2 lnpopulation lncitywage structure lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(lnpergdp-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
	reghdfe lnpopulation iv2 lnpergdp lncitywage structure lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(population-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
	reghdfe lncitywage   iv2 lnpergdp lnpopulation structure lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(lncitywage-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
	reghdfe structure    iv2 lnpergdp lnpopulation lncitywage lnperfdi lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(structure-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
	reghdfe lnperfdi     iv2 lnpergdp lnpopulation lncitywage structure lninternet gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(lnperfdi-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
	reghdfe lninternet   iv2 lnpergdp lnpopulation lncitywage structure lnperfdi gov, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(internet-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
	reghdfe gov          iv2 lnpergdp lnpopulation lncitywage structure lnperfdi lninternet, absorb(year citycode prov#year) cluster(citycode)
		$outregs2 ctitle(fiscal_ratio-iv2) keep(iv2) adds(adjusted R2, `e(r2_a)')
restore

// (2) 两个IV与基准回归残差项的相关性
qui reghdfe outcome dd $xlist $cityvar, $absorb1 resid
predict res, resid
pwcorr iv1 res  //相关系数是0.0002
pwcorr iv2 res  //相关系数是0.0007

// (3) Bartik IV 的敏感性分析
global outregs2  "outreg2 using $result/appendix-table3.xls, append dec(4) ad(4)"
global outregs1  "outreg2 using $result/appendix-table3.xls, append dec(4)"
*- 构造所有工具变量共同可用的固定样本
cap drop common_samp
qui ivreghdfe outcome (dd = iv1) $xlist $cityvar ///
    if !missing(biv_ex_t1, biv_ex_t3, biv_ex_t5, biv_ex_t10), $ivoption
gen byte common_samp = e(sample)

*- drop top1 industry
ivreghdfe outcome (dd = biv_ex_t1) $xlist $cityvar if common_samp == 1, $ivoption
	$outregs2 ctitle(Employ-2nd stage-Common samp) keep(dd) adds(F-test, `e(rkf)',KP-F, `e(widstat)',KP-LM, `e(idstat)',KP-LM-p, `e(idp)') $ivaddtext
	estimates restore _ivreg2_dd  
	$outregs1 ctitle(Employ-1st stage) keep(biv_ex_t1) 

*- drop top3 industries
ivreghdfe outcome (dd = biv_ex_t3) $xlist $cityvar if common_samp == 1, $ivoption
	$outregs2 ctitle(Employ-2nd stage-Common samp) keep(dd) adds(F-test, `e(rkf)',KP-F, `e(widstat)',KP-LM, `e(idstat)',KP-LM-p, `e(idp)') $ivaddtext
	estimates restore _ivreg2_dd  
	$outregs1 ctitle(Employ-1st stage) keep(biv_ex_t3) 

*- drop top5 industries
ivreghdfe outcome (dd = biv_ex_t5) $xlist $cityvar if common_samp == 1, $ivoption
	$outregs2 ctitle(Employ-2nd stage-Common samp) keep(dd) adds(F-test, `e(rkf)',KP-F, `e(widstat)',KP-LM, `e(idstat)',KP-LM-p, `e(idp)') $ivaddtext
	estimates restore _ivreg2_dd  
	$outregs1 ctitle(Employ-1st stage) keep(biv_ex_t5) 

*- drop top10 industries
ivreghdfe outcome (dd = biv_ex_t10) $xlist $cityvar if common_samp == 1, $ivoption
	$outregs2 ctitle(Employ-2nd stage-Common samp) keep(dd) adds(F-test, `e(rkf)',KP-F, `e(widstat)',KP-LM, `e(idstat)',KP-LM-p, `e(idp)') $ivaddtext
	estimates restore _ivreg2_dd  
	$outregs1 ctitle(Employ-1st stage) keep(biv_ex_t10) 




*-------------------------------------------------------------------------------
**#                    四、PSM & Heckman —— 附表4
*-------------------------------------------------------------------------------
//   PSM
global xlist     "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global cityvar   "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
global absorb1   "absorb(id cic2_code#year) cluster(id)"
global outreg    "outreg2 using $result/appendix-table4.xls, append dec(4) ad(4)"

*- 近邻匹配
use $regdata/dataset_psm1.dta, clear
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
reghdfe outcome dd $xlist $cityvar, $absorb1
	$outreg ctitle(Employ-n4-Weight !=.) keep(dd) adds(adjusted R2, `e(r2_a)') $option


*- 半径匹配
use $regdata/dataset_psm2.dta, clear
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
reghdfe outcome dd $xlist $cityvar, $absorb1
	$outreg ctitle(Employ-cal01-Weight !=.) keep(dd) adds(adjusted R2, `e(r2_a)') $option



//   Heckman
use $regdata/dataset_benchmark.dta, clear
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
cap drop imr
etregress outcome $xlist $cityvar, treat(dd = exclv $xlist $cityvar) twostep hazard(imr) first vce(conventional)
est store heck
esttab heck, b(%9.4f) se(%9.4f) sfmt(%9.4f) star(* 0.1 ** 0.05 *** 0.01)





*-------------------------------------------------------------------------------
**#                    五、稳健性检验 —— 附表5～7
*-------------------------------------------------------------------------------
use $regdata/dataset_benchmark.dta, clear
// 统一设置
global xlist    "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global cityvar  "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
global absorb1  "absorb(id cic2_code#year) cluster(id)"
global outreg   "outreg2 using $result/appendix-table5.xls, append dec(4) ad(4)"
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

*- 1. 替换X
* (1) 海关跨境电子商务企业名录
preserve	
	drop if cbtradetype_1 == 0  //仅保留备案登记信息为"跨境电子商务企业"的企业
	reghdfe outcome hgcbec $xlist $cityvar, $absorb1 
	$outreg ctitle(HG-CBEClist) keep(hgcbec) $option adds(adjusted R2, `e(r2_a)')
restore
* (2) 滞后一期
xtset id year
reghdfe outcome L.(dd $xlist $cityvar), $absorb1
	$outreg ctitle(Lag 1 year) keep(L.dd) $option adds(adjusted R2, `e(r2_a)')
xtset, clear

*- 2. 替换Y
xtset id year
gen growth = log( (D.a528/L.a528)+1 )
qui winsor2 growth, cut(1 99) replace
reghdfe growth L.(dd $xlist $cityvar), $absorb1
	$outreg ctitle(ln Growth Rate) keep(L.dd) $option adds(adjusted R2, `e(r2_a)')
xtset, clear

*- 3. 控制高维固定效应
global absorb2    "absorb(id cic2_code#year citycode#year) cluster(id)"
global absorb3    "absorb(id cic2_code#citycode#year) cluster(id)"
reghdfe outcome dd $xlist, $absorb2
	$outreg ctitle(city-year FE) keep(dd) addtext(ctrs, yes,firm fe, yes,cic2-year fe, yes,city-year fe, yes) adds(adjusted R2, `e(r2_a)')
reghdfe outcome dd $xlist, $absorb3
	$outreg ctitle(cic2-city-year FE) keep(dd) addtext(ctrs, yes,firm fe, yes,cic2-city-year fe, yes) adds(adjusted R2, `e(r2_a)')

*- 4. 调整标准误聚类层级
global absorb4    "absorb(id cic2_code#year) cluster(citycode#cic2_code)"
reghdfe outcome dd $xlist, $absorb4
	$outreg ctitle(city-cic2 stderr) keep(dd) $option adds(adjusted R2, `e(r2_a)')

*- 5. 排除同期相关政策
global outreg   "outreg2 using $result/appendix-table6.xls, append dec(4) ad(4)"
*5.1 跨境电商综试区
reghdfe outcome dd $xlist $cityvar trial1, $absorb1
	$outreg ctitle(PilotZones) keep(dd) $option adds(adjusted R2, `e(r2_a)')

*5.2 跨境电子商务服务试点城市
reghdfe outcome dd $xlist $cityvar trial2, $absorb1
	$outreg ctitle(ServiceCity) keep(dd) $option adds(adjusted R2, `e(r2_a)')

*5.3 国家电子商务示范城市
reghdfe outcome dd $xlist $cityvar trial3, $absorb1
	$outreg ctitle(CommerceCity) keep(dd) $option adds(adjusted R2, `e(r2_a)')

*5.4 自由贸易试验区
reghdfe outcome dd $xlist $cityvar trial4, $absorb1
	$outreg ctitle(FTA) keep(dd) $option adds(adjusted R2, `e(r2_a)')

*5.5 宽带中国示范城市
reghdfe outcome dd $xlist $cityvar trial5, $absorb1
	$outreg ctitle(Broadband) keep(dd) $option adds(adjusted R2, `e(r2_a)')

*5.6 纳入所有政策
reghdfe outcome dd $xlist $cityvar trial1-trial5, $absorb1
	$outreg ctitle(AllPolicy) keep(dd) $option adds(adjusted R2, `e(r2_a)')


*- 6. 更换研究样本
global outreg   "outreg2 using $result/appendix-table7.xls, append dec(4) ad(4)"
// (1) 长期存续企业
bys id: gen firmn = _N
reghdfe outcome dd $xlist $cityvar if firmn >= 5, $absorb1
	$outreg ctitle(continuous firm-5) keep(dd) adds(adjusted R2, `e(r2_a)') $option 
cap drop firmn

// (2) 不同年份区间：2007-2011；2012-2016
reghdfe outcome dd $xlist $cityvar if year>=2007&year<=2011, $absorb1
	$outreg ctitle(2007-2011) keep(dd) adds(adjusted R2, `e(r2_a)') $option 
reghdfe outcome dd $xlist $cityvar if year>=2012&year<=2016, $absorb1
	$outreg ctitle(2012-2016) keep(dd) adds(adjusted R2, `e(r2_a)') $option 

// (3) 剔除超级城市和电商核心城市
preserve
	drop if citycode == 110000 | citycode == 310000 | citycode == 440100 | citycode == 440300 | citycode == 330100
	reghdfe outcome dd $xlist $cityvar, $absorb1
		$outreg ctitle(delete supercity) keep(dd) adds(adjusted R2, `e(r2_a)') $option 
restore

// (4) 出口企业
use $regdata/dataset_exp.dta, clear
* 缩尾
local vars outcome lnwage lnoutput lnklr profit leverage lnconstraints lnexp exp_processtrade
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
* 回归
reghdfe outcome dd lnexp exp_processtrade $xlist $cityvar, $absorb1
	$outreg ctitle(Export Firm) keep(dd) $option adds(adjusted R2, `e(r2_a)')


// (5) 进口企业
use $regdata/dataset_imp1.dta, clear
* 缩尾
local vars outcome lnwage lnoutput lnklr profit leverage lnconstraints lnimp imp_processtrade
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
* 回归
reghdfe outcome ddlist lnimp imp_processtrade $xlist $cityvar, $absorb1
	$outreg ctitle(ImportFirm-list) keep(ddlist) $option adds(adjusted R2, `e(r2_a)')


// (6) 上市企业样本
use $regdata/dataset_stk.dta, clear
* 统一设置
global xlist      "size age soe liability roa capint wager"
global absorb_stk "absorb(fid ind#year citycode#year) cluster(fid)"
* 缩尾
local vars outcome size age liability roa capint wager
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
* 回归
reghdfe outcome dd $xlist, $absorb_stk
	$outreg ctitle(Employ-stk firm) keep(dd) $option adds(adjusted R2, `e(r2_a)')


// (7) 工企样本
use $regdata/dataset_gq.dta, clear
* 统一设置
global xlist    "soe age export2 wager abs_scale per_cap_1 profit_ratio liability"
global cityvar  "lnpergdp lnpopulation lncitywage structure lnperfdi internet fiscal_ratio"
global absorb1  "absorb(id cic2_code#year) cluster(id)"
* 缩尾
local vars outcome age wager abs_scale per_cap_1 profit_ratio liability
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi internet fiscal_ratio
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
* 回归
reghdfe outcome dd $xlist $cityvar, $absorb1  
	$outreg ctitle(GQdata) keep(dd) $option adds(adjusted R2, `e(r2_a)')




*-------------------------------------------------------------------------------
**#                    六、异质性分析 —— 附表8
*-------------------------------------------------------------------------------
use $regdata/dataset_benchmark.dta, clear
// 统一设置
global xlist    "soe export1 import1 lnwage lnoutput lnklr profit leverage lnconstraints"
global cityvar  "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
global absorb1  "absorb(id cic2_code#year) cluster(id)"
global outreg   "outreg2 using $result/appendix-table8.xls, append dec(4) ad(4)"
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
    
// 1. 企业规模
reghdfe outcome c.group_scale##c.(dd $xlist $cityvar), $absorb1
	$outreg ctitle(Firm Scale) keep(dd c.group_scale#c.dd) adds(adjusted R2, `e(r2_a)') $option

// 2. 企业的融资约束程度
reghdfe outcome c.group_ins_fs##c.(dd $xlist $cityvar), $absorb1
	$outreg ctitle(inside Constraints) keep(dd c.group_ins_fs#c.dd) adds(adjusted R2, `e(r2_a)') $option

reghdfe outcome c.group_out_fc##c.(dd $xlist $cityvar), $absorb1
	$outreg ctitle(outside Constraints) keep(dd c.group_out_fc#c.dd) adds(adjusted R2, `e(r2_a)') $option

// 3. 企业所处行业的竞争环境
reghdfe outcome c.group_hhi##c.(dd $xlist $cityvar), $absorb1 
	$outreg ctitle(HHI) keep(dd c.group_hhi#c.dd) adds(adjusted R2, `e(r2_a)') $option

// 4. 城市层级
reghdfe outcome c.group_city##c.(dd $xlist $cityvar), $absorb1  
	$outreg ctitle(City perGDP) keep(dd c.group_city#c.dd) adds(adjusted R2, `e(r2_a)') $option





*-------------------------------------------------------------------------------
**#                    七、进口来源结构的影响 —— 附表9
*-------------------------------------------------------------------------------
use $regdata/dataset_imp1.dta, clear
// 统一设置
global xlist    "soe lntariff imp_processtrade lnrer lnpercgdp lnoutput lnklr profit leverage lnconstraints"
global cityvar  "lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov"
global absorb1  "absorb(id cic2_code#year) cluster(id)"
global outreg   "outreg2 using $result/appendix-table9.xls, append dec(4) ad(4)"
global option   "addtext(ctrs, yes,firm fe, yes,cic2-year fe, yes)"
// 缩尾
local vars outcome lnoutput lnklr profit leverage lnconstraints lnimp lntariff imp_processtrade lnrer lnpercgdp lndist
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
// 回归
winsor2 lnlow lnhigh, cut(1 99) replace
reghdfe lnhigh ddlist $xlist $cityvar, $absorb1 
	$outreg ctitle(Highinc Import) keep(ddlist) adds(adjusted R2, `e(r2_a)') $option
reghdfe lnlow  ddlist $xlist $cityvar, $absorb1 
	$outreg ctitle(Lowinc Import) keep(ddlist) adds(adjusted R2, `e(r2_a)') $option
reghdfe outcome lnhigh lnlow $xlist $cityvar, $absorb1 
	$outreg ctitle(Employ) keep(lnhigh lnlow) adds(adjusted R2, `e(r2_a)') $option



use $regdata/dataset_imp2.dta, clear
// 缩尾
local vars outcome lnoutput lnklr profit leverage lnconstraints lnimp lntariff imp_processtrade lnrer lnpercgdp lndist
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
local vars lnpergdp lnpopulation lncitywage structure lnperfdi lninternet gov
foreach i of local vars {
	winsor2 `i', cut(1 99) replace
}
// 回归
winsor2 lnlow lnhigh, cut(1 99) replace
reghdfe lnhigh hgcbec $xlist $cityvar, $absorb1 
	$outreg ctitle(Highinc Import) keep(hgcbec) adds(adjusted R2, `e(r2_a)') $option
reghdfe lnlow  hgcbec $xlist $cityvar, $absorb1 
	$outreg ctitle(Lowinc Import) keep(hgcbec) adds(adjusted R2, `e(r2_a)') $option




*-------------------------------------------------------------------------------
**#                    八、跨境电商发展与周边城市就业 —— 附表10
*-------------------------------------------------------------------------------
use $regdata/dataset_city2.dta, clear
// 统一设置
global cityvarA        "L_lnpergdp_A L_lnpopulation_A L_lncitywage_A L_structure_A L_lnperfdi_A L_internet_A L_fiscal_ratio_A"
global cityvarB        "L_lnpergdp_B L_lnpopulation_B L_lncitywage_B L_structure_B L_lnperfdi_B L_internet_B L_fiscal_ratio_B"
global absorb_adjacent "absorb(citycode_A#citycode_B year) cluster(citycode_A#citycode_B)"
global outreg          "outreg2 using $result/appendix-table10.xls, append dec(4) ad(4)"
global option          "addtext(ctrs, yes,cityA-cityB fe, yes,year fe, yes)"
// 回归
reghdfe city_employment1_A L_lncbec_num2_B L_lncbec_num2_A, $absorb_adjacent
	$outreg ctitle(City Employ1) keep(L_lncbec_num2_B L_lncbec_num2_A) adds(adjusted R2, `e(r2_a)') addtext(cityA-cityB fe, yes,year fe, yes)
reghdfe city_employment1_A L_lncbec_num2_B L_lncbec_num2_A $cityvarA $cityvarB, $absorb_adjacent
	$outreg ctitle(City Employ1) keep(L_lncbec_num2_B L_lncbec_num2_A) adds(adjusted R2, `e(r2_a)') $option
reghdfe city_employment2_A L_lncbec_num2_B L_lncbec_num2_A, $absorb_adjacent
	$outreg ctitle(City Employ2) keep(L_lncbec_num2_B L_lncbec_num2_A) adds(adjusted R2, `e(r2_a)') addtext(cityA-cityB fe, yes,year fe, yes)
reghdfe city_employment2_A L_lncbec_num2_B L_lncbec_num2_A $cityvarA $cityvarB, $absorb_adjacent
	$outreg ctitle(City Employ2) keep(L_lncbec_num2_B L_lncbec_num2_A) adds(adjusted R2, `e(r2_a)') $option



*-------------------------------------------------------------------------------
**#                    九、跨境电商发展与城市内行业间就业结构 —— 附表11
*-------------------------------------------------------------------------------
use $regdata/dataset_city1.dta, clear
// 统一设置
global cityvar      "lnpergdp lnpopulation lncitywage structure lnperfdi internet fiscal_ratio"
global absorb_city  "absorb(citycode prov#year) cluster(citycode)"
global outreg       "outreg2 using $result/appendix-table11.xls, append dec(4) ad(4)"
global option       "addtext(ctrs, yes,city fe, yes,prov-year fe, yes)"
// 回归
xtset citycode year
*- 三产就业
reghdfe lnsector1 L.lncbec_city L.($cityvar), $absorb_city
	$outreg ctitle(Sector 1) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe lnsector2 L.lncbec_city L.($cityvar), $absorb_city
	$outreg ctitle(Sector 2) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe lnsector3 L.lncbec_city L.($cityvar), $absorb_city
	$outreg ctitle(Sector 3) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option

*- 生产性服务业
reghdfe prod_serv_r      L.lncbec_city L.($cityvar), $absorb_city
	$outreg ctitle(Producer Service) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe prod_serv_high_r L.lncbec_city L.($cityvar), $absorb_city 
	$outreg ctitle(High Producer Service) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option
reghdfe prod_serv_low_r  L.lncbec_city L.($cityvar), $absorb_city 
	$outreg ctitle(Low Producer Service) keep(L.lncbec_city) adds(adjusted R2, `e(r2_a)') $option

xtset, clear



*-------------------------------------------------------------------------------
**#                    十、跨境电商发展与行业内就业变动 —— 附表12
*-------------------------------------------------------------------------------
use $regdata/dataset_city4.dta, clear
// 统一设置
global absorb_cic  "absorb(citycode#year cic2_code#year) cluster(citycode#cic2_code)"
global outreg      "outreg2 using $result/appendix-table12.xls, append dec(4) ad(4)"
global option      "addtext(ctrs, yes,city-year fe, yes,cic2-year fe, yes)"
// 回归
egen c_c = group(citycode cic2_code)
xtset c_c year
reghdfe delta_Emp L.lncbec_cc, $absorb_cic
	$outreg ctitle(delta_Emp) keep(L.lncbec_cc) adds(adjusted R2, `e(r2_a)') $option
reghdfe within    L.lncbec_cc, $absorb_cic
	$outreg ctitle(within) keep(L.lncbec_cc) adds(adjusted R2, `e(r2_a)') $option
reghdfe between   L.lncbec_cc, $absorb_cic 
	$outreg ctitle(between) keep(L.lncbec_cc) adds(adjusted R2, `e(r2_a)') $option
reghdfe crosss    L.lncbec_cc, $absorb_cic 
	$outreg ctitle(cross) keep(L.lncbec_cc) adds(adjusted R2, `e(r2_a)') $option
reghdfe entering  L.lncbec_cc, $absorb_cic 
	$outreg ctitle(entering) keep(L.lncbec_cc) adds(adjusted R2, `e(r2_a)') $option
reghdfe exiting   L.lncbec_cc, $absorb_cic 
	$outreg ctitle(exiting) keep(L.lncbec_cc) adds(adjusted R2, `e(r2_a)') $option

xtset, clear





display "程序结束时间：$S_DATE $S_TIME"
log close




