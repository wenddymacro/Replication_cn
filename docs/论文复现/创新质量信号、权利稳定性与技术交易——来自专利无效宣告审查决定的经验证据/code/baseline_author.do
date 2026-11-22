clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
log using "logs/baseline_author.log", text replace
use "data/author_data.dta", clear
display "Panel observations: " _N
xtset pt_id year
reghdfe ln_transaction_freq uphold, absorb(pt_id year) cluster(ipc4)
estimates store baseline1
reghdfe ln_transaction_freq uphold, absorb(pt_id ipc4 year age) cluster(ipc4)
estimates store baseline2
reghdfe ln_transaction_freq uphold, absorb(pt_id ipc_year age) cluster(ipc4)
estimates store baseline3
estimates table baseline1 baseline2 baseline3, b se stats(N r2)
log close
