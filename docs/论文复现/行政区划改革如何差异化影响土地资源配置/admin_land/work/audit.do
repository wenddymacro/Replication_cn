clear all
set more off
use "C:\Users\ASUS\Documents\ChatGPT\论文复现\replication\admin_land\original\extracted\张星铜+附件上传\数据程序\数据.dta", clear
count
describe
summ year ym internew treatnew 批复时间new, detail
tab year
tab treatnew, missing
tab 批复时间new if treatnew==1, missing
bysort 区代码匹配: egen first_treat=min(cond(treatnew==1 & internew==1, year, .))
tab first_treat, missing
