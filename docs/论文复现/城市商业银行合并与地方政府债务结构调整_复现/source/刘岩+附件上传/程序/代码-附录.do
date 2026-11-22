clear all
set more off
cd "xxxxxx" //真实路径

capture mkdir "appendix_outputs"
global out "appendix_outputs"

******************************************************************************
* 附表3 识别效应检验
******************************************************************************
capture estimates clear
clear
use "data_province_after.dta",clear
egen id=group(省份)

stset year, id(id) failure(event==1)

stcox lnperGDP, vce(robust)
est store cox_1
stcox GDPg, vce(robust)
est store cox_2
stcox lnperIndustry, vce(robust)
est store cox_3
stcox lnperFinance, vce(robust)
est store cox_4
stcox fiscal_GDP, vce(robust)
est store cox_5
stcox fiscal_ratio, vce(robust)
est store cox_6
stcox debtold_s, vce(robust)
est store cox_7
stcox weight_npl, vce(robust)
est store cox_8
stcox lnperGDP GDPg lnperIndustry lnperFinance fiscal_GDP fiscal_ratio debtold_s weight_npl, vce(robust)
est store cox_9

esttab cox_* using "$out/appendix_table03_identification.rtf",b(%6.4f) t(%6.4f) nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   scalar(N) replace

******************************************************************************
* 附表4 省级城商行合并对地方投融资平台非标融资的影响
******************************************************************************
capture estimates clear
clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in trustnew_h_l rentnew_h_l othernew_h_l {
	reghdfe `var' D ,absorb(city year) vce(cluster city)
    est store model3_`var'_a
}

foreach var in trustnew_h_l rentnew_h_l othernew_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store model3_`var'_b
} 

esttab model3_* using "$out/appendix_table04_nonstandard_channels.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace   ///
   indicate("控制变量 =$cov_city") 
   
foreach var in trustold_h_l rentold_h_l otherold_h_l {
	reghdfe `var' D ,absorb(city year) vce(cluster city)
    est store model4_`var'_a
}

foreach var in trustold_h_l rentold_h_l otherold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store model4_`var'_b
}

esttab model4_* using "$out/appendix_table04_nonstandard_channels.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) append   ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附图1 平行趋势检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

gen distance=year-policy_year
//tab distance,missing
forv i=12(-1)1{
  gen pre`i'=(distance==-`i')
}
forv i=1(1)13{
  gen post`i'=(distance==`i')
}
gen current=(distance==0)

reghdfe debtnew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* $cov_city pre1,absorb(city year) vce(cluster city)
est store p1
coefplot,baselevels omitted ///
         keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 vertical ///
		 addplot(line @b @at) ///
		 yline(0,lp(dash) lc(black)) ///
		 levels(95) ///
		 xtitle("时间",size(small) margin(t=2)) ///
		 ytitle("平均处理效应",size(small) margin(r=2)) ///
		 title("附图1(a):非信贷类城投债务增量") ///
		 xline(5,lp(dash) lc(black)) ///
		 ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) ///
		 scale(1.0) ///
		 scheme(white) ///
		 saving(parallel_1,replace)

reghdfe bondnew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* $cov_city pre1,absorb(city year) vce(cluster city)
est store p1
coefplot,baselevels omitted ///
         keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 vertical ///
		 addplot(line @b @at) ///
		 yline(0,lp(dash) lc(black)) ///
		 levels(95) ///
		 xtitle("时间",size(small) margin(t=2)) ///
		 ytitle("平均处理效应",size(small) margin(r=2)) ///
		 title("附图1(b):债券增量") ///
		 xline(5,lp(dash) lc(black)) ///
		 ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) ///
		 scale(1.0) ///
		 scheme(white) ///
		 saving(parallel_2,replace)

reghdfe feibiaonew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* $cov_city pre1,absorb(city year) vce(cluster city)
est store p1
coefplot,baselevels omitted ///
         keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 vertical ///
		 addplot(line @b @at) ///
		 yline(0,lp(dash) lc(black)) ///
		 levels(95) ///
		 xtitle("时间",size(small) margin(t=2)) ///
		 ytitle("平均处理效应",size(small) margin(r=2)) ///
		 title("附图1(c):非标增量") ///
		 xline(5,lp(dash) lc(black)) ///
		 ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) ///
		 scale(1.0) ///
		 scheme(white) ///
		 saving(parallel_3,replace)		 
		 
