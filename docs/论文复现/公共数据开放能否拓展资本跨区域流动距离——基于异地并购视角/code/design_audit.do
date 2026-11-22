capture log close
clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/public_data_distance"
log using "logs/design_audit.log", text replace
use "data/数据2.dta", clear
describe
summarize MaDist did year postyear treat
codebook UnderlyingCity Symbol BuyerCity
 tab year
 tab postyear
 tab treat
 tab did
 tab year treat
 duplicates report UnderlyingCity year
 foreach cmd in csdid did2s did_imputation {
   capture noisily which `cmd'
 }
log close
