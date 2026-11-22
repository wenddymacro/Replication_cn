
******自由贸易试验区建设与地区经济安全水平———基于地级市的经验证据**********

**********************前置因素识别************************************
xtset id year
xtprobit set Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal
**********************基准回归************************************
xtreg Eco_safe Piolt i.year ,fe r
xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year if Direct==1,fe r
**********************平行趋势检验**********************************
encode 城市, generate(city)
replace action = . if action==2333
xtset city year
gen policy = year - action
tab policy
replace policy = -6 if policy < -6
replace policy = 4 if policy > 4
forvalues i = 6(-1)1{
gen pre_`i' = (policy == -`i' & Treat == 1)
}
gen current = (policy == 0 & Treat == 1)
forvalues j = 1(1)4{
gen post_`j' = (policy == `j' & Treat == 1)
}
replace pre_1=1
xtreg Eco_safe pre_* current post_* i.year,fe r
coefplot, baselevels vertical omitted keep(pre_* current post_*) level(90) yline(0,lcolor(edkblue*0.8)) xline(6,lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ytitle("政策动态效应", size(small)) xtitle("政策时点", size(small)) addplot(line @b @at) ciopts(lpattern(dash) recast(rcap) msize(medium)) msymbol(circle_hollow) scheme(s1mono)
**********************稳健性检验**********************************
xtreg Eco_safe Treatnryear Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
bootstrap , reps(500) seed(12345):xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year,fe r
xtreg Eco_safe Piolt  Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year if Pilot2020==1 ,fe r
xtreg Eco_safe Piolt  Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal Boradid Tefidid i.year ,fe r
**********************安慰剂检验**********************************
rename Treat treat
rename ryear time
rename id city
xtset city year
save 作图数据.dta,replace
// lnEC
clear
mat b = J(500,1,0)  
mat se = J(500,1,0)  
mat p = J(500,1,0)  
forvalues i = 1/500{
          use 作图数据.dta, clear
		  xtset city year 
		  keep if year==2008
		  sample 44, count
		  keep city
		  save MatchId.dta, replace
		  merge 1:m city using 作图数据.dta
		  gen treat1=(_merge ==3)
		  save MatchId`i'.dta,replace
		  
		  use 作图数据.dta, clear
		  bsample 1, strata(city)
		  keep year
		  save MatchYear.dta, replace
		  mkmat year, mat(sampleYear)
		  use MatchId`i'.dta,replace
		  
		  xtset city year
		  gen time1=0
		  foreach j of numlist 1/258{
		  replace time1=1 if (city==`j' & year>=sampleYear[`j',1])
		  }
		  gen did1=treat1*time1
		  global control "  Popu Capi Phys Econ Infra Inter Urban Consum Act "
		  qui xtreg Eco_safe did1 $control i.year  ,fe r

		  mat b[`i',1] = _b[did1]
          mat se[`i',1] = _se[did1]
		  scalar df_r = e(N) - e(df_m) -1
          mat p[`i',1] = 2*ttail(df_r,abs(_b[did1]/_se[did1]))
}  
svmat b, names(coef)
svmat se, names(se)
svmat p, names(pvalue)
drop if pvalue1 == .
label var pvalue1 "P value"
label var coef1 "Estimated coefficient"

twoway(scatter pvalue1 coef1, xlabel(-0.006(0.0005)0.006, grid) yline(0.1, lp(shortdash) lcolor(black)) xline(0, lp(shortdash) lcolor(black)) xtitle("Estimated coefficient") ytitle("P value") msymbol(smcircle_hollow) mcolor(black) legend(off)) (kdensity coef1) 
 
 
forvalue i=1/500{
     erase MatchId`i'.dta
}

graph export "Placebo results for lnEC.png", as(png) replace width(800) height(600)
**********************异质性分析**********************************
gen a1 = Edgewise * Piolt
gen a2 = Inland * Piolt
gen a3 = Coastal * Piolt
gen b1 = Second * Piolt
gen b2 = Third * Piolt
xtreg Eco_safe a1 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year ,fe r
xtreg Eco_safe a2 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year ,fe r
xtreg Eco_safe a3 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year ,fe r
xtreg Eco_safe b1 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Eco_safe b2 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
astile fenEco_safe =Eco_safe, nq(4)
gen d1 =1 if fenEco_safe==1
gen d2 =1 if fenEco_safe==2
gen d3 =1 if fenEco_safe==3
gen d4 =1 if fenEco_safe==4
replace d1=0 if d1==.
replace d2=0 if d2==.
replace d3=0 if d3==.
replace d4=0 if d4==.
gen e1 = d1 * Piolt
gen e2 = d2 * Piolt
gen e3 = d3 * Piolt
gen e4 = d4 * Piolt
xtreg Eco_safe e1 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Eco_safe e2 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Eco_safe e3 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Eco_safe e4 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
**********************机制检验**********************************
xtreg CapitalMismatch Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Labormismatch Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Agg_e Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Agg_i Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Agg_T1 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Agg_T2 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Agg_T3 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Agg_T4 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Healthinde Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Affinityindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Integrityindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r
xtreg Ceindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year ,fe r