reghdfe debtold_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* $cov_city pre1,absorb(city year) vce(cluster city)
est store p1
coefplot,baselevels omitted ///
         keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 vertical ///
		 addplot(line @b @at) ///
		 yline(0,lp(dash) lc(black)) ///
		 levels(95) ///
		xtitle("时间",size(small) margin(t=2)) ///
		 ytitle("平均处理效应",size(small) margin(r=2)) ///
		 title("附图1(d):非信贷类城投债务存量") ///
		 xline(5,lp(dash) lc(black)) ///
		 ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) ///
		 scale(1.0) ///
		 scheme(white) ///
		 saving(parallel_4,replace)

reghdfe bondold_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* $cov_city pre1,absorb(city year) vce(cluster city)
est store p1
coefplot,baselevels omitted ///
         keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 vertical ///
		 addplot(line @b @at) ///
		 yline(0,lp(dash) lc(black)) ///
		 levels(95) ///
		 xtitle("时间",size(small) margin(t=2)) ///
		 ytitle("平均处理效应",size(small) margin(r=2)) ///
		 title("附图1(e):债券存量") ///
		 xline(5,lp(dash) lc(black)) ///
		 ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) ///
		 scale(1.0) ///
		 scheme(white) ///
		 saving(parallel_5,replace)

reghdfe feibiaoold_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* $cov_city pre1,absorb(city year) vce(cluster city)
est store p1
coefplot,baselevels omitted ///
         keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) ///
		 vertical ///
		 addplot(line @b @at) ///
		 yline(0,lp(dash) lc(black)) ///
		 levels(95) ///
		 xtitle("时间",size(small) margin(t=2)) ///
		 ytitle("平均处理效应",size(small) margin(r=2)) ///
		 title("附图1(f):非标存量") ///
		 xline(5,lp(dash) lc(black)) ///
		 ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) ///
		 scale(1.0) ///
		 scheme(white) ///
		 saving(parallel_6,replace)		

graph combine parallel_1.gph parallel_2.gph parallel_3.gph parallel_4.gph parallel_5.gph parallel_6.gph,row(2) xsize(7.5) ysize(4)      
//运用grec调整

graph export "$out/appendix_figure01_parallel_trend.png", replace width(2400)

******************************************************************************
* 附图2 安慰剂检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
egen citycode=group(city)
save "data_city_v2.dta",replace
 
