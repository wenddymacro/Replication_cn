clear all
set more off
set processors 1
adopath ++ "../output/local_ado"
log using "../output/spatial.log", text replace
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
egen indid_year=group(indid year)
drop if missing(纬度) | missing(经度)
postfile spatial int radius double b se N r2 using "../output/spatial.dta", replace
foreach radius in 100 200 300 {
display "SPATIAL_RADIUS `radius'"
capture noisily acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(`radius') pfe1(stkcd) pfe2(indid_year) dropsingletons
local rc=_rc
display "SPATIAL_RC `radius' `rc'"
if `rc'==0 {
post spatial (`radius') (_b[chainleader]) (_se[chainleader]) (e(N)) (e(r2))
estimates save "../output/spatial_`radius'.ster", replace
}
}
postclose spatial
use "../output/spatial.dta", clear
export delimited using "../output/spatial.csv", replace
display "COMPLETE_spatial"
log close
