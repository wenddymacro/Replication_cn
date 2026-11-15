clear all
set more off
set processors 1
adopath ++ "../dependencies/stata_ado"
log using "../核验记录/表2_作者模型核验.log", text replace
use "../处理数据/数据1.dta", clear
gen long row_id=_n
global control_tfe "c.ecodev#i.year c.attention#i.year c.internet#i.year c.oswitch#i.year c.mobile#i.year c.fisupport#i.year"
tempname H
postfile `H' str10 spec double b se N r2 using "author_table2.dta", replace
reghdfe caput cityp size age lev cash cfo top10 sgr msh board indep qturn $control_tfe if cz==1, absorb(id year) vce(cl ids)
post `H' ("T2_1") (_b[cityp]) (_se[cityp]) (e(N)) (e(r2))
gen byte sample_T2_1=e(sample)
reghdfe caput cityp size age lev cash cfo top10 sgr msh board indep qturn $control_tfe if cz==0, absorb(id year) vce(cl ids)
post `H' ("T2_2") (_b[cityp]) (_se[cityp]) (e(N)) (e(r2))
gen byte sample_T2_2=e(sample)
reghdfe caput cityp size age lev cash cfo top10 sgr msh board indep qturn $control_tfe if xz==1, absorb(id year) vce(cl ids)
post `H' ("T2_3") (_b[cityp]) (_se[cityp]) (e(N)) (e(r2))
gen byte sample_T2_3=e(sample)
reghdfe caput cityp size age lev cash cfo top10 sgr msh board indep qturn $control_tfe if xz==0, absorb(id year) vce(cl ids)
post `H' ("T2_4") (_b[cityp]) (_se[cityp]) (e(N)) (e(r2))
gen byte sample_T2_4=e(sample)
postclose `H'
preserve
keep row_id sample_*
export delimited using "sample_flags.csv", replace
restore
use author_table2.dta, clear
export delimited using "author_table2.csv", replace
log close