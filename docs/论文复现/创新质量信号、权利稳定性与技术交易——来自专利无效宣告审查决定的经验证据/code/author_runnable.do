* 结果复现
clear all
cd  "C:/Users/ASUS/Documents/ChatGPT/论文复现/replication/patent_quality_signal_2025"

use "data/author_data.dta", clear
global fe ",absorb(pt_id ipc_year age) cluster(ipc4)"

*================================*
***      	正文图表	       ***
*================================*

*=========== [> 表1 <] ============

// 面板A: 专利-年层级描述性统计
global panel_a_vars  transaction_dummy transaction_freq ln_transaction_freq treat
sum  $panel_a_vars

// 面板B: 专利层级描述性统计
preserve
	collapse (sum) transaction_freq (max) transaction_dummy treat, by(pt_id)
	gen ln_transaction_freq = ln(transaction_freq + 1)
	sum  $panel_a_vars
restore



*=========== [> 表2：基准回归结果 <] ============
reghdfe ln_transaction_freq uphold, absorb(pt_id year) cluster(ipc4)

reghdfe ln_transaction_freq uphold, absorb(pt_id ipc4 year age) cluster(ipc4)

reghdfe ln_transaction_freq uphold $fe



*=========== [> 图1 <] ============
graph set window fontface "Times New Roman"	
graph set window fontface "华文仿宋"	

preserve
forvalues i = 6(-1)1{
	g pre_`i' = (eventyear == -`i')
}

forvalues i = 0(1)6{
	g post_`i' = (eventyear == `i')
}

replace pre_1 = 0

reghdfe ln_transaction_freq pre_* post_* $fe
est store  event


#delimit ;
coefplot event, keep(pre_* post_*)
    level(90)
    aseq swapnames noeqlabels vertical omitted
    ciopts(recast(rcap) lc(gs0) lp(solid) lw(thin)) scale(1.2)  xscale(titlegap(tiny))      
    msize(*0.5) color(gs0)  //c(l) 
    xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0"
           8 "1"  9 "2"  10 "3"  11 "4" 12 "5"  13 "6", labsize(*0.85))
    ylabel(-0.01(0.01)0.02, angle(0) format(%4.2f) labsize(*0.85) grid)
    xline(6, lp(dash))
    yline(0, lp(dash))
    legend(off)
    xsize(6.5) ysize(4.5)
    graphregion(fcolor(gs16) lcolor(gs16)) 
    plotregion(lcolor("white") lwidth(*0.9));
#delimit cr


restore


*=========== [> 表3：工具变量内生性检验 <] ============

ivreghdfe ln_transaction_freq (uphold = iv_panel ) $fe  keepsingletons first

	

*=========== [> 表4：搜寻成本检验 <] ============
* 技术领域新买家
reghdfe is_first_transaction_party uphold  $fe keepsing

* 技术领域原有买家
reghdfe is_not_first_transaction_party uphold  $fe keepsing


* 新交易网络
reghdfe is_new_transaction_pair uphold $fe keepsing

* 原有交易网络
reghdfe is_existing_transaction_pair uphold $fe keepsing


* 专利生命周期早期
reghdfe ln_transaction_freq  uphold if early_age==1  $fe keepsing

* 专利生命周期后期
reghdfe ln_transaction_freq  uphold if early_age ==0  $fe keepsing



*=========== [> 表5：契约成本检验 <] ============
* 契约成本较高的买方
reghdfe firm_buyer  uphold  $fe keepsing

* 契约成本较低的买方
reghdfe not_firm_buyer  uphold  $fe keepsing


* 契约复杂度高
reghdfe ln_transaction_freq  uphold if secrecy == 1  $fe keepsing

* 契约复杂度低
reghdfe ln_transaction_freq  uphold if secrecy == 0  $fe keepsing

