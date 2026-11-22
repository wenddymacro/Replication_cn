clear all
set more off
set processors 1
use "数据.dta", clear
bys 区代码匹配: egen county_treat_min=min(treatnew)
bys 区代码匹配: egen county_treat_max=max(treatnew)
count if county_treat_min!=county_treat_max
bys 区代码匹配: egen county_g=min(cond(internew==1,ym,.))
bys 区代码匹配: egen county_gmax=max(cond(internew==1,ym,.))
count if county_g!=county_gmax & county_g<.
bys 区代码匹配: keep if _n==1
tab county_g, missing
count
count if county_treat_min==0
count if county_treat_min==1 & county_g<.
count if county_treat_min==1 & county_g==.
