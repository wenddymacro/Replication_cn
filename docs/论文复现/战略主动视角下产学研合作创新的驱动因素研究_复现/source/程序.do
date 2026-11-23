
cd "..."
//************table 1 基准回归*****************
use 数据, replace
reghdfe rinsitinum  tshock3 , absorb(i.year  i.province#i.ind) cluster(stkcd)
est store r1
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind) cluster(stkcd)
est store r2
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r3
esttab r1 r2 r3 , se b(%12.4f) keep(tshock3) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace 
esttab r1 r2 r3 using "table 1.csv", se b(%12.4f) keep(tshock3) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace 

//************table 2 产学研合作创新专利分解*****************	
use 数据, replace 
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r4

reghdfe runi  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r5

reghdfe rres  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r6
 
reghdfe rinsitinum_inv  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r7

reghdfe rinsitinum_use  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r8 

reghdfe rinsitinum_design  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r9
esttab  r4 r5 r6 r7 r8 r9, se b(%12.4f) nogap keep(tshock3) ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 
esttab  r4 r5 r6 r7 r8 r9  using "table 2.csv", se b(%12.4f) nogap keep(tshock3) ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 

//************table 3 机制检验：实体清单冲击与供应链风险感知***************** 
use 数据, replace
foreach yvar in supply_mane_number other_number totalnumber supply_mane_ratio other_ratio  totalratio {
reghdfe `yvar' tshock3  c.Size#c.year c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)
est store `yvar'
}
esttab  supply_mane_number other_number totalnumber supply_mane_ratio other_ratio  totalratio, se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace  
esttab  supply_mane_number other_number totalnumber supply_mane_ratio other_ratio  totalratio   using "table 3.csv", se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace  
	 
	 
//************table 4 机制检验：实体清单冲击与政府支持*****************		 
use 数据, replace
reghdfe amount_gov  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r1	 
reghdfe tax tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r2	 
reghdfe iddum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r3 	
esttab r1 r2 r3, se b(%12.4f) keep(tshock3) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
esttab r1 r2 r3  using "table 4.csv", se b(%12.4f) keep(tshock3) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 

//************table 5 机制检验：排除竞争性假说*****************		 
use 数据, replace
foreach yvar in  FixedAssetGrowth TotalProfitGrowth OperatingProfitGrowth RevenueGrowth NetProfit TotalProfit {
       reghdfe `yvar'  tshock3  c.Size#c.year  c.BM#c.year ROA  TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
eststo `yvar'
	}	 
esttab FixedAssetGrowth TotalProfitGrowth OperatingProfitGrowth RevenueGrowth NetProfit TotalProfit , se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	
	
