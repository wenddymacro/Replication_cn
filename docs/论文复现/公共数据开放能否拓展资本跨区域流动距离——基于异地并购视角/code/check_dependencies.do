capture log close
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/public_data_distance"
log using "logs/dependencies.log", text replace
foreach cmd in reghdfe sum2docx logout pwcorr_a coefplot dpplot psmatch2 {
    capture noisily which `cmd'
}
log close
