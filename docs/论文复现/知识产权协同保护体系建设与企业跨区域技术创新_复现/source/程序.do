
*  ==========================================================  *
*              知识产权协同保护体系建设与企业跨区域技术创新：              *
*                兼论制度在全国统一大市场建设中的引领作用
*
*                          韩先锋，郑酌基              *
*  ==========================================================  *

* 
*  --------------------   正文实证结果   ---------------------
*  
**使用软件：Stata 18MP

**设定控制变量
use data,clear
global xlist "size age lev invt roa fixed cash RD big4 HHI gdp pop ind gdp2 pop2 ind2"

**设定结果四位小数显示
set cformat %9.4f


//************表1A栏：基准回归*****************
use data,clear
ppmlhdfe patent protect ,a(id year)clu(city_year)nolog
ppmlhdfe patent protect $xlist ,a(id year)clu(city_year)nolog
ppmlhdfe patent protect $xlist ,a(id year hy)clu(city_year)nolog
ppmlhdfe patent protect $xlist ,a(id year hy city_id)clu(city_year)nolog


//************表1B栏：基准回归*****************
use data,clear
ppmlhdfe Knowledge1 protect $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe Knowledge2 protect $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe transfer protect $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe newpatent protect $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe nonnewpatent protect $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe influence protect $xlist ,a(id year hy city_id)clu(city_year)nolog


//***********表2A栏：研发外部性机制分析*****************
use data_3,clear
reghdfe Penalty protect gdp pop ind,a(city_id year)clu(city_year)
reghdfe Percase protect gdp pop ind,a(city_id year)clu(city_year)
reghdfe Win protect gdp pop ind,a(city_id year)clu(city_year)


//***********表2A栏：信息不对称机制分析*****************
use data,clear
reghdfe lnsubs protect $xlist ,a(id year hy city_id)clu(city_year)
reghdfe density protect $xlist ,a(id year hy city_id)clu(city_year)
reghdfe lnsubs_density protect $xlist ,a(id year hy city_id)clu(city_year)


//***********表2B栏：交易成本机制分析*****************
use data,clear
reghdfe cost1 protect $xlist ,a(id year hy city_id)clu(city_year)
reghdfe cost2 protect $xlist ,a(id year hy city_id)clu(city_year)
reghdfe cost3 protect $xlist ,a(id year hy city_id)clu(city_year)


//***********表3：基于地理空间范围的跨区域技术创新溢出效应检验****************
use data,clear
ppmlhdfe patent protect $xlist if dljl1==1,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if dljl2==1,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if dljl3==1,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if dljl4==1,a(id year hy city_id)clu(city_year)nolog


//***********表4：基于知识空间范围的跨区域技术创新溢出效应检验****************
use data,clear
ppmlhdfe patent protect $xlist if jsjl1==1,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if jsjl2==1,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if jsjl3==1,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if jsjl4==1,a(id year hy city_id)clu(city_year)nolog


//***********表5：企业跨区域技术创新的溢出方向检验****************
use data,clear
ppmlhdfe patent protect $xlist if fz1==1 ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if fz2==1 ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if fz3==1 ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if fz4==1 ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if fz5==1 ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if fz6==1 ,a(id year hy city_id)clu(city_year)nolog


//***********表6：企业跨区域技术创新的经济动机讨论****************
use data,clear
ppmlhdfe patent protect##Industrial1 $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect##Industrial2 $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect##Industrial3 $xlist ,a(id year hy city_id)clu(city_year)nolog

ppmlhdfe patent protect##WW  $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect##Merge $xlist ,a(id year hy city_id)clu(city_year)nolog


*  --------------------   附录实证结果   ---------------------

//************附表2：描述性统计*****************
use data,clear
sum patent Knowledge1 Knowledge2 transfer newpatent nonnewpatent influence protect size age lev invt roa fixed cash RD big4 HHI gdp pop ind gdp2 pop2 ind2


//************附表3：知识产权协同保护体系建设对创新结构的影响效应*****************
use data,clear
ppmlhdfe utility protect $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe totalpatent protect $xlist ,a(id year hy city_id)clu(city_year)nolog


//************附表4：知识产权保护体系建设的政策冲击差异分析*****************
use data_2,clear
ppmlhdfe Totalpatent protect_direct size age lev invt roa fixed cash RD big4 HHI gdp pop ind ,a(id year hy city_id)clu(city_year)nolog

use data,clear
ppmlhdfe patent protect_indirect  $xlist ,a(id year hy city_id)clu(city_id_year)nolog
ppmlhdfe patent protect_synergism $xlist ,a(id year hy city_id)clu(city_pair_year)nolog
//注：此处聚类到X变量的冲击维度


//***********附表5：排除同期其他竞争性政策干扰*****************
use data,clear
ppmlhdfe patent protect Modelproperty $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect Court $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect Innovationcity $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect NIIDZ $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect Freetradearea $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect hightech $xlist ,a(id year hy city_id)clu(city_year)nolog


//***********附表6：考虑处理效应异质性的稳健估计*****************
use data,clear
twowayfeweights patent id year protect ,type(feTR)
//注：使用twowayfeweights命令检验时需要删除ind开头的变量

use data,clear
csdid patent $xlist , ivar(id)time(year)gvar(gvar) method(dripw) a(id year hy city_id) agg(simple) cluster(city_year)
csdid patent $xlist , ivar(id)time(year)gvar(gvar) method(dripw) a(id year hy city_id) agg(event) cluster(city_year)


