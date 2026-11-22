clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/public_data_distance"
log using "logs/stata_environment.log", text replace
about
sysdir
which reghdfe
which ftools
which esttab
log close
exit
