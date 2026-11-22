clear all
set more off
set maxvar 12000
capture log close _all
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
log using "logs/modern_did.log", text replace
use "data/author_data.dta", clear

capture drop g_cs
gen g_cs=treat_year
replace g_cs=0 if missing(g_cs)
xtset pt_id year

* Callaway-Sant'Anna (2021), never-treated comparison; multiplier bootstrap (999)
capture noisily csdid ln_transaction_freq, ivar(pt_id) time(year) gvar(g_cs) method(dr) unbalanced cluster(ipc4_code) reps(999) rseed(20261121) agg(event) dropmissing
if _rc==0 {
 estimates store csdid_event
 capture noisily estat simple
 capture noisily estat event
}

* Borusyak-Jaravel-Spiess imputation estimator; unit and year FE, same IPC4 clustering
capture noisily did_imputation ln_transaction_freq pt_id year treat_year, fe(pt_id year) cluster(ipc4_code) horizons(0/6) pretrends(6) autosample
if _rc==0 estimates store bjs

* Gardner two-stage DID; optimized patent FE and author IPC-year/age FE
capture noisily did2s ln_transaction_freq, first_stage(i.ipc_year i.age) second_stage(uphold) treatment(uphold) cluster(ipc4_code) unit(pt_id)
if _rc==0 estimates store did2s

* Correct Sun-Abraham cohort variable: original author code incorrectly passed binary treat.
preserve
keep ln_transaction_freq uphold pt_id ipc_year age ipc4_code treat treat_year year
gen never=missing(treat_year)
gen eventyear=year-treat_year
forvalues l=0/6 {
 gen L`l'event=(eventyear==`l')
}
forvalues l=1/6 {
 gen F`l'event=(eventyear==-`l')
}
replace F1event=0
capture noisily eventstudyinteract ln_transaction_freq F*event L*event, cohort(treat_year) control_cohort(never) absorb(pt_id ipc_year age) vce(cluster ipc4_code)
if _rc==0 {
 estimates store sa_corrected
 capture noisily event_plot e(b_iw)#e(V_iw), stub_lag(L#event) stub_lead(F#event) together plottype(scatter) alpha(0.1) graph_opt(xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8) lpattern(dash)) xlabel(-6(1)6)) lag_ci_opt(color(black%45 black%45)) lag_opt(color(black) msize(small))
 capture noisily graph save "output/eventstudy_sa_corrected.gph", replace
 capture noisily graph export "output/eventstudy_sa_corrected.png", replace width(1800)
}
restore
log close


