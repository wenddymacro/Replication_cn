clear all
set more off
set processors 1
use "数据.dta", clear
bys 区代码匹配: egen county_treat_min=min(treatnew)
bys 区代码匹配: egen county_treat_max=max(treatnew)
bys 区代码匹配: egen county_g=min(cond(internew==1,ym,.))
bys 区代码匹配: egen county_gmax=max(cond(internew==1,ym,.))
bys 区代码匹配: keep if _n==1
count if county_treat_min!=county_treat_max
list 区代码匹配 市代码匹配 所属城市 county_treat_min county_treat_max county_g if county_treat_min!=county_treat_max, noobs abbreviate(20)
tab county_g, missing