mat b=J(1000,1,0)
mat se=J(1000,1,0)
mat p=J(1000,1,0)
forv i=1/1000{
use "data_city_v2.dta",clear //抽取年份
xtset citycode year
bsample 1,strata(citycode) //根据citycode分组，每组随机抽取一个年份
keep year 
save matchyear.dta,replace
mkmat year,matrix(sampleyear) 
use "data_city_v2.dta",clear //抽取城市
xtset citycode year 
keep citycode
duplicates drop citycode,force
sample 66,count
egen random=group(citycode)
sort citycode
save matchcity.dta,replace
use "data_city_v2.dta",clear //抽样回归
sort citycode
merge m:m citycode using matchcity.dta
drop _merge
xtset citycode year 
gen DID=0
foreach j of numlist 1/66{ 
replace DID=1 if (random==`j' & year>=sampleyear[`j',1])
}
qui reghdfe debtnew_h_l DID $cov_city ,absorb(city year) vce(cluster city)
mat b[`i',1]=_b[DID]  //系数矩阵
mat se[`i',1]=_se[DID]  //标准误矩阵
scalar df_r=e(N)-e(df_m)-1
mat p[`i',1]=2*ttail(e(df_r),abs(_b[DID]/_se[DID]))  //p值矩阵
}
svmat b,names(coef)
svmat se,names(se)
svmat p,names(pvalue)
drop if pvalue1==.
twoway (kdensity coef1)(scatter pvalue1 coef1,msize(0.4)),  ///
  legend(order(1 "系数" 2 "P值" ))  ///
  ytitle("分布") ///
  xline(0.00) xline(0.4867) yline(0.05) ///
  title("(a):非信贷类城投债务增量")  ///
  xlabel(-0.7 "-0.7" 0 "0.0" 0.7 "0.7") ///
  ylabel(0 "0" 0.5 "0.5" 1 "1" 1.5 "1.5" 2 "2" 2.5 "2.5") ///
  yscale(range(0 2.5)) ///
  xscale(range(-0.7 0.7)) ///
  legend(position(6) ring(1) rows(1)) ///
  saving(Placebo_1,replace)

mat b=J(1000,1,0)
mat se=J(1000,1,0)
mat p=J(1000,1,0)
forv i=1/1000{
use "data_city_v2.dta",clear //抽取年份
xtset citycode year
bsample 1,strata(citycode) //根据citycode分组，每组随机抽取一个年份
keep year 
save matchyear.dta,replace
mkmat year,matrix(sampleyear) 
use "data_city_v2.dta",clear //抽取城市
xtset citycode year 
keep citycode
duplicates drop citycode,force
sample 66,count
egen random=group(citycode)
sort citycode
save matchcity.dta,replace
use "data_city_v2.dta",clear //抽样回归
sort citycode
merge m:m citycode using matchcity.dta
drop _merge
xtset citycode year 
gen DID=0
foreach j of numlist 1/66{ 
replace DID=1 if (random==`j' & year>=sampleyear[`j',1])
}
qui reghdfe debtold_h_l DID $cov_city ,absorb(city year) vce(cluster city)
mat b[`i',1]=_b[DID]  //系数矩阵
mat se[`i',1]=_se[DID]  //标准误矩阵
scalar df_r=e(N)-e(df_m)-1
mat p[`i',1]=2*ttail(e(df_r),abs(_b[DID]/_se[DID]))  //p值矩阵
}
svmat b,names(coef)
svmat se,names(se)
svmat p,names(pvalue)
drop if pvalue1==.
twoway (kdensity coef1)(scatter pvalue1 coef1,msize(0.4)),  ///
  legend(order(1 "系数" 2 "P值" ))  ///
  ytitle("分布") ///
  xline(0.00) xline(0.6765) yline(0.05) ///
  title("(b):非信贷类城投债务存量")  ///
  legend(position(6) ring(1) rows(1)) ///
  xlabel(-0.7 "-0.7" 0 "0.0" 0.7 "0.7") ///
  ylabel(0 "0" 0.5 "0.5" 1 "1" 1.5 "1.5" 2 "2" 2.5 "2.5") ///
  yscale(range(0 2.5)) ///
  xscale(range(-0.7 0.7)) ///
  saving(Placebo_4,replace)  
  
graph combine Placebo_1.gph  Placebo_4.gph

graph export "$out/appendix_figure02_placebo.png", replace width(2400)

******************************************************************************
* 附表5&附图3 Bacon分解结果
******************************************************************************
capture estimates clear
* 该命令同时生成 Bacon 分解结果及对应图示；如需导出图形，可在运行后使用 graph export。
use "data_city_after.dta",clear
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   

ddtiming debtnew_h_l D,i(city) t(year)  //是否更换解释变量权重不变
graph export "$out/appendix_figure03_bacon.png", replace width(2400)

******************************************************************************
* 附表6 De-Chaisemartin and d’Haultfoeuille（2020）检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
twowayfeweights debtnew_h_l city year D,type(feTR) controls(fiscalgap_ratio fiscal_GDP GDPg lnpop workyear) 
foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
    did_multiplegt_dyn `var' city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
     est store modelw1_`var'
}

esttab modelw1_* using "$out/appendix_table06_dechaisemartin.rtf",b(%6.4f) t(%6.4f)  nogap compress  ///
   keep(Av_tot_eff) ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   scalar(N) replace

******************************************************************************
* 附图4 De-Chaisemartin and d’Haultfoeuille（2020）平行趋势检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

did_multiplegt_dyn debtnew_h_l city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
event_plot e(estimates)#e(variances), /// 
    shift(1) ///
    graph_opt(xtitle("时间",size(small) margin(t=2)) ///
              ytitle("平均处理效应",size(small) margin(r=2)) ///
              title("附图4(a)：债务增量",size(small) margin(t=2)) ///
			  graphregion(color(white)) ///
			  plotregion(color(white)) ///
              xlabel(-7(1)5, labsize(small)) ///
			  ylabel(,labsize(small)) ///
			  xline(-1,lp(dash) lc(gray)) ///
			  yline(0,lp(dash) lc(gray)) ///
			  scheme(s1mono)) /// 				  
    stub_lag(Effect_#) stub_lead(Placebo_#) ///  
    ciplottype(rcap) ///
	together
graph save DIDM_1,replace	

did_multiplegt_dyn bondnew_h_l city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
event_plot e(estimates)#e(variances), /// 
    shift(1) ///
    graph_opt(xtitle("时间",size(small) margin(t=2)) ///
              ytitle("平均处理效应",size(small) margin(r=2)) ///
              title("附图4(b)：债券增量",size(small) margin(t=2)) ///
			  graphregion(color(white)) ///
			  plotregion(color(white)) ///
              xlabel(-7(1)5, labsize(small)) ///
			  ylabel(,labsize(small)) ///
			  xline(-1,lp(dash) lc(gray)) ///
			  yline(0,lp(dash) lc(gray)) ///
			  scheme(s1mono)) /// 				  
    stub_lag(Effect_#) stub_lead(Placebo_#) ///  
    ciplottype(rcap) ///
	together
graph save DIDM_2,replace

did_multiplegt_dyn feibiaonew_h_l city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
event_plot e(estimates)#e(variances), /// 
    shift(1) ///
    graph_opt(xtitle("时间",size(small) margin(t=2)) ///
              ytitle("平均处理效应",size(small) margin(r=2)) ///
              title("附图4(c)：非标增量",size(small) margin(t=2)) ///
			  graphregion(color(white)) ///
			  plotregion(color(white)) ///
              xlabel(-7(1)5, labsize(small)) ///
			  ylabel(,labsize(small)) ///
			  xline(-1,lp(dash) lc(gray)) ///
			  yline(0,lp(dash) lc(gray)) ///
			  scheme(s1mono)) /// 				  
    stub_lag(Effect_#) stub_lead(Placebo_#) ///  
    ciplottype(rcap) ///
	together
graph save DIDM_3,replace		

did_multiplegt_dyn debtold_h_l city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
event_plot e(estimates)#e(variances), /// 
    shift(1) ///
    graph_opt(xtitle("时间",size(small) margin(t=2)) ///
              ytitle("平均处理效应",size(small) margin(r=2)) ///
              title("附图4(d)：债务存量",size(small) margin(t=2)) ///
			  graphregion(color(white)) ///
			  plotregion(color(white)) ///
              xlabel(-7(1)5, labsize(small)) ///
			  ylabel(,labsize(small)) ///
			  xline(-1,lp(dash) lc(gray)) ///
			  yline(0,lp(dash) lc(gray)) ///
			  scheme(s1mono)) /// 				  
    stub_lag(Effect_#) stub_lead(Placebo_#) ///  
    ciplottype(rcap) ///
	together
graph save DIDM_4,replace	

did_multiplegt_dyn bondold_h_l city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
event_plot e(estimates)#e(variances), /// 
    shift(1) ///
    graph_opt(xtitle("时间",size(small) margin(t=2)) ///
              ytitle("平均处理效应",size(small) margin(r=2)) ///
              title("附图4(e)：债券存量",size(small) margin(t=2)) ///
			  graphregion(color(white)) ///
			  plotregion(color(white)) ///
              xlabel(-7(1)5, labsize(small)) ///
			  ylabel(,labsize(small)) ///
			  xline(-1,lp(dash) lc(gray)) ///
			  yline(0,lp(dash) lc(gray)) ///
			  scheme(s1mono)) /// 				  
    stub_lag(Effect_#) stub_lead(Placebo_#) ///  
    ciplottype(rcap) ///
	together
graph save DIDM_5,replace

did_multiplegt_dyn feibiaoold_h_l city year D,effects(6) placebo(6) controls($cov_city) cluster(city) graph_off
event_plot e(estimates)#e(variances), /// 
    shift(1) ///
    graph_opt(xtitle("时间",size(small) margin(t=2)) ///
              ytitle("平均处理效应",size(small) margin(r=2)) ///
              title("附图4(f)：非标存量",size(small) margin(t=2)) ///
			  graphregion(color(white)) ///
			  plotregion(color(white)) ///
              xlabel(-7(1)5, labsize(small)) ///
			  ylabel(,labsize(small)) ///
			  xline(-1,lp(dash) lc(gray)) ///
			  yline(0,lp(dash) lc(gray)) ///
			  scheme(s1mono)) /// 				  
    stub_lag(Effect_#) stub_lead(Placebo_#) ///  
    ciplottype(rcap) ///
	together
graph save DIDM_6,replace	
graph combine DIDM_1.gph DIDM_2.gph DIDM_3.gph DIDM_4.gph DIDM_5.gph DIDM_6.gph,row(2) xsize(8.5) ysize(4.3)

graph export "$out/appendix_figure04_dechaisemartin_event.png", replace width(2400)

******************************************************************************
* 附表7 Borusyak et al.（2024）检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
    did_imputation `var' city year policy_year,autosample controls($cov_city) fe(city year) cluster(city) tol(1) maxit(100)
     est store Borusyak_`var'
}

esttab Borusyak_* using "$out/appendix_table07_borusyak.rtf",b(%6.4f) t(%6.4f) nogap compress  ///
   keep(tau) ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   scalar(N) replace

******************************************************************************
* 附图5 Sun and Abraham（2021）检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

gen distance=year-policy_year
tab distance,missing
forv i=12(-1)1{
  gen pre`i'=(distance==-`i')
}
forv i=1(1)13{
  gen post`i'=(distance==`i')
}
gen current=(distance==0)
gen never=(policy_year==.)

eventstudyinteract debtnew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* pre1,cohort(policy_year) control_cohort(never) covariates($cov_city) absorb(i.city i.year) vce(cluster city)
matrix b=e(b_iw)
matrix V=e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) vertical recast(connect) color(black) order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) yline(0,lp(solid) lc(black)) xline(5,lp(dash) lc(black)) xtitle("时间",size(small) margin(t=2)) ytitle("平均处理效应",size(small) margin(r=2)) title("附图5(a):非信贷类城投债务增量", margin(t=2)) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) saving(SA_1,replace)	

