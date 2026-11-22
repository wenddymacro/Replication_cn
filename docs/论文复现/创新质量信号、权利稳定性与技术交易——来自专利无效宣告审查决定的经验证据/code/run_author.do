clear all
set more off
cd "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"
capture log close _all
log using "logs/author_run.log", text replace
do "code/author_runnable.do"
log close
