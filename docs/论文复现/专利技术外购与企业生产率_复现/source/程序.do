/********************************************************************
  本程序用于复现论文《专利技术外购与企业全要素生产率》的结果。

  使用软件及版本：
  - Stata 18.0
********************************************************************/


******----------******
*         图1        *
******----------******
 use 图1和图2数据,clear
keep 年份 购买专利企业数量占比 购买的专利总量


******----------******
*         图2        *
******----------******
 use 图1和图2数据,clear
foreach var of varlist 购买国内专利的企业数量占比 购买国外专利的企业数量占比 购买国内的专利数量占比 购买国外的专利数量占比 购买公共科研机构的专利数量占比 购买企业专利数量占比 购买企业和公共科研机构的专利数量占比 购买其他专利数量占比{
	egen M`var'=mean(`var')
}
keep M购买国内专利的企业数量占比 M购买国外专利的企业数量占比 M购买国内的专利数量占比 M购买国外的专利数量占比 M购买公共科研机构的专利数量占比 M购买企业专利数量占比 M购买企业和公共科研机构的专利数量占比 M购买其他专利数量占比
duplicates drop M购买国内专利的企业数量占比 M购买国外专利的企业数量占比 M购买国内的专利数量占比 M购买国外的专利数量占比 M购买公共科研机构的专利数量占比 M购买企业专利数量占比 M购买企业和公共科研机构的专利数量占比 M购买其他专利数量占比,force




******----------******
*         表1        *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
reghdfe  tfp_acf DID_buyall_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a1
reghdfe tfp_acf DID_buydom_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id)   
est store a2
reghdfe  tfp_acf DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a3
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=. //同时考虑不同来源后，控制组需要包括买过对应专利的企业
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 表1.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own)  


******----------******
*         表2        *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"   
xtset firm_id year 
reghdfe  RD_expense DID_buyall_own  $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a1  
predict double RD_hat, xb 
reghdfe  tfp_acf RD_hat $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a2
reghdfe  RD_labor DID_buyall_own  $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a3 
predict double RDlabor_hat, xb 
reghdfe  tfp_acf RDlabor_hat $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a4
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  RD_expense DID_buydom_own DID_buyfor_own  $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a5 
predict double RD_hat1, xb 
reghdfe  tfp_acf RD_hat1 $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a6
reghdfe RD_labor DID_buydom_own DID_buyfor_own  $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a7 
predict double RDlabor_hat1, xb 
reghdfe  tfp_acf RDlabor_hat1 $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a8
outreg2 [a1 a2 a3 a4 a5 a6 a7 a8] using 表2.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES, Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own RD_hat*  RDlabor_hat*)



******----------******
*         表3        *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"   
xtset firm_id year 
reghdfe  tfp_acf DID_buyall_process DID_buyall_product $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id)  //数据中已将购买了另一类型的专利但未买变量所定义的处理组类型的专利企业设为控制组，以匹配同时考虑不同来源的情况，即变量定义和基准回归结果一致。
//后续除基准变量DID_buydom_own和DID_buyfor_own外，分不同专利来源和类型时均在原始数据中做好了调整，以直接分析同时考虑不同来源专利技术的情况，故不再需要额外将缺失值设为0。全文分析的核心变量定义均保持一致。
est store a1
reghdfe  tfp_acf DID_buydom_process DID_buyfor_process DID_buydom_product DID_buyfor_product $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id) 
est store a2
reghdfe  tfp_acf DID_buyall_sameind DID_buyall_unsameind  $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a3
reghdfe  tfp_acf DID_buydom_sameind DID_buyfor_sameind DID_buydom_unsameind DID_buyfor_unsameind $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 表3.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buyall_process DID_buyall_product DID_buydom_process DID_buyfor_process DID_buydom_product DID_buyfor_product DID_buyall_sameind DID_buyall_unsameind DID_buydom_sameind DID_buyfor_sameind  DID_buydom_unsameind DID_buyfor_unsameind)  

******----------******
*         表4        *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  sale DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a1 
reghdfe  tax_ratio DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a2
reghdfe  subsidy_ratio DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a3
reghdfe  export_value  DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if year<2017 , a(firm_id indyear) vce(cluster firm_id) 
est store a4
reghdfe  domestic_sale DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if year<2017, a(firm_id indyear) vce(cluster firm_id) 
est store a5
outreg2 [a1 a2 a3 a4 a5] using 表4.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES, Year FE, YES, Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 
**********************************************************************************附录内容***********************************************************

******----------******
*         附表1        *
******----------******
use 附表1数据,clear

******----------******
*         附表2        *
******----------******
use 附表2数据,clear

******----------******
*         附表3       *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"   
sum2docx tfp_acf tfp_lp tfp_op DID_buyall_own DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 using 主要变量的描述性统计.docx, replace stats(N mean(%9.4f) median(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f)) title("附表3 主要变量的描述性统计")


******----------******
*         附表3       *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
reghdfe  tfp_acf DID_buyall_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a1
reghdfe tfp_acf DID_buydom_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id)   
est store a2
reghdfe  tfp_acf DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a3
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.  
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 附表4.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own)  


******----------******
*         附图1       *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
gen event = year -first_buyyear_own if treated_buyall_own==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treated_buyall_own==1|treated_buyall_own==0)
   }   