eventstudyinteract bondnew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* pre1,cohort(policy_year) control_cohort(never) covariates($cov_city) absorb(i.city i.year) vce(cluster city)
matrix b=e(b_iw)
matrix V=e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) vertical recast(connect) color(black) order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) yline(0,lp(solid) lc(black)) xline(5,lp(dash) lc(black)) xtitle("时间",size(small) margin(t=2)) ytitle("平均处理效应",size(small) margin(r=2)) title("附图5(b):债券增量", margin(t=2)) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) saving(SA_2,replace)	

eventstudyinteract feibiaonew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* pre1,cohort(policy_year) control_cohort(never) covariates($cov_city) absorb(i.city i.year) vce(cluster city)
matrix b=e(b_iw)
matrix V=e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) vertical recast(connect) color(black) order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) yline(0,lp(solid) lc(black)) xline(5,lp(dash) lc(black)) xtitle("时间",size(small) margin(t=2)) ytitle("平均处理效应",size(small) margin(r=2)) title("附图5(c):非标增量",margin(t=2)) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) saving(SA_3,replace)	

eventstudyinteract debtold_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* pre1,cohort(policy_year) control_cohort(never) covariates($cov_city) absorb(i.city i.year) vce(cluster city)
matrix b=e(b_iw)
matrix V=e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) vertical recast(connect) color(black) order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) yline(0,lp(solid) lc(black)) xline(5,lp(dash) lc(black)) xtitle("时间",size(small) margin(t=2)) ytitle("平均处理效应",size(small) margin(r=2)) title("附图5(d):非信贷类城投债务存量",margin(t=2)) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) saving(SA_4,replace)	

