clear all
set more off
set processors 1
log using "../logs/author_models.log", text replace
use data1, clear
xtset id year
gen long row_id=_n
tempname H
postfile `H' str16 spec str36 term double b se t N r2 within_r2 using "../data/author_results.dta", replace
xtreg Eco_safe Piolt i.year, fe vce(robust)
post `H' ("B1") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_B1=e(sample)
xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("B2") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_B2=e(sample)
xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year if Direct==1, fe vce(robust)
post `H' ("B3") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_B3=e(sample)
xtreg CapitalMismatch Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M1") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M1=e(sample)
xtreg Labormismatch Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M2") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M2=e(sample)
xtreg Agg_e Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M3") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M3=e(sample)
xtreg Agg_i Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M4") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M4=e(sample)
xtreg Agg_T1 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M5") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M5=e(sample)
xtreg Agg_T2 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M6") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M6=e(sample)
xtreg Agg_T3 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M7") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M7=e(sample)
xtreg Agg_T4 Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M8") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M8=e(sample)
xtreg Healthindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M9") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M9=e(sample)
xtreg Affinityindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M10") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M10=e(sample)
xtreg Integrityindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M11") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M11=e(sample)
xtreg Ceindex Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("M12") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_M12=e(sample)
xtreg Eco_safe Treatnryear Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A3_1") ("Treatnryear") (_b[Treatnryear]) (_se[Treatnryear]) (_b[Treatnryear]/_se[Treatnryear]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A3_1=e(sample)
xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year if Pilot2020==1, fe vce(robust)
post `H' ("A3_3") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A3_3=e(sample)
xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal Boradid Tefidid i.year, fe vce(robust)
post `H' ("A3_4") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A3_4=e(sample)
xtreg Eco_safe a3 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year, fe vce(robust)
post `H' ("A4_1") ("a3") (_b[a3]) (_se[a3]) (_b[a3]/_se[a3]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A4_1=e(sample)
xtreg Eco_safe a2 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year, fe vce(robust)
post `H' ("A4_2") ("a2") (_b[a2]) (_se[a2]) (_b[a2]/_se[a2]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A4_2=e(sample)
xtreg Eco_safe a1 Popu Capi Phys Econ Infra Inter Urban Consum Act i.year, fe vce(robust)
post `H' ("A4_3") ("a1") (_b[a1]) (_se[a1]) (_b[a1]/_se[a1]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A4_3=e(sample)
xtreg Eco_safe b1 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A4_4") ("b1") (_b[b1]) (_se[b1]) (_b[b1]/_se[b1]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A4_4=e(sample)
xtreg Eco_safe b2 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A4_5") ("b2") (_b[b2]) (_se[b2]) (_b[b2]/_se[b2]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A4_5=e(sample)
xtreg Eco_safe e1 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A5_1") ("e1") (_b[e1]) (_se[e1]) (_b[e1]/_se[e1]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A5_1=e(sample)
xtreg Eco_safe e2 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A5_2") ("e2") (_b[e2]) (_se[e2]) (_b[e2]/_se[e2]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A5_2=e(sample)
xtreg Eco_safe e3 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A5_3") ("e3") (_b[e3]) (_se[e3]) (_b[e3]/_se[e3]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A5_3=e(sample)
xtreg Eco_safe e4 Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe vce(robust)
post `H' ("A5_4") ("e4") (_b[e4]) (_se[e4]) (_b[e4]/_se[e4]) (e(N)) (e(r2_o)) (e(r2_w))
gen byte sample_A5_4=e(sample)
save "../data/author_work.dta", replace
preserve
keep row_id sample_*
export delimited using "../data/sample_flags.csv", replace
restore
bootstrap, reps(500) seed(12345): xtreg Eco_safe Piolt Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal i.year, fe robust
post `H' ("A3_2") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))
gen double policy=year-action
replace policy=-6 if policy < -6
replace policy=4 if policy>4
forvalues i=6(-1)2 {
gen byte pre_`i'=(policy==-`i' & Treat==1)
}
gen byte current=(policy==0 & Treat==1)
forvalues i=1/4 {
gen byte post_`i'=(policy==`i' & Treat==1)
}
xtreg Eco_safe pre_* current post_* i.year, fe robust
post `H' ("AF1") ("pre_6") (_b[pre_6]) (_se[pre_6]) (_b[pre_6]/_se[pre_6]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("pre_5") (_b[pre_5]) (_se[pre_5]) (_b[pre_5]/_se[pre_5]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("pre_4") (_b[pre_4]) (_se[pre_4]) (_b[pre_4]/_se[pre_4]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("pre_3") (_b[pre_3]) (_se[pre_3]) (_b[pre_3]/_se[pre_3]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("pre_2") (_b[pre_2]) (_se[pre_2]) (_b[pre_2]/_se[pre_2]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("current") (_b[current]) (_se[current]) (_b[current]/_se[current]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("post_1") (_b[post_1]) (_se[post_1]) (_b[post_1]/_se[post_1]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("post_2") (_b[post_2]) (_se[post_2]) (_b[post_2]/_se[post_2]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("post_3") (_b[post_3]) (_se[post_3]) (_b[post_3]/_se[post_3]) (e(N)) (e(r2_o)) (e(r2_w))
post `H' ("AF1") ("post_4") (_b[post_4]) (_se[post_4]) (_b[post_4]/_se[post_4]) (e(N)) (e(r2_o)) (e(r2_w))
postclose `H'
use "../data/author_results.dta", clear
export delimited using "../data/author_results.csv", replace
log close