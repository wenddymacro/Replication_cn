*****依据《中华人民共和国数据安全法》、《网络数据安全管理条例》等相关法规要求，本文使用的中国土地出让微观数据属自然资源部法定监管范畴。为严格履行数据安全保护义务，附件提供随机抽样的4%样本数据作验证参考。********

cd " " //使用计算机中存储文件的路径

*****************************Table1_to_Table5 & Appendix_Table2_part1****************************************

use "数据.dta", clear

**Determining control variables
global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"

drop if landuse!=1&landuse!=2&landuse!=3
reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
gen esample=e(sample)
keep if esample==1

**Table1-Baseline regression
reghdfe lnaprice internew,cluster( 区代码匹配 ) noabsorb
est store a
reghdfe lnaprice internew ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym) 
est store b
reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym) 
est store c
reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
est store d
esttab a b c d using Table1_all_baseline.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear

**Table2-Regression - land price by usage type - adding control variables
reghdfe lnaprice internew $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store res
reghdfe lnaprice internew $xlist_land if landuse==3,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store com
reghdfe lnaprice internew $xlist_land if landuse!=2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store rescom
reghdfe lnaprice internew $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store ind
esttab res com rescom ind using Table2_landprice_baseline.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Table3-Interaction terms for eastern, central and western regions
gen interneweast=internew*(qycode==1)
gen internewmiddle=internew*(qycode==2)
gen internewwest=internew*(qycode==3)
gen internewmidwes=internew*(qycode==2|qycode==3)

reghdfe lnaprice interneweast internewmidwes $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
est store all_east2_int
reghdfe lnaprice interneweast internewmidwes $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store res_east2_int
reghdfe lnaprice interneweast internewmidwes $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store ind_east2_int
reghdfe lnaprice interneweast internewmidwes $xlist_land if landuse==3,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store com_east2_int
reghdfe lnaprice interneweast internewmidwes $xlist_land if landuse!=2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store rescom_east2_int
esttab all_east2_int res_east2_int com_east2_int rescom_east2_int ind_east2_int using Table3_landprice_east2_int.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Table4-Interaction terms for large, medium and small cities
gen interbig=internew*big
gen internobig=internew*(1-big)

reghdfe lnaprice interbig internobig $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
est store all_big_int
reghdfe lnaprice interbig internobig $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store res_big_int
reghdfe lnaprice interbig internobig $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store ind_big_int
reghdfe lnaprice interbig internobig $xlist_land if landuse==3,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store com_big_int
reghdfe lnaprice interbig internobig $xlist_land if landuse!=2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store rescom_big_int
esttab all_big_int res_big_int com_big_int rescom_big_int ind_big_int using Table4_landprice_big_int.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Table5-Interaction terms for intra-city distance
gen close23=0 if disnew!=.&disnew>23&treatnew==1
replace close23=1 if disnew<=23&treatnew==1
replace close23=0 if treatnew==0
gen internewclose23=internew*close23
gen internewnoclose23=internew*(1-close23)

reghdfe lnaprice internewclose23 internewnoclose23 $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
est store all_close_int
reghdfe lnaprice internewclose23 internewnoclose23 $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store res_close_int
reghdfe lnaprice internewclose23 internewnoclose23 $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store ind_close_int
reghdfe lnaprice internewclose23 internewnoclose23 $xlist_land if landuse==3,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store com_close_int
reghdfe lnaprice internewclose23 internewnoclose23 $xlist_land if landuse!=2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store rescom_close_int
esttab all_close_int res_close_int com_close_int rescom_close_int ind_close_int using Table5_landprice_close23_int.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Dynamic Effect
gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.
reghdfe lnaprice internewa internew6-internew8 internew10-internew15 $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store all_dynam_m1