eventstudyinteract bondnew_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* pre1,cohort(policy_year) control_cohort(never) covariates($cov_city) absorb(i.city i.year) vce(cluster city)
matrix b=e(b_iw)
matrix V=e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) vertical recast(connect) color(black) order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) yline(0,lp(solid) lc(black)) xline(5,lp(dash) lc(black)) xtitle("时间",size(small) margin(t=2)) ytitle("平均处理效应",size(small) margin(r=2)) title("附图5(e):债券存量",margin(t=2)) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) saving(SA_5,replace)	

eventstudyinteract feibiaoold_h_l pre12 pre11 pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 current post* pre1,cohort(policy_year) control_cohort(never) covariates($cov_city) absorb(i.city i.year) vce(cluster city)
matrix b=e(b_iw)
matrix V=e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) vertical recast(connect) color(black) order(pre5 pre4 pre3 pre2 pre1 current post1 post2 post3 post4 post5) yline(0,lp(solid) lc(black)) xline(5,lp(dash) lc(black)) xtitle("时间",size(small) margin(t=2)) ytitle("平均处理效应",size(small) margin(r=2)) title("附图5(f):非标存量",margin(t=2)) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) saving(SA_6,replace)

graph combine SA_1.gph SA_2.gph SA_3.gph SA_4.gph SA_5.gph SA_6.gph,row(2) xsize(8.6) ysize(4)