esttab  FixedAssetGrowth TotalProfitGrowth OperatingProfitGrowth RevenueGrowth NetProfit TotalProfit using "table 5.csv", keep(tshock3) se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	  
//************图1 实体清单事件分析法估计结果*****************		 
use 数据, replace
gen u=0
replace u =1 if list==1
gen distance = year - listyear if u==1
tab distance ,missing
replace distance = 4 if  distance > 4
replace distance = -4 if  distance <-4
eventdd rinsitinum   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, timevar(distance) ci(rcap) cluster(stkcd) graph_op(ytitle("IUR") xlabel(-4(1)4)) method(hdfe, absorb(i.year i.stkcd i.province#i.ind)) level(90)
graph save "图1.gph", replace
 
**# 附录 #1
//************table 3.1 企业产学研相关指标的平衡性检验*****************	
use  数据_balance, replace
reg Size list, cl(stkcd)
eststo m1
reg Lev list, cl(stkcd)
eststo m2
reg ROA list, cl(stkcd)
eststo m3
reg ROE list, cl(stkcd)
eststo m4
reg BM list, cl(stkcd)
eststo m5
reg TobinQ list, cl(stkcd)
eststo m6
reg PB list, cl(stkcd) //存活占比
eststo m7
reg NetProfit list, cl(stkcd) //存活占比
eststo m8
reg Cashflow list, cl(stkcd) //管理费用率
eststo m9
esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 using "table 3.1.csv",se b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace		 
//************table 3.2 企业产学研相关指标的平衡性检验*****************	 
use  数据_balance, replace
reg insitinum list, cl(stkcd)
eststo m10
reg uni list, cl(stkcd)
eststo m11
reg res list, cl(stkcd)
eststo m12
esttab m10 m11 m12 using "table 3.2.csv",se b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	
 
	 
//************table 3.3 描述性统计*****************	 
use 数据, replace	 
logout , save (table 3.3) word replace: tabstat rinsitinum  tshock3 Size BM ROA TobinQ Growth AssetGrowth, s(N mean sd min max) f(%12.4f) c(s)	 

//************table 4.1 产学研合作创新对象的分解：中国科学院的作用*****************	 
use 数据, replace	
reghdfe rinsitinum_zky  tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r1
reghdfe runi_zky  tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r2
reghdfe rres_zky  tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r3
reghdfe rinsitinum_zky1  tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r4
reghdfe runi_zky1  tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r5
reghdfe rres_zky1  tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r6
esttab r1 r2 r3 r4 r5 r6, se keep(tshock3) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 	 
esttab r1 r2 r3 r4 r5 r6 using "table 4.1.csv", se keep(tshock3) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace

//************table 5.1 供应链风险感知与产学研合作创新*****************	 	 
use 数据, replace
foreach yvar in supply_mane_number  supply_mane_ratio  totalnumber totalratio {
reghdfe rinsitinum `yvar' c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)
est store `yvar'
}
esttab supply_mane_number  supply_mane_ratio  totalnumber totalratio , se  b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace  	  
esttab supply_mane_number  supply_mane_ratio  totalnumber totalratio  using "table 5.1.csv", se keep(supply_mane_number  supply_mane_ratio  totalnumber totalratio)  b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace  	  	 

//************table 5.2 供应链风险客观指标*****************		 
use 数据, replace	 

reghdfe idd1 tshock3    c.Size#c.year c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r1		 
reghdfe iddshare tshock3    c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r2
esttab r1 r2, se  b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
  	  	 
esttab r1 r2  using "table 5.2.csv", se  b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace  	 
	 
//************table 6.1 稳健性检验*****************	 
use 数据, replace
gen ti = (year>= 2017)&!missing(2017)
gen ti1 = (year>= 2016)&!missing(2016)
gen tshock2017=list*ti 
gen tshock2016=list*ti1
reghdfe rinsitinum tshock3 tshock2017 tshock2016   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r1
	 	
reghdfe rinsitinum tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year  i.stkcd i.city#i.ind) cluster(stkcd)
eststo r2

reghdfe rinsitinum tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.province#i.year  i.stkcd i.ind#i.year) cluster(stkcd)
eststo r3
	 
reghdfe rinsitinum tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth , absorb(i.year  i.stkcd i.province#i.ind) cluster(ind)
eststo r4

ppmlhdfe insitinum tshock3   c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth , absorb(i.year i.province#i.ind  i.stkcd) cluster(stkcd)
eststo r5

esttab r1 r2 r3 r4 r5 , se keep(tshock*) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 
esttab r1 r2 r3 r4 r5 using "table 6.1.csv", se keep(tshock*) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	  
//************table 6.2 PSM-DID回归*****************	 
use 数据, replace
reghdfe rinsitinum tshock3    if _weight!=., absorb(i.year i.province#i.ind) cluster(stkcd)
eststo r1
reghdfe rinsitinum tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth if _weight!=., absorb(i.year i.province#i.ind) cluster(stkcd)
eststo r2
reghdfe rinsitinum tshock3   c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth if _weight!=., absorb(i.year i.stkcd i.province#i.ind) cluster(stkcd)
eststo r3
esttab r1 r2 r3 , se keep(tshock*) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
esttab r1 r2 r3 using "table 6.2.csv", se keep(tshock*) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
//************table 6.3 PSM-DID回归产学研分解结果*****************	
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if _weight!=., absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r4
reghdfe runi  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if _weight!=., absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r5
reghdfe rres  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if _weight!=., absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r6
reghdfe rinsitinum_inv  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if _weight!=., absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r7
reghdfe rinsitinum_use  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if _weight!=., absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r8 
reghdfe rinsitinum_design  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if _weight!=., absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r9
esttab r4 r5 r6 r7 r8 r9, se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 
esttab r4 r5 r6 r7 r8 r9  using "table 6.3.csv", se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 

//************table 6.4 排除新冠疫情的影响*****************	 	 
use 数据, replace
drop if year==2020
reghdfe rinsitinum tshock3    c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r1

use 数据, replace
drop if year==2021
reghdfe rinsitinum tshock3    c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r2

use 数据, replace
drop if year==2022
reghdfe rinsitinum tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r3
	 
use 数据, replace
drop if IndustryName=="医药制造业"
reghdfe rinsitinum tshock3 c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r4

esttab r1 r2 r3 r4,se keep(tshock3) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace 	 
esttab r1 r2 r3 r4 using "table 6.4.csv",se keep(tshock3) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace 	 
	 
//************table 6.5 改变因变量度量方式*****************	 	 
use 数据, replace	 
reghdfe lrinsitinumsha tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r1
reghdfe lrinsitinumsha_inv tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r2
reghdfe lrinsitinumsha_use tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r3 
reghdfe lrinsitinumsha_design tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth, absorb(i.year  i.stkcd i.province#i.ind) cluster(stkcd)
eststo r4
esttab r1 r2 r3 r4 ,se keep(tshock3) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace 	 
esttab r1 r2 r3 r4 using "table 6.5.csv",se keep(tshock3) b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace 	 
	 
//************table 6.6 考虑子公司*****************	 
use 数据, replace
reghdfe rinsitinum_sub  tshock3 , absorb(i.year  i.province#i.ind) cluster(stkcd)
est store r1
reghdfe rinsitinum_sub  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind) cluster(stkcd)
est store r2
reghdfe rinsitinum_sub  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r3
esttab r1 r2 r3, se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	
	 
esttab r1 r2 r3 using "table 6.6.csv", se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
//************table 6.7 工具变量方法*****************	 	 
use 数据, replace	 
gen post = year >= 2018
gen iv_strength = listind_cum * post
summ  listind_cum 
reghdfe tshock3  iv_strength c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r1
ivreghdfe  rinsitinum  ( tshock3  =   iv_strength) c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd) savefirst
est store r2
reghdfe  rinsitinum  iv_strength c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd) 
est store r3
esttab r1 r2 r3 , se b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
esttab r1 r2 r3 using "table 6.7.csv", se b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	  
//************table 6.8 行业层面：实体清单对产学研合作创新影响的再检验*****************	 
use 数据_ind, replace
reghdfe rinsitinum list c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year i.sicproductcode) cluster(sicproductcode)
eststo r1

use 数据_province_ind, replace
reghdfe rinsitinum list c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth , absorb(i.year i.sicproductcode#i.province) cluster(sicproductcode)
eststo r2

esttab r1  r2 , se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace

esttab r1  r2 using "table 6.8.csv", se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 
//************图 6.1 异质性处理效应*****************	
use 数据, replace
tab stkcd,gen(stkcd)
tab year,gen(year)
gen yearSize = Size*year
gen yearBM = BM*year
tabulate province, generate(province_)
tabulate ind, generate(ind_)
local num_province = _N
local num_ind = _N
forvalues p = 1/31 {
    forvalues i = 1/75 {
        generate inter_`p'_`i' = province_`p' * ind_`i'
    }
}
gen u=0
replace u =1 if list==1
gen distance = year - listyear if u==1
tab distance ,missing
replace distance = 3 if  distance > 3
replace distance = -3 if  distance <-3
forvalues i=1/3{
     gen d_`i'  = 0 
	 replace d_`i'  = 1 if list== 1 & distance== -`i'
}

forvalues i=1/3 { 
     gen d`i'  = 0 
     replace d`i'  = 1 if list== 1 & distance== `i'
 }
gen d0  = 0
replace d0 = 1 if  list== 1 & distance== 0
drop d_1
gen never_list = (listyear == .)
*Sun and Abraham 2021
eventstudyinteract rinsitinum d_3 d_2 d0 d1 d2 d3 ,control_cohort(never_list) cohort(listyear) covariates( yearSize yearBM  ROA TobinQ Growth AssetGrowth i.year) absorb(i.stkcd i.province#i.ind) vce(cluster stkcd) 
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average effect") xlabel(-3(1)3) ///
    title("eventstudyinteract")) stub_lag(d#) stub_lead(d_#) together	 
	 
//************table 6.9 异质性处理效应*****************
*net install ddtiming, from(https://raw.githubusercontent.com/tgoldring/ddtiming/master)		 
use 数据, replace
xtset stkcd year
bysort stkcd: gen tt=_N
keep if tt==10
ddtiming  rinsitinum tshock3, i(stkcd) t(year)

	 

//************table 6.10 不同生产率企业的异质性作用*****************		 
use 数据, replace
foreach yvar in tfp_ols tfp_fix lntfp{
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if  `yvar'==0, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)	
est store l`yvar'r
reghdfe   rinsitinum  tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth  if  `yvar'==1, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)
est store h`yvar'r
}

esttab ltfp_olsr htfp_olsr ltfp_fixr htfp_fixr llntfpr hlntfpr,se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace
	 
esttab ltfp_olsr htfp_olsr ltfp_fixr htfp_fixr llntfpr hlntfpr using "table 6.10.csv",se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace


	
//************table 6.11不同供应商集中度企业的异质性*****************		
use 数据, replace
foreach yvar in tTPA tTPTTR tPCHHI{
eststo clear
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA  TobinQ Growth AssetGrowth if  `yvar'==0, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)
est store l`yvar'
reghdfe   rinsitinum tshock3 c.Size#c.year  c.BM#c.year ROA  TobinQ Growth AssetGrowth if  `yvar'==1, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)
est store h`yvar'
}
esttab  ltTPA htTPA  ltTPTTR htTPTTR  ltPCHHI  htPCHHI, se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	
esttab  ltTPA htTPA  ltTPTTR htTPTTR  ltPCHHI  htPCHHI  using "table 6.11.csv", se keep(tshock3) b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	
	
//************table 6.12不同地区－行业层面风险敞口企业的异质性*****************
use 数据, replace
foreach yvar in  risk_s risk_d{
reghdfe rinsitinum  tshock3  c.Size#c.year  c.BM#c.year  ROA TobinQ Growth AssetGrowth  if  `yvar'==0, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)	
est store l`yvar'
reghdfe   rinsitinum  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth  if  `yvar'==1, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)
est store h`yvar'
}
esttab  lrisk_s  hrisk_s lrisk_d hrisk_d , se b(%20.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace

esttab  lrisk_s  hrisk_s lrisk_d hrisk_d  using "table 6.12.csv", se b(%20.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace

	
	 
//************table 6.13不同技术和所有权企业的异质性*****************	 
use 数据, replace
foreach yvar in HighTech_2 SOE {
eststo clear
reghdfe rinsitinum tshock3  c.Size#c.year c.BM#c.year  ROA TobinQ Growth AssetGrowth  if  `yvar'==0, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)	
est store l`yvar'r
reghdfe   rinsitinum  tshock3  c.Size#c.year c.BM#c.year ROA TobinQ Growth AssetGrowth  if  `yvar'==1, absorb(i.province#i.ind i.year i.stkcd) cluster(stkcd)	
est store h`yvar'r
}
esttab lHighTech_2r hHighTech_2r  lSOEr hSOEr , se  b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 

esttab lHighTech_2r hHighTech_2r  lSOEr hSOEr using "table 6.13.csv", se  b(%12.4f) nogap ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
	 
//************table 6.14 专利质量***************** 
use 数据, replace
reghdfe breadth tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r1

reghdfe inventshare  tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r2

reghdfe  sumcitation tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r3

reghdfe  sumcitation_no tshock3  c.Size#c.year  c.BM#c.year ROA TobinQ Growth AssetGrowth, absorb(i.year i.province#i.ind i.stkcd) cluster(stkcd)
est store r4

esttab r1 r2 r3 r4 , se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
esttab r1 r2 r3 r4 using "table 6.14.csv", se b(%12.4f) nogap  ///
	 s(N r2_a) star(* 0.1 ** 0.05 *** 0.01) replace	 
	 
	 
	 

	 
	 