capture log close
clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/public_data_distance/data"
log using "../logs/author_full.log", text replace
do "../code/author_original.do"
log close
