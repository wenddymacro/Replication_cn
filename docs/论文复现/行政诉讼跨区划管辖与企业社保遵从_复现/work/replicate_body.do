clear all
set more off
set processors 1
adopath ++ "../dependencies/stata_ado"
log using "../logs/author_body.log", text replace
tempname H
postfile `H' str12 spec str36 term double b se N r2a using "../data/author_results.dta", replace
use data1, clear
gen long row_id=_n
quietly sum stress, meanonly
gen double ct_stress=stress-r(mean)
quietly sum gdpstress, meanonly
gen double ct_gdpstress=gdpstress-r(mean)
quietly sum liuyan, meanonly
gen double ct_liuyan=liuyan-r(mean)
reghdfe sbf court , absorb(codeid year) cluster(cityid) keepsin
post `H' ("T2_1") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T2_1=e(sample)
reghdfe sbf court size wage lev roe ocf age dual indboa nsoe, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T2_2") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T2_2=e(sample)
reghdfe sbf court size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T2_3") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T2_3=e(sample)
reghdfe sbf court dloan size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T4_1") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
post `H' ("T4_1") ("dloan") (_b[dloan]) (_se[dloan]) (e(N)) (e(r2_a))
gen byte sample_T4_1=e(sample)
reghdfe sbf court dbond size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T4_2") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
post `H' ("T4_2") ("dbond") (_b[dbond]) (_se[dbond]) (e(N)) (e(r2_a))
gen byte sample_T4_2=e(sample)
reghdfe sbf court dloanbond size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T4_3") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
post `H' ("T4_3") ("dloanbond") (_b[dloanbond]) (_se[dloanbond]) (e(N)) (e(r2_a))
gen byte sample_T4_3=e(sample)
reghdfe sbf court##c.ct_stress size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T5_1") ("1.court") (_b[1.court]) (_se[1.court]) (e(N)) (e(r2_a))
post `H' ("T5_1") ("1.court#c.ct_stress") (_b[1.court#c.ct_stress]) (_se[1.court#c.ct_stress]) (e(N)) (e(r2_a))
post `H' ("T5_1") ("ct_stress") (_b[ct_stress]) (_se[ct_stress]) (e(N)) (e(r2_a))
gen byte sample_T5_1=e(sample)
reghdfe sbf court##c.ct_gdpstress size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T5_2") ("1.court") (_b[1.court]) (_se[1.court]) (e(N)) (e(r2_a))
post `H' ("T5_2") ("1.court#c.ct_gdpstress") (_b[1.court#c.ct_gdpstress]) (_se[1.court#c.ct_gdpstress]) (e(N)) (e(r2_a))
post `H' ("T5_2") ("ct_gdpstress") (_b[ct_gdpstress]) (_se[ct_gdpstress]) (e(N)) (e(r2_a))
gen byte sample_T5_2=e(sample)
reghdfe sbf court##c.ct_liuyan size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T6_1") ("1.court") (_b[1.court]) (_se[1.court]) (e(N)) (e(r2_a))
post `H' ("T6_1") ("1.court#c.ct_liuyan") (_b[1.court#c.ct_liuyan]) (_se[1.court#c.ct_liuyan]) (e(N)) (e(r2_a))
post `H' ("T6_1") ("ct_liuyan") (_b[ct_liuyan]) (_se[ct_liuyan]) (e(N)) (e(r2_a))
post `H' ("T6_1") ("nsoe") (_b[nsoe]) (_se[nsoe]) (e(N)) (e(r2_a))
gen byte sample_T6_1=e(sample)
reghdfe sbf court##c.labor_intensity size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T6_2") ("1.court") (_b[1.court]) (_se[1.court]) (e(N)) (e(r2_a))
post `H' ("T6_2") ("1.court#c.labor_intensity") (_b[1.court#c.labor_intensity]) (_se[1.court#c.labor_intensity]) (e(N)) (e(r2_a))
post `H' ("T6_2") ("labor_intensity") (_b[labor_intensity]) (_se[labor_intensity]) (e(N)) (e(r2_a))
post `H' ("T6_2") ("nsoe") (_b[nsoe]) (_se[nsoe]) (e(N)) (e(r2_a))
gen byte sample_T6_2=e(sample)
reghdfe sbf court##c.unemployment size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T6_3") ("1.court") (_b[1.court]) (_se[1.court]) (e(N)) (e(r2_a))
post `H' ("T6_3") ("1.court#c.unemployment") (_b[1.court#c.unemployment]) (_se[1.court#c.unemployment]) (e(N)) (e(r2_a))
post `H' ("T6_3") ("unemployment") (_b[unemployment]) (_se[unemployment]) (e(N)) (e(r2_a))
post `H' ("T6_3") ("nsoe") (_b[nsoe]) (_se[nsoe]) (e(N)) (e(r2_a))
gen byte sample_T6_3=e(sample)
reghdfe sbf court##c.nsoe size wage lev roe ocf age dual indboa nsoe gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(codeid year) cluster(cityid) keepsin
post `H' ("T6_4") ("1.court") (_b[1.court]) (_se[1.court]) (e(N)) (e(r2_a))
post `H' ("T6_4") ("1.court#c.nsoe") (_b[1.court#c.nsoe]) (_se[1.court#c.nsoe]) (e(N)) (e(r2_a))
post `H' ("T6_4") ("nsoe") (_b[nsoe]) (_se[nsoe]) (e(N)) (e(r2_a))
gen byte sample_T6_4=e(sample)
keep row_id sample_*
export delimited using "../data/firm_flags.csv", replace
use data1, clear
duplicates drop cityid year, force
gen long row_id=_n
reghdfe percase1 court gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(cityid year) cluster(cityid)
post `H' ("T3_1") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T3_1=e(sample)
reghdfe percase2 court gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(cityid year) cluster(cityid)
post `H' ("T3_3") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T3_3=e(sample)
reghdfe penalty court gdp second_gdp fiscal_balance finlaon foreign_inv, absorb(cityid year) cluster(cityid)
post `H' ("T3_5") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T3_5=e(sample)
save "../data/city_author.dta", replace
keep row_id sample_*
export delimited using "../data/city_flags.csv", replace
use data2, clear
gen long row_id=_n
logit win court word_length gdp second_gdp fiscal_balance finlaon foreign_inv i.cityid i.year i.typeyg i.typebg , cluster(cityid)
post `H' ("T3_2") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T3_2=e(sample)
logit win court word_length gdp second_gdp fiscal_balance finlaon foreign_inv i.cityid i.year i.typeyg i.typebg if ifsbcase==1, cluster(cityid)
post `H' ("T3_4") ("court") (_b[court]) (_se[court]) (e(N)) (e(r2_a))
gen byte sample_T3_4=e(sample)
keep row_id sample_*
export delimited using "../data/case_flags.csv", replace
postclose `H'
use "../data/author_results.dta", clear
export delimited using "../data/author_results.csv", replace
log close