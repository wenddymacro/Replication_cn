clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
log using "logs/preflight.log", text replace
about
foreach cmd in reghdfe ivreghdfe bdiff didplacebo eventstudyinteract event_plot ppmlhdfe {
    capture noisily which `cmd'
}
use "data/author_data.dta", clear
describe
summarize ln_transaction_freq uphold transaction_dummy transaction_freq treat treat_year year eventyear ipc4
count
xtset pt_id year
log close