//***********附表7：其他稳健性检验*****************
use data,clear
tab year,gen(y)
tab hy,gen(h)
//注：设定年份、行业的虚拟变量

tobit patent protect $xlist h1-h17 y1-y11,ll(0) vce(cluster city_year)  
nbreg patent protect $xlist h1-h17 y1-y11,vce(cluster city_year) 
ppmlhdfe patent protect_keyindustries $xlist ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect $xlist if Non_municipalities==1 ,a(id year hy city_id)clu(city_year)nolog
ppmlhdfe patent protect_province $xlist ,a(id year hy city_id)clu(prov_id)nolog
ppmlhdfe patent protect_county $xlist ,a(id year hy city_id)clu(county_id)nolog
//注：此处聚类到X变量的冲击维度

ppmlhdfe patent protect $xlist ,a(id year hy city_id)clu(city_id2)nolog
ppmlhdfe patent protect $xlist ,a(id year hy city_id)clu(city_id2 year)nolog
ppmlhdfe patent protect $xlist ,a(id year hy city_id)clu(city_year id)nolog
ppmlhdfe patent protect $xlist ,a(id year hy city_id)clu(city_id2 id year)nolog


//************附表8：内生性检验*****************
**工具变量
use data,clear
reghdfe protect iv_1 $xlist ,a(id year hy)clu(city_year)
predict yzj_hat, xb 
ppmlhdfe patent yzj_hat $xlist ,a(id year hy)clu(city_year)nolog

reghdfe protect iv_2 $xlist ,a(id year hy)clu(city_year)
predict jdjdx_hat, xb 
ppmlhdfe patent jdjdx_hat $xlist ,a(id year hy)clu(city_year)nolog
//注：由于PPML模型尚未形成集成式工具变量命令，本文参照罗长远等(2024)、潘越等(2025)采用手工估计方式。在第一阶段使用reghdfe命令估计预测值，第二阶段使用ppmlhdfe命令将预测值与被解释变量进行回归，而后采用ivreghdfe命令进行工具变量有效性识别检验。需要说明的是，由于第一阶段估计的解释变量和被解释变量均为城市层面虚拟变量，考虑到城市固定效应可能导致的潜在共线性问题，本文在工具变量回归检验中并未纳入城市固定效应。
//工具变量有效性检验代码（由于OLS模型不适用于本文数据，因此仅需关注F值和LM值）：
//ivreghdfe patent (protect=iv_1) $xlist ,a(id year hy)clu(city_year)first
//ivreghdfe patent (protect=iv_2) $xlist ,a(id year hy)clu(city_year)first

**Heckman两阶段
use data,clear
probit treat $xlist iv_1
predict w,xb
gen imr1 = (treat==1) * (normalden(w) / normal(w))
gen imr0 = (treat==0) * (-normalden(w) / (1 - normal(w)))
ppmlhdfe patent protect imr1 imr0 $xlist ,a(id year hy city_id)clu(city_year)nolog


//************附图2：平行趋势检验*****************
use data,clear
ppmlhdfe patent d_4 d_3 d_2 current d1 d2 d3 d4 $xlist ,a(id year hy city_id)clu(city_year)nolog

coefplot, baselevels ///
keep(d_4 d_3 d_2 current d1 d2 d3 d4) ///
levels(90) vertical ///
yline(0,lcolor(edkblue*0.8)) ///
xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ///
ytitle("估计系数", size(small)) ///
xtitle("政策时点", size(small)) ///
addplot(line @b @at) ///
ciopts(lpattern(dash) recast(rcap) msize(medium)) ///
msymbol(circle_hollow) ///
scheme(s1mono)
//注：具体刻度需要手工调整优化


//************附图3：安慰剂检验*****************
use data,clear
cap program drop mypermute 
program define mypermute, rclass
    ppmlhdfe patent protect $xlist ,a(id year)clu(city_year)nolog
    matrix b = e(b)
    matrix V = e(V)
    return scalar beta = b[1,1]
    return scalar se = sqrt(V[1,1])
    return scalar df = e(N) - e(rank)  
end

permute protect beta = r(beta) se = r(se) df = r(df), ///
    reps(500) seed(223) saving("simulations.dta"): mypermute
	
	  use "simulations.dta", clear
gen t_value = beta / se
gen p_value = 2 * ttail(df, abs(beta/se))


 // 
#delimit ;
twoway 
    (scatter p_value beta, mc(blue) ms(Oh))  // 
    (kdensity beta, yaxis(2) lc(red) lp(solid)), 
    xline(0 0.3821, lc(black*0.5) lp(solid)) 
    yline(0.055, lc(black*0.5) lp(dash))
    xlabel(-0.4(0.1)0.4)
    xtitle("估计系数", size(*0.8)) 
    xlabel(, format(%4.3f) labsize(small))  // 
    ytitle("P值", size(*0.8)) 
    ylabel(, nogrid format(%4.2f) labsize(small) axis(1))
    ytitle("核密度", size(*0.8) axis(2)) 
    ylabel(, nogrid format(%4.2f) labsize(small) axis(2))
    legend(order(1 "P Value" 2 "系数核密度"))
    graphregion(color(white)) ;
#delimit cr
//注：考虑到抽取时间问题，本文采用双向固定效应模型在此估计（四重固定效应每次抽样需要20分钟，500次需要10000分钟）。每次随机抽样的结果可能存在细微差异。此外，具体颜色设计和刻度也同样需要手工调整。