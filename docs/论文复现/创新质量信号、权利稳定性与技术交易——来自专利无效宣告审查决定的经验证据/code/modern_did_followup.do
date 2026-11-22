clear all
set more off
set maxvar 12000
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
capture log close _all
log using "logs/modern_did_followup.log", text replace
use "data/author_data.dta", clear

* Re-estimate Gardner two-stage DID with patent FE absorbed by unit option and year FE in first stage.
capture noisily did2s ln_transaction_freq, first_stage(i.year) second_stage(uphold) treatment(uphold) cluster(ipc4_code) unit(pt_id)
local did2src=_rc
if `did2src'==0 {
 estimates store did2s_year_fe
 estimates save "output/did2s_year_fe.ster", replace
}

* Report Callaway-Sant'Anna event-study on a common [-6,+6] window.
capture noisily estimates use "output/csdid_event.ster"
if _rc==0 {
 capture noisily estat event, window(-6 6) dropmissing
}
log close
