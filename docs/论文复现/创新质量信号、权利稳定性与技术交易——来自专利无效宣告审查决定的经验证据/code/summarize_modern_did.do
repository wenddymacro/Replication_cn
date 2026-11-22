set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
capture log close _all
log using "logs/modern_did_summary.log", text replace
estimates use "output/csdid_storeall.ster"
estat simple, dropmissing
estat event, window(-6 6) dropmissing saving("output/csdid_event_window.dta", replace)
log close
