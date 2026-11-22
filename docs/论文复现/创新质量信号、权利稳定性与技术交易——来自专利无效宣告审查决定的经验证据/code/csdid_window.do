clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
capture log close _all
log using "logs/csdid_window.log", text replace
use "data/author_data.dta", clear
gen g_cs=treat_year
replace g_cs=0 if missing(g_cs)
xtset pt_id year
csdid ln_transaction_freq, ivar(pt_id) time(year) gvar(g_cs) method(dr) unbalanced cluster(ipc4_code) reps(999) rseed(20261121) storeall
estimates store csdid_storeall
estimates save "output/csdid_storeall.ster", replace
estat simple, dropmissing
estat event, window(-6 6) dropmissing saving("output/csdid_event_window.dta", replace)
log close