gen coef=.
gen year1=.
gen upper=.
gen lower=.
replace year1=-5 in 1
replace coef=_b[internewa] in 1
replace upper=_b[internewa]+_se[internewa]*invttail(1758,0.05) in 1
replace lower=_b[internewa]-_se[internewa]*invttail(1758,0.05) in 1
local num=1
foreach x in 6 7 8 10 11 12 13 14 15{
local num=`num'+1
replace year1=`x'-10 in `num'
replace coef=_b[internew`x'] in `num'
replace upper=_b[internew`x']+_se[internew`x']*invttail(1758,0.05) in `num'
replace lower=_b[internew`x']-_se[internew`x']*invttail(1758,0.05) in `num'
}
twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), legend(off) graphregion(color(white)) xline(0, lcolor(gray)) scheme(s2mono)
esttab all_dynam_m1  using landprice_dynamic_effect.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
eststo clear

**Placebo Tests
**Fake Time Points Part 1
gen 批复时间newfake=批复时间new-20000
gen postnewfake=1 if newdate>=批复时间newfake
replace postnewfake=0 if postnewfake==.
gen internewfake=treatnew*postnewfake

reghdfe lnaprice internewfake $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
est store all
reghdfe lnaprice internewfake $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store res
reghdfe lnaprice internewfake $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store ind
esttab all res ind using AppendixTable2_column1_landprice_baseline_placebotime.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear




*****************************Table6_to_Table9 & AppendixTable2_part2****************************************

use "数据.dta", clear

**Generating the sum of land transfers, area, and total revenue by city and land use type
bys 市代码匹配  year landuse:gen number=_N
bys 市代码匹配  year landuse:egen sumarea=total(面积)
bys 市代码匹配  year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配  year landuse,force

**Determining control variables
global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

drop if landuse!=1&landuse!=2&landuse!=3&landuse!=6
reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

**Table 6 amount and area
**Adding control variables_amount
reghdfe lnsumprice internew if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store resprice
reghdfe lnsumprice internew if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store indprice

**Adding control variables_area
reghdfe lnsumarea internew if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store resarea
reghdfe lnsumarea internew if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store indarea
reghdfe lnsumarea internew if landuse==6,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store infraarea

esttab resprice resarea indprice indarea infraarea using Table6_landsumprice_area_baseline.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear

** Table 7 eastern, central and western regions
drop qycode
gen qycode=1 if proid==11|proid==12|proid==13|proid==21|proid==31|proid==32|proid==33|proid==35|proid==37|proid==44|proid==46
replace qycode=2 if proid==14|proid==22|proid==23|proid==34|proid==36|proid==41|proid==42|proid==43
replace qycode=3 if proid==15|proid==45|proid==50|proid==51|proid==52|proid==53|proid==54|proid==61|proid==62|proid==63|proid==64|proid==65
label var qycode "区域编码（1=东，2=中，3=西）"

**Interaction terms for eastern, central and western regions
gen interneweast=internew*(qycode==1)
gen internewmiddle=internew*(qycode==2)
gen internewwest=internew*(qycode==3)
gen internewmidwes=internew*(qycode==2|qycode==3)

**Interaction terms for eastern, central and western regions2_amount

reghdfe lnsumprice interneweast internewmidwes if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store res_east2_int_price
reghdfe lnsumprice interneweast internewmidwes if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store ind_east2_int_price

**Interaction terms for eastern, central and western regions2_area

reghdfe lnsumarea interneweast internewmidwes if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store res_east2_int_area
reghdfe lnsumarea interneweast internewmidwes if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store ind_east2_int_area
reghdfe lnsumarea interneweast internewmidwes if landuse==6,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store infra_east2_int_area

esttab  res_east2_int_price res_east2_int_area ind_east2_int_price ind_east2_int_area infra_east2_int_area using Table7_landsumarea_east2_int.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Table 8 large, medium and small cities
merge m:1 所属城市 using  2010年市辖区常住人口规模-普查计算.dta
drop big
drop if _merge==2
drop _merge
gen big=1 if pop>=1000000&pop!=.
replace big=0 if big==.
gen interbig=internew*big
gen internobig=internew*(1-big)

**Interaction terms for large, medium and small cities_amount
reghdfe lnsumprice interbig internobig  if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store res_big_int_price
reghdfe lnsumprice interbig internobig  if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store ind_big_int_price

**Interaction terms for large, medium and small cities_area
reghdfe lnsumarea interbig internobig  if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store res_big_area
reghdfe lnsumarea interbig internobig  if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store ind_big_area
reghdfe lnsumarea interbig internobig  if landuse==6,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store infra_big_area
esttab res_big_int_price res_big_area ind_big_int_price ind_big_area infra_big_area using Table8_landsumarea_big_int.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Table 9 Interaction terms for intra-city distance
gen close=0 if disnew!=.&disnew>40&treatnew==1
replace close=1 if disnew<=40&treatnew==1
replace close=0 if treatnew==0

**Interaction terms for intra-city distance
gen internewclose=internew*close
gen internewnoclose=internew*(1-close)

gen close23=0 if disnew!=.&disnew>23&treatnew==1
replace close23=1 if disnew<=23&treatnew==1
replace close23=0 if treatnew==0
gen internewclose23=internew*close23
gen internewnoclose23=internew*(1-close23)


**Interaction terms for intra-city distance_amount

reghdfe lnsumprice internewclose23 internewnoclose23 if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store res_close_int_price
reghdfe lnsumprice internewclose23 internewnoclose23 if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store ind_close_int_price

**Interaction terms for intra-city distance_area
reghdfe lnsumarea internewclose23 internewnoclose23 if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store res_close_int_area
reghdfe lnsumarea internewclose23 internewnoclose23 if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store ind_close_int_area
reghdfe lnsumarea internewclose23 internewnoclose23 if landuse==6,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store infra_close_int_area
esttab res_close_int_price  res_close_int_area ind_close_int_price ind_close_int_area  infra_close_int_area using Table9_landsumarea_close23_int.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear


**Dynamic Effects
gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1


gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.

bys 市代码匹配  year :egen allarea=total(sumarea)
bys 市代码匹配  year :egen allprice=total(sumprice)
gen lnallarea=ln(allarea)
gen lnallprice=ln(allprice)
duplicates drop 市代码匹配  year,force


**Industrial
reghdfe lnallprice internewa internew6-internew8 internew10-internew15,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store allprice_dynam_m1


**Placebo Tests
**Fake Time Points Part 2
gen 批复时间newfake=批复时间new-20000
gen postnewfake=1 if newdate>=批复时间newfake
replace postnewfake=0 if postnewfake==.
gen internewfake=treatnew*postnewfake

keep if landuse==1
reghdfe lnallprice internewfake if internew!=1&internewa!=1 ,cluster( 市代码匹配 ) absorb( 市代码匹配 ym $xlist_city) 
est store a
reghdfe lnallarea internewfake if internew!=1&internewa!=1 ,cluster( 市代码匹配 ) absorb( 市代码匹配 ym $xlist_city) 
est store b
esttab a b using Table11_column23_landprice_baseline_placebotime.rtf,replace se compress nogap b(%6.4f) scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
est clear

*************Placebo Test with Fake Treatment（Appendix Figure 2）*****************************

clear
input long timelist int n
20150724 1
20160608 2
20140616 3
20151012 4
20160320 5
20141020 6
20140502 7
20150724 8
20121216 9
20141212 10
20150724 11
20131018 12
20170718 13
20140502 14
20141212 15
20150724 16
20180208 17
20131018 18
20161124 19
20150216 20
20160914 21
20160608 22
20140124 23
20141020 24
20160108 25
20140908 26
20161124 27
20150216 28
20140908 29
20180620 30
20150428 31
20131018 32
20141020 33
20121116 34
20130628 35
20121216 36
20140908 37
20150216 38
20160320 39
20130118 40
20161124 41
20151204 42
20170718 43
20160320 44
20141020 45
20110216 46
20130628 47
20120930 48
20160320 49
20141212 50
20110520 51
20160320 52
20151204 53
20141212 54
20151012 55
20160608 56
20170718 57
end

save "numlist.dta",replace


**Land Price
forvalues i=1(1)5 {
use "数据.dta", clear  
save gaidid1_datacity,replace
use gaidid1_datacity,clear
keep 市代码匹配 newdate lnaprice
duplicates drop 市代码匹配,force
save gaidid_datacity,replace
use gaidid_datacity,clear
** create the false dataset
sample 57, count
keep 市代码匹配
gen n=_n
merge 1:1 n using "numlist.dta" 
drop _merge
save gaitempcity,replace
use gaidid1_datacity,clear
merge m:1 市代码匹配 using gaitempcity
drop treatnew
gen treatnew=(_merge==3)
drop postnew internew
gen postnew=1 if newdate>=timelist&timelist!=.
drop _merge
save gaidid1_datacity,replace
use gaidid1_datacity,clear
gen internew=treatnew*postnew
replace internew=0 if internew==.
sort 市代码匹配
global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"
reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
parmest,format (estimate min95 max95 %8.2f p %8.3f) saving("gaitemp1city.dta", replace)
use "gaitemp1city.dta", clear
keep if parm=="internew"
append using "gaisimulationscity.dta"
save "gaisimulationscity.dta", replace
}

erase "gaitemp1city.dta"
use "gaisimulationscity.dta", clear
drop if estimate==.
save "gaisimulationscity.dta", replace
**Graphs
use  "gaisimulationscity.dta",clear
kdensity estimate,xline(0) scheme(s2mono) graphregion(color(white)) ytitle("probability density") xtitle("coefficient of Merger") saving("PlaceboTest_Landprice.emf", replace) 


**House Land Price
forvalues i=1(1)300 {
use "数据.dta", clear  
save gaidid1_datacity,replace
use gaidid1_datacity,clear
keep 市代码匹配 newdate lnaprice
duplicates drop 市代码匹配,force
save gaidid_datacity,replace
use gaidid_datacity,clear
** create the false dataset
sample 57, count
keep 市代码匹配
gen n=_n
merge 1:1 n using "numlist.dta" 
drop _merge
save gaitempcity,replace
use gaidid1_datacity,clear
merge m:1 市代码匹配 using gaitempcity
drop treatnew
gen treatnew=(_merge==3)
drop postnew internew
gen postnew=1 if newdate>=timelist&timelist!=.
drop _merge
save gaidid1_datacity,replace
use gaidid1_datacity,clear
gen internew=treatnew*postnew
replace internew=0 if internew==.
sort 市代码匹配
global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"
reghdfe lnaprice internew $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
parmest,format (estimate min95 max95 %8.2f p %8.3f) saving("gaitemp1city.dta", replace)
use "gaitemp1city.dta", clear
keep if parm=="internew"
append using "gaisimulationscity.dta"
save "gaisimulationscity.dta", replace
}

erase "gaitemp1city.dta"
use "gaisimulationscity.dta", clear
drop if estimate==.
save "gaisimulationscity.dta", replace
**Graphs
use  "gaisimulationscity.dta",clear
kdensity estimate,xline(0) scheme(s2mono) graphregion(color(white)) ytitle("probability density") xtitle("coefficient of Merger") saving("PlaceboTest_HouseLandPrice.emf", replace) 


**Industrial Land Price
forvalues i=1(1)300 {
use "数据.dta", clear  
save gaidid1_datacity,replace
use gaidid1_datacity,clear
keep 市代码匹配 newdate lnaprice
duplicates drop 市代码匹配,force
save gaidid_datacity,replace
use gaidid_datacity,clear
** create the false dataset
sample 57, count
keep 市代码匹配
gen n=_n
merge 1:1 n using "numlist.dta" 
drop _merge
save gaitempcity,replace
use gaidid1_datacity,clear
merge m:1 市代码匹配 using gaitempcity
drop treatnew
gen treatnew=(_merge==3)
drop postnew internew
gen postnew=1 if newdate>=timelist&timelist!=.
drop _merge
save gaidid1_datacity,replace
use gaidid1_datacity,clear
gen internew=treatnew*postnew
replace internew=0 if internew==.
sort 市代码匹配
global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"
reghdfe lnaprice internew $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
parmest,format (estimate min95 max95 %8.2f p %8.3f) saving("gaitemp1city.dta", replace)
use "gaitemp1city.dta", clear
keep if parm=="internew"
append using "gaisimulationscity.dta"
save "gaisimulationscity.dta", replace
}

erase "gaitemp1city.dta"
use "gaisimulationscity.dta", clear
drop if estimate==.
save "gaisimulationscity.dta", replace
**Graphs
use  "gaisimulationscity.dta",clear
kdensity estimate,xline(0) scheme(s2mono) graphregion(color(white)) ytitle("probability density") xtitle("coefficient of Merger") saving("PlaceboTest_IndustrialLandPrice.emf", replace) 

*******House Land Amount Revenue

clear
set obs 0
gen iteration = .
gen estimate = .
gen min95 = .
gen max95 = .
gen p = .
save "gaisimulationscity.dta", replace emptyok

use "数据.dta", clear  
bys 市代码匹配 year landuse: gen number=_N
bys 市代码匹配 year landuse: egen sumarea=total(面积)
bys 市代码匹配 year landuse: egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配 year landuse, force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"
drop if landuse!=1&landuse!=2&landuse!=3&landuse!=6
reghdfe lnsumprice internew, cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

save gaidid1_datacity, replace


forvalues i=1(1)100 {
 
    use gaidid1_datacity, clear
	
    preserve
    keep 市代码匹配
    duplicates drop 市代码匹配, force
    sample 57, count
    gen n=_n
	
    merge 1:1 n using "numlist.dta"
    keep if _merge==3
    keep 市代码匹配 timelist
    tempfile temp_treat
    save `temp_treat'
    restore
    
    merge m:1 市代码匹配 using `temp_treat'
    
    drop treatnew postnew internew
    
    gen treatnew = (_merge==3)
    gen postnew = (newdate>=timelist & timelist!=.)
    gen internew = treatnew * postnew
    replace internew = 0 if internew==.
    drop _merge
    
    reghdfe lnsumprice internew if landuse==1, cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
    
    parmest, format(estimate min95 max95 %8.2f p %8.3f) saving("gaitemp1city.dta", replace)
    use "gaitemp1city.dta", clear
    keep if parm=="internew"
    append using "gaisimulationscity.dta"
    save "gaisimulationscity.dta", replace
}

kdensity estimate, xline(0) scheme(s2mono) graphregion(color(white)) ///
    ytitle("probability density") xtitle("coefficient of Merger") ///
    saving("PlaceboTest_HouseLandAmountRvenue.emf", replace)
	

***********House Land Area 

clear
set obs 0
gen iteration = .
gen estimate = .
gen min95 = .
gen max95 = .
gen p = .
save "gaisimulationscity.dta", replace emptyok

use "数据.dta", clear  

bys 市代码匹配 year landuse: gen number=_N
bys 市代码匹配 year landuse: egen sumarea=total(面积)
bys 市代码匹配 year landuse: egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配 year landuse, force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"
drop if landuse!=1&landuse!=2&landuse!=3&landuse!=6
reghdfe lnsumarea internew if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

save gaidid1_datacity, replace


forvalues i=1(1)100 {

    use gaidid1_datacity, clear
    
    preserve
    keep 市代码匹配
    duplicates drop 市代码匹配, force
    sample 57, count
    gen n=_n
    
    merge 1:1 n using "numlist.dta"
    keep if _merge==3
    keep 市代码匹配 timelist
    tempfile temp_treat
    save `temp_treat'
    restore
    
    merge m:1 市代码匹配 using `temp_treat'
    
    drop treatnew postnew internew
    
    gen treatnew = (_merge==3)
    gen postnew = (newdate>=timelist & timelist!=.)
    gen internew = treatnew * postnew
    replace internew = 0 if internew==.
    drop _merge
    
    reghdfe lnsumarea internew if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
    
    parmest, format(estimate min95 max95 %8.2f p %8.3f) saving("gaitemp1city.dta", replace)
    use "gaitemp1city.dta", clear
    keep if parm=="internew"
    append using "gaisimulationscity.dta"
    save "gaisimulationscity.dta", replace
}

kdensity estimate, xline(0) scheme(s2mono) graphregion(color(white)) ///
    ytitle("probability density") xtitle("coefficient of Merger") ///
    saving("PlaceboTest_HouseLandArea.emf", replace)

********************Parallel trends graph**************************************
******Parallel trends graph_land price
use "数据.dta",clear

global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.
reghdfe lnaprice internewa internew6-internew8 internew10-internew15 $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store all_dynam_m1

preserve
clear
set obs 10  

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(1758, 0.05) in 1
replace lower = coef - se * invttail(1758, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(1758, 0.05) in `num'
    replace lower = coef - se * invttail(1758, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
	   xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)

	   restore

******Parallel trends graph_House land price
use "数据.dta",clear

global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.
reghdfe lnaprice internewa internew6-internew8 internew10-internew15 $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)

est store all_dynam_m1

preserve
clear
set obs 10  

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(1758, 0.05) in 1
replace lower = coef - se * invttail(1758, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(1758, 0.05) in `num'
    replace lower = coef - se * invttail(1758, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
	   xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)

*restore

******Parallel trends graph_Industrial Land Price
use "数据.dta",clear

global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.
reghdfe lnaprice internewa internew6-internew8 internew10-internew15 $xlist_land if landuse==2,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
est store all_ind_dynam_m1

*preserve
clear
set obs 10  

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(1758, 0.05) in 1
replace lower = coef - se * invttail(1758, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(1758, 0.05) in `num'
    replace lower = coef - se * invttail(1758, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
	   xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)

*restore

******Parallel trends graph_House Land Amount Revenue

use "数据.dta", clear

bys 市代码匹配  year landuse:gen number=_N
bys 市代码匹配  year landuse:egen sumarea=total(面积)
bys 市代码匹配  year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配  year landuse,force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"
drop esample
drop if landuse!=1&landuse!=2&landuse!=3&landuse!=6
reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.

bys 市代码匹配  year :egen allarea=total(sumarea)
bys 市代码匹配  year :egen allprice=total(sumprice)
gen lnallarea=ln(allarea)
gen lnallprice=ln(allprice)
duplicates drop 市代码匹配  year,force

reghdfe lnallprice internewa internew6-internew8 internew10-internew15 if landuse==1, cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
est store allprice_dynam_m1

clear
set obs 10

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(216, 0.05) in 1
replace lower = coef - se * invttail(216, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(216, 0.05) in `num'
    replace lower = coef - se * invttail(216, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
       xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)
*restore
	   
************Parallel trends graph_Industrial Land Amount Revenue

use "数据.dta", clear

bys 市代码匹配  year landuse:gen number=_N
bys 市代码匹配  year landuse:egen sumarea=total(面积)
bys 市代码匹配  year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配  year landuse,force

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1


gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.

bys 市代码匹配  year :egen allarea=total(sumarea)
bys 市代码匹配  year :egen allprice=total(sumprice)
gen lnallarea=ln(allarea)
gen lnallprice=ln(allprice)
duplicates drop 市代码匹配  year,force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

reghdfe lnallprice internewa internew6-internew8 internew10-internew15 if landuse==2, cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
est store allprice_dynam_m1

clear
set obs 10

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(216, 0.05) in 1
replace lower = coef - se * invttail(216, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(216, 0.05) in `num'
    replace lower = coef - se * invttail(216, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
       xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)
*restore

*********Parallel trends graph_House Land Area

use "数据.dta", clear

bys 市代码匹配  year landuse:gen number=_N
bys 市代码匹配  year landuse:egen sumarea=total(面积)
bys 市代码匹配  year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配  year landuse,force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.

bys 市代码匹配  year :egen allarea=total(sumarea)
bys 市代码匹配  year :egen allprice=total(sumprice)
gen lnallarea=ln(allarea)
gen lnallprice=ln(allprice)
duplicates drop 市代码匹配  year,force

reghdfe lnallarea internewa internew6-internew8 internew10-internew15 if landuse==1,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store allarea_house_dynam_m1

clear
set obs 10

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(216, 0.05) in 1
replace lower = coef - se * invttail(216, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(216, 0.05) in `num'
    replace lower = coef - se * invttail(216, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
       xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)
*restore
	   	   	   
*********Parallel trends graph_Industrial Land Area

use "数据.dta", clear

bys 市代码匹配  year landuse:gen number=_N
bys 市代码匹配  year landuse:egen sumarea=total(面积)
bys 市代码匹配  year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配  year landuse,force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.

bys 市代码匹配  year :egen allarea=total(sumarea)
bys 市代码匹配  year :egen allprice=total(sumprice)
gen lnallarea=ln(allarea)
gen lnallprice=ln(allprice)
duplicates drop 市代码匹配  year,force

reghdfe lnallarea internewa internew6-internew8 internew10-internew15 if landuse==2,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store allarea_ind_dynam_m1

clear
set obs 10

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(216, 0.05) in 1
replace lower = coef - se * invttail(216, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(216, 0.05) in `num'
    replace lower = coef - se * invttail(216, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
       xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)
*restore
   
*********Parallel trends graph_Infrastructure Land Area
use "数据.dta", clear

bys 市代码匹配  year landuse:gen number=_N
bys 市代码匹配  year landuse:egen sumarea=total(面积)
bys 市代码匹配  year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配  year landuse,force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

reghdfe lnsumprice internew,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

gen centeryear=year-int(批复时间new/10000)
tab centeryear,gen(centeryear)
forvalues i=1/20{
 gen internew`i'=treatnew*centeryear`i'
 replace internew`i'=0 if internew`i'==.
 }
replace internew15=1 if internew16==1|internew17==1|internew18==1|internew19==1|internew20==1

gen internewa=1 if internew1==1|internew2==1|internew3==1|internew4==1|internew5==1
replace internewa=0 if internewa==.

bys 市代码匹配  year :egen allarea=total(sumarea)
bys 市代码匹配  year :egen allprice=total(sumprice)
gen lnallarea=ln(allarea)
gen lnallprice=ln(allprice)
duplicates drop 市代码匹配  year,force

reghdfe lnallarea internewa internew6-internew8 internew10-internew15 if landuse==6,cluster( 市代码匹配 ) absorb( 市代码匹配 year $xlist_city)
est store allarea_infra_dynam_m1

clear
set obs 10

gen coef = .
gen se = .
gen year1 = .
gen upper = .
gen lower = .

replace year1 = -5 in 1
replace coef = _b[internewa] in 1
replace se = _se[internewa] in 1
replace upper = coef + se * invttail(216, 0.05) in 1
replace lower = coef - se * invttail(216, 0.05) in 1

local num = 1
foreach x in 6 7 8 10 11 12 13 14 15 {
    local num = `num' + 1
    replace year1 = `x' - 10 in `num'
    replace coef = _b[internew`x'] in `num'
    replace se = _se[internew`x'] in `num'
    replace upper = coef + se * invttail(216, 0.05) in `num'
    replace lower = coef - se * invttail(216, 0.05) in `num'
}

twoway (connected coef year1, mcolor(black) msymbol(diamond) lcolor(black) lpattern(solid)) ///
       (connected upper year1, msymbol(none) lcolor(black) lpattern(dash)) ///
       (connected lower year1, msymbol(none) lcolor(black) lpattern(dash)), ///
       legend(off) graphregion(color(white)) xline(-1, lcolor(gray)) scheme(s2mono) ///
       xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5)	      
*restore

********************Oster Test***************************************

******Oster Test_Land Price
use "数据.dta",clear

global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"	  

drop if landuse!=1&landuse!=2&landuse!=3
reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
gen esample=e(sample)
keep if esample==1

reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
psacalc2 delta internew
reghdfe lnaprice internew $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) //住房用地
psacalc2 delta internew
reghdfe lnaprice internew $xlist_land if landuse==3,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) //工业用地
psacalc2 delta internew

tempname temp
tempfile results
postfile `temp' str20 landtype double(delta) using `results'

// 全样本回归和psacalc2
quietly reghdfe lnaprice internew $xlist_land ,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city) 
quietly psacalc2 delta internew
local delta = r(delta)
post `temp' ("All Sample") (`delta')

// 住房用地回归和psacalc2
quietly reghdfe lnaprice internew $xlist_land if landuse==1,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
quietly psacalc2 delta internew
local delta = r(delta)
post `temp' ("Residential Land") (`delta')

// 工业用地回归和psacalc2
quietly reghdfe lnaprice internew $xlist_land if landuse==3,cluster( 区代码匹配 ) absorb( 区代码匹配 ym $xlist_city)
quietly psacalc2 delta internew
local delta = r(delta)
post `temp' ("Industrial Land") (`delta')

postclose `temp'

use `results', clear

export delimited using "psacalc_results1.csv", replace


*******Oster Test_Land Area and Amount Revenue
use "数据.dta", clear

bys 市代码匹配 year landuse:gen number=_N
bys 市代码匹配 year landuse:egen sumarea=total(面积)
bys 市代码匹配 year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配 year landuse,force

global xlist_city "c.lnpergdp9#i.year c.lnmidu9#i.year c.fiscrev9#i.year c.yichan9#i.year c.lnperdoctor9#i.year"

drop if landuse!=1&landuse!=2&landuse!=3&landuse!=6
reghdfe lnsumprice internew,cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
gen esample=e(sample)
keep if esample==1

tempfile results
tempname memhold
postfile `memhold' str20 outcome_var str20 landtype double(delta) using `results'

// 住房出让金分析+psacalc2
qui reghdfe lnsumprice internew if landuse==1,cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
local beta_price = _b[internew]
qui psacalc2 delta internew
local delta_price = r(delta)
post `memhold' ("House Sum Price") ("House")  (`delta_price')

// 住房面积分析+psacalc2
qui reghdfe lnsumarea internew if landuse==1,cluster(市代码匹配) absorb(市代码匹配 year $xlist_city)
local beta_area = _b[internew]
qui psacalc2 delta internew
local delta_area = r(delta)
post `memhold' ("House Sum Area") ("House")  (`delta_area')

postclose `memhold'

use `results', clear

export delimited using "psacalc_results2.csv", replace


********************Balancing test***************************************************

use "数据.dta",clear

global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"	  

local depvars1 "lnpergdp9 lnmidu9 fiscrev9 yichan9 lnperdoctor9"
local depvars2 "popgrowthrate9 wasteuserate9 pollutionden9 SO29 propertyinvest9 area9 sale9 birthrate9 deathrate9 lnperRD9 lnperelectral9"

eststo clear

tempfile temp
tempname memhold

postfile `memhold' str32 varname mean1 sd1 mean0 sd0 coef1 se1 coef2 se2 using `temp'

foreach var of local depvars1 {
    qui sum `var' if treatnew==1 & year==2009
    local mean1 = r(mean)
    local sd1 = r(sd)
    
    qui sum `var' if treatnew==0 & year==2009
    local mean0 = r(mean)
    local sd0 = r(sd)
    
    qui reg `var' treatnew if year==2009, robust
    local coef1 = _b[treatnew]
    local se1 = _se[treatnew]
    
    post `memhold' ("`var'") (`mean1') (`sd1') (`mean0') (`sd0') (`coef1') (`se1') (.) (.)
}

foreach var of local depvars2 {
    qui sum `var' if treatnew==1 & year==2009
    local mean1 = r(mean)
    local sd1 = r(sd)
    
    qui sum `var' if treatnew==0 & year==2009
    local mean0 = r(mean)
    local sd0 = r(sd)
    
    qui reg `var' treatnew if year==2009, robust
    local coef1 = _b[treatnew]
    local se1 = _se[treatnew]

    qui reg `var' treatnew $xlist_city if year==2009, robust
    local coef2 = _b[treatnew]
    local se2 = _se[treatnew]
    
    post `memhold' ("`var'") (`mean1') (`sd1') (`mean0') (`sd0') (`coef1') (`se1') (`coef2') (`se2')
}

postclose `memhold'

use `temp', clear

format mean1 sd1 mean0 sd0 coef1 se1 coef2 se2 %9.3f

export excel using "regression_results.xlsx", firstrow(variables) replace


*************************************Propensity Score Matching (PSM)*********************
*********Matching cities + land parcels

use "数据.dta",clear

global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "lnpergdp9 lnmidu9 fiscrev9 yichan9 lnperdoctor9"
logit internew $xlist_land $xlist_city i.ym, cluster(区代码匹配)
predict pscore
	
// 1 最近1邻匹配
psmatch2 internew, pscore(pscore) outcome(lnaprice) neighbor(1) common ties ate

reghdfe lnaprice internew $xlist_land if _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city) 
est store all_psm1
reghdfe lnaprice internew $xlist_land if landuse==1 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store res_psm1
reghdfe lnaprice internew $xlist_land if landuse==2 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store ind_psm1

esttab all_psm1 res_psm1 ind_psm1 using AppendixTable5_psm邻居1A.rtf, ///
    replace se compress nogap b(%6.4f) ///
    scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 

drop _support	

// 2半径匹配（0.05半径）
psmatch2 internew, pscore(pscore) outcome(lnaprice) caliper(0.05) common ties ate

reghdfe lnaprice internew $xlist_land if _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city) 
est store all_psm2
reghdfe lnaprice internew $xlist_land if landuse==1 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store res_psm2
reghdfe lnaprice internew $xlist_land if landuse==2 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store ind_psm2

esttab all_psm2 res_psm2 ind_psm2 using AppendixTable5_psm半径1A.rtf, ///
    replace se compress nogap b(%6.4f) ///
    scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
	
drop _support	
	
// 3 核匹配（Epanechnikov核）
psmatch2 internew, pscore(pscore) outcome(lnaprice) kernel common ties ate

reghdfe lnaprice internew $xlist_land if _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city) 
est store all_psm3
reghdfe lnaprice internew $xlist_land if landuse==1 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store res_psm3
reghdfe lnaprice internew $xlist_land if landuse==2 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store ind_psm3

esttab all_psm3 res_psm3 ind_psm3 using AppendixTable5_psm核匹配1A.rtf, ///
    replace se compress nogap b(%6.4f) ///
    scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 	
	
*********Matching cities
drop pscore _est_all_psm1 _est_res_psm1 _est_ind_psm1 _est_all_psm2 _est_res_psm2 _est_ind_psm2 _pscore _treated _support _weight _lnaprice

logit internew $xlist_city 
predict pscore  

// 1 最近1邻匹配
psmatch2 internew, pscore(pscore) outcome(lnaprice) neighbor(1) common ties ate

reghdfe lnaprice internew $xlist_land if _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city) 
est store all_psm1
reghdfe lnaprice internew $xlist_land if landuse==1 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store res_psm1
reghdfe lnaprice internew $xlist_land if landuse==2 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store ind_psm1

esttab all_psm1 res_psm1 ind_psm1 using AppendixTable5_psm邻居1B.rtf, ///
    replace se compress nogap b(%6.4f) ///
    scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 

drop _support	

// 2半径匹配（0.05半径）
psmatch2 internew, pscore(pscore) outcome(lnaprice) caliper(0.05) common ties ate

reghdfe lnaprice internew $xlist_land if _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city) 
est store all_psm2
reghdfe lnaprice internew $xlist_land if landuse==1 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store res_psm2
reghdfe lnaprice internew $xlist_land if landuse==2 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store ind_psm2

esttab all_psm2 res_psm2 ind_psm2 using AppendixTable5_psm半径1B.rtf, ///
    replace se compress nogap b(%6.4f) ///
    scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
	
drop _support	
	
// 3 核匹配（Epanechnikov核）
psmatch2 internew, pscore(pscore) outcome(lnaprice) kernel common ties ate

reghdfe lnaprice internew $xlist_land if _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city) 
est store all_psm3
reghdfe lnaprice internew $xlist_land if landuse==1 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store res_psm3
reghdfe lnaprice internew $xlist_land if landuse==2 & _support==1, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
est store ind_psm3

esttab all_psm3 res_psm3 ind_psm3 using AppendixTable5_psm核匹配1B.rtf, ///
    replace se compress nogap b(%6.4f) ///
    scalars(r2 r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 	

***********PSM_Land Area and Amount Revenue*
use "数据.dta", clear

bys 市代码匹配 year landuse:gen number=_N
bys 市代码匹配 year landuse:egen sumarea=total(面积)
bys 市代码匹配 year landuse:egen sumprice=total(成交价格/cpibase2004)
gen lnnumber=ln(number)
gen lnsumarea=ln(sumarea)
gen lnsumprice=ln(sumprice)
duplicates drop 市代码匹配 year landuse,force

global xlist_city "lnpergdp9 lnmidu9 fiscrev9 yichan9 lnperdoctor9"

logit internew $xlist_city  
predict pscore  

// 最近邻匹配(1:1)分析
psmatch2 internew, pscore(pscore) outcome(lnsumprice) neighbor(1) common ties ate
scalar att_nn1_price = r(att)
// Amount Revenue
reghdfe lnsumprice internew $xlist_city if landuse==1 & _support==1, ///
    cluster(市代码匹配) absorb(市代码匹配 year)
est store resprice_nn

// Area
psmatch2 internew, pscore(pscore) outcome(lnsumarea) neighbor(1) common ties ate
scalar att_nn1_area = r(att)

reghdfe lnsumarea internew $xlist_city if landuse==1 & _support==1, ///
    cluster(市代码匹配) absorb(市代码匹配 year)
est store resarea_nn

// 半径匹配分析
// Amount Revenue
psmatch2 internew, pscore(pscore) outcome(lnsumprice) radius caliper(0.05) common ties ate
scalar att_rad_price = r(att)
reghdfe lnsumprice internew $xlist_city if landuse==1 & _support==1, ///
    cluster(市代码匹配) absorb(市代码匹配 year)
est store resprice_rad

// Area
psmatch2 internew, pscore(pscore) outcome(lnsumarea) radius caliper(0.05) common ties ate
scalar att_rad_area = r(att)
reghdfe lnsumarea internew $xlist_city if landuse==1 & _support==1, ///
    cluster(市代码匹配) absorb(市代码匹配 year)
est store resarea_rad

// Epanechnikov核匹配分析
// Amount Revenue
psmatch2 internew, pscore(pscore) outcome(lnsumprice) kernel kerneltype(epan) common ties ate
scalar att_kernel_price = r(att)
reghdfe lnsumprice internew $xlist_city if landuse==1 & _support==1, ///
    cluster(市代码匹配) absorb(市代码匹配 year)
est store resprice_kernel

// Area
psmatch2 internew, pscore(pscore) outcome(lnsumarea) kernel kerneltype(epan) common ties ate
scalar att_kernel_area = r(att)
reghdfe lnsumarea internew $xlist_city if landuse==1 & _support==1, ///
    cluster(市代码匹配) absorb(市代码匹配 year)
est store resarea_kernel


esttab resprice_nn resarea_nn resprice_rad resarea_rad resprice_kernel resarea_kernel using AppendixTable5_psm核匹配2.rtf, ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    b(3) t(2) ar2 scalars(N) ///
    mtitles("Price_NN" "Area_NN" "Price_Rad" "Area_Rad" "Price_Kernel" "Area_Kernel")

