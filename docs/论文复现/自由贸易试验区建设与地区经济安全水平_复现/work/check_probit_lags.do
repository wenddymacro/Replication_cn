clear all
set more off
set processors 1
log using "../logs/probit_lags.log", text replace
use data1, clear
xtset id year
tempname H
postfile `H' str20 variant str32 term double b se z N converged using "../data/probit_audit.dta", replace
estimates use "../data/appendix_probit.ster"
foreach v in Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal {
 post `H' ("author_code_levels") ("`v'") (_b[`v']) (_se[`v']) (_b[`v']/_se[`v']) (e(N)) (e(converged))
}
* Paper says covariates are lagged; supplemental test only, not author-code replacement.
capture noisily xtprobit set L.(Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal), iterate(50)
if _rc==0 {
 foreach v in Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal {
  post `H' ("paper_lag_test") ("L.`v'") (_b[L.`v']) (_se[L.`v']) (_b[L.`v']/_se[L.`v']) (e(N)) (e(converged))
 }
}
postclose `H'
use "../data/probit_audit.dta", clear
export delimited using "../data/probit_audit.csv", replace
log close
