capture log close
clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/public_data_distance"
log using "logs/baseline_author.log", text replace
use "data/data1.dta", clear
describe
count
summarize MaDist did
duplicates report Symbol year
global xlist "Age Soe Size Leverage Roa Cash Growth Board Independent Gdp GdpGrowth Pop Trade"
reghdfe MaDist did, absorb(year Symbol) vce(cluster Symbol)
estimates store col1
reghdfe MaDist did $xlist, absorb(year Symbol) vce(cluster Symbol)
estimates store col2
log close