reghdfe  tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/5{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/5{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==6
	replace se=0 if _n==6

	forvalue i=7/13{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=7/13{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=13, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=13, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(6, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11"4" 12"5" 13"6" , labsize(small) tl(0.8)) ///
	xtitle("购买全部专利相对时间(Buy_all)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图1全部购买, replace)	graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)
	
	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
gen event = year -first_buyyeardom_own if treated_buydom_own==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treated_buydom_own==1|treated_buydom_own==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/5{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/5{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==6
	replace se=0 if _n==6

	forvalue i=7/13{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=7/13{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=13, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=13, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(6, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11"4" 12"5" 13"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国内专利相对时间(Buy_domestic)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图1国内购买, replace)	graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)
	

use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
gen event = year -first_buyyearfor_own if treated_buyfor_own==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/11{
  replace eventt`i' = 0 if eventt`i' ==.&(treated_buydom_own==1|treated_buydom_own==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt5 eventt6  eventt7  eventt8 eventt9  eventt10 eventt11  $ctrl_vars $ctrl_vars1 ,absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/3{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/3{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==4
	replace se=0 if _n==4

	forvalue i=5/11{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=5/11{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=11, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=11, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(4, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-4" 2 "-3" 3 "-2" 4 "-1" 5 "0" 6 "1" 7 "2" 8 "3" 9 "4" 10 "5" 11"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国外专利相对时间(Buy_foreign)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图1国外购买, replace) graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)
	
******----------******
*         附图2       *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
gen event = year -first_buyyear_own if treated_buyall_own==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treated_buyall_own==1|treated_buyall_own==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 
honestdid, pre(1/5) post(6/12) mvec(0(0.003)0.03) alpha(0.05) 
local plotopts xtitle(平行趋势不成立的相对程度Mbar) ytitle(95%稳健置信区间) title(相对偏离程度限制) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scheme(s1mono) 
honestdid, cached coefplot `plotopts'   
honestdid, pre(1/5) post(6/12) mvec(0(0.003)0.03) delta(sd) alpha(0.05)
local plotopts xtitle(平行趋势不成立的相对程度Mbar) ytitle(95%稳健置信区间) title(平滑限制) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scheme(s1mono) 
honestdid, cached coefplot `plotopts'


use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
gen event = year -first_buyyeardom_own if treated_buydom_own==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treated_buydom_own==1|treated_buydom_own==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 
honestdid, pre(1/5) post(6/12) mvec(0(0.003)0.03) alpha(0.05) 
local plotopts xtitle(平行趋势不成立的相对程度Mbar) ytitle(95%稳健置信区间) title(相对偏离程度限制) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scheme(s1mono) 
honestdid, cached coefplot `plotopts'  
honestdid, pre(1/5) post(6/12) mvec(0(0.003)0.03) delta(sd) alpha(0.05)
local plotopts xtitle(平行趋势不成立的相对程度Mbar) ytitle(95%稳健置信区间) title(平滑限制) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scheme(s1mono) 
honestdid, cached coefplot `plotopts'
******----------******
*         附表5       *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 

eststo m1: ivreghdfe  tfp_acf  (DID_buyall_own =IV1 IV2_all ) $ctrl_vars $ctrl_vars1, ///
    abs(firm_id indyear) cluster(firm_id) first savefirst savefprefix(first_)
estimates dir

estadd scalar F = e(widstat), replace
estadd scalar cdf1 = e(cdf), replace
estadd scalar sstat1 = e(sstat), replace

esttab first_DID_buyall_own m1 using "${OUTPATH}附表5.csv", replace ///
    coeflabels(_cons "Constant") ///
    b(4) se(4) compress nogaps scalar(F) ///
    order(IV1 IV2_all  DID_buyall_own $ctrl_vars $ctrl_vars1) ///
    stats(N r2 F cdf1 sstat1, fmt(0 3 3 3 3) labels("Obs" "R2" "F" "CD Wald F" "SW S stat.")) ///
    nobaselevels star(* 0.10 ** 0.05 *** 0.01)

replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	

eststo m2: ivreghdfe  tfp_acf  (DID_buydom_own DID_buyfor_own= IV1 IV2_dom IV2_for) $ctrl_vars $ctrl_vars1, ///
    abs(firm_id indyear) cluster(firm_id) first savefirst savefprefix(first_)
estimates dir

estadd scalar F = e(widstat), replace
estadd scalar cdf1 = e(cdf), replace
estadd scalar sstat1 = e(sstat), replace

esttab first_DID_buydom_own first_DID_buyfor_own m2 using "${OUTPATH}附表5.csv", append ///
    coeflabels(_cons "Constant") ///
    b(4) se(4) compress nogaps scalar(F) ///
    order(IV1 IV2_dom IV2_for DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1) ///
    stats(N r2 F cdf1 sstat1, fmt(0 3 3 3 3) labels("Obs" "R2" "F" "CD Wald F" "SW S stat.")) ///
    nobaselevels star(* 0.10 ** 0.05 *** 0.01)

******----------******
*         附表6      *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 

eststo m1: ivreghdfe  tfp_acf  (DID_buyall_own =IV1 IV2_all ) $ctrl_vars $ctrl_vars1, ///
    abs(firm_id indyear region_id) cluster(firm_id) first savefirst savefprefix(first_)
estimates dir

estadd scalar F = e(widstat), replace
estadd scalar cdf1 = e(cdf), replace
estadd scalar sstat1 = e(sstat), replace

esttab first_DID_buyall_own m1 using "${OUTPATH}附表6.csv", replace ///
    coeflabels(_cons "Constant") ///
    b(4) se(4) compress nogaps scalar(F) ///
    order(IV1 IV2_all  DID_buyall_own $ctrl_vars $ctrl_vars1) ///
    stats(N r2 F cdf1 sstat1, fmt(0 3 3 3 3) labels("Obs" "R2" "F" "CD Wald F" "SW S stat.")) ///
    nobaselevels star(* 0.10 ** 0.05 *** 0.01)

replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	

eststo m2: ivreghdfe  tfp_acf  (DID_buydom_own DID_buyfor_own= IV1 IV2_dom IV2_for) $ctrl_vars $ctrl_vars1, ///
    abs(firm_id indyear region_id) cluster(firm_id) first savefirst savefprefix(first_)
estimates dir

estadd scalar F = e(widstat), replace
estadd scalar cdf1 = e(cdf), replace
estadd scalar sstat1 = e(sstat), replace

esttab first_DID_buydom_own first_DID_buyfor_own m2 using "${OUTPATH}附表6.csv", append ///
    coeflabels(_cons "Constant") ///
    b(4) se(4) compress nogaps scalar(F) ///
    order(IV1 IV2_dom IV2_for DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1) ///
    stats(N r2 F cdf1 sstat1, fmt(0 3 3 3 3) labels("Obs" "R2" "F" "CD Wald F" "SW S stat.")) ///
    nobaselevels star(* 0.10 ** 0.05 *** 0.01)
	
******----------******
*         附表7      *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
plausexog uci tfp_acf $ctrl_vars $ctrl_vars1 (DID_buyall_own = IV1 IV2_all), gmin(0.005 -0.1) gmax(0.05 0.001) grid(5) level(.95) vce(cluster firm_id)
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	
plausexog uci tfp_acf $ctrl_vars $ctrl_vars1 (DID_buydom_own DID_buyfor_own= IV1 IV2_dom IV2_for), gmin(0.005 -0.1 -0.02) gmax(0.05 0.01 0.02) grid(5) level(.95) vce(cluster firm_id)

******----------******
*        附表8      *
******----------******
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 

use psm2004-2021mix1,clear  //不同的处理组和控制组，故匹配得到不同的样本
xtset firm_id year 
reghdfe  tfp_acf DID_buyall_own  $ctrl_vars $ctrl_vars1 [aweight=_weight], a(firm_id indyear) vce(cluster firm_id) 
est store a1
outreg2 [a1  ] using 附表8.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 


use  psm2004-2021mix2,clear
xtset firm_id year 
reghdfe  tfp_acf DID_buydom_own $ctrl_vars $ctrl_vars1 [aweight=_weight], a(firm_id indyear) vce(cluster firm_id) 
est store a2
outreg2 [a2  ] using 附表8.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 


use  psm2004-2021mix3,clear
xtset firm_id year 
reghdfe  tfp_acf DID_buyfor_own $ctrl_vars $ctrl_vars1 [aweight=_weight], a(firm_id indyear) vce(cluster firm_id) 
est store a3
outreg2 [a3  ] using 附表8.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 


use  psm2004-2021sin1,clear
xtset firm_id year 
reghdfe  tfp_acf DID_buyall_own  $ctrl_vars $ctrl_vars1 [aweight=_weight], a(firm_id indyear) vce(cluster firm_id) 
est store a4
outreg2 [a4  ] using 附表8.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 


use  psm2004-2021sin2,clear
xtset firm_id year 
reghdfe  tfp_acf DID_buydom_own  $ctrl_vars $ctrl_vars1 [aweight=_weight], a(firm_id indyear) vce(cluster firm_id) 
est store a5
outreg2 [a5  ] using 附表8.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 

 
use  psm2004-2021sin3,clear
xtset firm_id year 
reghdfe  tfp_acf DID_buyfor_own  $ctrl_vars $ctrl_vars1 [aweight=_weight], a(firm_id indyear) vce(cluster firm_id) 
est store a6
outreg2 [a6  ] using 附表8.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own ) 

******----------******
*         附图3      *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
psmatch2 treated_buyall_own $ctrl_vars $ctrl_vars1, out( tfp_acf) ate neighbor(2) caliper(0.01) common ties
pstest $ctrl_vars $ctrl_vars1, both graph xsize(4) ysize(3) saving(balancing_assumption, replace)  
graph export "附图3全部购买.emf", replace


psmatch2 treated_buydom_own $ctrl_vars $ctrl_vars1, out( tfp_acf ) ate neighbor(2) caliper(0.01) common ties
pstest, both graph xsize(4) ysize(3) saving(balancing_assumption, replace)
graph export "附图3国内购买.emf", replace


psmatch2 treated_buyfor_own $ctrl_vars $ctrl_vars1, out(tfp_acf) ate neighbor(2) caliper(0.01) common ties
pstest, both graph xsize(4) ysize(3) saving(balancing_assumption, replace)
graph export "附图3国外购买.emf", replace

******----------******
*         附图4     *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year
psmatch2 treated_buyall_own $ctrl_vars $ctrl_vars1, out(tfp_acf) ate neighbor(2) caliper(0.01) common ties
pstest, both   
psgraph, graphregion(margin(b=5)) plotregion(margin(b=5)) scheme(s2mono) xsize(3) ysize(3)


psmatch2 treated_buydom_own $ctrl_vars $ctrl_vars1, out(tfp_acf) ate neighbor(2) caliper(0.01) common ties
pstest, both   
psgraph, graphregion(margin(b=5)) plotregion(margin(b=5)) scheme(s2mono) xsize(3) ysize(3)


psmatch2 treated_buyfor_own $ctrl_vars $ctrl_vars1, out(tfp_acf) ate neighbor(2) caliper(0.01) common ties
pstest, both   
psgraph, graphregion(margin(b=5)) plotregion(margin(b=5)) scheme(s2mono) xsize(3) ysize(3)


******----------******
*    附表9&附表10     *
******----------******	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year
keep if year==2004
psmatch2 treated_buyall_own $ctrl_vars $ctrl_vars1, out(tfp_acf) ate neighbor(2) caliper(0.01) common ties  //其他年份和处理组控制组操作类似
pstest, both   




use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year
keep if year==2021
psmatch2 treated_buyall_own $ctrl_vars $ctrl_vars1, out(tfp_acf) ate neighbor(2) caliper(0.01) common ties
pstest, both   


******----------******
*        附图5      *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
sort firm_id year
xtset firm_id year
reghdfe   tfp_acf  DID_buydom_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store did_bbb
didplacebo did_bbb, treatvar(DID_buydom_own) pbomix(3) seed(1)

reghdfe   tfp_acf  DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store did_bbb
didplacebo did_bbb, treatvar(DID_buyfor_own) pbomix(3) seed(1)

******----------******
*        附表11     *
******----------******
use 数据,clear
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
global ctrl_vars2 "ownership  firmsize firmage capex_labor lnPatent_before85 Dum_license "
global ctrl_vars3 "ownership  firmsize firmage capex_labor lnPatent_before85 lnLicennum_since85"
xtset firm_id year  
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own  $ctrl_vars2 $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a1
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own  $ctrl_vars3 $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a2
outreg2 [a1 a2] using 附表11.xls, replace  se adjr2 dec(4)  addtext(Firm FE, YES,  Industryyear FE, YES)   sortvar (DID_buydom_own DID_buyfor_own Dum_license lnLicennum_since85)


use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
bys firm_id: egen X=sum(Dum_license)
drop if X>0
drop X
xtset firm_id year    
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a3
outreg2 [a3] using 附表11.xls, append se adjr2 dec(4)  addtext(Firm FE, YES, Industryyear FE, YES)   

use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year        
reghdfe  tfp_acf DID_buydom_ownout DID_buyfor_ownout $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a4
outreg2 [a4] using 附表11.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  

use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own DID_buydom_ownin DID_buyfor_ownin $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a5
outreg2 [a5] using 附表11.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar ( DID_buydom_own DID_buyfor_own licensedom_own lnLicen_before85 DID_buydom_ownout DID_buyfor_ownout DID_buydom_ownin DID_buyfor_ownin )

******----------******
*        附表12     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year         
reghdfe  tfp_acf DID_buydom_ownafg DID_buyfor_ownafg $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a1
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	
reghdfe  tfp_acf DID_buydom_ownre DID_buyfor_ownre DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a2
reghdfe  tfp_lp DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a3
reghdfe  tfp_op DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear) vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 附表12.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES, Industryyear FE, YES)  sortvar (DID_buydom_ownafg DID_buyfor_ownafg  DID_buydom_own DID_buyfor_own DID_buydom_ownre DID_buyfor_ownre)

******----------******
*        附表13    *
******----------******
use 工企匹配数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
reghdfe  tfp DID_buyall_own $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a1 
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	
reghdfe  tfp DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a2
outreg2 [a1 a2] using 附表13.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own )  

use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
reghdfe   tfp_acf  DID_buyall_owncon1 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a3
reghdfe   tfp_acf  DID_buydom_owncon1  DID_buyfor_owncon1  $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id) 
est store a4
outreg2 [ a3 a4] using 附表13.xls, append se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own DID_buyall_owncon1   DID_buydom_owncon1  DID_buyfor_owncon1 ) 

******----------******
*        附图6     *
******----------******
*Borusyak et al. (2021)
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
set seed 12345
did_imputation tfp_acf firm_id year  first_buyyear_own, fe(firm_id indyear) cluster(firm_id) autosample  horizons(0/6) pretrend(6)  maxit(2000)  minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
 title("Borusyak et al. (2021) imputation estimator") xlabel(-6(1)6))
estimates store bjs1  
did_imputation  tfp_acf  firm_id year  first_buyyeardom_own, fe(firm_id indyear) cluster(firm_id) autosample  horizons(0/6) pretrend(6)  maxit(2000)  minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
 title("Borusyak et al. (2021) imputation estimator") xlabel(-6(1)6))
estimates store bjs2
did_imputation  tfp_acf  firm_id year  first_buyyearfor_own , fe(firm_id indyear) cluster(firm_id) autosample  horizons(0/6) pretrend(4)  maxit(2000)  minn(0)
event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
 title("Borusyak et al. (2021) imputation estimator") xlabel(-6(1)6))
estimates store bjs3


event_plot bjs1 bjs2 bjs3, ///
    stub_lag(tau# tau# tau#) ///
    stub_lead(pre# pre# pre#) ///
    plottype(scatter) ciplottype(rcap) ///
    together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
    graph_opt(title("Event study estimators", size(medlarge)) ///
    xtitle("相对时期") ytitle("平均处理效应") xlabel(-6(1)6) ///
    ylabel(-0.6(0.1)0.6) ///
    legend(order(1 "全部购买" 3 "国内购买" 5 "国外购买") rows(3) region(style(none))) ///
    xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) ///
    graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
    ) ///
    lag_opt1(msymbol(Sh) color(black) mfcolor(black)) lag_ci_opt1(color(black)) ///
    lag_opt2(msymbol(Oh) color(black) mfcolor(black)) lag_ci_opt2(color(black)) ///
    lag_opt3(msymbol(diamond)  color(black) mfcolor(black)) lag_ci_opt3(color(black)) /// 
    lead_opt1(msymbol(Sh) color(black) mfcolor(black)) lead_ci_opt1(color(black)) ///
    lead_opt2(msymbol(Oh) color(black) mfcolor(black)) lead_ci_opt2(color(black)) ///
    lead_opt3(msymbol(diamond)  color(black) mfcolor(black)) lead_ci_opt3(color(black)) 
	
*Callaway & Sant'Anna (2021) 
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
set seed 12345
xtset firm_id year
gen buy_year = year if patent_buy_own == 1
 bysort firm_id: egen first_buy_own = min(buy_year)
 replace first_buy_own=0 if treated_buyall_own==0 
 drop buy_year
gen buy_year = year if matchdom_own == 1
 bysort firm_id: egen first_buydom_own = min(buy_year)
 replace first_buydom_own=0 if treated_buydom_own==0  
 drop buy_year
 gen buy_year = year if matchfor_own == 1
 bysort firm_id: egen first_buyfor_own = min(buy_year)
 replace first_buyfor_own=0 if treated_buyfor_own==0 
 drop buy_year
tab indyear, gen(dindyear)
csdid tfp_acf DID_buyall_own $ctrl_vars $ctrl_vars1 dindyear*, ivar(firm_id) time(year) gvar(first_buy_own) wboot method(dripw) notyet rseed(12345)
 estat event, window(-6 6) estore(csa1)
 event_plot csa1, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-6(1)6) ///
 title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

csdid tfp_acf DID_buydom_own $ctrl_vars $ctrl_vars1 dindyear*, ivar(firm_id) time(year) gvar(first_buydom_own) wboot method(dripw) notyet rseed(12345)
estat event, window(-6 6)  estore(csa2)
event_plot csa2, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-6(1)6) ///
 title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

csdid tfp_acf DID_buyfor_own $ctrl_vars $ctrl_vars1 dindyear*, ivar(firm_id) time(year) gvar(first_buyfor_own) wboot method(dripw) notyet rseed(12345)
estat event, window(-4 6)  estore (csa3)
event_plot csa3, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-6(1)6) ///
 title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together


event_plot csa1 csa2 csa3, ///
    stub_lag(Tp# Tp# Tp#) ///
    stub_lead(Tm# Tm# Tm#) ///
    plottype(scatter) ciplottype(rcap) ///
    together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
    graph_opt( ///
        title("Event study estimators", size(medlarge)) ///
        xtitle("相对时期") ytitle("平均处理效应") xlabel(-6(1)6) ///
        /* yscale(range(-0.6 0.6) noextend) */ ///
        ylabel(-0.9(0.1)0.6) ///
        legend(order(1 "全部购买" 3 "国内购买" 5 "国外购买") rows(3) region(style(none))) ///
        xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) ///
        graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
    ) ///
    lag_opt1(msymbol(Sh) color(black) mfcolor(black)) lag_ci_opt1(color(black)) ///
    lag_opt2(msymbol(Oh) color(black) mfcolor(black)) lag_ci_opt2(color(black)) ///
    lag_opt3(msymbol(diamond) color(black) mfcolor(black)) lag_ci_opt3(color(black)) ///
    lead_opt1(msymbol(Sh) color(black) mfcolor(black)) lead_ci_opt1(color(black)) ///
    lead_opt2(msymbol(Oh) color(black) mfcolor(black)) lead_ci_opt2(color(black)) ///
    lead_opt3(msymbol(diamond) color(black) mfcolor(black)) lead_ci_opt3(color(black))	
	
*Sun and Abraham (2021)	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
set seed 12345

capture program drop addbase0
program define addbase0
    syntax namelist(min=2 max=2), base(name)

    local bmat : word 1 of `namelist'
    local vmat : word 2 of `namelist'

    matrix b = `bmat'
    matrix V = `vmat'

    local cn : colnames b
    if strpos(" `cn' ", " `base' ") == 0 {
        matrix b = b, 0
        matrix colnames b = `cn' `base'

        local k = colsof(V)
        matrix V = (V, J(`k',1,0) \ J(1,`k',0), 0)

        matrix colnames V = `: colnames `vmat'' `base'
        matrix rownames V = `: rownames `vmat'' `base'
    }

    matrix `bmat' = b
    matrix `vmat' = V
end

capture program drop make_event_dummies
program define make_event_dummies
    syntax , first(name) treated(name) leads(integer)

    capture drop event event_bin pre_* post_* no_treat

    gen event = year - `first'
    gen event_bin = event
    replace event_bin = -1 if inrange(event,-3,-1)
    replace event_bin = -2 if inrange(event,-6,-4)
    replace event_bin = -3 if inrange(event,-9,-7)
    replace event_bin = -4 if inrange(event,-12,-10)
    replace event_bin = -5 if inrange(event,-15,-13)
    replace event_bin = -6 if inrange(event,-17,-16)
    replace event_bin =  6 if event >= 6 & event < .

    forvalues i = 1/`leads' {
        gen pre_`i' = (event_bin == -`i')
    }

    gen post_0 = (event_bin == 0)
    forvalues j = 1/5 {
        gen post_`j' = (event_bin == `j')
    }
    gen post_6 = (event_bin == 6)

    gen no_treat = `treated'
    recode no_treat (0=1) (1=0)
    label variable no_treat "Never Treated"

   
    drop pre_1
end


make_event_dummies, first(first_buyyear_own) treated(treated_buyall_own) leads(6)

eventstudyinteract tfp_acf pre_* post_*, ///
    vce(cluster firm_id) ///
    absorb(firm_id indyear) ///
    cohort(first_buyyear_own) ///
    control_cohort(no_treat) ///
    covariates($ctrl_vars $ctrl_vars1)

matrix sa_b1 = e(b_iw)
matrix sa_v1 = e(V_iw)
addbase0 sa_b1 sa_v1, base(pre_1)

drop event event_bin pre_* post_* no_treat

make_event_dummies, first(first_buyyeardom_own) treated(treated_buydom_own) leads(6)

eventstudyinteract tfp_acf pre_* post_*, ///
    vce(cluster firm_id) ///
    absorb(firm_id indyear) ///
    cohort(first_buyyeardom_own) ///
    control_cohort(no_treat) ///
    covariates($ctrl_vars $ctrl_vars1)

matrix sa_b2 = e(b_iw)
matrix sa_v2 = e(V_iw)
addbase0 sa_b2 sa_v2, base(pre_1)

drop event event_bin pre_* post_* no_treat

make_event_dummies, first(first_buyyearfor_own) treated(treated_buyfor_own) leads(4)

eventstudyinteract tfp_acf pre_* post_*, ///
    vce(cluster firm_id) ///
    absorb(firm_id indyear) ///
    cohort(first_buyyearfor_own) ///
    control_cohort(no_treat) ///
    covariates($ctrl_vars $ctrl_vars1)

matrix sa_b3 = e(b_iw)
matrix sa_v3 = e(V_iw)
addbase0 sa_b3 sa_v3, base(pre_1)

drop event event_bin pre_* post_* no_treat

event_plot sa_b1#sa_v1 sa_b2#sa_v2 sa_b3#sa_v3, ///
    stub_lag(post_# post_# post_#) ///
    stub_lead(pre_# pre_# pre_#) ///
    plottype(scatter) ciplottype(rcap) ///
    together perturb(-0.325(0.13)0.325) trimlead(6) noautolegend ///
    graph_opt( ///
        title("Event study estimators", size(medlarge)) ///
        xtitle("相对时期") ytitle("平均处理效应") ///
        xlabel(-6(1)6) ///
        ylabel(-0.6(0.1)0.6, angle(horizontal)) ///
        legend(order(1 "全部购买" 3 "国内购买" 5 "国外购买") rows(3) region(style(none))) ///
        xline(0, lcolor(gs8) lpattern(dash)) ///
        yline(0, lcolor(gs8)) ///
        graphregion(color(white)) bgcolor(white) ///
    ) ///
    lag_opt1(msymbol(Sh) color(black) mfcolor(black)) lag_ci_opt1(color(black)) ///
    lag_opt2(msymbol(Oh) color(black) mfcolor(black)) lag_ci_opt2(color(black)) ///
    lag_opt3(msymbol(diamond) color(black) mfcolor(black)) lag_ci_opt3(color(black)) ///
    lead_opt1(msymbol(Sh) color(black) mfcolor(black)) lead_ci_opt1(color(black)) ///
    lead_opt2(msymbol(Oh) color(black) mfcolor(black)) lead_ci_opt2(color(black)) ///
    lead_opt3(msymbol(diamond) color(black) mfcolor(black)) lead_ci_opt3(color(black))

******----------******
*        附表14     *
******----------******
use 事前数据,clear  //只用初期的控制变量数据，看是否影响企业成为处理组
global V1 ownership  firmage ROA  SA  share_largest firmsize lnPatent_before85 capex_labor  
global V2 ownership  firmage ROA  SA  share_largest firmsize lnPatent_before85 capex_labor  tfp_acf
reg  treated_buydom_own  $V1,   vce(cluster firm_id) 
est store a1
reg  treated_buyfor_own  $V1,  vce(cluster firm_id) 
est store a2
reg  treated_buydom_own  $V2,   vce(cluster firm_id) 
est store a3
reg  treated_buyfor_own  $V2,  vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 附表14.xls, replace se adjr2 dec(4)   


use 数据,clear
global V3 oriownership_t  orifirmage_t oriROA_t  orifirmsize_t orilnPatent_before85_t oricapex_labor_t   
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $V3, a(firm_id indyear) vce(cluster firm_id) 
est store a5
outreg2 [a5] using 附表14.xls, append se adjr2 dec(4)  addtext(Firm FE, YES, Industryyear FE, YES)  sortvar ( ownership  firmage ROA  SA  share_largest firmsize lnPatent_before85 capex_labor  tfp_acf DID_buydom_own DID_buyfor_own oriownership_t  orifirmage_t oriROA_t  orifirmsize_t orilnPatent_before85_t oricapex_labor_t  )

******----------******
*        附表15     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone" 
xtset firm_id year 
drop if year<2009
eststo m1: ivreghdfe  tfp_acf  (DID_buyall_own =IV1 IV2_all ) $ctrl_vars $ctrl_vars1, ///
    abs(firm_id indyear ) cluster(firm_id) first savefirst savefprefix(first_)
estimates dir

estadd scalar F = e(widstat), replace
estadd scalar cdf1 = e(cdf), replace
estadd scalar sstat1 = e(sstat), replace

esttab first_DID_buyall_own m1 using "${OUTPATH}附表15.csv", replace ///
    coeflabels(_cons "Constant") ///
    b(4) se(4) compress nogaps scalar(F) ///
    order(IV1 IV2_all  DID_buyall_own $ctrl_vars $ctrl_vars1) ///
    stats(N r2 F cdf1 sstat1, fmt(0 3 3 3 3) labels("Obs" "R2" "F" "CD Wald F" "SW S stat.")) ///
    nobaselevels star(* 0.10 ** 0.05 *** 0.01)

replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.	

eststo m2: ivreghdfe  tfp_acf  (DID_buydom_own DID_buyfor_own= IV1 IV2_dom IV2_for) $ctrl_vars $ctrl_vars1, ///
    abs(firm_id indyear ) cluster(firm_id) first savefirst savefprefix(first_)
estimates dir

estadd scalar F = e(widstat), replace
estadd scalar cdf1 = e(cdf), replace
estadd scalar sstat1 = e(sstat), replace

esttab first_DID_buydom_own first_DID_buyfor_own m2 using "${OUTPATH}附表15.csv", append ///
    coeflabels(_cons "Constant") ///
    b(4) se(4) compress nogaps scalar(F) ///
    order(IV1 IV2_dom IV2_for DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1) ///
    stats(N r2 F cdf1 sstat1, fmt(0 3 3 3 3) labels("Obs" "R2" "F" "CD Wald F" "SW S stat.")) ///
    nobaselevels star(* 0.10 ** 0.05 *** 0.01)
	
******----------******
*        附表16     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
reghdfe  tfp_acf DID_buyall_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster ind_id) 
est store a1
reghdfe  tfp_acf DID_buyall_own $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster city_id) 
est store a2
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.  
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster ind_id) 
est store a3
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster city_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 附表16.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own)  

******----------******
*        附表17     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year     
reghdfe  tfp_acf DIDbuycompa_dom $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a1
reghdfe tfp_acf DIDbuycompa_for $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id)   
est store a2
reghdfe  tfp_acf DIDbuycompa_dom2 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a3
reghdfe  tfp_acf DIDbuycompa_for2 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a4
reghdfe  tfp_acf DIDbuycompa_dom1 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a5
outreg2 [a1 a2 a3 a4 a5 ] using 附表17.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DIDbuycompa_dom DIDbuycompa_for DIDbuycompa_dom2 DIDbuycompa_for2 DIDbuycompa_dom1) 


******----------******
*        附图7     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year   
gen event = year -first_comdom_year if treatedcompa_dom==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treatedcompa_dom==1|treatedcompa_dom==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/5{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/5{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==6
	replace se=0 if _n==6

	forvalue i=7/13{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=7/13{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=13, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=13, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(6, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11"4" 12"5" 13"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国内专利相对时间(Buy_domestic_only)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图7a1, replace)	graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)


use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year   
gen event = year -first_comfor_year if treatedcompa_for==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/11{
  replace eventt`i' = 0 if eventt`i' ==.&(treatedcompa_for==1|treatedcompa_for==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt5 eventt6  eventt7  eventt8 eventt9  eventt10 eventt11  $ctrl_vars $ctrl_vars1 ,absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/3{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/3{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==4
	replace se=0 if _n==4

	forvalue i=5/11{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=5/11{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=11, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=11, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(4, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-4" 2 "-3" 3 "-2" 4 "-1" 5 "0" 6 "1" 7 "2" 8 "3" 9 "4" 10 "5" 11"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国外专利相对时间(Buy_foreign_only)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图7a2, replace) graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)
	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year   
gen event = year -first_comdom_year2 if treatedcompa_dom2==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treatedcompa_dom2==1|treatedcompa_dom2==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/5{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/5{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==6
	replace se=0 if _n==6

	forvalue i=7/13{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=7/13{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=13, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=13, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(6, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11"4" 12"5" 13"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国内专利相对时间(Buy_domestic_only1)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图7b1, replace)	graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)
	
	
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year   
gen event = year -first_comfor_year2 if treatedcompa_for2==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/11{
  replace eventt`i' = 0 if eventt`i' ==.&(treatedcompa_for2==1|treatedcompa_for2==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt5 eventt6  eventt7  eventt8 eventt9  eventt10 eventt11  $ctrl_vars $ctrl_vars1 ,absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/3{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/3{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==4
	replace se=0 if _n==4

	forvalue i=5/11{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=5/11{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=11, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=11, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(4, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-4" 2 "-3" 3 "-2" 4 "-1" 5 "0" 6 "1" 7 "2" 8 "3" 9 "4" 10 "5" 11"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国外专利相对时间(Buy_foreign_only1)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///	
	name(附图7b2, replace) graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)	


use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year   
gen event = year -first_comdom_year1 if treatedcompa_dom1==1
replace event=-1 if event<=-1&event>=-3
replace event=-2 if event<=-4&event>=-6
replace event=-3 if event<=-7&event>=-9
replace event=-4 if event<=-10&event>=-12
replace event=-5 if event<=-13&event>=-15
replace event=-6 if event<=-16&event>=-18
replace event=6 if event>=6&event~=.  
tab event, gen(eventt)

forvalues i = 1/13{
  replace eventt`i' = 0 if eventt`i' ==.&(treatedcompa_dom1==1|treatedcompa_dom1==0)
   }   
reghdfe tfp_acf eventt1 eventt2 eventt3 eventt4 eventt5  eventt7  eventt8 eventt9  eventt10 eventt11 eventt12 eventt13 $ctrl_vars $ctrl_vars1, absorb(firm_id indyear) vce(cluster firm_id) 

cap drop b 
	cap drop se b_up b_low id 
	gen b=.
	gen se=.
	forvalue i=1/5{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=1/5{
	replace se=_se[eventt`i'] if _n==`i'
	}
	replace b=0 if _n==6
	replace se=0 if _n==6

	forvalue i=7/13{
	replace b=_b[eventt`i'] if _n==`i'
	}
	forvalue i=7/13{
	replace se=_se[eventt`i'] if _n==`i'
	}
	gen b_up=b+1.96*se
	gen b_low=b-1.96*se
	gen idd=_n 

	scatter b idd if idd<=13, connect(l) lcolor(black) lwidth(*0.6) lp(solid) msymbol(circle) msize(*0.4) mcolor(black) || (rcap b_low b_up idd if idd<=13, lcolor(black) lwidth(*0.6)) ///
	,yline(0, lcolor(black) lwidth(0.2)) xline(6, lwidth(0.2) lcolor(black) lp(shortdash)) ylabel(-0.64 "-0.64" -0.48 "0.48" -0.32 "-0.32" -0.16 "-0.16" 0 "0" 0.16 "0.16" 0.32 "0.32" 0.48 "0.48" 0.64 "0.64", labsize(small) tl(0.8) nogrid) ///
	xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11"4" 12"5" 13"6" , labsize(small) tl(0.8)) ///
	xtitle("购买国内专利相对时间(Buy_domestic_foreign)", box margin(small) size(small) fcolor(white) lc(white)) ///
	ytitle("估计系数大小", box margin(small) size(small) fcolor(white) lc(white)) ///
	graphregion(color(white)) ///
	legend(off) ///
    name(附图7c, replace)	graphregion(margin(small)) plotregion(margin(small)) aspectratio(0.8)
	

******----------******
*        附表18     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
reghdfe  tfp_acf DID_buydom_firm DID_buyfor_firm DID_buydom_insti DID_buyfor_insti $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a1
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if Dum_firm_all==1|treated_buyall_own==0, a(firm_id indyear) vce(cluster firm_id) 
est store a2
reghdfe tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if Dum_insti_all==1|treated_buyall_own==0, a(firm_id indyear) vce(cluster firm_id) 
est store a3
reghdfe tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if (Dum_mixsource_all==1)|treated_buyall_own==0, a(firm_id indyear) vce(cluster firm_id) 
est store a4
reghdfe tfp_acf  DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if (Dum_mixsource_all==0)|treated_buyall_own==0, a(firm_id indyear) vce(cluster firm_id) 
est store a5
outreg2 [a1 a2 a3 a4 a5] using 附表18.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buydom_firm DID_buyfor_firm DID_buydom_insti DID_buyfor_insti DID_buyall_own DID_buydom_own DID_buyfor_own) 

******----------******
*        附表19      *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1  if highIPR==1, a(firm_id indyear) vce(cluster firm_id) 
est store a1
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if highIPR==0 , a(firm_id indyear) vce(cluster firm_id) 
est store a2
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if highTech==1, a(firm_id indyear) vce(cluster firm_id) 
est store a3
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own $ctrl_vars $ctrl_vars1 if highTech==0 , a(firm_id indyear) vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4] using 附表19.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES, Year FE, YES, Industryyear FE, YES)  sortvar (DID_buyall_own  DID_buydom_own DID_buyfor_own)  

******----------******
*        附表20     *
******----------******
use 附表20数据,clear 
ttable3 meancited_5 meanHHI_IPC famin_ratio meanterm_granted, by(tech_source)  

******----------******
*        附表21   *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor lnPatent_before85 "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 
reghdfe  tfp_acf DID_faminbuydom DID_faminbuyfor $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a1
reghdfe  tfp_acf DID_waixinbuydom DID_waixinbuyfor $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a2
reghdfe  tfp_acf DID_htechbuydom5 DID_htechbuyfor5 $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a3
reghdfe  tfp_acf DID_ltechbuydom5 DID_ltechbuyfor5 $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a4
reghdfe  tfp_acf DID_htechbuydom_ipc DID_htechbuyfor_ipc $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a5
reghdfe  tfp_acf DID_ltechbuydom_ipc DID_ltechbuyfor_ipc $ctrl_vars $ctrl_vars1, a(firm_id indyear) vce(cluster firm_id) 
est store a6
outreg2 [a1 a2 a3 a4 a5 a6] using 附表21.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES, Industryyear FE, YES)  sortvar ( DID_faminbuydom DID_faminbuyfor DID_waixinbuydom DID_waixinbuyfor DID_htechbuydom5 DID_htechbuyfor5 DID_ltechbuydom5 DID_ltechbuyfor5 DID_htechbuydom_ipc DID_htechbuyfor_ipc DID_ltechbuydom_ipc DID_ltechbuyfor_ipc )

******----------******
*        附表22     *
******----------******
use 数据,clear
global ctrl_vars "ownership  firmsize firmage capex_labor "  
global ctrl_vars1 "perGDP_growth lnCityPatent85  lnHtechfirm  lnHzone"  
xtset firm_id year 

replace DID_buydom_own=0 if DID_buydom_own==.&DID_buyfor_own~=.
replace DID_buyfor_own=0 if DID_buyfor_own==.&DID_buydom_own~=.
gen DDinterac_dom=DID_buydom_own*lnPatent_before85
gen DDinterac_for=DID_buyfor_own*lnPatent_before85
gen DDinterac_dom1=DID_buydom_own*lnfmPatent_before85   
gen DDinterac_for1=DID_buyfor_own*lnfmPatent_before85
gen DDinterac_dom2=DID_buydom_own*lncite5Patent_before85
gen DDinterac_for2=DID_buyfor_own*lncite5Patent_before85
gen DDinterac_dom3=DID_buydom_own*lnHHIPatent_before85
gen DDinterac_for3=DID_buyfor_own*lnHHIPatent_before85   

reghdfe  tfp_acf DID_buydom_own DID_buyfor_own DDinterac_dom DDinterac_for lnPatent_before85 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a1
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own DDinterac_dom1 DDinterac_for1 lnfmPatent_before85  $ctrl_vars $ctrl_vars1 , a(firm_id indyear ) vce(cluster firm_id) 
est store a2
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own DDinterac_dom2 DDinterac_for2 lncite5Patent_before85 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a3
reghdfe  tfp_acf DID_buydom_own DID_buyfor_own DDinterac_dom3 DDinterac_for3 lnHHIPatent_before85 $ctrl_vars $ctrl_vars1, a(firm_id indyear ) vce(cluster firm_id) 
est store a4
outreg2 [a1 a2 a3 a4 ] using 附表22.xls, replace se adjr2 dec(4)  addtext(Firm FE, YES,Industryyear FE, YES)  sortvar (DID_buydom_own DID_buyfor_own DDinterac_dom DDinterac_for lnPatent_before85 DDinterac_dom1 DDinterac_for1 lnfmPatent_before85  DDinterac_dom2 DDinterac_for2 lncite5Patent_before85 DDinterac_dom3 DDinterac_for3 lnHHIPatent_before85)  