clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
log using "logs/install_dependencies.log", text replace
foreach pkg in ftools reghdfe ivreg2 ranktest ivreghdfe bdiff didplacebo eventstudyinteract event_plot ppmlhdfe csdid drdid did_imputation did2s avar {
    capture noisily ssc install `pkg', replace
}
foreach cmd in ftools reghdfe ivreg2 ranktest ivreghdfe bdiff didplacebo eventstudyinteract event_plot ppmlhdfe csdid drdid did_imputation did2s avar {
    capture noisily which `cmd'
}
log close
