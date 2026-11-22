********************************************************************************
*                         减税与企业工业机器人应用                             *
*                               中国工业经济                                   *
*                                2025年07月                                    *
*                                 Stata 17                                     *
********************************************************************************


clear all
cd  ""  //请设置本地目录

global fctrs "pre_size pre_lkl pre_export pre_import pre_robotstock pre_robotgrowth"   
global fe "firmid year cic4#year city#year year#c.($fctrs)"
global ppmlfe "firmid year cic4#year city#year year#c.pre_size year#c.pre_lkl year#c.pre_export year#c.pre_import year#c.pre_robotstock year#c.pre_robotgrowth"
global hefe "firmid year cic4#year city#year year#c.($fctrs) poe#year"
global ebctrs "pre_size pre_lkl pre_export pre_import"
global cl "firmid"




********************
**#  正文部分      *
********************

**#  正文图  

**图1 平行趋势假设评估
use "数据\tax_robot.dta",clear

xi:reghdfe asrobot d2004 d2005 d2006 d2008 d2009 d2011 d2012, absorb($fe) vce(cluster $cl)

foreach i of numlist 2004/2006 2008/2009 2011/2012{
gen double coef`i'=_b[d`i']
gen double se`i'=_se[d`i']
}

foreach i of numlist 2004/2006 2008/2009 2011/2012{
gen double up95`i'=coef`i'+1.96*se`i'
gen double down95`i'=coef`i'-1.96*se`i'
}

foreach i of numlist 2007{
gen coef`i' = 0 
gen se`i' = 0 
gen up95`i' = 0  
gen down95`i' = 0  
}

keep in 1
keep firmid coef* se* up95* down95*
reshape long coef se up95 down95,i(firmid) j(year)
keep year coef up95 down95
save "数据\图1.dta",replace

use "数据\图1.dta",clear

graph twoway  ///
	(scatter coef year, mcolor(black) msize(medium))  ///
	(rcap up95 down95 year, color(black) msize(medium) lcolor(black) lpattern(solid) lwidth(0.3)),  ///
	xline(2007, lcolor(black) lpattern(dash) lwidth(0.2))  ///
	yline(0, lcolor(black) lpattern(solid) lwidth(0.2))  ///
	legend(off)  ///
	ytitle("",justification(center) margin(small) size(2.5))  ///
	xtitle("",justification(center) margin(small) size(2.5))  ///
	xlabel(2004(1)2012,labsize(2.5) nogrid) ylabel(,labsize(2.5) nogrid)  ///
	title("",size(medium)) graphregion(color(white))
	graph export "结果\图\图1.pdf",replace


**#  正文表  
use "数据\tax_robot.dta",clear

**表1 基准回归结果
*第（1）列
reghdfe asrobot c.poe##c.post, absorb(firmid year) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post, absorb(firmid cic4#year) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post, absorb(firmid cic4#year city#year) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\表1.rtf", keep(c.poe#c.post) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**表2 机制分析：所得税实际税率下降
*第（1）列
ivreghdfe asrobot (etr_profit = poe_post), absorb($fe) cluster($cl) first savefirst savefp(f)
est restore fetr_profit

*第（2）列
ivreghdfe asrobot (etr_profit = poe_post), absorb($fe) cluster($cl)
est store r2

*第（3）列
ivreghdfe asrobot (etr_sales = poe_post), absorb($fe) cluster($cl) first savefirst savefp(f)
est restore fetr_sales

*第（4）列
ivreghdfe asrobot (etr_sales = poe_post), absorb($fe) cluster($cl) 
est store r4
esttab fetr_profit r2 fetr_sales r4 using "结果\表\表2.rtf", keep(poe_post etr_profit etr_sales) b(%9.4f) se nogap compress scalars(N widstat idstat) star(* 0.1 ** 0.05 *** 0.01) replace 
 
 
**表3 机制分析：要素替代效应
*第（1）列
reghdfe asrobotl c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asvaluewage c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post##c.dlaborshare, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe laborshare c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\表3.rtf", keep(c.poe#c.post c.poe#c.post#c.dlaborshare) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**表4 异质性分析：企业生产率与规模
*第（1）列
reghdfe asrobot c.poe##c.post##c.dtfp_gmm, absorb($hefe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post##c.dtfp_lp, absorb($hefe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post##c.dlarge_asset, absorb($hefe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post##c.dlarge_sales, absorb($hefe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\表4.rtf", keep(c.poe#c.post#c.dtfp_gmm c.poe#c.post#c.dtfp_lp c.poe#c.post#c.dlarge_asset c.poe#c.post#c.dlarge_sales) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace

 
**表5 异质性分析：市场竞争与需求
*第（1）列
reghdfe asrobot c.poe##c.post##c.dfirm_num, absorb($hefe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post##c.dhhi, absorb($hefe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post##c.dgdpper, absorb($hefe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post##c.dgdp, absorb($hefe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\表5.rtf", keep(c.poe#c.post#c.dfirm_num c.poe#c.post#c.dhhi c.poe#c.post#c.dgdpper c.poe#c.post#c.dgdp) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace



 
********************
**#  附录部分      *
********************

