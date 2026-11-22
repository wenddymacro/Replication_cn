clear all
set more off
set processors 1
use "数据.dta", clear
format 批复时间new %12.0f
bys 市代码匹配: egen city_treat_min=min(treatnew)
bys 市代码匹配: egen city_treat_max=max(treatnew)
count if city_treat_min!=city_treat_max
bys 市代码匹配: egen city_g=min(cond(internew==1,ym,.))
bys 市代码匹配: keep if _n==1
count
tab city_g, missing
summ city_g, detail
list 市代码匹配 所属城市 city_treat_min city_treat_max city_g if city_treat_min!=city_treat_max, noobs
list 市代码匹配 所属城市 city_g if city_treat_min==1, noobs abbreviate(20)
