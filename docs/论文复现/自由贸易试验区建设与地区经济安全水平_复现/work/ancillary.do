clear all
set more off
set processors 1
log using "../logs/ancillary.log", text replace
use data1, clear
xtset id year
xtprobit set Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal
estimates save "../data/appendix_probit", replace
summarize Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal
* Separate reproducible placebo seed: original program does not specify one here.
set seed 12345
drop if missing(id,year)
tempfile base ids years matched
save `base'
tempname H
postfile `H' int draw double b se p using "../data/placebo.dta", replace
forvalues i=1/500 {
 quietly {
  use `base', clear
  keep if year==2008
  sample 44, count
  keep id
  save `ids', replace
  merge 1:m id using `base'
  gen byte treat1=(_merge==3)
  drop _merge
  save `matched', replace
  use `base', clear
  bsample 1, strata(id)
  keep year
  mkmat year, matrix(sampleYear)
  use `matched', clear
  xtset id year
  gen byte time1=0
  forvalues j=1/258 {
   replace time1=1 if id==`j' & year>=sampleYear[`j',1]
  }
  gen byte did1=treat1*time1
  xtreg Eco_safe did1 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year, fe robust
  post `H' (`i') (_b[did1]) (_se[did1]) (2*ttail(e(N)-e(df_m)-1,abs(_b[did1]/_se[did1])))
 }
}
postclose `H'
use "../data/placebo.dta", clear
export delimited using "../data/placebo.csv", replace
log close
