*  ==========================================================  *
*             公共数据开放能否拓展资本跨区域流动距离？
*                         ——基于异地并购视角
*
*                      蓝发钦，胡晓敏，徐卓琳
*  ==========================================================  *
* *  --------------------  软件版本   ---------------------

*   Stata/MP 17.0 for Windows (64-bit x86-64)

* *  --------------------  变量说明   ---------------------
/*
被解释变量：
	异地并购地理距离：MaDist
	
核心解释变量
	公共数开放：did

控制变量
	企业年龄：Age
	企业产权性质：Soe
	企业规模：Size
	企业资产负债率：Leverage
	企业总资产收益率：Roa
	企业现金流：Cash
	企业成长性：Growth
	企业董事会规模：Board
	企业独立董事占比：Independent
	地区人均生产总值:Gdp
	地区生产总值增长率：GdpGrowth
	地区人均自然增长率：Pop
	地区进出口占比：Trade

公共数据开放平台特点变量
	城市累计开放公共数据目录数：TtlNum
	累计无条件开放数据目录数：UnlimitNum
	累计有条件开放数据目录数：LimitNum
	更新频率：FrequencyScore
	政务服务与市场监管主题开放数据目录数：Gov
	财政税收与金融经济主题开放数据目录数：Finance
	环境保护与资源能源主题开放数据目录数：Environment
	民生服务及文化休闲主题开放数据目录数：LivelyHood
	法律主题开放数据目录数：Law
*/
*   ----------------------------------------------------------
*   -------------------   正文实证结果   ---------------------
*   ----------------------------------------------------------

*  表1 公共数据开放与异地并购地理距离分布
use 数据1.dta,clear 
global xlist "Age Soe Size Leverage Roa Cash Growth Board Independent Gdp GdpGrowth Pop Trade"
reghdfe MaDist did, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did $xlist, absorb(year Symbol) vce(cluster Symbol) 

*  表2 优化地区信息环境：公共数据开放数量、获取难度、更新时效与开放主题的影响
use 数据1.dta,clear
reghdfe MaDist did_TtlNum $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did_UnlimitNum did_LimitNum $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did_FrequencyScore $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did_gov did_finance did_environment did_livelyhood did_law $xlist, absorb(year Symbol) vce(cluster Symbol)

*  表3 优化地区信息环境：不同并购场景的异质性影响
use 数据1.dta,clear
reghdfe MaDist did did_FirstMA $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did did_MixedMA $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did did_Mng $xlist, absorb(year Symbol) vce(cluster Symbol)

*  表4 改善地方政府治理：政策不确定性与营商环境 
use 数据1.dta,clear
reghdfe MaDist did did_Uncertainty $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe Uncertainty did $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did did_Business $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe Business did $xlist, absorb(year Symbol) vce(cluster Symbol)

*  表5 提升地区禀赋优势：传统资源禀赋、创新资源禀赋与并购溢价
use 数据1.dta,clear
reghdfe MaDist did did_Energy $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did did_Wage $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe Innovation did $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe premium did $xlist, absorb(year Symbol) vce(cluster Symbol) 

*  表6 弥合地区"数字鸿沟"
use 数据1.dta,clear
reghdfe MaDist did did_Digital $xlist, absorb(year Symbol) vce(cluster Symbol)
reghdfe MaDist did did_DigitalDiff $xlist, absorb(year Symbol) vce(cluster Symbol)

*   ----------------------------------------------------------
*   -------------------   附录实证结果   ---------------------
*   ----------------------------------------------------------
use 数据2.dta,clear

*  附表3 描述性统计结果
sum2docx  MaDist did $xlist TtlNum UnlimitNum LimitNum FrequencyScore Gov Finance Environment LivelyHood Law                                        ///
          using 描述性统计结果.docx, replace                                 ///
		  stats(N mean(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f))               ///
		  title("表1  主要变量描述性统计")

