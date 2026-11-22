clear all
set more off
set processors 1
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/admin_land/work/author_run"
use "数据.dta", clear
global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"
drop if landuse!=1&landuse!=2&landuse!=3
reghdfe lnaprice internew $xlist_land, cluster(区代码匹配) absorb(区代码匹配 ym $xlist_city)
gen author_esample=e(sample)
keep if author_esample
keep lnaprice internew 区代码匹配 ym
save "analysis_sample.dta", replace
export delimited using "analysis_sample.csv", replace
log close _all