graph export "$out/appendix_figure05_sun_abraham.png", replace width(2400)

******************************************************************************
* 附表8 倾向得分匹配后主回归模型检验结果
******************************************************************************
capture estimates clear
* 本段先完成逐年匹配，再生成附表8；其中 pstest 和 psgraph 同时对应附表9与附图6。
foreach i in 2005 2007 2009 2010 2011 2012 2014 2015 2020 2021 {
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
replace treat=1 if city==5104|city==5134|city==1402|city==1404|city==1405|city==1407|city==1403|city==2108|city==2110|city==3602
keep if policy_year==.|policy_year==`i' //当前合并和没有合并的全部观测值
keep if year==`i'-1 //保留观测值前一年的值
psmatch2 treat fiscalgap_ratio GDPg sec lnpop DLratio achhi,outcome(debtnew_h_l) logit ate ties common n(1)
save `i'.dta,replace
}

clear
foreach i in 2005 2007 2009 2010 2011 2012 2014 2015 2020 2021 {
 append using `i'.dta
}

pstest fiscalgap_ratio GDPg sec lnpop DLratio achhi,both graph
pstest fiscalgap_ratio GDPg sec lnpop DLratio achhi, both graph
graph rename appendix_fig6, replace
graph export "$out/appendix_figure06_psm_balance.png", replace width(2400)

cd "$out"
asdoc pstest fiscalgap_ratio GDPg sec lnpop DLratio achhi, both save(appendix_table09_psm_balance.doc) replace
cd "xxxx" //真实路径

keep if _weight!=.
keep city 
duplicates drop city,force
merge 1:m city using "data_city_after.dta"
keep if _merge==3

xtset city year
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"
global cov_city2 "fiscalgap_ratio_z fiscal_GDP_z GDPg_z sec_z lnpop_z"

drop if year<2003
//面板B：2003-2023
foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l { 
reghdfe `var' D $cov_city2 , absorb(city year) vce(cluster city)
    est store model8_`var'
}

esttab model8_* using "$out/appendix_table08_psm_regression.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
    ar2(%6.4f) scalar(N) replace  ///
   indicate("控制变量 =$cov_city2")

drop if year>2018
//面板A:2003-2018
foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l { 
reghdfe `var' D $cov_city , absorb(city year) vce(cluster city)
    est store model9_`var'
}

esttab model9_* using "$out/appendix_table08_psm_regression.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
    ar2(%6.4f) scalar(N) append  ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表10 使用IV后省级城商行合并对地方政府非信贷类城投债务的影响
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
gen post2004 = year >= 2004
gen iv_proximity = bankcity_neg * post2004
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"   


