clear all
set more off
set processors 1
set seed 824
capture log close
log using "../output/deterministic.log", text replace
adopath ++ "../output/local_ado"
postfile coef str20 model str100 term double b se N r2 r2_a df using "../output/coefficients.dta", replace
file open status using "../output/model_status.txt", write replace
program define collect_result
syntax, model(string)
matrix bb=e(b)
matrix vv=e(V)
local terms : colnames bb
local j=0
foreach term of local terms {
local ++j
post coef ("`model'") ("`term'") (bb[1,`j']) (sqrt(vv[`j',`j'])) (e(N)) (e(r2)) (e(r2_a)) (e(df_r))
}
estimates save "../output/`model'.ster", replace
end
*软件版本：Stata/MP 18.0 for Windows (64-bit x86-64)
use "../author/listed.dta", clear
global clist "lnage lnasset lnsize lev edu ceo"
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
display "MODEL initial_1"
capture noisily reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "initial_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("initial_1")
}
gen esample=1 if e(sample)
*====================================================================*
*==============================正文部分==============================*
*====================================================================*
*************************************************************
***                                                       ***
***                  表 1 基准回归结果                    ***
***                                                       ***
*************************************************************
/* Column 1 企业、年份固定效应 */
display "MODEL T1_1"
capture noisily reghdfe TFP chainleader , absorb(stkcd year) vce(cluster city)
local rc = _rc
file write status "T1_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T1_1")
}
capture est store e011
/* Column 2 企业、年份固定效应+企业控制变量 */
display "MODEL T1_2"
capture noisily reghdfe TFP chainleader $clist , absorb(stkcd year) vce(cluster city)
local rc = _rc
file write status "T1_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T1_2")
}
capture est store e012
/* Column 3 企业、年份固定效应+企业、城市控制变量 */
display "MODEL T1_3"
capture noisily reghdfe TFP chainleader $xlist , absorb(stkcd year) vce(cluster city)
local rc = _rc
file write status "T1_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T1_3")
}
capture est store e013
/* Column 4 企业、行业-时间、省份-时间固定效应+企业、城市控制变量 */
display "MODEL T1_4"
capture noisily reghdfe TFP chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T1_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T1_4")
}
capture est store e014
* OMITTED presentation or separate bootstrap: outreg2 [e01*] using ".\图表\表1_基准回归结果.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
*** 表 2 链长制对供应链布局调整、协调投资和交易成本的影响 ***
***                                                       ***
*************************************************************
/* Column 1 本地交易占比 */
display "MODEL T2_1"
capture noisily reghdfe local chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T2_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T2_1")
}
capture est store e021
/* Column 2 土地出让规模 */
display "MODEL T2_2"
capture noisily reghdfe lnland chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T2_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T2_2")
}
capture est store e022
/* Column 3 与获土地企业交易 */
display "MODEL T2_3"
capture noisily reghdfe local_land chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T2_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T2_3")
}
capture est store e023
/* Column 4 信息搜寻成本 */
display "MODEL T2_4"
capture noisily reghdfe searcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T2_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T2_4")
}
capture est store e024
/* Column 5 差旅谈判费用 */
display "MODEL T2_5"
capture noisily reghdfe travcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T2_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T2_5")
}
capture est store e025
/* Column 6 和解撤诉案件 */
display "MODEL T2_6"
capture noisily reghdfe clawsuit chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T2_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T2_6")
}
capture est store e026
* OMITTED presentation or separate bootstrap: outreg2 [e02*] using ".\图表\表2_链长制对供应链布局调整、协调投资和交易成本的影响.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***    表 3 链长制对本地供应链匹配质量与研发合作的影响    ***
***                                                       ***
*************************************************************
/* Column 1 应收退货和质量赔款占比 */
display "MODEL T3_1"
capture noisily reghdfe refund chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T3_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T3_1")
}
capture est store e031
/* Column 2 与本地有出口经验企业交易 */
display "MODEL T3_2"
capture noisily reghdfe local_export chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T3_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T3_2")
}
capture est store e032
/* Column 3 研发费用 */
display "MODEL T3_3"
capture noisily reghdfe lninnofee chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T3_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T3_3")
}
capture est store e033
/* Column 4 专利申请量 */
display "MODEL T3_4"
capture noisily reghdfe patent chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T3_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T3_4")
}
capture est store e034
/* Column 5 本地合作专利申请量 */
display "MODEL T3_5"
capture noisily reghdfe lpatent chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T3_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T3_5")
}
capture est store e035
/* Column 6 链上专利影响 */
display "MODEL T3_6"
capture noisily reghdfe lpatent c.chainleader##c.c_lpatent $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T3_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T3_6")
}
capture est store e036
* OMITTED presentation or separate bootstrap: outreg2 [e03*] using ".\图表\表3_链长制对本地供应链匹配质量与研发合作的影响.xls", keep(chainleader c.chainleader##c.c_lpatent) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***               表 4 适应不良风险的考察                 ***
***                                                       ***
*************************************************************
/* Column 1 产业链完善 */
display "MODEL T4_1"
capture noisily reghdfe TFP chainleader $xlist if g_clus1==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T4_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T4_1")
}
capture est store e041
/* Column 2 产业链不完善 */
display "MODEL T4_2"
capture noisily reghdfe TFP chainleader $xlist if g_clus1==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T4_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T4_2")
}
capture est store e042
/* Column 3 政商关系好 */
display "MODEL T4_3"
capture noisily reghdfe TFP chainleader $xlist if g_gc==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T4_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T4_3")
}
capture est store e043
/* Column 4 政商关系差 */
display "MODEL T4_4"
capture noisily reghdfe TFP chainleader $xlist if g_gc==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T4_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T4_4")
}
capture est store e044
/* Column 5 专用性投资低 */
display "MODEL T4_5"
capture noisily reghdfe TFP chainleader $xlist if g_contract==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T4_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T4_5")
}
capture est store e045
/* Column 6 专用性投资高 */
display "MODEL T4_6"
capture noisily reghdfe TFP chainleader $xlist if g_contract==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T4_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T4_6")
}
capture est store e046
* OMITTED presentation or separate bootstrap: outreg2 [e04*] using ".\图表\表4_适应不良风险的考察.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
//组间系数差异检验
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_clus1) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_gc) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_contract) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
*************************************************************
***                                                       ***
***           表 5 要素型协调与组织型协调的影响           ***
***                                                       ***
*************************************************************
/* Column 1 协调工具-生产率 */
display "MODEL T5_1"
capture noisily reghdfe TFP c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T5_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T5_1")
}
capture est store e051
/* Column 2 协调工具-本地布局 */
display "MODEL T5_2"
capture noisily reghdfe local c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T5_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T5_2")
}
capture est store e052
/* Column 3 协调工具-信息搜寻成本 */
display "MODEL T5_3"
capture noisily reghdfe searcost c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T5_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T5_3")
}
capture est store e053
/* Column 4 协调工具-差旅谈判成本 */
display "MODEL T5_4"
capture noisily reghdfe travcost c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T5_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T5_4")
}
capture est store e054
/* Column 5 协调工具-应收退货和质量赔款 */
display "MODEL T5_5"
capture noisily reghdfe refund c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T5_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T5_5")
}
capture est store e055
/* Column 6 协调工具-本地合作专利 */
display "MODEL T5_6"
capture noisily reghdfe lpatent c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "T5_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("T5_6")
}
capture est store e056
* OMITTED presentation or separate bootstrap: outreg2 [e05*] using ".\图表\表5_要素型协调与组织型协调的影响.xls", keep(c.chainleader#c.org c.chainleader#c.res) stats(coef se) dec(4) nolabel nocons replace
*====================================================================*
*==============================附录部分==============================*
*====================================================================*
*************************************************************
***                                                       ***
***               附表 3 链长制的微观协调                 ***
***                                                       ***
*************************************************************
/* Column 1 产业链协调词频-城市层面 */
preserve
use "../author/city.dta", clear
display "MODEL A3_1"
capture noisily reghdfe chaincol chainleader_c lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)
local rc = _rc
file write status "A3_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A3_1")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader_c) stats(coef se) dec(4) nolabel nocons replace
restore
/* Column 2 产业链协作补贴 */
display "MODEL A3_2"
capture noisily reghdfe q_chainsub chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A3_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A3_2")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
/* Column 3 服务对接次数 */
display "MODEL A3_3"
capture noisily reghdfe survey chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A3_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A3_3")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
/* Column 4 行业组织-城市层面 */
preserve
use "../author/city.dta", clear
display "MODEL A3_4"
capture noisily reghdfe socialorg chainleader_c lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)
local rc = _rc
file write status "A3_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A3_4")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader_c) stats(coef se) dec(4) nolabel nocons append
restore
//注：为与企业层面政策变量chainleader相区分，代码中城市层面的政策变量命名为chainleader_c。
*************************************************************
***                                                       ***
***               附图 1 & 2 补贴与信贷变化               ***
***                                                       ***
*************************************************************
//补贴总额
bys treat year: egen subsidy_m=mean(subsidy)
twoway (line subsidy_m year if treat==1, lcolor(black) lpattern(solid))  (line subsidy_m year if treat==0, lcolor(black) lpattern(dash))  ,  legend(label(1 `"{fontface "宋体":处理组}"')  label(2 `"{fontface "宋体":控制组}"')  ring(0) pos(1) col(1))  xscale(range(2013.5 2023.5))  xtitle(`"{fontface "宋体":年份}"')  ytitle(`"{fontface "宋体":补贴总额（万元）}"')  xlabel(2014(1)2023)  graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
graph export "../output/附图1_处理组和控制组补贴总额变化趋势.png", as(png) replace
//产业链补贴
bys treat year: egen chainsub_m=mean(chainsub)
twoway (line chainsub_m year if treat==1, lcolor(black) lpattern(solid))  (line chainsub_m year if treat==0, lcolor(black) lpattern(dash))  ,  legend(label(1 `"{fontface "宋体":处理组}"')  label(2 `"{fontface "宋体":控制组}"')  ring(0) pos(1) col(1))  xscale(range(2013.5 2024))  xtitle(`"{fontface "宋体":年份}"')  ytitle(`"{fontface "宋体":产业链协作补贴额（万元）}"')  xlabel(2014(1)2023)  graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
graph export "../output/附图1_处理组和控制组产业链协作补贴额变化趋势.png", as(png) replace
//借款总额
bys treat year: egen loan_m=mean(loan)
twoway (line loan_m year if treat==1, lcolor(black) lpattern(solid))  (line loan_m year if treat==0, lcolor(black) lpattern(dash))  ,  legend(label(1 `"{fontface "宋体":处理组}"')  label(2 `"{fontface "宋体":控制组}"')  ring(0) pos(1) col(1))  xscale(range(2013.5 2023.5))  xtitle(`"{fontface "宋体":年份}"')  ytitle(`"{fontface "宋体":借款总额（万元）}"')  xlabel(2014(1)2023)  graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
graph export "../output/附图2_处理组和控制组借款总额变化趋势.png", as(png) replace
//长期借款占比
bys treat year: egen q_longloan_m=mean(q_longloan)
twoway (line q_longloan_m year if treat==1, lcolor(black) lpattern(solid))  (line q_longloan_m year if treat==0, lcolor(black) lpattern(dash))  ,  legend(label(1 `"{fontface "宋体":处理组}"')  label(2 `"{fontface "宋体":控制组}"')  ring(0) pos(1) col(1))  xscale(range(2013.5 2023.5))  xtitle(`"{fontface "宋体":年份}"')  ytitle(`"{fontface "宋体":长期借款占总负债比例}"')  xlabel(2014(1)2023)  graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
graph export "../output/附图2_处理组和控制组长期借款占比变化趋势.png", as(png) replace
*************************************************************
***                                                       ***
***           附表 4 基于税调数据样本的补充检验           ***
***                                                       ***
*************************************************************
* SKIPPED: tax survey data not supplied
//囿于税调数据包含大量企业敏感的财务与税务信息，我们仅提供分析代码。
*************************************************************
***                                                       ***
***              附表 5 主要变量描述性统计                ***
***                                                       ***
*************************************************************
preserve
replace gdppc=gdppc/10000                      //万元
replace asset = asset/100000000	               //亿元
replace innofee = innofee/100000000	           //亿元
replace size = size/10000	                   //万人
order TFP chainleader asset size age lev ceo edu gdppc secondary govexp ftd local land local_land searcost travcost clawsuit refund local_export innofee patent lpatent
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表5_主要变量描述性统计.xls", replace sum(log) dec(4) keep(TFP chainleader asset size age lev ceo edu gdppc secondary govexp ftd local land local_land searcost travcost clawsuit refund local_export innofee patent lpatent)
restore
*************************************************************
***                                                       ***
***                  附图 4 平行趋势检验                  ***
***                                                       ***
*************************************************************
preserve
global num1=4
global num2=3
gen event=year-chainleader_l
tab chainleader_l
tab event
replace event=-$num1 if event<=-$num1
replace event=$num2 if event>=$num2
forvalues i=$num1(-1)1{
gen pre`i'=0
replace pre`i'=1 if event==-`i'
}
forvalues i=0(1)$num2{
gen post`i'=0
replace post`i'=1 if event==`i'
}
display "MODEL A5_1"
capture noisily reghdfe TFP pre$num1-pre2 post0-post$num2 pre1 $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A5_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A5_1")
}
capture est store ec_ols_1
event_plot ec_ols_1, stub_lag(post#) stub_lead(pre#) shift(0) plottype(scatter) together alpha(0.05) noautolegend ciplottype(rcap)  graph_opt(xline(0, lcolor(black%45) lpattern(dash)) yline(0, lcolor(black%45)) graphregion(color(white)) bgcolor(white) xscale(range(-4.5(1)3.5)) xlabel(-4(1)3, labsize(4)) ylabel(,format(%3.2f) angle(0) labsize(4)) ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"' `"{fontface "宋体":系}"' `"{fontface "宋体":数}"',orientation(horizontal) size(4)) xtitle(`"{fontface "宋体":时期}"',size(4))  legend(label(1 `"{fontface "宋体":估计系数值}"') label(2 `"{fontface "宋体":置信区间}"') row(1) col(2) ring(1) pos(6) region(lcolor(black)) size(4)) xsize(10) ysize(5))  lag_opt1(msymbol(d) color(black) msize(1.8)) lag_ci_opt1(color(black) lwidth(0.4))
graph export "../output/附图4_平行趋势检验.png", as(png) replace
restore
*************************************************************
***                                                       ***
***           附表 6 & 附图 5 Goodman-Bacon分解           ***
***                                                       ***
*************************************************************
* Modern estimators and Bacon decomposition: separate runner
*************************************************************
***                                                       ***
***              附表 7 处理组自选择问题检验              ***
***                                                       ***
*************************************************************
//第（1）—（3）列-城市层面
preserve
use "../author/city.dta", clear
keep if year>=2014 & year<=2016
display "MODEL A7_1"
capture noisily reghdfe treat city_TFP lngdppc secondary govexp ftd, absorb(prv) vce(cluster city)
local rc = _rc
file write status "A7_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A7_1")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(city_TFP lngdppc secondary govexp ftd) stats(coef se) dec(4) nolabel nocons replace
restore
preserve
use "../author/city.dta", clear
keep if year>=2014 & year<=2016
display "MODEL A7_2"
capture noisily reghdfe treat city_TFP_gr lngdppc secondary govexp ftd, absorb(prv) vce(cluster city)
local rc = _rc
file write status "A7_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A7_2")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(city_TFP_gr lngdppc secondary govexp ftd) stats(coef se) dec(4) nolabel nocons append
restore
preserve
use "../author/city.dta", clear
keep if year==2014
display "MODEL A7_3"
capture noisily reghdfe treat city_TFP_chg lngdppc secondary govexp ftd, absorb(prv) vce(cluster city)
local rc = _rc
file write status "A7_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A7_3")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(city_TFP_chg lngdppc secondary govexp ftd) stats(coef se) dec(4) nolabel nocons append
restore
//第（4）—（6）列-企业层面
preserve
keep if year>=2014 & year<=2016
display "MODEL A7_4"
capture noisily reghdfe treat TFP $xlist, absorb(prv indid) vce(cluster city)
local rc = _rc
file write status "A7_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A7_4")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(TFP $xlist) stats(coef se) dec(4) nolabel nocons append
restore
preserve
keep if year>=2014 & year<=2016
display "MODEL A7_5"
capture noisily reghdfe treat TFP_gr $xlist, absorb(prv indid) vce(cluster city)
local rc = _rc
file write status "A7_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A7_5")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(TFP_gr $xlist) stats(coef se) dec(4) nolabel nocons append
restore
preserve
keep if year==2014
display "MODEL A7_6"
capture noisily reghdfe treat TFP_chg $xlist, absorb(prv indid) vce(cluster city)
local rc = _rc
file write status "A7_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A7_6")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(TFP_chg $xlist) stats(coef se) dec(4) nolabel nocons append
restore
*************************************************************
***                                                       ***
***           附表 8 基于事前生产率趋势的分组回归         ***
***                                                       ***
*************************************************************
/* Column 1 城市事前生产率增速-高 */
display "MODEL A8_1"
capture noisily reghdfe TFP chainleader $xlist if g_cTFP_d==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A8_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A8_1")
}
capture est store ef081
/* Column 2 城市事前生产率增速-低 */
display "MODEL A8_2"
capture noisily reghdfe TFP chainleader $xlist if g_cTFP_d==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A8_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A8_2")
}
capture est store ef082
/* Column 3 行业小类事前生产率增速-高 */
display "MODEL A8_3"
capture noisily reghdfe TFP chainleader $xlist if g_sTFP_d==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A8_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A8_3")
}
capture est store ef083
/* Column 4 行业小类事前生产率增速-低 */
display "MODEL A8_4"
capture noisily reghdfe TFP chainleader $xlist if g_sTFP_d==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A8_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A8_4")
}
capture est store ef084
/* Column 5 行业中类事前生产率增速-高 */
display "MODEL A8_5"
capture noisily reghdfe TFP chainleader $xlist if g_mTFP_d==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A8_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A8_5")
}
capture est store ef085
/* Column 6 行业中类事前生产率增速-低 */
display "MODEL A8_6"
capture noisily reghdfe TFP chainleader $xlist if g_mTFP_d==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A8_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A8_6")
}
capture est store ef086
* OMITTED presentation or separate bootstrap: outreg2 [ef08*] using ".\图表\附表8_基于事前生产率趋势的分组回归.xls", keep(chainleader) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***        附表 9 基于考核压力和晋升激励的分组检验        ***
***                                                       ***
*************************************************************
/* Column 1 考核压力-高 */
display "MODEL A9_1"
capture noisily reghdfe TFP chainleader $xlist if g_perf==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A9_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A9_1")
}
capture est store ef091
/* Column 2 考核压力-低 */
display "MODEL A9_2"
capture noisily reghdfe TFP chainleader $xlist if g_perf==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A9_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A9_2")
}
capture est store ef092
/* Column 3 晋升激励-高 */
display "MODEL A9_3"
capture noisily reghdfe TFP chainleader $xlist if g_promo==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A9_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A9_3")
}
capture est store ef093
/* Column 4 晋升激励-低 */
display "MODEL A9_4"
capture noisily reghdfe TFP chainleader $xlist if g_promo==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A9_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A9_4")
}
capture est store ef094
* OMITTED presentation or separate bootstrap: outreg2 [ef09*] using ".\图表\附表9_基于考核压力和晋升激励的分组检验.xls", keep(chainleader) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***       附表 10 仅保留严格响应上层推动样本的检验        ***
***                                                       ***
*************************************************************
/* Column 1 剔除先于省份实施 */
display "MODEL A10_1"
capture noisily reghdfe TFP chainleader_na $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A10_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A10_1")
}
capture est store ef101
/* Column 2 剔除省份最早实施 */
display "MODEL A10_2"
capture noisily reghdfe TFP chainleader_nf $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A10_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A10_2")
}
capture est store ef102
/* Column 3 同省份密集实施 */
display "MODEL A10_3"
capture noisily reghdfe TFP chainleader_f $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A10_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A10_3")
}
capture est store ef103
* OMITTED presentation or separate bootstrap: outreg2 [ef10*] using ".\图表\附表10_仅保留严格响应上层推动样本的检验.xls", keep(chainleader_na chainleader_nf chainleader_f) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***              附表 11 调整处理组识别方法1              ***
***                                                       ***
*************************************************************
/* Column 1 链条解构匹配 */
display "MODEL A11_1"
capture noisily reghdfe TFP chainleader_d $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A11_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A11_1")
}
capture est store ef111
/* Column 2 匹配主营业务 */
display "MODEL A11_2"
capture noisily reghdfe TFP chainleader_m $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A11_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A11_2")
}
capture est store ef112
/* Column 3 剔除综合行业 */
display "MODEL A11_3"
capture noisily reghdfe TFP chainleader $xlist if ind_d~="S", absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A11_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A11_3")
}
capture est store ef113
/* Column 4 语义匹配 */
display "MODEL A11_4"
capture noisily reghdfe TFP chainleader_k $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A11_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A11_4")
}
capture est store ef114
/* Column 5 与LLM并集 */
display "MODEL A11_5"
capture noisily reghdfe TFP chainleader_kw $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A11_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A11_5")
}
capture est store ef115
/* Column 6 与LLM交集 */
display "MODEL A11_6"
capture noisily reghdfe TFP chainleader_kt $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A11_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A11_6")
}
capture est store ef116
* OMITTED presentation or separate bootstrap: outreg2 [ef11*] using ".\图表\附表11_调整处理组识别方法1.xls", keep(chainleader_d chainleader_m chainleader chainleader_k chainleader_kw chainleader_kt) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***              附表 12 调整处理组识别方法2              ***
***                                                       ***
*************************************************************
/* Column 1 保留模糊词 */
display "MODEL A12_1"
capture noisily reghdfe TFP chainleader_w1 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A12_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A12_1")
}
capture est store ef121
/* Column 2 剔除模糊词 */
display "MODEL A12_2"
capture noisily reghdfe TFP chainleader_t1 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A12_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A12_2")
}
capture est store ef122
/* Column 3 任一年匹配 */
display "MODEL A12_3"
capture noisily reghdfe TFP chainleader_w2 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A12_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A12_3")
}
capture est store ef123
/* Column 4 全年份匹配 */
display "MODEL A12_4"
capture noisily reghdfe TFP chainleader_t2 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A12_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A12_4")
}
capture est store ef124
* OMITTED presentation or separate bootstrap: outreg2 [ef12*] using ".\图表\附表12_调整处理组识别方法2.xls", keep(chainleader_w1 chainleader_t1 chainleader_w2 chainleader_t2) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***            附表 13 排除同期冲击与替代解释1            ***
***                                                       ***
*************************************************************
/* Column 1 控制突发公共卫生事件 */
display "MODEL A13_1"
capture noisily reghdfe TFP chainleader lncovid $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A13_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A13_1")
}
capture est store ef131
/* Column 2 控制出口管制 */
display "MODEL A13_2"
capture noisily reghdfe TFP chainleader BIS $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A13_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A13_2")
}
capture est store ef132
/* Column 3 控制纵向一体化 */
display "MODEL A13_3"
capture noisily reghdfe TFP chainleader vas $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A13_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A13_3")
}
capture est store ef133
/* Column 4 控制纵向并购 */
display "MODEL A13_4"
capture noisily reghdfe TFP chainleader merge $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A13_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A13_4")
}
capture est store ef134
/* Column 5 控制书记变更 */
display "MODEL A13_5"
capture noisily reghdfe TFP chainleader $xlist d_mps if year<=2022, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A13_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A13_5")
}
capture est store ef135
/* Column 6 控制市长变更 */
display "MODEL A13_6"
capture noisily reghdfe TFP chainleader $xlist d_mayor if year<=2022, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A13_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A13_6")
}
capture est store ef136
* OMITTED presentation or separate bootstrap: outreg2 [ef13*] using ".\图表\附表13_排除同期冲击与替代解释1.xls", keep(chainleader lncovid BIS vas merge d_mps d_mayor) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***            附表 14 排除同期冲击与替代解释2            ***
***                                                       ***
*************************************************************
/* Column 1 控制五年规划 */
display "MODEL A14_1"
capture noisily reghdfe TFP chainleader plan $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A14_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A14_1")
}
capture est store ef141
/* Column 2 控制开发区政策 */
display "MODEL A14_2"
capture noisily reghdfe TFP chainleader lndevezone $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A14_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A14_2")
}
capture est store ef142
/* Column 3 控制创新集群政策 */
display "MODEL A14_3"
capture noisily reghdfe TFP chainleader techzone $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A14_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A14_3")
}
capture est store ef143
/* Column 4 控制央企链长 */
display "MODEL A14_4"
capture noisily reghdfe TFP chainleader firm_cl $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A14_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A14_4")
}
capture est store ef144
* OMITTED presentation or separate bootstrap: outreg2 [ef14*] using ".\图表\附表14_排除同期冲击与替代解释2.xls", keep(chainleader plan lndevezone techzone firm_cl) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***                附表 15 溢出效应检验1                  ***
***                                                       ***
*************************************************************
global W_controls "W_lnage W_lnasset W_lnsize W_lev W_edu W_ceo W_lngdppc W_secondary W_govexp W_ftd"
/* Column 1 溢出效应检验 */
display "MODEL A15_1"
capture noisily reghdfe TFP chainleader LocalSpill SpatialSpill100 SpatialSpill200 SpatialSpill300 $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A15_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A15_1")
}
capture est store ef151
/* Column 2 空间滞后模型SLX */
display "MODEL A15_2"
capture noisily reghdfe TFP chainleader W_chainleader $xlist $W_controls, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A15_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A15_2")
}
capture est store ef152
/* Column 3 空间杜宾模型SDM */
display "MODEL A15_3"
capture noisily ivreghdfe TFP chainleader W_chainleader $xlist $W_controls (W_TFP = W2_chainleader), absorb(stkcd prv#year indid#year) cluster(city)
local rc = _rc
file write status "A15_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A15_3")
}
capture est store ef153
* OMITTED presentation or separate bootstrap: outreg2 [ef15*] using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader LocalSpill SpatialSpill100 SpatialSpill200 SpatialSpill300 W_chainleader W_TFP) stats(coef se) dec(4) nolabel nocons replace
/* Column 4-6 空间相关标准误 */
preserve
egen indid_year = group(indid year)
drop if missing(纬度) | missing(经度)
* Spatial HAC handled separately: acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(100) pfe1(stkcd) pfe2(indid_year) dropsingletons
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
* Spatial HAC handled separately: acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(200) pfe1(stkcd) pfe2(indid_year) dropsingletons
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
* Spatial HAC handled separately: acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(300) pfe1(stkcd) pfe2(indid_year) dropsingletons
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
restore
*************************************************************
***                                                       ***
***                附表 16 溢出效应检验2                  ***
***                                                       ***
*************************************************************
/* Column 1 控制组:同城市非实施产业链 */
display "MODEL A16_1"
capture noisily reghdfe TFP chainleader $xlist if c_city_nind==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A16_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A16_1")
}
capture est store ef161
/* Column 2 控制组:非实施城市 */
display "MODEL A16_2"
capture noisily reghdfe TFP chainleader $xlist if c_ncity==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A16_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A16_2")
}
capture est store ef162
/* Column 3 控制组:实施行业非实施城市 */
display "MODEL A16_3"
capture noisily reghdfe TFP chainleader $xlist if c_ncity_ind==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A16_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A16_3")
}
capture est store ef163
/* Column 4 与本地的外地迁入企业交易占总交易数比*/
display "MODEL A16_4"
capture noisily reghdfe local_in chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A16_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A16_4")
}
capture est store ef164
/* Column 5 与本地的外地迁入企业交易占本地交易数比*/
display "MODEL A16_5"
capture noisily reghdfe local_inl chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A16_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A16_5")
}
capture est store ef165
* OMITTED presentation or separate bootstrap: outreg2 [ef16*] using ".\图表\附表16_溢出效应检验2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***                附表 17 溢出效应检验3                  ***
***                                                       ***
*************************************************************
preserve
use "../author/city.dta", clear
/* Column 1 企业进入 */
display "MODEL A17_1"
capture noisily reghdfe lnnewreg chainleader_c SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)
local rc = _rc
file write status "A17_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A17_1")
}
capture est store ef171
/* Column 2 发明专利 */
display "MODEL A17_2"
capture noisily reghdfe lncity_patent chainleader_c SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)
local rc = _rc
file write status "A17_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A17_2")
}
capture est store ef172
/* Column 3 企业进入-未实施链长制地区 */
display "MODEL A17_3"
capture noisily reghdfe lnnewreg SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd if treat==0, absorb(city year) vce(cluster city)
local rc = _rc
file write status "A17_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A17_3")
}
capture est store ef173
/* Column 4 发明专利-未实施链长制地区 */
display "MODEL A17_4"
capture noisily reghdfe lncity_patent SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd if treat==0, absorb(city year) vce(cluster city)
local rc = _rc
file write status "A17_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A17_4")
}
capture est store ef174
* OMITTED presentation or separate bootstrap: outreg2 [ef17*] using ".\图表\附表17_溢出效应检验3.xls", keep(chainleader_c SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300) stats(coef se) dec(4) nolabel nocons replace
restore
*************************************************************
***                                                       ***
***                附表 18 其他稳健性检验1                ***
***                                                       ***
*************************************************************
/* Column 1 更换OP法 */
display "MODEL A18_1"
capture noisily reghdfe TFP_OP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_1")
}
capture est store ef181
/* Column 2 更换ACF法 */
display "MODEL A18_2"
capture noisily reghdfe TFP_ACF chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_2")
}
capture est store ef182
/* Column 3 更换GMM法 */
display "MODEL A18_3"
capture noisily reghdfe TFP_GMM chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_3")
}
capture est store ef183
/* Column 4 市场份额 */
display "MODEL A18_4"
capture noisily reghdfe MS chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_4")
}
capture est store ef184
/* Column 5 市场加成率 */
display "MODEL A18_5"
capture noisily reghdfe PMR chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_5")
}
capture est store ef185
/* Column 6 控制市场份额 */
display "MODEL A18_6"
capture noisily reghdfe TFP chainleader MS $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_6")
}
capture est store ef186
/* Column 7 控制价格加成率 */
display "MODEL A18_7"
capture noisily reghdfe TFP chainleader PMR $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A18_7 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A18_7")
}
capture est store ef187
* OMITTED presentation or separate bootstrap: outreg2 [ef18*] using ".\图表\附表18_其他稳健性检验1.xls", keep(chainleader MS PMR) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***                 附表 19 其他稳健性检验2               ***
***                                                       ***
*************************************************************
/* Column 1 更换核心解释变量（下半年推后） */
display "MODEL A19_1"
capture noisily reghdfe TFP chainleader_h $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_1")
}
capture est store ef191
/* Column 2 更换核心解释变量（以政府工作报告和政府文件中更早年份）*/
display "MODEL A19_2"
capture noisily reghdfe TFP chainleader_r $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_2")
}
capture est store ef192
/* Column 3 剔除上市公司少于5家城市 */
display "MODEL A19_3"
capture noisily reghdfe TFP chainleader $xlist if m_firm>=5, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_3")
}
capture est store ef193
/* Column 4 剔除上市公司少于10家城市 */
display "MODEL A19_4"
capture noisily reghdfe TFP chainleader $xlist if m_firm>=10, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_4")
}
capture est store ef194
* OMITTED presentation or separate bootstrap: outreg2 [ef19*] using ".\图表\附表19_其他稳健性检验2.xls", keep(chainleader_h chainleader_r chainleader) stats(coef se) dec(4) nolabel nocons replace
/* Column 5 改变样本窗口 */
preserve
use "../author/listed_extended.dta", clear
display "MODEL A19_5"
capture noisily reghdfe TFP chainleader $xlist if zxs~=1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_5")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表19_其他稳健性检验2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
restore
/* Column 6 未剔除直辖市 */
preserve
use "../author/listed_extended.dta", clear
display "MODEL A19_6"
capture noisily reghdfe TFP chainleader $xlist if year>=2014, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_6")
}
* OMITTED presentation or separate bootstrap: outreg2 using ".\图表\附表19_其他稳健性检验2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
restore
*************************************************************
***                                                       ***
***                 附图 7 异质性分析结果                 ***
***                                                       ***
*************************************************************
//行业门类-分组
foreach var in A B C D E F G I K L M N Q R S {
display "MODEL A19_7_`var'"
capture noisily reghdfe TFP chainleader $xlist if ind_d=="`var'", absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_7_`var' rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_7_`var'")
}
capture est store e1`var'
}
//合并建筑业(E)和房地产业(K)
display "MODEL A19_8"
capture noisily reghdfe TFP chainleader $xlist if ind_d=="E" | ind_d=="K", absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_8 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_8")
}
capture est store e1EK
//合并其他服务业(L M N P Q R)
display "MODEL A19_9"
capture noisily reghdfe TFP chainleader $xlist if ind_d=="L" | ind_d=="M" | ind_d=="N" | ind_d=="P" | ind_d=="Q" | ind_d=="R", absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_9 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_9")
}
capture est store e1QT
coefplot e1A || e1B || e1C || e1D || e1F || e1G || e1I || e1EK || e1QT,  keep(chainleader)  xline(0)  levels(90)  graphregion(color(white))  bycoefs byopts(xrescale)  ylabel(1 `"{fontface "宋体":农、林、牧、渔业}"'  2 `"{fontface "宋体":采矿业}"'  3 `"{fontface "宋体":制造业}"'  4 `"{fontface "宋体":电力、热力、燃气及水生产和供应业}"'  5 `"{fontface "宋体":批发和零售业}"'  6 `"{fontface "宋体":交通运输、仓储和邮政业}"'  7 `"{fontface "宋体":信息传输、软件和信息技术服务业}"'  8 `"{fontface "宋体":建筑业和房地产业}"'  9 `"{fontface "宋体":其他服务业}"', angle(horizontal))  xlabel(-1(0.5)1)  msize(small)  mcolor(black)  lcolor(black)  lpattern(solid)  ciopts(lcolor(black) lpattern(solid))  xscale(range(-1 1))  legend(off)  name(coefplot_chain, replace)
graph export "../output/附图7_行业异质性分析结果a.png", as(png) replace
//制造业-分组
foreach var in C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 C28 C29 C30 C31 C32 C33 C34 C35 C36 C37 C38 C39 C40 C41 C42 {
display "MODEL A19_10_`var'"
capture noisily reghdfe TFP chainleader $xlist if ind=="`var'", absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A19_10_`var' rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A19_10_`var'")
}
capture est store e1`var'
}
coefplot e1C13 || e1C14 || e1C15 || e1C17 || e1C18 || e1C19 || e1C21 || e1C22 || e1C23 || e1C24 || e1C25 || e1C26 || e1C27 || e1C28 || e1C29 || e1C30 || e1C31 || e1C32 || e1C33 || e1C34 || e1C35 || e1C36 || e1C37 || e1C38 || e1C39 || e1C40 || e1C41,  keep(chainleader)  xline(0)  levels(90)  graphregion(color(white))  bycoefs byopts(xrescale)  ylabel(1 `"{fontface "宋体":农副食品加工业}"'  2 `"{fontface "宋体":食品制造业}"'  3 `"{fontface "宋体":酒、饮料和精制茶制造业}"'  4 `"{fontface "宋体":纺织业}"'  5 `"{fontface "宋体":纺织服装、服饰业}"'  6 `"{fontface "宋体":皮革、毛皮、羽毛及其制品和制鞋业}"'  7 `"{fontface "宋体":家具制造业}"'  8 `"{fontface "宋体":造纸及纸制品业}"'  9 `"{fontface "宋体":印刷和记录媒介复制业}"'  10 `"{fontface "宋体":文教、工美、体育和娱乐用品制造业}"'  11 `"{fontface "宋体":石油加工、炼焦及核燃料加工业}"'  12 `"{fontface "宋体":化学原料及化学制品制造业}"'  13 `"{fontface "宋体":医药制造业}"'  14 `"{fontface "宋体":化学纤维制造业}"'  15 `"{fontface "宋体":橡胶和塑料制品业}"'  16 `"{fontface "宋体":非金属矿物制品业}"'  17 `"{fontface "宋体":黑色金属冶炼及压延加工业}"'  18 `"{fontface "宋体":有色金属冶炼及压延加工业}"'  19 `"{fontface "宋体":金属制品业}"'  20 `"{fontface "宋体":通用设备制造业}"'  21 `"{fontface "宋体":专用设备制造业}"'  22 `"{fontface "宋体":汽车制造业}"'  23 `"{fontface "宋体":铁路、船舶、航空航天和其它运输设备制造业}"'  24 `"{fontface "宋体":电气机械及器材制造业}"'  25 `"{fontface "宋体":计算机、通信和其他电子设备制造业}"'  26 `"{fontface "宋体":仪器仪表制造业}"'  27 `"{fontface "宋体":其他制造业}"', angle(horizontal))  xlabel(-1(0.5)1)  msize(small)  mcolor(black)  lcolor(black)  lpattern(solid)  ciopts(lcolor(black) lpattern(solid))  xscale(range(-1 1))  legend(off)  name(coefplot_chain, replace)
graph export "../output/附图7_行业异质性分析结果b.png", as(png) replace
*************************************************************
***                                                       ***
***             附表 20 行业异质性的原因分析              ***
***                                                       ***
*************************************************************
/* Column 1 外部风险-高 */
display "MODEL A20_1"
capture noisily reghdfe TFP chainleader $xlist if g_incf==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_1")
}
capture est store ef201
/* Column 2 外部风险-低 */
display "MODEL A20_2"
capture noisily reghdfe TFP chainleader $xlist if g_incf==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_2")
}
capture est store ef202
/* Column 3 技术密集-高 */
display "MODEL A20_3"
capture noisily reghdfe TFP chainleader $xlist if g_tech==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_3")
}
capture est store ef203
/* Column 4 技术密集-低 */
display "MODEL A20_4"
capture noisily reghdfe TFP chainleader $xlist if g_tech==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_4")
}
capture est store ef204
/* Column 5 产业链上游 */
display "MODEL A20_5"
capture noisily reghdfe TFP chainleader $xlist if g_pos==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_5")
}
capture est store ef205
/* Column 6 产业链中下游 */
display "MODEL A20_6"
capture noisily reghdfe TFP chainleader $xlist if g_pos==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_6")
}
capture est store ef206
/* Column 7 行业竞争程度-高 */
display "MODEL A20_7"
capture noisily reghdfe TFP chainleader $xlist if g_hhl==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_7 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_7")
}
capture est store ef207
/* Column 8 行业竞争程度-低 */
display "MODEL A20_8"
capture noisily reghdfe TFP chainleader $xlist if g_hhl==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A20_8 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A20_8")
}
capture est store ef208
* OMITTED presentation or separate bootstrap: outreg2 [ef20*] using ".\图表\附表20_行业异质性的原因分析.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***             附表 21 减少交易摩擦的补充证据            ***
***                                                       ***
*************************************************************
/* Column 1 管理与销售成本 */
display "MODEL A21_1"
capture noisily reghdfe cost_ms chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_1")
}
capture est store ef211
/* Column 2 管理与销售成本-剔除无关项 */
display "MODEL A21_2"
capture noisily reghdfe cost_t chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_2")
}
capture est store ef212
/* Column 3 管理与销售成本-控制战略变革 */
display "MODEL A21_3"
capture noisily reghdfe cost_ms chainleader strategy $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_3")
}
capture est store ef213
/* Column 4 管理与销售成本-控制业务调整 */
display "MODEL A21_4"
capture noisily reghdfe cost_ms chainleader change $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_4")
}
capture est store ef214
/* Column 5 履约监督费用 */
display "MODEL A21_5"
capture noisily reghdfe supcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_5")
}
capture est store ef215
/* Column 6 三项费用加和 */
display "MODEL A21_6"
capture noisily reghdfe totalcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_6")
}
capture est store ef216
/* Column 7 上市公司原告 */
display "MODEL A21_7"
capture noisily reghdfe clawsuit_y chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_7 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_7")
}
capture est store ef217
/* Column 8 上市公司被告 */
display "MODEL A21_8"
capture noisily reghdfe clawsuit_b chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A21_8 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A21_8")
}
capture est store ef218
* OMITTED presentation or separate bootstrap: outreg2 [ef21*] using ".\图表\附表21_减少交易摩擦的补充证据.xls", keep(chainleader strategy change) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***        附表 22 改善本地供应链匹配质量的补充证据       ***
***                                                       ***
*************************************************************
/* Column 1 交易对象平均劳动生产率 */
display "MODEL A22_1"
capture noisily reghdfe profitpc chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A22_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A22_1")
}
capture est store ef221
/* Column 2 与本地高新技术企业交易 */
display "MODEL A22_2"
capture noisily reghdfe local_hte chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A22_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A22_2")
}
capture est store ef222
/* Column 3 与本地专精特新企业交易 */
display "MODEL A22_3"
capture noisily reghdfe local_si chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A22_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A22_3")
}
capture est store ef223
* OMITTED presentation or separate bootstrap: outreg2 [ef22*] using ".\图表\附表22_改善本地供应链匹配质量的补充证据.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***            附表 23 适应不良风险的补充证据1            ***
***                                                       ***
*************************************************************
/* Column 1 产业配套-好 */
display "MODEL A23_1"
capture noisily reghdfe TFP chainleader $xlist if g_clus2==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A23_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A23_1")
}
capture est store ef231
/* Column 2 产业配套-差 */
display "MODEL A23_2"
capture noisily reghdfe TFP chainleader $xlist if g_clus2==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A23_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A23_2")
}
capture est store ef232
/* Column 3 市委书记调整频率-低 */
display "MODEL A23_3"
capture noisily reghdfe TFP chainleader $xlist if g_mps==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A23_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A23_3")
}
capture est store ef233
/* Column 4 市委书记调整频率-高 */
display "MODEL A23_4"
capture noisily reghdfe TFP chainleader $xlist if g_mps==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A23_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A23_4")
}
capture est store ef234
/* Column 5 市长调整频率-低 */
display "MODEL A23_5"
capture noisily reghdfe TFP chainleader $xlist if g_mayor==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A23_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A23_5")
}
capture est store ef235
/* Column 6 市长调整频率-高 */
display "MODEL A23_6"
capture noisily reghdfe TFP chainleader $xlist if g_mayor==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A23_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A23_6")
}
capture est store ef236
* OMITTED presentation or separate bootstrap: outreg2 [ef23*] using ".\图表\附表23_适应不良风险的补充证据1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
//组间系数差异检验
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_clus2) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_mps) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_mayor) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
*************************************************************
***                                                       ***
***            附表 24 适应不良风险的补充证据2            ***
***                                                       ***
*************************************************************
/* Column 1 本地采购-低 */
display "MODEL A24_1"
capture noisily reghdfe TFP chainleader $xlist if g_govpur==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A24_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A24_1")
}
capture est store ef241
/* Column 2 本地采购-高 */
display "MODEL A24_2"
capture noisily reghdfe TFP chainleader $xlist if g_govpur==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A24_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A24_2")
}
capture est store ef242
/* Column 3 市属国企占比-低 */
display "MODEL A24_3"
capture noisily reghdfe TFP chainleader $xlist if g_mstate==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A24_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A24_3")
}
capture est store ef243
/* Column 4 市属国企占比-高 */
display "MODEL A24_4"
capture noisily reghdfe TFP chainleader $xlist if g_mstate==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A24_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A24_4")
}
capture est store ef244
/* Column 5 有历史交易经验 */
display "MODEL A24_5"
capture noisily reghdfe TFP chainleader $xlist if  g_lpast==1, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A24_5 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A24_5")
}
capture est store ef245
/* Column 6 无历史交易经验 */
display "MODEL A24_6"
capture noisily reghdfe TFP chainleader $xlist if  g_lpast==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A24_6 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A24_6")
}
capture est store ef246
* OMITTED presentation or separate bootstrap: outreg2 [ef24*] using ".\图表\附表24_适应不良风险的补充证据2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
//组间系数差异检验
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_govpur) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_mstate) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
xtset, clear
xtset city
* OMITTED presentation or separate bootstrap: bdiff, group(g_lpast) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
*************************************************************
***                                                       ***
***     附表 26 要素型协调与组织型协调的影响：补充证据    ***
***                                                       ***
*************************************************************
/* Column 1 产业链协作补贴 */
display "MODEL A26_1"
capture noisily reghdfe q_chainsub c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A26_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A26_1")
}
capture est store ef261
/* Column 2 调研对接次数 */
display "MODEL A26_2"
capture noisily reghdfe survey c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A26_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A26_2")
}
capture est store ef262
* OMITTED presentation or separate bootstrap: outreg2 [ef26*] using ".\图表\附表26_要素型协调与组织型协调的影响：补充证据.xls", keep(c.chainleader#c.res c.chainleader#c.org) stats(coef se) dec(4) nolabel nocons replace
*************************************************************
***                                                       ***
***             附表 27 政策设计与差异化战略              ***
***                                                       ***
*************************************************************
/* Column 1 产业链规划数量 */
display "MODEL A27_1"
capture noisily reghdfe TFP c.chainleader#c.num_h c.chainleader#c.num_l $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A27_1 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A27_1")
}
capture est store ef271
/* Column 2 发展战略 */
display "MODEL A27_2"
capture noisily reghdfe TFP c.chainleader#c.adv_h c.chainleader#c.adv_l $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A27_2 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A27_2")
}
capture est store ef272
/* Column 3 发展战略-经济发达 */
display "MODEL A27_3"
capture noisily reghdfe TFP c.chainleader#c.adv_h c.chainleader#c.adv_l $xlist if g_gdp==1 , absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A27_3 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A27_3")
}
capture est store ef273
/* Column 4 发展战略-经济欠发达 */
display "MODEL A27_4"
capture noisily reghdfe TFP c.chainleader#c.adv_h c.chainleader#c.adv_l $xlist if g_gdp==0, absorb(stkcd prv#year indid#year) vce(cluster city)
local rc = _rc
file write status "A27_4 rc=" (`rc') _n
if `rc' == 0 {
collect_result, model("A27_4")
}
capture est store ef274
* OMITTED presentation or separate bootstrap: outreg2 [ef27*] using ".\图表\附表27_政策设计与差异化战略.xls", keep(c.chainleader#c.num_h c.chainleader#c.num_l c.chainleader#c.adv_h c.chainleader#c.adv_l) stats(coef se) dec(4) nolabel nocons replace
postclose coef
file close status
use "../output/coefficients.dta", clear
export delimited using "../output/coefficients.csv", replace
display "REPLICATION_DETERMINISTIC_COMPLETE"
log close
