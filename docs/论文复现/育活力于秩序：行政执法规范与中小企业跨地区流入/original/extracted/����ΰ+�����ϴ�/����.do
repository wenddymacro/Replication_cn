
*****************************************************************************

**                 育活力于秩序：行政执法规范与中小企业跨地区流入                 **

*****************************************************************************    

/*
version 18
*/
set more off
clear all
cd

global County_Control "Adminis Official Highrail Subway Impoverished LnPollution LnPopolation LnLight"







*===============================================================================
*                                 正文图表
*===============================================================================
/////////////////表1 基准回归
use master,clear

reg Firmflows Discretion, vce(cluster city_id) //Firmflow代表取IHS转换的中小企业跨地区流入数
eststo a

reg Firmflows Discretion $County_Control , vce(cluster city_id)
eststo b

reghdfe Firmflows Discretion $County_Control ,absorb(county_id) vce(cluster city_id)
eststo c

reghdfe Firmflows Discretion $County_Control ,absorb(province_id#year) vce(cluster city_id)
eststo d

reghdfe Firmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo e

esttab a b c d e using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)


 
 
 
/////////////////图1 平行趋势检验
use master,clear

#delimit;
eventdd Firmflows $County_Control, timevar(window_time) method(hdfe, absorb(county_id province_id#year) cluster(city_id)) ///
	 inrange leads(5) lags(8) ///
     baseline(-1) noline  /// 
     coef_op(m(oh) c(l) color(black) lcolor(black)) ///
     graph_op(ytitle("估" "计" "系" "数", color(black) place(top) size(*0.8) orientation(horizontal) )
     color(black) ///
	 xtitle("行政裁量权基准制度推行的前后年份",color(black) size(*0.8)) ///
     xline(-1, lc(black*0.5) lp(dash)) ///
	 ylabel(-0.4(0.2)0.6,nogrid labsize(small) angle(0) tposition(inside) format (%7.1f)) ///
	 xlabel(-5 "- 5"-4 "- 4"-3 "- 3"-2 "-2"-1 "-1"0 "0"1 "1"2 "2"3 "3"4 "4"5 "5"6 "6"7 "7"8 "8",nogrid labsize(small) tposition(inside) format (%7.1f)) ///
	legend(rows(1) position(11) size(*0.8) order(1 "95%置信区间" 2 "估计系数")) ///      
	scheme(stcolor)); 
#delimit cr 
 

    

 
/////////////////表2 排除同期政策的稳健性检验
use master,clear
//"物流标准化"
reghdfe Firmflows Discretion $County_Control logistics, absorb(county_id province_id#year) vce(cluster city_id)
eststo a

//"宽带中国"
reghdfe Firmflows Discretion $County_Control broadband, absorb(county_id province_id#year) vce(cluster city_id)
eststo b

//"国家智慧城市"
reghdfe Firmflows Discretion $County_Control SmartCity, absorb(county_id province_id#year) vce(cluster city_id)
eststo c

//大语言模型识别的营商环境政策
reghdfe Firmflows Discretion $County_Control govLLM01, absorb(county_id province_id#year) vce(cluster city_id)
eststo d

reghdfe Firmflows Discretion $County_Control govLLMnum, absorb(county_id province_id#year) vce(cluster city_id)
eststo e

reghdfe Firmflows Discretion $County_Control departLLM01, absorb(county_id province_id#year) vce(cluster city_id)
eststo f

reghdfe Firmflows Discretion $County_Control departLLMnum, absorb(county_id province_id#year) vce(cluster city_id)
eststo g

esttab a b c d e f g using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
  

    

 
/////////////////表3 机制检验：提高执法规范性—执法公开性
use master,clear

//行政处罚提供法律（法规条例）的比例（数量比）
reghdfe DRCountRatio Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe DRPCountRatio Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

//罚金金额提供法律（法规条例）的比例（金额比）
reghdfe DRAmountRatio Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe DRPAmountRatio Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

esttab a b c d using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
  

    

 
/////////////////表4 机制检验：提高执法规范性—执法横向公平
use master,clear

//大型企业与中小企业的执法差异
reghdfe DRCountRatio_smes Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe DRPCountRatio_smes Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

reghdfe DRAmountRatio_smes Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe DRPAmountRatio_smes Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

//大型企业与小微企业执法差异
reghdfe DRCountRatio_ses Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a1

reghdfe DRPCountRatio_ses Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b1

reghdfe DRAmountRatio_ses Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c1

reghdfe DRPAmountRatio_ses Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d1

//国有企业与非国企业执法差异
reghdfe DRCountRatio_state Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a2

reghdfe DRPCountRatio_state Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b2

reghdfe DRAmountRatio_state Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c2

reghdfe DRPAmountRatio_state Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d2
	        
esttab a b c d a1 b1 c1 d1 a2 b2 c2 d2 using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)	
  

 

 
/////////////////表5 机制检验：提高执法规范性—执法公正性
use master,clear

reghdfe APDMR Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe APDNMR Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

reghdfe APDMRExWC Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe APDNMRExWC Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

esttab a b c d using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
    

    

 
/////////////////表6 机制检验：降低企业费用负担
use master,clear
//宏观区县层面
reghdfe FRatio Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe NTRatio Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b


use firmmaster,clear
//微观企业层面
reghdfe ITC Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo c

esttab a b c using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
  

 
  
 
/////////////////表7 进一步分析：对税负和税收的影响
//对税负的影响
use firmmaster,clear
//微观企业层面
reghdfe CTB Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo a

reghdfe VATB Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo b

reghdfe ITB Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo c

  
use master,clear
//宏观区县层面
reghdfe PTB Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

reghdfe GTB Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo e

//对税收的影响
reghdfe LnTR Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo f  
  
esttab a b c d e f using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
  
  

     
 
/////////////////表8 进一步分析：对本地市场的影响：外延边际
use master,clear
//企业数量
reghdfe FE Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe NFE Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

//企业质量
reghdfe TCF Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe NFFirmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

reghdfe NIFirmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo e

reghdfe FIFirmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo f

esttab a b c d e f using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)

 
 
    
 
/////////////////表9 进一步分析：对本地市场的影响：集约边际 
use firmmaster,clear
//企业投资
reghdfe InvestI Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo a

reghdfe InvestII Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo b

reghdfe InvestIII Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo c

reghdfe InvestIV Discretion $County_Control legalentity income profit netprofit,absorb(industry_id#county_id province_id#year industry_id#year) vce(cluster city_id)
eststo d

esttab a b c d using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
   
		
  

	 

















	 
	 
	 
	 
	 
	 
	 
	 









*===============================================================================
*                                 附录图表
*===============================================================================

****-------附录1：地方罚没收入的特征事实-------

/////////////////附图1 地方罚没收入的特征事实1
use 附录数据/趋势对比,clear

#delimit;
	twoway (line value_local year,yaxis(1)  lpattern(dash) color(gs5) lwidth(Medium)) ///
	(scatter value_local year,yaxis(1)  msymbol(Sh) mcolor(gs5) msize(1.5)) ///
	(line value_central year,yaxis(1)  lpattern(solid) color(gs3) lwidth(Medium)) ///
	(scatter value_central year,yaxis(1)  msymbol(S) mcolor(gs3) msize(1.5)), ///
	ylabel(0(5)40,axis(1) nogrid labsize(small) tposition(inside)) ///
	xlabel(2011(1)2022,nogrid labsize(small) tposition(inside)) ///
	ytitle("百" "亿" "元",axis(1) color(black) size(*0.8) place(top) orientation(horizontal)) ///
	xtitle("年份",color(black) size(*0.8)) ///
	legend(rows(1) ring(0) position(12) bexpand size(*0.8) order(2 "地方罚没收入变化趋势  " 4 "中央罚没收入变化趋势  ")) ///      
	graphregion(color(white))   ///   
	scheme(stcolor); 
#delimit cr	





/////////////////附图2 地方罚没收入的特征事实2
use 附录数据/趋势对比,clear

#delimit;
	twoway (line taxincrease year, lpattern(dash) color(gs5) lwidth(Medium)) ///
	(scatter taxincrease year, msymbol(Sh) mcolor(gs5) msize(1.5)) ///
	(line fineincrease year, lpattern(solid) color(gs3) lwidth(Medium)) ///
	(scatter fineincrease year, msymbol(S) mcolor(gs3) msize(1.5)), ///
	ylabel(-10(10)40, nogrid labsize(small) tposition(inside)) ///
	xlabel(2011(1)2022,nogrid labsize(small) tposition(inside)) ///
    yline(0, lc(black*0.5) lp(shortdash)) ///
	ytitle("同" "比" "增" "长" "率" "(%)", color(black) size(*0.8) place(top) orientation(horizontal)) ///
	xtitle("年份",color(black) size(*0.8)) ///
	legend(rows(1) ring(0) position(12) bexpand size(*0.8) order(2 "地方税收收入同比增长率           " 4 "地方罚没收入同比增长率" )) ///      
	graphregion(color(white))   ///   
	scheme(stcolor); 
#delimit cr



   

/////////////////附图3 地方罚没收入的特征事实3
use 附录数据/趋势对比,clear

**画图:罚没收入、非税收入国有资本经营收入
#delimit;
	twoway (line finesbili year ,lpattern(solid) color(gs3) lwidth(Medium)) ///
	(scatter finesbili year ,msymbol(S) mcolor(gs3) msize(1.5))  ///
	(line operationincomebili year ,lpattern(dash) color(gs5) lwidth(Medium)) ///
	(scatter operationincomebili year ,msymbol(O) mcolor(gs5) msize(1.5))  , ///
	ylabel(0(4)25, axis(1) nogrid labsize(small) tposition(inside)) ///
	xlabel(2011(1)2022,nogrid labsize(small) tposition(inside)) ///
	ytitle("占" "比" "(%)",axis(1) color(black) size(*0.8) place(top) orientation(horizontal)) ///
	xtitle("年份",color(black) size(*0.8)) ///
	legend(rows(2) ring(0) position(12) bexpand size(*0.8) order(2 "罚没收入占非税收入的变化趋势  " 4 "国有资本经营收入占非税收入的变化趋势  ")) ///      
	graphregion(color(white))   ///   
	scheme(stcolor); 
#delimit cr	
//导出图例
graph save "Graph" "各项非税变化趋势1.ghp", replace	
	
**画图:罚没收入、非税收入国有资本经营收入
#delimit;
	twoway (line feesbili year ,lpattern(solid) color(gs3) lwidth(Medium)) ///
	(scatter feesbili year ,msymbol(Sh) mcolor(gs3) msize(1.5))  ///
	(line otherbili year ,lpattern(dash) color(gs5) lwidth(Medium)) ///
	(scatter otherbili year ,msymbol(Oh) mcolor(gs5) msize(1.5))  , ///
	ylabel(0(8)48, axis(1) nogrid labsize(small) tposition(inside)) ///
	xlabel(2011(1)2022,nogrid labsize(small) tposition(inside)) ///
	ytitle("占" "比" "(%)",axis(1) color(black) size(*0.8) place(top) orientation(horizontal)) ///
	xtitle("年份",color(black) size(*0.8)) ///
	legend(rows(2) ring(0) position(12) bexpand size(*0.8) order(2 "行政事业性收费占非税收入的变化趋势  " 4 "其他收入占非税收入的变化趋势  ")) ///      
	graphregion(color(white))   ///   
	scheme(stcolor); 
#delimit cr	
//导出图例
graph save "Graph" "各项非税变化趋势2.ghp", replace	

//合并画图
graph combine "各项非税变化趋势1.ghp" "各项非税变化趋势2.ghp"







****-------附录2：行政裁量权基准制度的核心内容-------
//附图4～附图7为政策文本原文内容，非数据结果







****-------附录4：数据处理说明与描述性统计-------
/////////////////附表1 描述性统计
use 附录数据/addmaster.dta ,clear

//被解释变量、核心解释变量、控制变量
logout, save(mytable) word replace:tabstat Firmflows Discretion $County_Control ,s(n mean sd min max) c(s) f(%12.3f)

//机制变量（区县层面）
logout, save(mytable) word replace:tabstat DRCountRatio DRPCountRatio DRAmountRatio DRPAmountRatio APDMR APDNMR APDMRExWC APDNMRExWC FRatio NTRatio,s(n mean sd min max) c(s) f(%12.3f)

use 附录数据/addfirmmaster.dta ,clear
//机制变量(企业层面)
logout, save(mytable) word replace:tabstat ITC,s(n mean sd min max) c(s) f(%12.3f)









****-------附录5：稳健性检验-------
/////////////////附图8 安慰剂检验
use 附录数据/安慰剂.dta,clear

	gen t_value = beta / se
	gen p_value = 2 * ttail(df, abs(beta/se))
//回归系数
sum beta, detail
  twoway(scatter p_value beta,                                                ///
    msy(oh) mcolor(black)                                              ///
    xline(0, lpattern(dash)     lcolor(black*0.5))                ///
    xline(0.1600, lpattern(solid)    lcolor(black*0.5))                ///
    yline(0.1   , lpattern(shortdash) lcolor(black))                ///
    scheme(qleanmono)                                                  ///
    xtitle("{stSans:估计系数}", size(*0.8))               ///
	xlabel(, format(%4.2f) labsize(small) tposition(inside))                ///
    ytitle("{stSans:P}""{stSans:值}" , color(black) size(*0.8) place(top) orientation(horizontal)) ylabel(, nogrid format(%4.2f) labsize(small) tposition(inside))  ///
    saving("/Users/ytt/Documents/data/自由裁量权/绘图/安慰剂检验_估计系数.ghp", replace)), ///
    xlabel(-0.06(0.02)0.06 , labsize(small))                                    ///
    ylabel(0(0.25)1,angle(0)  labsize(small) format(%03.2f)) ///
	graphregion(fcolor(white)) 





/////////////////附图9 Cengiz et al.（2019）估计量的事件研究结果
use 附录数据/addmaster,clear

*运行 stackedev 命令
 preserve
stackedev Firmflows F*event L*event, cohort(cohortyear) time(year) never_treat(no_treat) unit_fe(county_id) clust_unit(city_id) covariates($County_Control ) other_fe(province_id#year)
 restore  	

//平行趋势检验图
event_plot e(b)#e(V), default_look graph_opt(xtitle("行政裁量权基准制度推行的前后年份",color(black) size(*0.8))    ///
    ytitle("估" "计" "系" "数", color(black) place(top) size(*0.8) orientation(horizontal)) ///    
	title("Cengiz et al. (2019)",color(black) size(Meduim Small)) ///
    ylabel(-0.4(0.2)1.0,angle(0)  labsize(small) format(%03.1f)) ///
 	xline(-1, lc(black*0.5) lp(dash)) ///
 	xline(0, lc(gray*0.05) lp(dash)) ///
	xlabel(-5(1)9, labsize(small)) ///
    name(CDLZ, replace)) stub_lag(L#event) stub_lead(F#event) together




	
/////////////////附图10 Borusyak et al.（2024）估计量的事件研究结果
use 附录数据/addmaster,clear

*运行 did_imputation 命令
did_imputation Firmflows county_id year treatyear , autosample horizons(0/8) pretrends(5) fe(province_id#year) cluster(city_id) controls($County_Control )

//平行趋势检验图
event_plot, default_look graph_opt(xtitle("行政裁量权基准制度推行的前后年份",color(black) size(*0.8)) ///
	ytitle("估" "计" "系" "数", color(black) place(top) size(*0.8) orientation(horizontal)) ///    
	title("Borusyak et al.(2021)",color(black) size(*0.7)) ///    
    ylabel(-0.4(0.2)0.8,angle(0)  labsize(small) format(%03.1f)) ///
	xlabel(-5(1)8, labsize(small)) ///
	name(BJS, replace)) together





/////////////////附表2 更换变量的稳健性检验
use 附录数据/addmaster,clear
//更换被解释变量
reghdfe LnFirmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe NegFirmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

reghdfe curt_Firmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe NFIR Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

reghdfe FTR Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo e

//更换核心解释变量
reghdfe Firmflows didlater $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo f

reghdfe Firmflows didfabuyear $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo g

esttab a b c d e f g using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)
	


    


/////////////////附表3 更换回归样本的稳健性检验
use 附录数据/addmaster,clear

reghdfe Firmflowsall Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe Firmflows500 Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

reghdfe Firmflowsexcept Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe Firmflows Discretion $County_Control Firmflowsout, absorb(county_id province_id#year) vce(cluster city_id)
eststo d

reghdfe Firmflows Discretion $County_Control if before==0, absorb(county_id province_id#year) vce(cluster city_id)
eststo e

reghdfe Firmflows Discretion $County_Control if bigcity==0, absorb(county_id province_id#year) vce(cluster city_id)
eststo f

esttab a b c d e f using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)





/////////////////附表4 排除空壳企业影响的稳健性检验
use 附录数据/addmaster,clear
 
reghdfe Firmflowsnonrisks Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe Firmflowsnontreatrisks Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

reghdfe FirmflowsMatures Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

esttab a b c using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)





/////////////////附表5 更换对照组的稳健性检验
use 附录数据/addmaster,clear
//地理匹配DID
reghdfe Firmflows Discretion $County_Control if geomerge==1,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

//PSM-DID，1:1邻匹配	 
use 附录数据/addmaster,clear
	set seed 0001 
	gen tmp = runiform() 
	sort tmp 
	psmatch2 Discretion $County_Control, out(Firmflows) logit ate neighbor(1) common caliper(.05) ties 
	pstest $County_Control, both graph 
	gen common=_support
	drop if common == 0  
	drop if _weight ==.  
reghdfe Firmflows Discretion $County_Control , absorb(county_id province_id#year) vce(cluster city_id)
eststo b

//PSM-DID，1:2邻匹配
use 附录数据/addmaster,clear
	set seed 0001 
	gen tmp = runiform() 
	sort tmp 
	psmatch2 Discretion $County_Control, out(Firmflows) logit ate neighbor(2) common caliper(.05) ties 
	pstest $County_Control, both graph 
	gen common=_support
	drop if common == 0  
	drop if _weight ==.  
reghdfe Firmflows Discretion $County_Control , absorb(county_id province_id#year) vce(cluster city_id)
eststo c

//PSM-DID，1:4邻匹配
use 附录数据/addmaster,clear
	set seed 0001 
	gen tmp = runiform() 
	sort tmp 
	psmatch2 Discretion $County_Control, out(Firmflows) logit ate neighbor(4) common caliper(.05) ties 
	pstest $County_Control, both graph 
	gen common=_support
	drop if common == 0  
	drop if _weight ==.  
reghdfe Firmflows Discretion $County_Control , absorb(county_id province_id#year) vce(cluster city_id)
eststo d

//PSM-DID，核匹配
use 附录数据/addmaster,clear
	psmatch2 Discretion $County_Control, kernel out(Firmflows) comm
	pstest $County_Control, both graph 
reghdfe Firmflows Discretion $County_Control [pw=_weight], absorb(county_id province_id#year) vce(cluster city_id)
eststo e
	
//熵平衡匹配
use 附录数据/addmaster,clear
	ebalance Discretion Adminis Official Highrail Subway Impoverished, targets(1)	
	ebalance Discretion LnPollution LnPopolation LnLight, targets(3)	
reghdfe Firmflows Discretion $County_Control [pweight=_webal], absorb(county_id province_id#year) vce(cluster city_id)
eststo f

esttab a b c d e f using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)





/////////////////附表6 更换城市面板、聚类层级和回归模型的稳健性检验
use 附录数据/CityPairs.dta,clear
**第（1）列使用城市对的面板数据进行回归
reghdfe FirmflowsCityPairs deta_Discretion OfficialCity HighrailCity SubwayCity LnPollutionCity LnPopolationCity LnLightCity,absorb(city_id#oldcity_id year#oldcity_id) vce(cluster city_id#oldcity_id)
eststo a

use 附录数据/CityPanel,clear
**第（2）列使用城市的面板数据进行回归
reghdfe FirmflowsCity Discretion OfficialCity HighrailCity SubwayCity LnPollutionCity LnPopolationCity LnLightCity,absorb(city_id province_id#year) vce(cluster city_id)
eststo b

use 附录数据/addmaster,clear  
**第（3）、（4）列更改聚类层级进行回归
reghdfe Firmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster province_id#year)
eststo c

reghdfe Firmflows Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster county_id)
eststo d

**第（5）列更改回归模型进行回归
ppmlhdfe Firmflowsnum Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo e

esttab a b c d e using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)





/////////////////附表7 考虑政策前地方财政能力、治理压力和企业外流反馈的稳健性检验
use 附录数据/addmaster,clear
//考虑地方财政能力
reghdfe Firmflows Discretion Discretion_fiscalcapa $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

//考虑地方治理压力
reghdfe Firmflows Discretion $County_Control ,absorb(governpressure#year county_id province_id#year) vce(cluster city_id)
eststo b

//考虑企业外流反馈
reghdfe Firmflows Discretion Discretion_outflows $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

esttab a b c using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)





/////////////////附表8 流入企业结构特征的异质性分析
use 附录数据/addmaster,clear
//制造业与服务业
reghdfe Firmflowszzy Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe Firmflowsfwy Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

//初创企业与成熟企业
reghdfe FirmflowsStartups Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe FirmflowsMatures Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

//中型企业与小微型企业
reghdfe Firmflowsmes Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo e

reghdfe Firmflowsss Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo f

esttab a b c d e f using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)



   

/////////////////附表9 流入企业来源地特征的异质性分析
use 附录数据/addmaster,clear
//省内流入 
reghdfe Firmflowsinprovince Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

//省外流入
reghdfe Firmflowsprovout Discretion $County_Control ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

esttab a b using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)



   
     
/////////////////附表10 要素集聚水平的异质性分析
use 附录数据/addmaster,clear
//省级开发区
reghdfe Firmflows Discretion $County_Control if provincialzones==0,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe Firmflows Discretion $County_Control if provincialzones==1,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

//国家级开发区
reghdfe Firmflows Discretion $County_Control if statezones==0,absorb(county_id province_id#year) vce(cluster city_id)
eststo c

reghdfe Firmflows Discretion $County_Control if statezones==1,absorb(county_id province_id#year) vce(cluster city_id)
eststo d

esttab a b c d using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)


   
     
/////////////////附表11 行政体制划分的异质性分析
//=0代表县，=1代表市辖区
reghdfe Firmflows Discretion $County_Control if district==0 ,absorb(county_id province_id#year) vce(cluster city_id)
eststo a

reghdfe Firmflows Discretion $County_Control if district==1 ,absorb(county_id province_id#year) vce(cluster city_id)
eststo b

esttab a b using shift.rtf,star(* 0.1 ** 0.05 *** 0.01) replace b(4) se(4) ar2(4) scalar(N)























