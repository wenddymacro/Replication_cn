**文章题目：产业转移、产业链供应链优化与企业异地合作创新****************************

 
 *======================================
version 16（StataSE）
drop _all
set more off
clear all

 *==============================================================================
global control1 RDSpendSum  Far Roe Growth Size  Cash_as lnpergdp Finance1 consume1 educ struc1
global control2 c.RDSpendSum_initial#i.year c.Far_initial#i.year c.Roe_initial#i.year c.Size_initial#i.year c.Cash_as_initial#i.year c.Growth_initial#i.year c.lnpergdp_2007#i.year c.Finance1_2007#i.year c.consume1_2007#i.year c.educ_2007#i.year c.struc1_2007#i.year
//安装必要的程序包；若需要安装reghdfe，请运行下列代码；若已经安装reghdfe，请忽略
// ssc install reghdfe, replace


/////////////////////////////////表1//////////////////////////////////
///////////////////////////////第（1）列///////////////////////////////
reghdfe lnapp did, absorb(year id) vce(cl city_num) 
est store m1
///////////////////////////////第（2）列///////////////////////////////	
reghdfe lnapp did  $control1, absorb(year id ) vce(cl city_num)
est store m2
///////////////////////////////第（3）列///////////////////////////////	
reghdfe lnapp did  $control2, absorb(year id ) vce(cl city_num) 
est store m3
///////////////////////////////第（4）列///////////////////////////////	
reghdfe ihs_cro_app did, absorb(year id) vce(cl city_num)
est store m4
///////////////////////////////第（5）列///////////////////////////////	
reghdfe ihs_cro_app did  $control1, absorb(year id ) vce(cl city_num)
est store m5
///////////////////////////////第（6）列///////////////////////////////	
reghdfe ihs_cro_app did  $control2, absorb(year id ) vce(cl city_num)
est store m6
esttab m1 m2 m3 m4 m5 m6,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 


/////////////////////////////////表2//////////////////////////////////
///////////////////////////////第（1）列///////////////////////////////
reghdfe lnapp did $control1 if Spec_Division==1, absorb(year id) vce(cl city_num) 
est store m1
///////////////////////////////第（2）列///////////////////////////////
reghdfe lnapp did $control1 if Spec_Division==0 , absorb(year id) vce(cl city_num)
est store m2
///////////////////////////////第（3）列///////////////////////////////
reghdfe TFP_LP 专业化分工  $control1, absorb(year id ) vce(cl id)  //3、4列均为企业层面的回归，因此标准误聚类在企业层面
est store m3
///////////////////////////////第（4）列///////////////////////////////
reghdfe TFP_OP 专业化分工  $control1, absorb(year id ) vce(cl id)
est store m4
esttab m1 m2 m3 m4,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 


/////////////////////////////////表3//////////////////////////////////
///////////////////////////////第（1）列///////////////////////////////
reghdfe lnapp did $control1 if Cus_Stability==1, absorb(year id) vce(cl city_num)  
est store m1 
///////////////////////////////第（2）列///////////////////////////////
reghdfe lnapp did $control1 if Cus_Stability==0 , absorb(year id) vce(cl city_num)
est store m2 
///////////////////////////////第（3）列///////////////////////////////
reghdfe lnapp did $control1 if Supp_Stability==1, absorb(year id) vce(cl city_num) 
est store m3  
///////////////////////////////第（4）列///////////////////////////////
reghdfe lnapp did $control1 if Supp_Stability==0 , absorb(year id) vce(cl city_num) 
est store m4 
esttab m1 m2 m3 m4,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 
bdiff, group(Supp_Stability) model(reghdfe lnapp did $control1 ,absorb(year id) vce(cl city_num)) reps(500) bs first  //Empirical p-value =  0.040