local m "reghdfe ln_transaction_freq uphold, absorb(pt_id ipc_year age) cluster(ipc4)"
bdiff,group(secrecy) model(`m') reps(500) bs first detail  


* 技术领域诉讼风险高
reghdfe ln_transaction_freq  uphold if high_risk ==1  $fe keepsing

* 技术领域诉讼风险低
reghdfe ln_transaction_freq  uphold if high_risk  ==0  $fe keepsing

local m "reghdfe ln_transaction_freq uphold, absorb(pt_id ipc_year age) cluster(ipc4)"
bdiff,group(high_risk) model(`m') reps(500) bs first detail   


*=========== [> 表6:异质性检验 <] ============

* 个人专利
reghdfe ln_transaction_freq uphold if aplct_person==1  $fe keepsing

* 非个人权利人
reghdfe ln_transaction_freq uphold if aplct_person==0  $fe keepsing

local m "reghdfe ln_transaction_freq uphold, absorb(pt_id ipc_year age) cluster(ipc4)"
bdiff,group(aplct_person) model(`m') reps(500) bs first detail 


* 权利保护范围大
reghdfe ln_transaction_freq uphold if claim_group==1  $fe keepsing

* 权利保护范围小
reghdfe ln_transaction_freq uphold if claim_group==0  $fe keepsing

local m "reghdfe ln_transaction_freq uphold, absorb(pt_id ipc_year age) cluster(ipc4)"
bdiff,group(claim_group) model(`m') reps(500) bs first detail  


* 技术复杂度高
reghdfe ln_transaction_freq uphold if ipc_group==1 $fe keepsing  

* 技术复杂度低
reghdfe ln_transaction_freq uphold if ipc_group==0 $fe keepsing  

local m "reghdfe ln_transaction_freq uphold, absorb(pt_id ipc_year age) cluster(ipc4)"
bdiff,group(ipc_group) model(`m') reps(500) bs first detail   



*================================*
***      	附录图表	       ***
*================================*

*=========== [> 附图2  <] ============
* Placebo test               
xtset pt_id year

reghdfe ln_transaction_freq uphold $fe
est store did

didplacebo did, treatvar(uphold) pbounit rep(500) seed(1)


*=========== [> 附图3  <] ============
*  Sun and Abraham (2020)
preserve
keep ln_transaction_freq uphold pt_id ipc_year age  ipc4_code treat treat_year year
replace treat_year=. if treat_year==0
gen never = (treat_year== .) 
gen eventyear= year - treat_year 

* Estimation
tsset pt_id year
sum treat_year

forvalues l = 0/6 {
	gen L`l'event = eventyear==`l'
}
forvalues l = 1/6 {
	gen F`l'event = eventyear==-`l'
}
replace F1event =0 

eventstudyinteract ln_transaction_freq F*event L*event , cohort(treat) control_cohort(never) absorb(pt_id ipc_year age) vce(cluster ipc4_code)
estimates store sa   

* Plotting 
event_plot e(b_iw)#e(V_iw), stub_lag(L#event) stub_lead(F#event) together ///
	plottype(scatter)   alpha(0.1) ///
	graph_opt(xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8) lpattern(dash)) xlabel(-6(1)6)) ///
	lag_ci_opt(color(black%45 black%45)) ///
	lag_opt(color(black) msize(small))

restore


*=========== [> 附表2：稳健性检验  <] ============

* 剔除部分无效
reghdfe ln_transaction_freq uphold if first_decision_code_pair ==1 $fe

* 剔除多次无效
reghdfe ln_transaction_freq uphold if pair_invalidation_count ==1 $fe

* 剔除专利法影响
reghdfe ln_transaction_freq uphold if ayear >= 2009 $fe

* 因变量：是否发生交易
reghdfe transaction_dummy uphold $fe

* 因变量:交易次数（原值）
reghdfe transaction_freq uphold $fe

*因变量：反正弦双曲变换
reghdfe transaction_freq_asinh uphold $fe

* 泊松回归
ppmlhdfe transaction_freq uphold,absorb(ipc_year age pt_id) irr nolog cluster(ipc4_code)



*=========== [> 附表3: 使用不同相似度匹配稳健性检验 <] ============

*控制组相似度大于0.7
reghdfe ln_transaction_freq uphold if similarity > 0.7 $fe 

*控制组相似度大于0.5
reghdfe ln_transaction_freq uphold if similarity > 0.75 $fe

*控制组相似度大于0.8
reghdfe ln_transaction_freq uphold if similarity > 0.8 $fe


