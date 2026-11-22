clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
log using "logs/eventstudy_author.log", text replace
use "data/author_data.dta", clear
forvalues i = 6(-1)1 {
    gen pre_`i' = (eventyear == -`i')
}
forvalues i = 0/6 {
    gen post_`i' = (eventyear == `i')
}
replace pre_1 = 0
reghdfe ln_transaction_freq pre_* post_*, absorb(pt_id ipc_year age) cluster(ipc4)
estimates store event
coefplot event, keep(pre_* post_*) level(90) aseq swapnames noeqlabels vertical omitted ciopts(recast(rcap) lc(gs0) lp(solid) lw(thin)) scale(1.2) xscale(titlegap(tiny)) msize(*0.5) color(gs0) xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "5" 13 "6", labsize(*0.85)) ylabel(-0.01(0.01)0.02, angle(0) format(%4.2f) labsize(*0.85) grid) xline(6, lp(dash)) yline(0, lp(dash)) legend(off) xsize(6.5) ysize(4.5) graphregion(fcolor(gs16) lcolor(gs16)) plotregion(lcolor("white") lwidth(*0.9))
graph save "output/eventstudy_author.gph", replace
log close
