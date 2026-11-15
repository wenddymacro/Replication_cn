
*****************************************************************************

**                    新城建设与地区创业活跃度                             **
**                     陈勇兵，胡佳雯，陈永安                              **

*****************************************************************************    


version 16
drop _all
set more off
clear all
cd 
global cyear popdensity2006yr* agriareaper2006yr*  consratio2006yr* lnindp2006yr* jinrong2006yr* 
global cyearpre popdensitypreyr* agriareaperpreyr*  consratiopreyr* lnindppreyr* jinrongpreyr*


*===============================================================================
*                                 正文图表
*===============================================================================
/////////////////表1 描述性统计
use city.dta,clear
reghdfe lnNo_GSmgfper tp $cyear ,ab(city_id prov_id##year)  vce(cluster city_id)
gen in_sample=1 if e(sample)==1
sum2docx lnNo_GSmgfper popdensity2006 agriareaper2006  consratio2006 lnindp2006 jinrong2006 if in_sample==1 using "outcome\table1.docx", replace stats(N mean(%9.4f) sd(%9.4f) min(%9.4f) median(%9.4f) p90 max(%9.4f)) title("表1：描述性统计") font(Times New Roman,10)
					

//////////////////表2 基准回归
use city.dta,clear 
reghdfe lnNo_GSmgfper tp $cyear ,ab(city_id prov_id##year)  vce(cluster city_id)
gen in_sample=1 if e(sample)==1
est clear
reghdfe lnNo_GSmgfper tp if in_sample==1, ab(city_id prov_id##year)  vce(cluster city_id)
est store g1
reghdfe lnNo_GSmgfper tp  $cyear if in_sample==1, ab(city_id prov_id##year)  vce(cluster city_id)
est store g2
reghdfe lnNo_GSmgfper tp  $cyear if in_sample==1, ab(city_id prov_id##year)  vce(cluster prov_id)
est store g3

esttab g1 g2 g3 using "outcome/table2.rtf", replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se 
					
//////////////////图1 平行趋势检验
use city.dta,clear 
gen dist=year-firstyear
eventdd lnNo_GSmgfper $cyear, timevar(dist)   inrange leads(4) lags(4) method(hdfe, absorb(city_id prov_id##year) cluster(city_id))  coef_op(m(oh) c(l) color(black) lcolor(black))   graph_op(xtitle("相对时间")  ytitle("估计结果")  color(black) xline(-1, lc(black*0.5) lp(dash) )   graphregion(fcolor(white)))

forvalues i=55(1)62 {
	local b_`i'=e(b)[1,`i']
}
matrix define mat1_mgf= (`b_55',`b_56',`b_57',0,`b_58',`b_59',`b_60',`b_61',`b_62')
mat colnames mat1_mgf =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4

forvalues i=55(1)62 {
	local v_`i'=e(V)[`i',`i']
}
matrix input mat2_mgf = (`v_55',`v_56',`v_57',0,`v_58',`v_59',`v_60',`v_61',`v_62')
mat colnames mat2_mgf =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4

event_plot   mat1_mgf#mat2_mgf  , stub_lag(T+# T+#) stub_lead(T-# T-#)   plottype( connected ) ciplottype(rcap) together trimlag(4) noautolegend graph_opt(xtitle("相对于新城开建的时间") ytitle("地区制造业创业活跃度") xlabel( -4 -3 -2 -1 0 1 2 3 4, labsize(small)) ylabel( -0.3  0 0.3 0.6 , labsize(small)) legend(order(1 "制造业创业活跃度" ) rows(1) region(style(none)))xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)))    lag_opt1(msymbol(Sh) color(black)) lag_ci_opt1(color(black)) perturb(-0.325(0.13)0.325)			
		
graph save "outcome/figure1", replace	

//////////////////表3 新城建设与招商引资
use city.dta,clear
gen tpmeanprice_gongye2007=tp*meanprice_gongye2007
reghdfe lnNo_GSmgfper tp  tpmeanprice_gongye2007  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est clear
est store g1

reghdfe lnNo_GSmgfper tp  $cyear if east==0,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g2

reghdfe lnNo_GSmgfper tp  $cyear if east==1,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g3

use city-industry.dta, clear
reghdfe hhi5 tp  $cyear, ab(hylb city_id prov_id##year)  vce(cluster city_id)   
est store g4

use city.dta,clear
foreach v in   lngdpper2006  lngdpperpre { //
   gen tp`v'=tp*`v'
}
reghdfe lnNo_GSmgfper tp tplngdpper2006 $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g5
reghdfe lnNo_GSmgfper tp tplngdpperpre $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g6		

esttab g1 g2 g3 g4 g5 g6  using "outcome/table3.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se

//////////////////表4 新城建设的产业集聚效应与人口集聚效应
use city.dta,clear
est clear
reghdfe zhuan  tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g1
reghdfe duo tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g2
reghdfe density1 tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g3
reghdfe density2 tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g4
reghdfe thirdind tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g5
reghdfe thirdindemp tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g6

esttab g1 g2 g3 g4 g5 g6  using "outcome/table4.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se

//////////////////表5 城市化滞后的解释
use city.dta,clear
est clear
reghdfe avglife tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)   
est store g1
reghdfe life3rate tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g2
reghdfe ksi tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g3
reghdfe Score tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g4
reghdfe zhichu tp  $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g5

esttab g1 g2 g3 g4 g5 using "outcome/table5.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se

						
						
						
*===============================================================================
*                                 附录表格
*===============================================================================	
/////////////////附表1 平衡性检验
use city.dta,clear
duplicates drop city_id, force

balancetable treatment lngdp2006 secondind2006 thirdind2006 lnindp2006 lntax2006 lnwage2006 fdiper2006 zfguimo2006 jinrong2006 popdensity2006 naturalrate2006 agriareaper2006 consratio2006 greenrate2006 slope  using "outcome/appentable1.xlsx", replace format(%9.4f) 
						
					
//////////////////附表2 阿森费尔特沉降检验					
use city.dta,clear										
est clear
reghdfe lnNo_GSmgfper tp ch2_lnNo_GSmgfper $cyear, ab(city_id prov_id##year)  vce(cluster city_id)  
est store g1
reghdfe lnNo_GSmgfper tp Pre12 $cyear, ab(city_id prov_id##year)  vce(cluster city_id) 
est store g2 	
esttab g1 g2  using "outcome/appentable2.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se 						
				
//////////////////附表3 安慰剂检验					
use city.dta,clear
keep if post<0 
drop if firstyear==2007   
gen fake1=(treatment==1 & post>=-1) 
reghdfe lnNo_GSmgfper fake1  $cyear, ab(city_id prov_id##year)  vce(cluster city_id) 
est clear
est store g1

use city.dta,clear
keep if post<0 
drop if firstyear==2007 | firstyear==2008
gen fake2=(treatment==1 & post>=-2) 
reghdfe lnNo_GSmgfper fake2  $cyear, ab(city_id prov_id##year)  vce(cluster city_id) 
est store g2

esttab g1 g2  using "outcome/appentable3.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se 																										
//////////////////附图1 插补法估计量							
use city.dta,clear	
//制造业				
did_imputation lnNo_GSmgfper  city_id year  firstyear, timecontrols(agriareaper2006 consratio2006 lnindp2006  jinrong2006) fe(city_id year) autosample  pretrends(4) horizons(0 1 2 3 4) cluster(city_id) 

matrix define mat1_bor1=e(b)
matrix mat1_bor=mat1_bor1[1,1..9]
mat colnames mat1_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
forvalues i=1(1)9 {
	local v_`i'=e(V)[`i',`i']
}
matrix input mat2_bor = (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9')
mat colnames mat2_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4 		
//OLS
use city.dta,clear
reghdfe lnNo_GSmgfper pre8 pre7 pre6 pre5 pre4 pre3 pre2  post0 post1 post2  post3 post4 post5 post6 post7 post8 $cyear, ab(city_id prov_id##year)  vce(cluster city_id)

forvalues i=5(1)12 {
	local b_`i'=e(b)[1,`i']
}
matrix define mat1_ols= (`b_5',`b_6',`b_7',0,`b_8',`b_9',`b_10',`b_11',`b_12')
mat colnames mat1_ols =  T-4 T-3 T-2 T-1 T+0 T+1 T+2  T+3 T+4

forvalues i=5(1)12 {
	local v_`i'=e(V)[`i',`i']
}
matrix input mat2_ols = (`v_5',`v_6',`v_7',0,`v_8',`v_9',`v_10',`v_11',`v_12')
mat colnames mat2_ols =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4		
//合并画图
event_plot   mat1_bor#mat2_bor  mat1_ols#mat2_ols, stub_lag( T+# T+#) stub_lead( T-# T-#)  alpha(0.05) plottype(scatter) ciplottype(rcap) together trimlag(4) noautolegend graph_opt( xtitle("相对于新城开建的时间") ytitle("地区制造业创业活跃度") xlabel( -4 -3 -2 -1 0 1 2 3 4, labsize(small)) ylabel( -0.2  0 0.2 0.4 , labsize(small)) legend(order(1 "Borusyak et al." 3 "TWFE OLS") rows(1) region(style(none))) xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)))   lag_opt1(msymbol(O) color(dkorange)) lag_ci_opt1(color(dkorange))  lag_opt2(msymbol(Sh) color(black)) lag_ci_opt2(color(black))  perturb(-0.325(0.13)0.325)		
		
graph save "outcome/appenfigure1", replace
				
//////////////////附表4 排除同时期其他政策的影响
use city.dta,clear
est clear
reghdfe lnNo_GSmgfper tp  $cyear kfq,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g1
reghdfe lnNo_GSmgfper tp  $cyear cx,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g2

esttab g1 g2 using "outcome/appentable4.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se					
									
//////////////////附表5 稳健性检验
//剔除省会城市
use city.dta,clear
drop if yy=="01"
est clear
reghdfe lnNo_GSmgfper tp $cyear  ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g1

//地区创业活跃度的重新测度
use city.dta,clear
reghdfe lnNo_GSmgf tp  $cyear,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g2

//灵活控制地区特征差异
reghdfe lnNo_GSmgfper tp  $cyearpre,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g3

//控制特定处理组趋势
use city.dta,clear
gen treatment_trend2=treatment_trend*treatment_trend
reghdfe lnNo_GSmgfper tp  $cyear treatment_trend  ,ab(city_id prov_id##year)  vce(cluster city_id)  
est store g4
reghdfe lnNo_GSmgfper tp  $cyear treatment_trend treatment_trend2 ,ab(city_id prov_id##year)  vce(cluster city_id) 
est store g5

esttab g1 g2 g3 g4 g5 using "outcome/appentable5.rtf" , replace ar2 compress nogap ///
					b(%6.4f) se(%6.4f) star(* 0.1 ** 0.05 *** 0.01) se