**#  附录图  

**附图1  2004—2019年主要国家制造业企业的工业机器人使用数量
use "数据\附图1.dta",clear

graph twoway /// 
	connect installations year if Country == "中国", lcolor(black) lp(solid) mcolor(black) msymbol(c) || ///
	connect installations year if Country == "美国", lcolor(black) lp(dash) mcolor(black) msymbol(t)  || ///
	connect installations year if Country == "德国", lcolor(black) lp(longdash_dot) mcolor(black) msymbol(s) || ///
	connect installations year if Country == "日本", lcolor(black) lp(shortdash) mcolor(black) msymbol(oh)  ///
	xlabel(2004(1)2019,labsize(2.5) angle(45) nogrid) xti("") ylabel(0(20)140,labsize(2.5) nogrid) ///
	xsize(20) ysize(12) scale(1.4)  ///
	ytitle("（千台）",justification(center) margin(small) size(2.5))  ///
    xtitle("",justification(center) margin(middle) size(2.5))  /// 
	xscale(titlegap(2))  ///
	leg(order(1 "中国" 2 "美国" 3 "德国" 4 "日本") size(2.5) symysize(2.5) symxsize(8) pos(6) ring(1) col(4) lpattern(blank)) ///
	graphregion(color(white))
	graph export "结果\图\附图1.pdf",replace


**附图2  2004—2012年内外资企业的所得税实际税率
use "数据\附图2.dta",clear

graph twoway /// 
	connect etr year if poe == 1, lcolor(black) lp(solid) msymbol(c) mcolor(black) ||  ///
	connect etr year if poe == 0, lcolor(black) lp(dash) msymbol(s) mcolor(black)  ///
	xlabel(2004(1)2012,labsize(2.5) nogrid) xti("") ylabel(5(5)25,labsize(2.5) nogrid)  ///
	xsize(20) ysize(12) scale(1.4)  ///
	xline(2007, lcolor(black) lpattern(dash) lwidth(0.2))  ///
	ytitle("（%）",justification(center) margin(small) size(2.5))  ///
    xtitle("",justification(center) margin(small)size(2.5))  /// 
	leg(order(1 "内资企业" 2 "外资企业") size(2.5) symysize(2.5) symxsize(8) pos(6) ring(1) col(2) lpattern(blank))  ///
	graphregion(color(white))  
	graph export "结果\图\附图2.pdf",replace
	
	
**附图3  2004—2012年民营企业和外资企业的平均工业机器人存量对比
use "数据\附图3.dta",clear

graph twoway /// 
	connect poe_foe_ratio year, lcolor(black) lp(solid) mcolor(black)  ///
	xlabel(2004(1)2012,labsize(2.5) nogrid) xti("") ylabel(,labsize(2.5) nogrid)  ///
	xsize(20) ysize(12) scale(1.4)  ///
	ytitle("民营企业/外资企业",justification(center) margin(small) size(2.5))  ///
	xtitle("",justification(center) margin(small)size(2.5))  /// 
	xscale(titlegap(2))  ///
	graphregion(color(white))  
	graph export "结果\图\附图3.pdf",replace

	
**附图4  HonestDiD估计结果
use "数据\tax_robot.dta",clear

reghdfe asrobot d2004 d2005 d2006 d2008 d2009 d2011 d2012, absorb($fe) vce(cluster $cl)
matrix list e(b)
matrix l_vec = (1/4)\(1/4)\(1/4)\(1/4)\(1/4)\(1/4)\(1/4)
honestdid, pre(1/3) post(4/7) mvec(0(0.1)1) delta(rm)