*  附表4 变量相关性分析		  
logout,save("Table1_corr") word replace: ///
  pwcorr_a MaDist did $xlist, format(%9.4f)

*  附表5 多重共线性分析
use 数据2.dta,clear
reghdfe MaDist did $xlist, absorb(year Symbol) vce(cluster Symbol) resid
predict residuals, resid
regress residuals did $xlist
vif

*  附图7 平行趋势检验
use 数据2.dta,clear
gen eventyear=year-postyear
sum eventyear
bys Symbol:egen mineventyear=min(eventyear)
drop if mineventyear!=. & mineventyear>-1
bys Symbol:egen maxeventyear=max(eventyear)
drop if maxeventyear!=. & maxeventyear<1

gen event=year-postyear if treat==1
tab event
replace event=-5 if event<=-5
replace event=5 if event>=5
tab event,gen(eventt)
forvalues i = 1/11{
	replace eventt`i' = 0 if eventt`i' == .
  }
drop eventt1
reghdfe MaDist eventt* $xlist , absorb(year Symbol) vce(cluster Symbol)
coefplot, keep(eventt2 eventt3 eventt4 eventt5 eventt6 eventt7 eventt8 eventt9 eventt10 eventt11) coeflabels( eventt2 = "-4" eventt3 = "-3" eventt4 = "-2" eventt5 = "-1" eventt6 = "0" eventt7 = "1" eventt8="2" eventt9="3" eventt10="4" eventt11="5") vertical yline(0) ytitle("DID系数") xtitle("公共数据平台上线时间") addplot(line @b @at) ciopts(recast(rcap)) scheme(s1mono)

*  附图8 安慰剂检验
use 数据2.dta,clear
permute did beta = _b[did] se = _se[did] df = e(df_r) , reps(1000) rseed(123) strata(year) saving("simulations", replace): reghdfe MaDist did $xlist, absorb(year Symbol) vce(cluster Symbol)
use "simulations", clear
gen t_value = beta / se
gen p_value = 2 * ttail(df, abs(beta/se))
#delimit ;
dpplot beta, 
 xline(0.1897, lc(black*0.5) lp(dash))
 xline(0, lc(black*0.5) lp(solid))
 xlabel(-0.2(0.1)0.2)
    xtitle("估计系数", size(*0.8)) xlabel(, format(%4.2f) labsize(small))
    ytitle("系数核密度分布", size(*0.8)) ylabel(, nogrid format(%4.2f) labsize(small)) 
    note("") caption("") graphregion(fcolor(white)) scheme(s1mono);
#delimit cr

*  附表6 其他政策冲击排除
use 数据2.dta,clear
reghdfe MaDist did did_court $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did did_belt $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did did_internet $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did did_broadband $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did did_market $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did did_bigdata $xlist, absorb(year Symbol) vce(cluster Symbol) 

*  附表7 控制地区产业协同的影响
use 数据2.dta,clear
reghdfe MaDist did LQ $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did RCA $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did SI $xlist, absorb(year Symbol) vce(cluster Symbol) 
reghdfe MaDist did SD $xlist, absorb(year Symbol) vce(cluster Symbol) 

*  附表8 倾向得分匹配
use 数据2.dta,clear
set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1
psmatch2 did $xlist, outcome(MaDist) logit neighbor(3) ties common  ate caliper(0.05)
pstest, both graph saving(balancing_assumption, replace)
graph export "PSM_DID.emf", replace
reghdfe MaDist did $xlist if _support == 1, absorb(year Symbol) vce(cluster Symbol) 

*  附表8 考虑政策生效滞后性
use 数据2.dta,clear
reghdfe MaDist did1 $xlist, absorb(year Symbol) vce(cluster Symbol)  

*  附表8 增强固定效应控制
use 数据2.dta,clear
reghdfe MaDist did $xlist, absorb(year#ind Symbol) vce(cluster Symbol)

*  附表8 更新样本
use 数据3.dta,clear
reghdfe MaDist did $xlist, absorb(year Symbol) vce(cluster Symbol)