/////////////////////////////////表4//////////////////////////////////
///////////////////////////////第（1）列///////////////////////////////
**供应链韧性和效率指标为反向指标，即数值越大，供应链韧性/效率则越低
reghdfe lnapp did $control1 if SC_Resilience==0, absorb(id year) vce(cl city_num) 
est store m1 
///////////////////////////////第（2）列///////////////////////////////
reghdfe lnapp did $control1 if SC_Resilience==1, absorb(id year) vce(cl city_num) 
est store m2 
///////////////////////////////第（3）列///////////////////////////////
reghdfe lnapp did $control1 if SC_Resilience1==0, absorb(id year) vce(cl city_num) 
est store m3 
///////////////////////////////第（4）列///////////////////////////////
reghdfe lnapp did $control1 if SC_Resilience1==1, absorb(id year) vce(cl city_num) 
est store m4 
///////////////////////////////第（5）列///////////////////////////////
reghdfe lnapp did $control1 if SC_Efficiency==0, absorb(year id) vce(cl city_num)  
est store m5  
///////////////////////////////第（6）列///////////////////////////////
reghdfe lnapp did $control1 if SC_Efficiency==1 , absorb(year id) vce(cl city_num) 
est store m6 
esttab m1 m2 m3 m4 m5 m6,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 



/////////////////////////////////表5//////////////////////////////////
///////////////////////////////第（1）列///////////////////////////////
reghdfe ln新兴产业 did $control1, absorb(year id ) vce(cl city_num)
est store m1
///////////////////////////////第（2）列///////////////////////////////  
reghdfe ln数字核心 did $control1, absorb(year id ) vce(cl city_num) 
est store m2 
///////////////////////////////第（3）列/////////////////////////////// 
reghdfe ln清洁能源 did $control1, absorb(year id ) vce(cl city_num) 
est store m3 
///////////////////////////////第（4）列///////////////////////////////  
reghdfe ln清洁生产 did $control1, absorb(year id ) vce(cl city_num) 
est store m4 


///////////////////////////////第（5）列///////////////////////////////  
reghdfe ihs_新兴产业 did $control1, absorb(year id ) vce(cl city_num) 
est store m5 
///////////////////////////////第（6）列/////////////////////////////// 
reghdfe ihs_数字核心 did $control1, absorb(year id ) vce(cl city_num) 
est store m6  
///////////////////////////////第（7）列///////////////////////////////
reghdfe ihs_清洁能源 did $control1, absorb(year id ) vce(cl city_num) 
est store m7 
///////////////////////////////第（8）列///////////////////////////////  
reghdfe ihs_清洁生产 did $control1, absorb(year id ) vce(cl city_num)  
est store m8 
esttab m1 m2 m3 m4 m5 m6 m7 m8,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 



/////////////////////////////////图1//////////////////////////////////
twoway ///
    (connected mean_lnapp year if group==1, ///
        lcolor(gs0) lwidth(medium) ///
        mcolor(gs0) mfcolor(gs3) ///
        msymbol(diamond) msize(medium)) ///
    (connected mean_lnapp year if group==0, ///
        lcolor(gs8) lwidth(medium) ///
        mcolor(gs8) mfcolor(gs10) ///
        msymbol(circle) msize(medium)), ///
	xline(2010, lcolor(black) lwidth(medium) lpattern(dash)) ///
    ytitle("企业异地联合申请专利数", size(medium) margin(r=2)) ///
    xtitle("") ///
    xlabel(2007(1)2021, angle(90) tposition(inside) labsize(11pt)) ///
	ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4",format(%9.2f) angle(0) tposition(inside) labsize(11pt) labcolor(black) labgap(2)) ///
    legend(order(1 "处理组" 2 "对照组") ///
           pos(4) ring(0) cols(1) size(medium)) ///
    graphregion(color(white) lcolor(white)) ///
    plotregion(margin(t=8 r=3) color(white) lcolor(black) lwidth(thick)) ///
    xscale(lwidth(0.5)) yscale(lwidth(0.5)) ///
    xtick(2007(1)2021, tlength(1) tposition(inside))