local plotopts xtitle(M bar,size(2.5)) ytitle("95%稳健置信区间",size(2.5)) colorspec(black)  ///
	graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))  ///
	yline(0, lcolor(black) lpattern(solid) lwidth(0.3))  ///
	xlabel(,labsize(2.5) nogrid) ylabel(,labsize(2.5) nogrid) 
	honestdid, cached coefplot `plotopts'
	graph export "结果\图\附图4.pdf",replace

	
**附图5  安慰剂检验
use "数据\附图5.dta",clear

graph twoway ///
	(kdensity beta, lpattern(solid) lwidth(0.3) lcolor(black)),  ///
	xline(0.0033,lpattern(dash) lwidth(0.2) lcolor(black))  ///
	legend(off)  ///
	ytitle("",justification(center) margin(small) size(2.5))  ///
	xtitle("",justification(center) margin(small)size(2.5))  ///
	title(,size(medium)) graphregion(color(white))  ///  
	xlabel(-0.006(0.003)0.006,labsize(2.5) nogrid) ylabel(,labsize(2.5) nogrid)
	graph export "结果\图\附图5.pdf",replace

**#  附录表  

**附表1 描述性统计
use "数据\tax_robot.dta",clear
keep asrobot poe post pre_size pre_lkl pre_export pre_import
outreg2 using "结果\表\附表1.rtf", replace sum(detail) eqkeep(N mean sd min p50 max) ///
keep(asrobot poe post pre_size pre_lkl pre_export pre_import) dec(3) 


use "数据\tax_robot.dta",clear
**附表2 考虑西部大开发和高技术企业税收豁免的回归结果
*第（1）列
reghdfe asrobot c.poe##c.post if west == 0, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post if west == 1, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post if hightech == 0, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post if hightech == 1, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表2.rtf", keep(c.poe#c.post) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表3 排除预期效应
*第（1）列
reghdfe asrobot c.poe##c.post d2004 d2005 d2006, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post d2007, absorb($fe) vce(cluster $cl)
est store r2
esttab r1 r2 using "结果\表\附表3.rtf", keep(c.poe#c.post d*) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表4 稳健性检验：排除被解释变量的零值问题的影响
*第（1）列
ppmlhdfe robot c.poe##c.post, absorb($ppmlfe) vce(cluster $cl) separation(mu fe)
est store r1

*第（2）列
reghdfe robotdummy c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
ppmlhdfe robotdummy c.poe##c.post, absorb($ppmlfe) vce(cluster $cl) separation(mu fe)
est store r3
esttab r1 r2 r3 using "结果\表\附表4.rtf", keep(c.poe#c.post) b(%9.4f) se nogap compress scalars(r2_a r2_p N) star(* 0.1 ** 0.05 *** 0.01) replace

**附表5 稳健性检验：更换被解释变量衡量方式
*第（1）列
reghdfe lnrobot c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe lnrobot_001 c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asvalue c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot_main c.poe##c.post, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表5.rtf", keep(c.poe#c.post) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表6 稳健性检验：更换企业所有制衡量方式
*第（1）列
reghdfe asrobot c.poe##c.post if hmt == 0, absorb($fe) vce(cluster $cl)
est store r1

use "数据\tax_robot_capital.dta",clear
*第（2）列
reghdfe asrobot c.poe_25##c.post, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe_50##c.post, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe_100##c.post, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表6.rtf", keep(c.poe#c.post c.poe_25#c.post c.poe_50#c.post c.poe_100#c.post) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


use "数据\tax_robot.dta",clear
**附表7 稳健性检验：排除生产成本冲击的回归结果
*第（1）列
reghdfe asrobot c.poe##c.post c.poe##c.minwage, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post c.poe##c.pfee, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post c.poe##c.landcost, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post c.poe##c.minwage c.poe##c.pfee c.poe##c.landcost, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表7.rtf", keep(c.poe#c.post c.poe#c.minwage c.poe#c.pfee c.poe#c.landcost) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表8 稳健性检验：排除金融危机冲击的回归结果
*第（1）列
reghdfe asrobot c.poe##c.post c.poe##c.gdpperwd, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post c.poe##c.creditwd, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post c.poe##c.lgfv, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post c.poe##c.gdpperwd c.poe##c.creditwd c.poe##c.lgfv, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表8.rtf", keep(c.poe#c.post c.poe#c.gdpperwd c.poe#c.creditwd c.poe#c.lgfv) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表9 稳健性检验：排除产业政策冲击的回归结果
*第（1）列
reghdfe asrobot c.poe##c.post subsidy, absorb($fe) vce(cluster $cl)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post vat, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post finance, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post subsidy vat finance, absorb($fe) vce(cluster $cl)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表9.rtf", keep(c.poe#c.post subsidy vat finance) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表10 稳健性检验：更换样本范围或权重
*第（1）列
reghdfe asrobot c.poe##c.post if poe_change1 !=., absorb($fe) vce(cluster $cl) 
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post if balancepanel == 1, absorb($fe) vce(cluster $cl)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post if sales2000 == 1, absorb($fe) vce(cluster $cl)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post if r90 == 1, absorb($fe) vce(cluster $cl)
est store r4

*第（5）列
reghdfe asrobot c.poe##c.post [pweight = _webal], absorb($fe) vce(cluster $cl) 
est store r5
esttab r1 r2 r3 r4 r5 using "结果\表\附表10.rtf", keep(c.poe#c.post) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace


**附表11 平衡性检验
bysort firmid:keep if _n == 1
*面板A: 匹配前
logout,save("结果\表\附表11A") replace:ttable3 $ebctrs, by(poe)
*面板B: 熵平衡法匹配后
ebalance poe $ebctrs, k("结果\表\附表11B") replace targets(1 1 1 1) maxiter(1000) tol(0.0001) 


use "数据\tax_robot.dta",clear
**附表12 稳健性检验：更换标准误聚类层级
*第（1）列
reghdfe asrobot c.poe##c.post, absorb($fe) vce(cluster cic4)
est store r1

*第（2）列
reghdfe asrobot c.poe##c.post, absorb($fe) vce(cluster city)
est store r2

*第（3）列
reghdfe asrobot c.poe##c.post, absorb($fe) vce(cluster cic4 city)
est store r3

*第（4）列
reghdfe asrobot c.poe##c.post, absorb($fe) vce(cluster poe#year)
est store r4
esttab r1 r2 r3 r4 using "结果\表\附表12.rtf", keep(c.poe#c.post) b(%9.4f) se nogap compress scalars(r2_a N) star(* 0.1 ** 0.05 *** 0.01) replace




********************************************************************************
*                                 谢谢阅读                                     *
********************************************************************************