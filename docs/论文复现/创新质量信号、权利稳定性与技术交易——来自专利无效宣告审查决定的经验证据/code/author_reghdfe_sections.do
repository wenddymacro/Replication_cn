clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
log using "logs/author_reghdfe_sections.log", text replace
use "data/author_data.dta", clear
global fe ",absorb(pt_id ipc_year age) cluster(ipc4)"
* Table 4: search-cost mechanisms
reghdfe is_first_transaction_party uphold $fe keepsingletons
reghdfe is_not_first_transaction_party uphold $fe keepsingletons
reghdfe is_new_transaction_pair uphold $fe keepsingletons
reghdfe is_existing_transaction_pair uphold $fe keepsingletons
reghdfe ln_transaction_freq uphold if early_age==1 $fe keepsingletons
reghdfe ln_transaction_freq uphold if early_age==0 $fe keepsingletons
* Table 5: contract-cost mechanisms
reghdfe firm_buyer uphold $fe keepsingletons
reghdfe not_firm_buyer uphold $fe keepsingletons
reghdfe ln_transaction_freq uphold if secrecy==1 $fe keepsingletons
reghdfe ln_transaction_freq uphold if secrecy==0 $fe keepsingletons
reghdfe ln_transaction_freq uphold if high_risk==1 $fe keepsingletons
reghdfe ln_transaction_freq uphold if high_risk==0 $fe keepsingletons
* Table 6: heterogeneity
reghdfe ln_transaction_freq uphold if aplct_person==1 $fe keepsingletons
reghdfe ln_transaction_freq uphold if aplct_person==0 $fe keepsingletons
reghdfe ln_transaction_freq uphold if claim_group==1 $fe keepsingletons
reghdfe ln_transaction_freq uphold if claim_group==0 $fe keepsingletons
reghdfe ln_transaction_freq uphold if ipc_group==1 $fe keepsingletons
reghdfe ln_transaction_freq uphold if ipc_group==0 $fe keepsingletons
* Appendix robustness: sample definitions and alternative outcomes
reghdfe ln_transaction_freq uphold if first_decision_code_pair==1 $fe
reghdfe ln_transaction_freq uphold if pair_invalidation_count==1 $fe
reghdfe ln_transaction_freq uphold if ayear>=2009 $fe
reghdfe transaction_dummy uphold $fe
reghdfe transaction_freq uphold $fe
reghdfe transaction_freq_asinh uphold $fe
reghdfe ln_transaction_freq uphold if similarity>0.7 $fe
reghdfe ln_transaction_freq uphold if similarity>0.75 $fe
reghdfe ln_transaction_freq uphold if similarity>0.8 $fe
log close
