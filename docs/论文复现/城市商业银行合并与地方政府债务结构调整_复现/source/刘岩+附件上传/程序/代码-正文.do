clear all
set more off
global root "xxxxx" //真实路径
cd "$root"

capture mkdir "main_outputs"
global out "main_outputs"

******************************************************************************
* 表1 主要变量描述性统计
******************************************************************************
capture estimates clear
clear
use "data_city_after.dta", clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

cd "$out"
logout, save(main_table01_descriptive_statistics) word replace: ///
    tabstat D debtnew_h_l debtold_h_l bondnew_h_l bondold_h_l ///
    feibiaonew_h_l feibiaoold_h_l bankloan_h_z fiscalgap_ratio ///
    fiscal_GDP GDPg lninvest lnpop workyear, ///
    stat(N mean sd min max) c(s) f(%12.4f)
cd "$root"

******************************************************************************
* 表2 省级城商行合并对地方政府非信贷类城投债务的影响
******************************************************************************
capture estimates clear
clear
use "data_city_after.dta", clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l {
    reghdfe `var' D, absorb(city year) vce(cluster city)
    est store model1_`var'_a
}

foreach var in debtnew_h_l bondnew_h_l feibiaonew_h_l {
    reghdfe `var' D $cov_city, absorb(city year) vce(cluster city)
    est store model1_`var'_b
}

esttab model1_* using "$out/main_table02.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) replace ///
    indicate("控制变量 =$cov_city")

foreach var in debtold_h_l bondold_h_l feibiaoold_h_l {
    reghdfe `var' D, absorb(city year) vce(cluster city)
    est store model2_`var'_a
}

foreach var in debtold_h_l bondold_h_l feibiaoold_h_l {
    reghdfe `var' D $cov_city, absorb(city year) vce(cluster city)
    est store model2_`var'_b
}

esttab model2_* using "$out/main_table02.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) append ///
    indicate("控制变量 =$cov_city")

******************************************************************************
* 表3 省级城商行合并对不同行政层级地方政府城投债务的影响
******************************************************************************
capture estimates clear
clear
use "data_city_after.dta", clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

* 面板A：银行贷款渠道
foreach var in bankloan_c_z bankloan_d_z {
    reghdfe `var' D $cov_city, absorb(city year) vce(cluster city)
    est store model5_`var'
}

use "data_province_after.dta", clear
rename event D
xtset code year

reghdfe bankloan_p_z D GDPg fiscal_GDP sec lnperIndustry ///
    lnperFinance fiscal_ratio weight_npl, absorb(code year) vce(cluster code)
est store model5_prov

esttab model5_* using "$out/main_table03.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) replace

* 面板B和面板C：非信贷类城投债务增量与存量
use "data_city_after.dta", clear
drop if province==31|province==11|province==12|province==50
drop if year<2003|year>2018

global cov_city "fiscalgap_ratio_z fiscal_GDP_z GDPg_z lninvest_z lnpop_z workyear"

foreach var in debtnew_c_l debtnew_d_l {
    reghdfe `var' D $cov_city, absorb(city year) vce(cluster city)
    est store model6_`var'_a
}

foreach var in debtold_c_l debtold_d_l {
    reghdfe `var' D $cov_city, absorb(city year) vce(cluster city)
    est store model7_`var'_a
}

use "data_province_after.dta", clear
rename event D
xtset code year

reghdfe debtnew_p_l D GDPg fiscal_GDP sec lnperIndustry ///
    lnperFinance fiscal_ratio weight_npl, absorb(code year) vce(cluster code)
est store model6_b

reghdfe debtold_p_l D GDPg fiscal_GDP sec lnperIndustry ///
    lnperFinance fiscal_ratio weight_npl, absorb(code year) vce(cluster code)
est store model7_b

esttab model6_* using "$out/main_table03.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) append

esttab model7_* using "$out/main_table03.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) append

******************************************************************************
* 表4 省级城商行合并对不同层级政府债券融资成本的影响
******************************************************************************
capture estimates clear
clear
use "data_bond.dta", clear