ivreghdfe debtnew_h_l (D = iv_proximity)  $cov_city, absorb(city year) cluster(city) first savefirst
est store iv_1
ivreghdfe debtold_h_l (D = iv_proximity)  $cov_city, absorb(city year) cluster(city) first savefirst
est store iv_2

esttab iv_* using "$out/appendix_table10_iv.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
    ar2(%6.4f) scalar(N) replace ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表11 考虑地方政府债务置换后的检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
gen Post2015 = (year >= 2015)   
gen total_debt_ratio=(debtold_t+bankloan_t)/(GDP/10000)
bysort city: egen debt_ratio_2014 = max(cond(year == 2014, total_debt_ratio, .))   
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"   

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {   
    reghdfe `var' D c.Post2015#c.debt_ratio_2014 $cov_city, absorb(city year) vce(cluster city)    
    est store model11_`var'
}   
   
esttab model11_* using "$out/appendix_table11_debt_swap.rtf",b(%6.4f) t(%6.4f)  noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表12 扩展研究时间后省级城商行合并对地方政府债务的影响
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50 

global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z sec_z lnpop_z" //工业层面的控制变量在2016年后有缺失 此处用第二产业占比代替

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw2_`var'
}

esttab modelw2_* using "$out/appendix_table12_extend_time.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace  ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表13 更换样本时间后省级城商行合并对地方政府债务的影响
******************************************************************************
capture estimates clear
//面板A
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2014  //2015年地方政府专项债
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw3a_`var'
}

esttab modelw3a_* using "$out/appendix_table13_change_sample_time.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace ///
   indicate("控制变量 =$cov_city")
//面板B   
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
drop if year==2009|year==2010 //2009年四万亿计划
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw3b_`var'
}

esttab modelw3b_* using "$out/appendix_table13_change_sample_time.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01) append ///
   ar2(%6.4f) scalar(N) replace   ///
   indicate("控制变量 =$cov_city")   
//面板C      
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
drop if year==2013|year==2014 //2013年融资平台新增贷款
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw3c_`var'
}

esttab modelw3c_* using "$out/appendix_table13_change_sample_time.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01) append ///
   ar2(%6.4f)  scalar(N) replace  ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表14 增加直辖市样本后省级城商行合并对地方政府债务的影响
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z" //市委书记晋升激励不适用于四个直辖市

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw4_`var'
}

esttab modelw4_* using "$out/appendix_table14_include_municipalities.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace ///
   indicate("控制变量 =$cov_city")


******************************************************************************
* 附表16 股权划分下省级城商行合并对地方政府债务的影响
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' Dn $cov_city ,absorb(city year) vce(cluster city)
    est store modelw5_`var'
}

esttab modelw5_* using "$out/appendix_table16_control_right_definition.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace  ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表17 剔除少量发行异常值后省级城商行合并对地方政府债务的影响
******************************************************************************
capture estimates clear
//面板A：样本期内只发行过1次 
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

replace bondnew_h=. if bondnew_h==0
gen is_missing = missing(bondnew_h)
bysort province city: egen total_missing = total(is_missing)
bysort province city: egen total_years = count(year)
drop if total_missing == total_years-1
drop is_missing total_missing total_years

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw6a_`var'
}

esttab modelw6a_* using "$out/appendix_table17_drop_sparse_issuance.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace  ///
   indicate("控制变量 =$cov_city")  

//面板B：样本期内只发行过2次 
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

replace bondnew_h=. if bondnew_h==0
gen is_missing = missing(bondnew_h)
bysort province city: egen total_missing = total(is_missing)
bysort province city: egen total_years = count(year)
drop if total_missing == total_years-2
drop is_missing total_missing total_years

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw6b_`var'
}

esttab modelw6b_* using "$out/appendix_table17_drop_sparse_issuance.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) append  ///
   indicate("控制变量 =$cov_city")  

//面板C：样本期内只发行过3次   
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

