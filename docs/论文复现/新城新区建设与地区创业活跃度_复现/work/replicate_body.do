version 16
clear all
set more off
set processors 1
adopath ++ "../dependencies/stata_ado"
log using "../logs/author_body.log", text replace
global cyear popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr*
tempname H
postfile `H' str12 spec str32 term double b se N r2a using "../data/author_results.dta", replace
use "city.dta", clear
gen long row_id=_n
reghdfe lnNo_GSmgfper tp $cyear, absorb(city_id prov_id##year) vce(cluster city_id)
gen byte in_sample=e(sample)
gen double tpmeanprice_gongye2007=tp*meanprice_gongye2007
gen double tplngdpper2006=tp*lngdpper2006
gen double tplngdpperpre=tp*lngdpperpre
reghdfe lnNo_GSmgfper tp  if in_sample==1, absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T2_1") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T2_1=e(sample)
reghdfe lnNo_GSmgfper tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* if in_sample==1, absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T2_2") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T2_2=e(sample)
reghdfe lnNo_GSmgfper tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* if in_sample==1, absorb(city_id prov_id##year) vce(cluster prov_id)
post `H' ("T2_3") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T2_3=e(sample)
reghdfe lnNo_GSmgfper tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* kfq , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T3_1") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
post `H' ("T3_1") ("kfq") (_b[kfq]) (_se[kfq]) (e(N)) (e(r2_a))
gen byte sample_T3_1=e(sample)
reghdfe lnNo_GSmgfper tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* cx , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T3_2") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
post `H' ("T3_2") ("cx") (_b[cx]) (_se[cx]) (e(N)) (e(r2_a))
gen byte sample_T3_2=e(sample)
reghdfe lnNo_GSmgfper tp tpmeanprice_gongye2007 popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T4_1") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
post `H' ("T4_1") ("tpmeanprice_gongye2007") (_b[tpmeanprice_gongye2007]) (_se[tpmeanprice_gongye2007]) (e(N)) (e(r2_a))
gen byte sample_T4_1=e(sample)
reghdfe lnNo_GSmgfper tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* if east==0, absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T4_2") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T4_2=e(sample)
reghdfe lnNo_GSmgfper tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* if east==1, absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T4_3") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T4_3=e(sample)
reghdfe lnNo_GSmgfper tp tplngdpper2006 popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T4_5") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
post `H' ("T4_5") ("tplngdpper2006") (_b[tplngdpper2006]) (_se[tplngdpper2006]) (e(N)) (e(r2_a))
gen byte sample_T4_5=e(sample)
reghdfe lnNo_GSmgfper tp tplngdpperpre popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T4_6") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
post `H' ("T4_6") ("tplngdpperpre") (_b[tplngdpperpre]) (_se[tplngdpperpre]) (e(N)) (e(r2_a))
gen byte sample_T4_6=e(sample)
reghdfe zhuan tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T5_1") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T5_1=e(sample)
reghdfe duo tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T5_2") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T5_2=e(sample)
reghdfe density1 tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T5_3") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T5_3=e(sample)
reghdfe density2 tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T5_4") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T5_4=e(sample)
reghdfe thirdind tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T5_5") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T5_5=e(sample)
reghdfe thirdindemp tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T5_6") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T5_6=e(sample)
reghdfe avglife tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T6_1") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T6_1=e(sample)
reghdfe life3rate tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T6_2") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T6_2=e(sample)
reghdfe ksi tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T6_3") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T6_3=e(sample)
reghdfe Score tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T6_4") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T6_4=e(sample)
reghdfe zhichu tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(city_id prov_id##year) vce(cluster city_id)
post `H' ("T6_5") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T6_5=e(sample)
gen double dist=year-firstyear
gen byte evpre2=dist==-2
gen byte evpre3=dist==-3
gen byte evpre4=dist==-4
gen byte evpre5=dist==-5
gen byte evpre6=dist==-6
gen byte evpre7=dist==-7
gen byte evpre8=dist==-8
gen byte evpost0=dist==0
gen byte evpost1=dist==1
gen byte evpost2=dist==2
gen byte evpost3=dist==3
gen byte evpost4=dist==4
gen byte evpost5=dist==5
gen byte evpost6=dist==6
gen byte evpost7=dist==7
gen byte evpost8=dist==8
reghdfe lnNo_GSmgfper $cyear evpre8 evpre7 evpre6 evpre5 evpre4 evpre3 evpre2 evpost0 evpost1 evpost2 evpost3 evpost4 evpost5 evpost6 evpost7 evpost8, absorb(city_id prov_id##year) vce(cluster city_id)
gen byte sample_F1=e(sample)
post `H' ("F1") ("evpre8") (_b[evpre8]) (_se[evpre8]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpre7") (_b[evpre7]) (_se[evpre7]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpre6") (_b[evpre6]) (_se[evpre6]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpre5") (_b[evpre5]) (_se[evpre5]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpre4") (_b[evpre4]) (_se[evpre4]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpre3") (_b[evpre3]) (_se[evpre3]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpre2") (_b[evpre2]) (_se[evpre2]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost0") (_b[evpost0]) (_se[evpost0]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost1") (_b[evpost1]) (_se[evpost1]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost2") (_b[evpost2]) (_se[evpost2]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost3") (_b[evpost3]) (_se[evpost3]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost4") (_b[evpost4]) (_se[evpost4]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost5") (_b[evpost5]) (_se[evpost5]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost6") (_b[evpost6]) (_se[evpost6]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost7") (_b[evpost7]) (_se[evpost7]) (e(N)) (e(r2_a))
post `H' ("F1") ("evpost8") (_b[evpost8]) (_se[evpost8]) (e(N)) (e(r2_a))
lincom (evpre4+evpre3+evpre2)/3
post `H' ("F1") ("pre_reported") (r(estimate)) (r(se)) (e(N)) (e(r2_a))
lincom (evpost0+evpost1+evpost2+evpost3+evpost4)/5
post `H' ("F1") ("post_reported") (r(estimate)) (r(se)) (e(N)) (e(r2_a))
keep row_id sample_*
export delimited using "../data/city_flags.csv", replace
use "city-industry.dta", clear
gen long row_id=_n
reghdfe hhi5 tp popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr* , absorb(hylb city_id prov_id##year) vce(cluster city_id)
post `H' ("T4_4") ("tp") (_b[tp]) (_se[tp]) (e(N)) (e(r2_a))
gen byte sample_T4_4=e(sample)
keep row_id sample_*
export delimited using "../data/city-industry_flags.csv", replace
postclose `H'
use "../data/author_results.dta", clear
export delimited using "../data/author_results.csv", replace
log close