global cov_bond duration amount group1 group3
global cov_id lnasset lev group2 ROETTM oldbond profit longdebt
global cov_city fiscalgap_ratio fiscal_GDP GDPg

reghdfe bondrate D $cov_bond $cov_id $cov_city, absorb(city year) vce(cluster city)
est store bondrate_1

reghdfe bondrate D $cov_bond $cov_id $cov_city ///
    if 城投行政等级=="地市"|城投行政等级=="地市(开发区)", ///
    absorb(city year) vce(cluster city)
est store bondrate_2

reghdfe bondrate D $cov_bond $cov_id $cov_city ///
    if 城投行政等级=="区县"|城投行政等级=="区县(开发区)", ///
    absorb(city year) vce(cluster city)
est store bondrate_3

reghdfe bondrate D $cov_bond $cov_id $cov_city ///
    if 城投行政等级=="省"|城投行政等级=="省(开发区)", ///
    absorb(city year) vce(cluster city)
est store bondrate_4

esttab bondrate_* using "$out/main_table04.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) replace ///
    indicate("债券控制变量 =$cov_bond" "企业控制变量 =$cov_id" "城市控制变量 =$cov_city")

******************************************************************************
* 表5 城商行合并在地方政府的债务溢出效应中的作用
******************************************************************************
capture estimates clear
clear
use "data_firm_after.dta", clear

drop if year<2003

global cov_city "fiscalgap_ratio_z GDPg_z lninvest_z lnpop_z"

foreach var in debt_h_new {
    egen `var'_m = mean(`var')
    egen `var'_sd = sd(`var')
    gen `var'_zs = (`var' - `var'_m) / `var'_sd
}

//面板A
keep city year debt_h_new_zs D ///
    fiscalgap_ratio_z GDPg_z lninvest_z lnpop_z

duplicates drop city year, force

reghdfe debt_h_new_zs D $cov_city, ///
    absorb(city year) vce(cluster city)
est store z_1
esttab z_* using "$out/main_table05.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) replace ///
	 indicate("城市控制变量 =$cov_city")

*----------------------------------------------------------------	 
clear
use "data_firm_after.dta", clear

drop if year<2003

global cov_firm "lnage_z lev_z lnsize_z profit_z"
global cov_city "fiscalgap_ratio_z GDPg_z lninvest_z lnpop_z"

foreach var in debt_h_new inv1 {
    egen `var'_m = mean(`var')
    egen `var'_sd = sd(`var')
    gen `var'_zs = (`var' - `var'_m) / `var'_sd
}

gen SOE_a = 1 if ownership==1
replace SOE_a = 0 if SOE_a==.	 
	
//面板B
reghdfe inv1_zs debt_h_new_zs $cov_firm $cov_city, ///
    absorb(city year panelid) vce(cluster city)
est store x_a

reghdfe inv1_zs debt_h_new_zs $cov_firm $cov_city if SOE_a==1, ///
    absorb(city year panelid) vce(cluster city)
est store x_b

reghdfe inv1_zs debt_h_new_zs $cov_firm $cov_city if SOE_a==0, ///
    absorb(city year panelid) vce(cluster city)
est store x_c

//面板C	 
reghdfe inv1_zs D debt_h_new_zs $cov_firm $cov_city, ///
	 absorb(city year panelid) vce(cluster city)
est store x_d
 
reghdfe inv1_zs D debt_h_new_zs $cov_firm $cov_city if SOE_a==1, ///
	 absorb(city year panelid) vce(cluster city)	 
est store x_e

reghdfe inv1_zs D debt_h_new_zs $cov_firm $cov_city if SOE_a==0, ///
	 absorb(city year panelid ) vce(cluster city)	 
est store x_f 
	 
esttab x_* using "$out/main_table05.rtf", ///
    b(%6.4f) t(%6.4f) noconstant nogap compress ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    ar2(%6.4f) scalar(N) append ///
	 indicate("企业控制变量 =$cov_firm" "城市控制变量 =$cov_city")	 
	 