replace bondnew_h=. if bondnew_h==0
gen is_missing = missing(bondnew_h)
bysort province city: egen total_missing = total(is_missing)
bysort province city: egen total_years = count(year)
drop if total_missing == total_years-3
drop is_missing total_missing total_years

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw6c_`var'
}

esttab modelw6c_* using "$out/appendix_table17_drop_sparse_issuance.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) append  ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表18 剔除省会和单列市后省级城商行合并对地方政府债务的影响
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
drop if shenghui==1|danlie==1
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' D $cov_city ,absorb(city year) vce(cluster city)
    est store modelw7_`var'
}

esttab modelw7_* using "$out/appendix_table18_drop_capital_subprovincial.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
    ar2(%6.4f) scalar(N) replace  ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表19 加入资本扩充倍数作为交乘项的检验结果（正文）
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"   
replace capital_ratio=1 if capital_ratio==.

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' c.D#c.capital_ratio D capital_ratio $cov_city ,absorb(city year) vce(cluster city)
    est store model12a_`var'
}

esttab model12a_* using "$out/appendix_table19_capital_interaction_main.rtf",b(%6.4f) t(%6.4f)  noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace ///
   indicate("控制变量 =$cov_city")
   
******************************************************************************
* 附表20 加入资本扩充倍数作为交乘项的检验结果（脚注）
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"   
replace capital_ratio=1 if capital_ratio==.

reghdfe bankloan_h_z c.D#c.capital_ratio D capital_ratio $cov_city ,absorb(city year) vce(cluster city)
est store model13      

esttab model13 using "$out/appendix_table20_capital_bankloan_footnote.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace ///
   indicate("控制变量 =$cov_city")

******************************************************************************
* 附表21 加入财政压力后三重交乘项的检验结果（正文）
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
replace capital_ratio=1 if capital_ratio==.

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
    reghdfe `var' ///
        c.D#c.capital_ratio#c.fiscalgap_ratio_z /// 
        c.D#c.capital_ratio ///                      
        c.D#c.fiscalgap_ratio_z ///                 
        c.capital_ratio#c.fiscalgap_ratio_z ///      
        D capital_ratio fiscalgap_ratio_z ///       
       fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear, absorb(city year) vce(cluster city)     
    est store model13_`var'
}
esttab model13_* using "$out/appendix_table21_fiscal_triple_main.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace

******************************************************************************
* 附表22 改变财政压力变量后的稳健性检验
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018   
replace capital_ratio=1 if capital_ratio==.

gen fis=(f2/10000)/fiscal
gen fis_z=L.fis
   
foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
    reghdfe `var' ///
        c.D#c.capital_ratio#c.fis_z /// 
        c.D#c.capital_ratio ///                      
        c.D#c.fis_z ///                 
        c.capital_ratio#c.fis_z ///      
        D capital_ratio fis_z ///       
       GDPg_z lninvest_z lnpop_z workyear, absorb(city year) vce(cluster city)     
    est store model14_`var'
}
esttab model14_* using "$out/appendix_table22_fiscal_alternative.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace

******************************************************************************
* 附表23 加入地方金融竞争程度作为交乘项的检验结果（正文）
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' c.D#c.achhi_z D achhi_z $cov_city ,absorb(city year) vce(cluster city)
    est store model14_`var'
}

esttab model14_* using "$out/appendix_table23_financial_competition_main.rtf",b(%6.4f) t(%6.4f) noconstant nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace ///
  indicate("控制变量 =$cov_city")

******************************************************************************
* 附表24 更换为权重衡量的地方金融竞争程度指标的交乘项的检验结果
******************************************************************************
capture estimates clear
use "data_city_after.dta",clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l debtold_h_l bondold_h_l feibiaoold_h_l {
	reghdfe `var' c.D#c.qchhi_z D qchhi_z $cov_city ,absorb(city year) vce(cluster city)
    est store model15_`var'
}

esttab model15_* using "$out/appendix_table24_financial_competition_weighted.rtf",b(%6.4f) t(%6.4f) nogap compress  ///
   star(* 0.1 ** 0.05 *** 0.01)  ///
   ar2(%6.4f) scalar(N) replace
