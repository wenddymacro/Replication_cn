***图1
use 附图1.dta
twoway line PatentNumber year if Treat==0 & year>=2010, sort || ///
line PatentNumber year if Treat==1 & year>=2010, sort lpattern(dash) ///
legend(label(1 "{stSans:对照组}") label(2 "{stSans:实验组}")  cols(1) position(10) ring(0)) ///
ylabel(0(5)20,labsize(*0.75) format(%02.1f) angle(horizontal)) ///
xlabel(2010(1)2021,labsize(*0.75)) ///
xline(2013, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
xline(2014, lwidth(vthin) lpattern(dash) lcolor(green)) ///
xline(2017, lwidth(vthin) lpattern(dash) lcolor(blue))
***1
use Benchmark.dta
outreg2 using Table-Decriptive.doc, replace sum(log) dec(4) keep(KeyTech DID Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
***2
use Benchmark.dta
keep if Treat==0 & year<2013
outreg2 using Table-2013-对照组-政策前-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==1 & year<2013
outreg2 using Table-2013-控制组-政策前-statistics.doc, replace sum(log) dec(4) keep(KeyTech Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==0 & year>=2013
outreg2 using Table1-2013-对照组-政策后-statistics.doc, replace sum(log) dec(4) keep(KeyTech Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==1 & year>=2013
outreg2 using Table1-2013-控制组-政策后-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==0 & year<2014
outreg2 using Table1-2014-对照组-政策前-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==1 & year<2014
outreg2 using Table1-2014-控制组-政策前-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==0 & year>=2014
outreg2 using Table1-2014-对照组-政策后--statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==1 & year>=2014
outreg2 using Table1-2014-控制组-政策后-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==0 & year<2017
outreg2 using Table1-2017-对照组-政策前-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==1 & year<2017
outreg2 using Table1-2017-控制组-政策前-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==0 & year>=2017
outreg2 using Table1-2017-对照组-政策后-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
use Benchmark.dta,clear
keep if Treat==1 & year>=2017
outreg2 using Table1-2017-控制组-政策后-statistics.doc, replace sum(log) dec(4) keep(KeyTech  Area Pgdp Population Industrilazion Government Agglomeration) title(Decriptive statistics)
***3
use Benchmark.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
global control_lag "Area_lag Pgdp_lag Population_lag Industrilazion_lag Government_lag Agglomeration_lag"
reghdfe KeyTech DID, a(id year) vce(r)
reghdfe KeyTech DID $control_county, a(id year) vce(r)
reghdfe KeyTech_w DID $control_county, a(id year) vce(r)
reghdfe KeyTech DID $control_lag, a(id year) vce(r)
***图2
use 附图2.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe KeyTech pre*  current  post* $control_county , a(id year) vce(r)
coefplot, baselevels ///
keep(pre* current post*) ///
vertical ///
coeflabels( pre4 = "-4" ///
pre3 = "-3" ///
pre2 = "-2" ///
current = "0" ///
post1 = "1" ///
post2 = "2" ///
post3 = "3" ///
post4 = "4" ///
post5 = "5") ///
yline(0,lcolor(edkblue*0.8)) ///
ylabel(-5(5)10,labsize(*0.75) format(%02.1f) angle(horizontal)) ///
xline(10, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
xlabel(,labsize(*0.75)) ///
addplot(line @b @at) ///
ytitle("{stSans:关}" "{stSans:键}""{stSans:核}" "{stSans:心}""{stSans:技}" "{stSans:术}", size(medsmall) orientation(h))           ///
xtitle("{stSans:政策时点}",    ///
size(medsmall))    ///
levels(95)    ///
ciopts(lpattern(dash) recast(rcap) msize(medium)) ///
msymbol(circle_hollow) ///
plotregion(style(none))    ///
scheme(s1mono)

***4
use Robust.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe lnpat DID $control_county, a(id year) vce(r)
reghdfe lnqual DID $control_county, a(id year) vce(r)
reghdfe KeyTech DID $control_county Dig_delevement, a(id year) vce(r)
reghdfe KeyTech DID $control_county, a(id year county_year) vce(r)
reghdfe KeyTech stagged $control_county, a(id year) vce(r)
***5
use 政策干扰.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe KeyTech c.DID##c.Broad $control_county, a(id year) vce(r)
reghdfe KeyTech c.DID##c.Smart $control_county, a(id year) vce(r)
reghdfe KeyTech T1 DID T2 Treat_group $control_county, a(id year) vce(r)
reghdfe KeyTech DID $control_county if ZXS==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if ZHSYQ==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if TC==0, a(id year) vce(r)
***6
use Counterfactual.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe KeyTech DID_13 $control_county, a(id year) vce(r)
reghdfe KeyTech DID_14 $control_county, a(id year) vce(r)
reghdfe KeyTech DID_17 $control_county, a(id year) vce(r)
reghdfe KeyTech DID_fss $control_county, a(id year) vce(r)
***7
use CSDID.dta
csdid KeyTech if year>=2010, ivar(id) time(year) gvar(reformyear) method(dripw) agg(event) notyet
csdid KeyTech , ivar(id) time(year) gvar(reformyear) method(stdipw) agg(simple)
***8
*注：实现结果请按照如下两步进行：
*1)按照如下步骤安装正版软件：
Step1 R 官方下载地址：https://cran.r-project.org/mirrors.html
Step2 选择镜像：根据IP选择适合镜像
Step3 选择下载类型：base
Tips：安装路径中不要包括中文字符，以减少不必要的错误！
Step4 RStudio 官方下载地址：https://posit.co/download/rstudio-desktop/
Tips：请保证是Win10+或MacOS12+正版电脑系统
Step5 Gurobi 官方下载地址：https://www.gurobi.com/academia/academic-program-and-licenses/
Tips：请使用教育机构提供的邮箱地址验证
Step6 从上述官网获取注册号注册激活
*2)按照如下Code在R中进行复现：
library(synthdid)
library(ggplot2)
set.seed(12345)
data('Benchmark')
setup = panel.matrices(Benchmark)
tau.hat = synthdid_estimate(setup$Y, setup$N0, setup$T0)
print(summary(tau.hat))
se = sqrt(vcov(tau.hat, method='placebo'))
sprintf('point estimate: %1.2f', tau.hat)
***9
use Mechanism.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe KeyTech Cospecialize DID $control_county, a(id year) vce(r)
test  Cospecialize=0
reghdfe KeyTech Diffusion DID $control_county, a(id year) vce(r)
test  Diffusion=0
reghdfe KeyTech Efficiency DID $control_county, a(id year) vce(r)
test  Efficiency=0
reghdfe KeyTech Cospecialize Diffusion Efficiency DID $control_county, a(id year) vce(r)
test  Cospecialize+Diffusion+Efficiency=0
***10
use Heterogeneity.dta
global control_county "Area Pgdp Population Industrilazion Government Agg"
reghdfe KeyTech DID $control_county if YGD==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if YGD==1, a(id year) vce(r)
reghdfe KeyTech DID $control_county if WB==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if WB==1, a(id year) vce(r)
reghdfe KeyTech DID $control_county if AI==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if AI==1, a(id year) vce(r)


