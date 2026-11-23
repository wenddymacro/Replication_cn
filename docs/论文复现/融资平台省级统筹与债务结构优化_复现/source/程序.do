
cd  "路径"

global 平台x  Size Level  Roa Turn  Liquidity Quick Cashratio  Age
global 地区 Lngdp Structure Lnincome Lnoutcome



**# 表1基准回归
use 数据1.dta,replace

reghdfe  Str Integ  ,absorb( id year) cluster(id) 
outreg2 using 表1基准回归.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,No ,CityCV ,No ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ $平台x ,absorb( id year) cluster(id) 
outreg2 using 表1基准回归.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ $平台x) addtext(FirmCV ,Yes ,CityCV ,No  ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ $平台x $地区    ,absorb( id year) cluster(id)
outreg2 using 表1基准回归.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ $平台x $地区) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)



**# 表2 债务结构分解

use 数据1.dta,replace

reghdfe  ln非标准债务 Integ    $平台x $地区 ,absorb( id year) cluster(id)   
outreg2 using 表2债务结构分解.rtf,replace  bdec(4)  sdec(4) rdec(4) r2 ctitle(Non-stand ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  ln城投债余额 Integ    $平台x $地区  ,absorb( id year) cluster(id) 
outreg2 using 表2债务结构分解.rtf,append  bdec(4)  sdec(4) rdec(4) r2 ctitle(Standard ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  ln有息债务 Integ    $平台x $地区 ,absorb( id year) cluster(id)   
outreg2 using 表2债务结构分解.rtf,append  bdec(4)  sdec(4) rdec(4) r2 ctitle(Debt ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)


 
**# 表3 机制检验 
**# Penal A 

use 数据1.dta,replace

reghdfe 政府应收账款数量占比 Integ  $平台x  $地区   , absorb(id year ) cluster(id) 
outreg2 using 表3PenalA.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Receive_Num ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe 政府应收账款金额占比 Integ  $平台x  $地区   , absorb(id year ) cluster(id) 
outreg2 using 表3PenalA.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Receive_Amount ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)
 
reghdfe 城投业务占比 Integ  $平台x  $地区   , absorb(id year ) cluster(id) 
outreg2 using 表3PenalA.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Market_Ratio ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe 市场化业务1 Integ  $平台x  $地区   , absorb(id year ) cluster(id) 
outreg2 using 表3PenalA.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Market_Probability ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)




**# Penal B 
use 数据1.dta,replace