*===============================================================================

/////////////////////////////////附表1//////////////////////////////////
sum cro_application  did  $control1

/////////////////////////////////附图1//////////////////////////////////
use 平行趋势图.dta, clear
set scheme s1mono
twoway ///
(rcap max90 min90 horizon, lcolor(gs6)) ///
(scatter estimate horizon, ///
    msymbol(Oh) ///
    mcolor(black)) ///
(line estimate horizon, ///
    lcolor(black) ///
    lpattern(solid)), ///
xtitle("相对时期") ///
ytitle("系数") ///
xlabel(-3(1)5, labsize(small)) ///
ylabel(-0.6(0.2)1.0, labsize(small) angle(horizontal)) ///
xline(0, lc(gs8) lp(dash)) ///
yline(0, lc(gs8) lp(dash)) ///
graphregion(color(white)) ///
legend(off)

/////////////////////////////////附表2//////////////////////////////////
preserve
*【剔除2014年之后上市的公司样本】
reghdfe lnapp did        $control1 if 公司上市年份<=2014, absorb(year id ) vce(cl city_num) 
est store m1
reghdfe ihs_cro_app did  $control1 if 公司上市年份<=2014, absorb(year id ) vce(cl city_num) 
est store m2
restore 
*【排除其他政策干扰】
reghdfe lnapp did        $control1 innovation, absorb(year id ) vce(cl city_num)
est store m3
reghdfe ihs_cro_app did  $control1 innovation, absorb(year id ) vce(cl city_num)
est store m4
*【增加固定效应】
reghdfe lnapp       did  $control1, absorb(year id i.year#i.ind_code_num) vce(cl city_num)
est store m5
reghdfe ihs_cro_app did  $control1, absorb(year id i.year#i.ind_code_num) vce(cl city_num)
est store m6
*【调整聚类维度】
reghdfe lnapp did        $control1, absorb(year id ) vce(cl year#ind_code_num)
est store m7
reghdfe ihs_cro_app did  $control1, absorb(year id ) vce(cl year#ind_code_num)
est store m8 
*【泊松回归】
ppmlhdfe cro_application did $control1, absorb(year id ) vce(cl city_num)  
est store m9
*【专利强度】
reghdfe appli_intens did  $control1, absorb(year id ) vce(cl city_num) 
est store m10
*【PSM-DID】
set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1
psmatch2 group $control1, outcome(lnapp) logit neighbor(2) ties common ate caliper(0.05)
reghdfe lnapp did $control1 if _support == 1, absorb(year id) vce(cl city_num)
est store m1
reghdfe ihs_cro_app did $control1 if _support == 1, absorb(year id) vce(cl city_num)
est store m2
*【调整划分方式】
drop if province == "北京市" | province == "天津市" | province == "河北省" | province == "辽宁省" | province == "上海市" | province == "江苏省" | province == "浙江省" | province == "福建省" | province == "山东省" | province == "广东省" | province == "海南省"
bysort id (city): gen city_change = (city[1] != city[_N])  
drop if city_change == 1  
drop city_change  
reghdfe lnapp did  $control1, absorb(year id ) vce(cl city_num)
est store m3
reghdfe ihs_cro_app did  $control1, absorb(year id ) vce(cl city_num)
est store m4


/////////////////////////////////附图2//////////////////////////////////
local y_var lnapp    
foreach y in `y_var'{
	qui reghdfe lnapp $control1, absorb(year id ) vce(cl city_num) 
	permute post beta=_b[c.group#c.post],reps(500) saving("安慰剂检验_随机处理年份.dta",replace) : reghdfe `y' c.group#c.post $control1, absorb(year id ) vce(cl city_num)
	permute group beta=_b[c.group#c.post],reps(500) saving("安慰剂检验_随机处理个体.dta",replace) : reghdfe `y' c.group#c.post $control1, absorb(year id ) vce(cl city_num)
}
local random 随机处理年份 
foreach ran in `random'{
	use "安慰剂检验_`ran'.dta",clear
dpplot beta, xline(0.28, lc(black%70) lp(shortdash) lwidth(thin)) xline(0, lc(black%80) lwidth(thin) lp(shortdash)) xtitle("估计系数", size(*0.8)) xlabel(-0.40 "-0.4" -0.20 "-0.2" 0 "0" 0.20 "0.2" 0.40 "0.4" 0.60 "0.6" , format(%4.2f) labsize(small))ytitle("核""密""度", size(*0.8) orientation(h)) ylabel(, nogrid  labsize(small)) note("") caption("") graphregion(fcolor(white)) msize(small) mcolor(gs6) msymbol(o) title("(a)随机处理年份")
}
graph export "lnapp-随机处理年份.png", replace

local random  随机处理个体
foreach ran in `random'{
	use "安慰剂检验_`ran'.dta",clear
dpplot beta, xline(0.28, lc(black%70) lp(shortdash) lwidth(thin)) xline(0, lc(black%80) lwidth(thin) lp(shortdash)) xtitle("估计系数", size(*0.8)) xlabel(-0.40 "-0.4" -0.20 "-0.2" 0 "0" 0.20 "0.2" 0.40 "0.4" 0.60 "0.6", format(%4.2f) labsize(small))ytitle("核""密""度", size(*0.8) orientation(h)) ylabel(, nogrid  labsize(small)) note("") caption("") graphregion(fcolor(white)) msize(small) mcolor(gs6) msymbol(o) title("(b)随机处理个体")
}
graph export "lnapp-随机处理个体.png", replace


/////////////////////////////////附表3//////////////////////////////////
///////////////////////////企业创新信息披露水平///////////////////////////
reghdfe lnapp did $control1 if h_index==1 , absorb(year id) vce(cl city_num) 
est store m1 
reghdfe lnapp did $control1 if h_index==0 , absorb(year id) vce(cl city_num)
est store m2   
///////////////////////////地级市知识产权保护水平///////////////////////////
reghdfe lnapp did $control1 if h_protect==1 , absorb(year id) vce(cl city_num)
est store m3 
reghdfe lnapp did $control1 if h_protect==0 , absorb(year id) vce(cl city_num) 
est store m4  
///////////////////////////调整为制造业和生产性服务业////////////////////////
replace h_indus = 0 if regexm(ind_code, "^[BCDE]")  // 检查是否以B、C、D、E开头
replace h_indus = 1 if regexm(ind_code, "^[GIJKLM]")  // 检查是否以G I J K L M开头
reghdfe lnapp did $control1 if h_indus==1 , absorb(year id ind_code) vce(cl city_num)
est store m5
reghdfe lnapp did $control1 if h_indus==0 , absorb(year id ind_code) vce(cl city_num)
est store m6
///////////////////////////划分为中部、西部示范区回归////////////////////////
preserve 
local cities "梧州市 贵港市 贺州市 玉林市 重庆市 广安市 兰州市 白银市 银川市 石嘴山市 渭南市"
foreach cityname of local cities {
    drop if city == "`cityname'"
}
reghdfe lnapp did $control1, absorb(year id) vce(cl city_num) 
est store m7
restore
preserve 
local cities "合肥市 芜湖市 马鞍山市 铜陵市 安庆市 池州市 巢湖市 滁州市 宣城市 六安市  衡阳市 郴州市 永州市 荆州市 荆门市 运城市 三门峡市 临汾市  赣州市"
foreach cityname of local cities {
    drop if city == "`cityname'"
}
reghdfe lnapp did $control1, absorb(year id) vce(cl city_num) 
est store m8
restore


/////////////////////////////////附表4//////////////////////////////////
///////////////////////////////第（1）列///////////////////////////////
reghdfe lnapp did $control1 if h_Depent_total==1, absorb(year id) vce(cl city_num)
est store m1
///////////////////////////////第（2）列///////////////////////////////  
reghdfe lnapp did $control1 if h_Depent_total==0, absorb(year id) vce(cl city_num) 
est store m2
esttab m1 m2,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 


/////////////////////////////////附表5、6//////////////////////////////////
//若未安装csdid命令，请先运行下列代码进行安装
// ssc install csdid, replace
// help csdid
//此外，由于csdid命令也依赖于几个其他命令包，若您的软件未安装，也请先安装，再运行
// ssc install drdid, replace  //双重稳健DID核心方法
// ssc install ftools, replace  //负责加速运算
// ssc install reghdfe, replace
ddtiming lnapp did, i(id) t(year) 
ddtiming ihs_cro_app did, i(id) t(year) 
///////////////////////////////第（1）列///////////////////////////////
csdid lnapp       $control1, idvar(id) time(year) gvar(approval) agg(simple)  method(stdipw) cluster(city_num)
est store m1
///////////////////////////////第（2）列///////////////////////////////
csdid ihs_cro_app $control1, idvar(id) time(year) gvar(approval) agg(simple) method(stdipw) cluster(city_num)
est store m2
///////////////////////////////第（3）列///////////////////////////////
csdid lnapp       $control1, idvar(id) time(year) gvar(approval) agg(event)  method(stdipw) cluster(city_num)
est store m3
///////////////////////////////第（4）列///////////////////////////////
csdid ihs_cro_app $control1, idvar(id) time(year) gvar(approval) agg(event) method(stdipw)  cluster(city_num)
est store m4
///////////////////////////////第（5）列///////////////////////////////
csdid lnapp       $control1, idvar(id) time(year) gvar(approval) agg(group)  method(stdipw) cluster(city_num)
est store m5
///////////////////////////////第（6）列///////////////////////////////
csdid ihs_cro_app $control1, idvar(id) time(year) gvar(approval) agg(group) method(stdipw) cluster(city_num)
est store m6
esttab m1 m2 m3 m4 m5 m6,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 




/////////////////////////////////附表7//////////////////////////////////
///////////////////////////////Panel A 第（1）列//////////////////////////
reghdfe ln企业主体   did $control1, absorb(year id ) vce(cl city_num)  
est store m1
///////////////////////////////Panel A 第（2）列///////////////////////////
reghdfe ln多主体参与 did $control1, absorb(year id ) vce(cl city_num)
est store m2 
///////////////////////////////Panel A 第（3）列///////////////////////////
reghdfe ln跨行业    did $control1,  absorb(year id ) vce(cl city_num)  
est store m3
///////////////////////////////Panel A 第（4）列///////////////////////////
reghdfe lnquality_j did  $control1, absorb(year id ) vce(cl city_num)
est store m4
///////////////////////////////Panel A 第（5）列///////////////////////////
reghdfe lnquality_z did  $control1, absorb(year id ) vce(cl city_num)
est store m5
esttab m1 m2 m3 m4 m5,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01)

///////////////////////////////Panel B 第（1）列//////////////////////////
reghdfe ihs_企业主体   did $control1, absorb(year id ) vce(cl city_num)
est store m1 
///////////////////////////////Panel B 第（2）列//////////////////////////
reghdfe ihs_多主体参与 did $control1, absorb(year id ) vce(cl city_num)
est store m2 
///////////////////////////////Panel B 第（3）列//////////////////////////
reghdfe ihs_跨行业    did $control1, absorb(year id ) vce(cl city_num) 
est store m3
///////////////////////////////Panel B 第（4）列//////////////////////////
reghdfe ihs_quality_j did  $control1, absorb(year id ) vce(cl city_num) 
est store m4
///////////////////////////////Panel B 第（5）列//////////////////////////
reghdfe ihs_quality_z did  $control1, absorb(year id ) vce(cl city_num) 
est store m5
esttab m1 m2 m3 m4 m5,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) 


















































