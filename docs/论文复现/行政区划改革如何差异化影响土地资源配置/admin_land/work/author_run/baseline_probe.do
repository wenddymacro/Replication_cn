clear all
set more off
set processors 1
use "数据.dta", clear
global xlist_land "lnarea i.landuse zhaopaigua landlevel cunliang lndiscity"
global xlist_city "c.lnpergdp9#i.ym c.lnmidu9#i.ym c.fiscrev9#i.ym c.yichan9#i.ym c.lnperdoctor9#i.ym"
drop if landuse!=1&landuse!=2&landuse!=3
reghdfe lnaprice internew, cluster(区代码匹配) absorb(区代码匹配 ym)