reghdfe  ln土地资产 Integ  $地区  $平台x  ,absorb( id year) cluster(id) 
outreg2 using 表3PenalB.rtf,replace  bdec(4) sdec(4)  rdec(4) r2 ctitle(Land_Asset ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  ln政府补助 Integ  $地区  $平台x   ,absorb( id year) cluster(id) 
outreg2 using 表3PenalB.rtf,append  bdec(4) sdec(4)  rdec(4) r2 ctitle(Gover_Subsidy ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)
 
reghdfe  平台评级 Integ  $地区  $平台x  ,absorb( id year) cluster(id) 
outreg2 using 表3PenalB.rtf,append  bdec(4)  sdec(4)  rdec(4) r2 ctitle(Credit_Rating ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

use 数据2,replace //债券层面数据
reghdfe CS Integ  $平台x  $地区   , absorb(id year ) cluster(id) 
outreg2 using 表3PenalB.rtf,append bdec(4)  sdec(4)  rdec(4) r2 ctitle(Bond_Spread ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)  


**# 表4和表5 异质性检验

**表4 政府干预程度  
use 数据1.dta,replace

reghdfe  Non_Stand Integ    $平台x $地区 if 政府干预==1,absorb( id year) cluster(id)  
outreg2 using 表4异质性检验A.rtf,replace   bdec(4) sdec(4) rdec(4) r2 ctitle(High ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 

reghdfe  Non_Stand Integ    $平台x $地区 if 政府干预==0,absorb( id year) cluster(id)  
outreg2 using 表4异质性检验A.rtf,append   bdec(4) sdec(4) rdec(4) r2 ctitle(Low ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 

//bdiff, group(政府干预) model(reghdfe  Non_Stand Integ    $平台x $地区 ,absorb(id year )  cluster(id) ) seed(123) reps(1000) detail 

reghdfe  Non_Stand Integ    $平台x $地区 if 市场化程度==1,absorb( id year) cluster(id)  
outreg2 using 表4异质性检验A.rtf,append   bdec(4) sdec(4) rdec(4) r2 ctitle(High ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 

reghdfe  Non_Stand Integ    $平台x $地区 if 市场化程度==0,absorb( id year) cluster(id)  
outreg2 using 表4异质性检验A.rtf,append   bdec(4) sdec(4) rdec(4) r2 ctitle(Low ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 

//bdiff, group(市场化程度) model(reghdfe  Non_Stand Integ    $平台x $地区 ,absorb(id year )  cluster(id) ) seed(123) reps(1000) detail 

		
** 表5 平台统筹特征

**地市与区县
use 数据1.dta,replace

gen CityInteg=(城投行政级别=="地市级" & Integ==1)
gen CountyInteg=(城投行政级别=="区县级" & Integ==1)

preserve
drop    if  城投行政级别=="区县级" & Integ==1
reghdfe  Bond CityInteg  $地区  $平台x  ,absorb( id year) cluster(id) 
outreg2 using 表5异质性检验B.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(City ) keep(CityInteg ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 
restore
	
preserve
drop    if  城投行政级别=="地市级" & Integ==1
reghdfe  Bond CountyInteg  $地区  $平台x  ,absorb( id year) cluster(id)	
outreg2 using 表5异质性检验B.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(County ) keep(CountyInteg ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 
restore
	
** 政府与国资

gen GovInteg=(股东性质=="政府" & Integ==1)
gen FirmInteg=(股东性质=="省属国企" & Integ==1)

preserve
drop    if  股东性质=="省属国企"
reghdfe  Bond GovInteg  $地区  $平台x  ,absorb( id year) cluster(id) 
outreg2 using 表5异质性检验B.rtf,append bdec(4) sdec(4) rdec(4) r2 ctitle(Gover ) keep(GovInteg ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 
restore

preserve
drop    if  股东性质=="政府"
reghdfe  Bond FirmInteg  $地区  $平台x  ,absorb( id year) cluster(id) 
outreg2 using 表5异质性检验B.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Firm ) keep(FirmInteg ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 
restore



**# 表6 拓展性分析
use 数据1.dta,replace
   
reghdfe  债券期限1年内 Integ  $地区  $平台x  ,absorb( id year) cluster(id) 
outreg2 using 表6拓展性分析.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(1 ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes)   
  
  
reghdfe  债券期限1_3年占比 Integ  $地区  $平台x  ,absorb( id year) cluster(id)  
outreg2 using 表6拓展性分析.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(1-3 ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 

reghdfe  债券期限3年以上占比 Integ  $地区  $平台x  ,absorb( id year) cluster(id)   
outreg2 using 表6拓展性分析.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(3 ) keep(Integ ) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes) 

  
**# 附表A3 描述性统计 
 
use 数据1.dta,replace
logout,dec(4) save(附表A3)word replace:tabstat Str Integ $平台x $地区 ,s(N mean p50 sd min max ) f(%12.4f) c(s) 



**# 附图A5 事前趋势检验与动态效应
use 数据1.dta,replace

gen policy = year - 上划year
tab policy
replace policy = -6 if policy < -6
replace policy = 3 if policy > 3  
forvalues i = 6(-1)1{
  gen pre_`i' = (policy == -`i' & 上划year<2025) 
}

forvalues j = 0(1)3{
  gen  post_`j' = (policy == `j' & 上划year<2025)
}

replace pre_1=0

reghdfe Str  pre_*  post_* $平台x $地区   , absorb( id year) cluster(id) 

forvalues i = 2 /6{
  gen b_`i' =_b[pre_`i']
}
gen avg_coef=(b_2+b_3+b_4+b_5+b_6)/5
su avg_coef
return list

coefplot,baselevels omitted keep(pre*  post*) vertical recast(connect) lcol(black) order(pre*  post*) ytitle("政策效应") xtitle("政策时点") yline(0,lp(solid) lc(black)) xline(6, lp(dash) lc(gs10)) transform(pre_5=@-r(mean) pre_4=@-r(mean) pre_3=@-r(mean) pre_2*=@-r(mean) pre_1=@  post_0=@-r(mean) post_1=@-r(mean) post_2=@-r(mean) post_3=@-r(mean) ) ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0)  graphregion(color(white))  plotregion(lcolor(black))  //附图A5

graph export "附图A5.pdf", as(pdf) name("Graph") replace



**# 稳健性检验

**# (1)附表A4 排除非随机选择因素
use 数据1.dta,replace
sort year
egen t = group(year)
sort id year
foreach v of varlist $平台x $地区{
   bys id: replace `v' = `v'[1]
}
foreach v in  $地区{
    gen `v't=c.`v'*t   
	gen `v't2=c.`v'*(t^2)
	gen `v't3=c.`v'*(t^3)
}

foreach v in  $平台x{
    gen `v't=c.`v'*t   
	gen `v't2=c.`v'*(t^2)
	gen `v't3=c.`v'*(t^3)
}

global 地区t Lngdpt Structuret Lnincomet Lnoutcomet
global 平台xt Aget Sizet Levelt  Roat Turnt  Liquidityt Quickt Cashratiot

global 地区t2 Lngdpt2 Structuret2 Lnincomet2 Lnoutcomet2
global 平台xt2 Aget2 Sizet2 Levelt2  Roat2 Turnt2  Liquidityt2 Quickt2 Cashratiot2

global 地区t3 Lngdpt3 Structuret3 Lnincomet3 Lnoutcomet3
global 平台xt3 Aget3 Sizet3 Levelt3  Roat3 Turnt3  Liquidityt3 Quickt3 Cashratiot3


reghdfe  Str Integ    $地区t  $平台xt ,absorb( id year) cluster(id) 
outreg2 using 附表A4.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ   $地区t  $平台xt $地区t2  $平台xt2  ,absorb( id year) cluster(id) 
outreg2 using 附表A4.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ   $地区t  $平台xt $地区t2  $平台xt2 $地区t3  $平台xt3 ,absorb( id year) cluster(id) 
outreg2 using 附表A4.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)



**# (2)附表A5 区分银行贷款与非标债务
use 数据1.dta,replace

reghdfe  银行贷款占比 Integ  $平台x $地区   ,absorb( id year) cluster(id) 
outreg2 using 附表A5.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Bankloan ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  非标债务占比 Integ  $平台x $地区  ,absorb( id year) cluster(id) 
outreg2 using 附表A5.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Nonstand  ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)


**# (3)附图A6 处理组样本较少问题
use 数据1.dta,replace

gen 处理组=(上划year<2025)
xtset id year
keep if 处理组==1
keep id year   Str Integ $平台x $地区
save "data_处理组.dta",replace


use 数据1.dta,replace
gen 对照组=(上划year>2025)
xtset id year
keep id year  Str Integ $平台x $地区
save "data_对照组.dta",replace

use 数据1.dta,replace
xtset id year
gen 对照组=(上划year>2025)
keep if 对照组==1
keep id 对照组
duplicates drop id,force
save 对照组list.dta,replace

*********************
set  seed 0000

mat b  = J(1000,1,0)    
mat se = J(1000,1,0)    
mat p  = J(1000,1,0)    

forvalues i=1/1000{
  use 对照组list.dta, clear
  sample 407,count
  keep id
  save match_id.dta, replace        
 
  merge 1:m id using data_对照组.dta,gen(m)
  keep if m==3
  drop m
  append using data_处理组.dta
  
  xtset id year
 
  qui:reghdfe Str Integ $平台x $地区  ,absorb( id year) cluster(id)
  
  mat  b[`i',1] = _b[Integ]
  mat se[`i',1] = _se[Integ]

  mat p[`i',1] = 2*ttail(e(df_r), abs(_b[Integ]/_se[Integ]))
}
 
svmat b, names(coef)
svmat se, names(se)
svmat p, names(pvalue)

drop if pvalue1 == .
label var pvalue1 p值
label var coef1 估计系数
keep coef1 se1 pvalue1 

twoway kdensity coef1,yaxis(1) ///
 ylabel(0(5)50,nogrid angle(0) axis(1)) ytitle(kdensity, axis(1)) ///
 ytitle(kdensity, axis(1)) ///
 xline(-0.0423, lwidth(vthin) lp(shortdash) lc(red)) xlabel(,nogrid) xtitle("Coefficients") ///
 title("Placebo Test")  ///
 plotregion(style(none)) ///
 graphregion(color(white)) //附图A6

graph export "附图A6.pdf", as(pdf) name("Graph") replace


**# (4)附图A7 异质性处理效应-Sun and Abraham(2020)

use 数据1.dta,replace
 
gen aaa=year if Integ==1
bys id:egen action=min(aaa)
gen nevertreat=(action==.)
gen pd=year-action
tab pd
replace pd = -6 if pd < -6
replace pd = 3 if pd > 3 & pd<2000
forvalues i = 6(-1)1{
	gen pre_`i'=(pd==-`i' )
}
forvalues j = 0(1)3{
	gen post_`j'=(pd==`j')
}
eventstudyinteract Str pre_6 pre_5 pre_4 pre_3 pre_2 post_0 post_1 post_2 post_3   ,cohort(action) control_cohort(never) covariates($平台x $地区 ) absorb(i.id i.year) vce(robust)
matrix b = e(b_iw)
matrix V = e(V_iw)
ereturn post b V

forvalues i = 2 /6{
  gen b_`i' =_b[pre_`i']
}
gen avg_coef=(b_2+b_3+b_4+b_5+b_6)/5
su avg_coef
return list

coefplot,baselevels omitted keep(pre*  post*) vertical recast(connect) color(black) order(pre*  post*) ytitle("Coefficients") xtitle("Year") title("Sun and Abraham(2020)")  yline(0,lp(solid) lc(black)) xline(6, lp(dash) lc(gs10))  ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0)  graphregion(color(white))  plotregion(lcolor(black)) transform (*=@-r(mean)) //附图A7

graph export "附图A7.pdf", as(pdf) name("Graph") replace



**# (5)附表A6 更换不同城投口径

use 数据1.dta,replace

reghdfe  Str Integ  $平台x $地区 if  万德==1,absorb( id year) cluster(id) 
outreg2 using 附表A6.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Wind ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ  $平台x $地区 if  银保监会==1,absorb( id year) cluster(id) 
outreg2 using 附表A6.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(2 ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ  $平台x $地区 if  企业预警通==1,absorb( id year) cluster(id) 
outreg2 using 附表A6.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(3 ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ  $平台x $地区 if  华泰固收==1,absorb( id year) cluster(id) 
outreg2 using 附表A6.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(4 ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

reghdfe  Str Integ  $平台x $地区 if  华西固收==1,absorb( id year) cluster(id) 
outreg2 using 附表A6.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(5 ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)



**# (6)附表A7 排除其他政策干扰


use 数据1.dta,replace

reghdfe  Str Integ Exit   $平台x $地区   ,absorb( id year) cluster(id) 
outreg2 using 附表A7.rtf,replace   bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ Exit) addtext(CV ,Yes ,Year Fe, Yes,Firm Fe,Yes, Province#Year Fe ,No , City#Year Fe,No ,Ind#Year Fe ,No )

reghdfe  Str Integ  $平台x $地区  ,absorb( id year#Pro) cluster(id)  
outreg2 using 附表A7.rtf,append   bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(CV ,Yes ,Firm Fe,Yes ,Year Fe, No, Province#Year Fe ,Yes , City#Year Fe,No ,Ind#Year Fe ,No)

reghdfe  Str Integ  $平台x $地区  ,absorb( id year#City) cluster(id)  
outreg2 using 附表A7.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(CV ,Yes ,Firm Fe,Yes , Year Fe, No,Province#Year Fe ,No , City#Year Fe,Yes ,Ind#Year Fe ,No)

reghdfe  Str Integ  $平台x $地区 ,absorb( id year#Ind)  cluster(id)
outreg2 using 附表A7.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(CV ,Yes ,Firm Fe,Yes ,Year Fe, No, Province#Year Fe ,No , City#Year Fe,No ,Ind#Year Fe ,Yes )

reghdfe  Str Integ  $平台x $地区  ,absorb(id year#City year#Pro  year#Ind) cluster(id)  
outreg2 using 附表A7.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(CV ,Yes ,Firm Fe,Yes ,Year Fe, No, Province#Year Fe ,Yes , City#Year Fe,Yes ,Ind#Year Fe ,Yes)



**# (7)附表A8 更换被解释变量的测度方式

use 数据1.dta,replace
reghdfe  Str1 Integ $平台x ,absorb( id year) cluster(id)    
outreg2 using 附表A8.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Str1 ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,No ,Year Fe, No,Firm Fe,No )

reghdfe  Str1 Integ $平台x  $地区 ,absorb( id year) cluster(id) 
outreg2 using 附表A8.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str1 ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, No,Firm Fe,No)


**# (8)附图A8和A9 遗漏变量检验

use 数据1.dta,replace
   
sensemakr Str Integ  $地区  $平台x  i.year i.id , treat(Integ) benchmark(Size) contourplot  clim(0 0.15) 
graph save "s_contourplot" "附图A8系数.gph",replace
 
sensemakr Str Integ  $地区  $平台x  i.year i.id , treat(Integ) benchmark(Size) tcontourplot clim(0 0.08)
graph save "s_tcontourplot" "附图A8t值.gph",replace

sensemakr Str Integ  $地区  $平台x  i.year i.id , treat(Integ) benchmark(Lngdp) contourplot  clim(0 0.08) 
graph save "s_contourplot" "附图A9系数.gph",replace

sensemakr Str Integ  $地区  $平台x  i.year i.id , treat(Integ) benchmark(Lngdp) tcontourplot  clim(0 0.08) 
graph save "s_tcontourplot" "附图A9t值.gph",replace



**# (9)附图A10 安慰剂检验

use 数据1.dta,replace
gen aaa=year if Integ==1
bys id:egen action=min(aaa)
drop aaa
bys id:egen treat=max(Integ)
replace treat=1 if action<3000
save 安慰剂检验.dta,replace

set seed 0000

**正式开始***
mat b = J(1000,1,0)
mat se = J(1000,1,0) 
mat p = J(1000,1,0) 
forvalues i=1/1000{
 use 安慰剂检验.dta,replace
 xtset id year
 gen aaa=1
 bys id:gen bbb=sum(aaa)
 sample 1 if bbb!=1, count by(id)
 drop if bbb==1
 sample 407, count
 keep id year
 rename year policy_year
 save 安慰剂抽取数据, replace
 merge 1:m id using 安慰剂检验.dta
 xtset id year
 gen treat_aw = (_merge == 3)
 gen period = (year >= policy_year)
 gen did = treat_aw*period
 qui reghdfe  Str did  $地区  $平台x  ,absorb( id year) cluster(id)
 mat b[`i',1] = _b[did]
 mat se[`i',1] = _se[did]
 mat p[`i',1] = 2*ttail(e(df_r), abs(_b[did]/_se[did]))
}
svmat b, names(coef)
svmat se, names(se)
svmat p, names(pvalue)
drop if pvalue1 == .k
label var pvalue1 p值
label var coef1 估计系数
keep coef1 se1 pvalue1 


twoway (kdensity coef1, yaxis(2)) (scatter pvalue1 coef1, msymbol(smcircle_hollow) mcolor(grey) yaxis(1)), ///
xlabel(-0.05(0.02)0.05,nogrid format(%4.2f))  ///
ytitle("p" "值",orientation(horizontal) axis(1)) ///
ytitle("核" "密" "度",orientation(horizontal) axis(2)) ///
ylabel(0(0.2)1,nogrid axis(1) format(%7.1f) angle(0)) ///
ylabel(,axis(2) angle(0)) ///
xline(-.0422987, lwidth(vthin) lp(shortdash)) xtitle("估计系数") ///
yline(0.1,lwidth(vthin) lp(dash)) ytitle("p值") ///
legend(label(1 "估计系数核密度") label( 2 "p值"))  ///
plotregion(style(none)) ///
graphregion(color(white))  ///
saving(附图A9.png,replace)  //附图A9

graph export "附图A10.pdf", as(pdf) name("Graph") replace



**# (10)附表A9 PSM-DID
use 数据1.dta,replace

graph set window fontface   "times new roman"
graph set window fontfacesans "宋体"
set scheme s1color

** 1.1 最近邻匹配
set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1

gen treat=(上划year<2024)
psmatch2 treat $平台x  $地区 , outcome(Str) logit neighbor(1) ties common ate  

reghdfe Str Integ   $平台x  $地区 if _weight!=. &_support==1  ,a(year id )  cluster(id)
outreg2 using 附表A9.rtf,replace  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)


** 卡尺匹配
use 数据1.dta,replace
set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1

gen treat=(上划year<2024)
psmatch2 treat $平台x  $地区 , outcome(Str) radius cal(0.01) ate ties logit common 

reghdfe Str Integ   $平台x  $地区  if  _weight!=. &_support==1,a(year id )  cluster(id) 
outreg2 using 附表A9.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)

** 核匹配
use 数据1.dta,replace
set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1

gen treat=(上划year<2024)
psmatch2 treat $平台x  $地区 , outcome(Str)  kernel    logit common

reghdfe Str Integ   $平台x  $地区  if _weight!=. &_support==1,a(year id )  cluster(id) 
outreg2 using 附表A9.rtf,append  bdec(4) sdec(4) rdec(4) r2 ctitle(Str ) keep(Integ ) addtext(FirmCV ,Yes ,CityCV ,Yes ,Year Fe, Yes,Firm Fe,Yes)


 
  