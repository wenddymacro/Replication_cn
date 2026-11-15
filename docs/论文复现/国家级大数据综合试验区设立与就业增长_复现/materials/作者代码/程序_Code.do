
***************国家级大数据综合试验区设立与就业增长*******************


use 数据_Firmdata,clear


global Firm_Control "Lev  Age Roa Capital  Cash Growth Mshrrat Shrholder1  Share_indep" 
global City_Control "Gdpt Popt Secondt Waget Edut  Firm_numt Thirdt"	 
 
 
*****正文图表*****
 
 
**表1**
reghdfe Labor Bigdata_Post ,absorb(Firm  ) cluster(city)
est store m1

reghdfe Labor Bigdata_Post ,absorb(Firm year ) cluster(city)
est store m2

reghdfe Labor Bigdata_Post  $Firm_Control  ,absorb(Firm year) cluster(city)
est store m3

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m4
	
esttab m1 m2 m3 m4 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)
		
		
**图1**

reghdfe Labor d_5 d_4 d_3 d_2 d_1 d0 d1 d2 d3 d4 d5 $Firm_Control $City_Control ,absorb(Firm year) cluster(city) 
coefplot,  keep(d_5 d_4 d_3 d_2 d_1 d0 d1 d2 d3 d4 d5) omitted  vertical level(95) ///
	color(black) yline(0,lp(solid) lc(black) lw(thin))  xline(5,lp(solid) lc(black) lw(thin)) ///
	ytitle("系数") xtitle("与国家级大数据综合试验区政策实施的相对年份") ///
	coeflabels(d_5 = "-5" d_4 = "-4"  d_3 = "-3"  d_2 = "-2" d_1 = "-1" d0 = "0" ///
     d1  = "1" d2 = "2" d3 = "3" d4  = "4" d5 = "5", ///
	labsize(*1.0) angle(0) labcolor(purple)) 	 ///
	ciopts(recast(rcap) lc(black) lp(solid) lw(thin)) ///
	msymbol(Oh) mcolor(black)  msize(small) ///
	scale(1.2)  xscale(titlegap(tiny)) ///
	plotregion(lstyle(none)) graphregion(lstyle(none) margin(zero))  
	

	 

**表2**	

use 数据_Ctiydata,clear	
global City_Control "Gdpt Popt Secondt Waget Edut  Firm_numt Thirdt"		
	
reghdfe Newfirm Bigdata_Post $City_Control ,absorb(city year  ) cluster(city)	 	 
est store m1	
	
reghdfe Newfirm_score Bigdata_Post $City_Control ,absorb(city year  ) cluster(city)	 	 
est store m2
	  	  
reghdfe New_affiliate Bigdata_Post   $City_Control ,absorb(city year) cluster(city)		
est store m3			  
		  
reghdfe Bigdata_newfirm Bigdata_Post $City_Control ,absorb(city year  ) cluster(city)	 	 	 
est store m4	 
 
reghdfe Bigdataindus_emp Bigdata_Post $City_Control ,absorb(city year  ) cluster(city)	
est store m5	 
	 
esttab m1 m2 m3 m4 m5,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)	





use 数据_Firmdata,clear


global Firm_Control "Lev  Age Roa Capital  Cash Growth Mshrrat Shrholder1  Share_indep" 
global City_Control "Gdpt Popt Secondt Waget Edut  Firm_numt Thirdt"	

**表3**


reghdfe TFP Bigdata_Post   $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m1

reghdfe Labor  Bigdata_Post  TFP $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m2

reghdfe Market_share Bigdata_Post   $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m3

reghdfe Labor Bigdata_Post Market_share $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m4

esttab m1 m2 m3 m4 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post TFP Market_share)
		
		
**表4**

reghdfe Finan Bigdata_Post   $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m1

reghdfe Subsidy Bigdata_Post   $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m2

reghdfe Inno_subsi Bigdata_Post   $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m3

reghdfe Labor Bigdata_Post   $Firm_Control $City_Control if Finance_dum==0 ,absorb(Firm year) cluster(city)
est store m4

reghdfe Labor Bigdata_Post   $Firm_Control $City_Control if Finance_dum==1 ,absorb(Firm year) cluster(city)
est store m5

reghdfe Debt Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m6

esttab m1 m2 m3 m4 m5 m6,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)


**表5**

reghdfe Total_wage Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m1

reghdfe Social_security Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m2

reghdfe Allowances Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m3

reghdfe ESG_DID  Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m4

reghdfe ESG_pengbo  Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)		
est store m5

esttab m1 m2 m3 m4 m5 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)		
		
		
		
**表6**

reghdfe High_status Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m1

reghdfe Low_status Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)	
est store m2	
	
reghdfe High_kudos Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m3

reghdfe Low_kudos Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)	
est store m4		

reghdfe Highedu_staff Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m5

reghdfe Senior_staff Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m6	

esttab m1 m2 m3 m4 m5 m6 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)	



**图2**

*使用julia软件绘制，代码见“机器学习画图_Code.txt”文件





**表7**

use 数据_MLdata,clear

  *当年属于政策试点
  count if 真实实施 == 1  
  *当年属于最优规划
  count if  理论实施 == 1 //
  *当年属于最优规划且在政策试点
  count if  理论实施 == 1 & 真实实施 == 1  //
  *当年属于最优规划且不在政策试点
  count if  理论实施 == 1 & 真实实施 == 0  //
  *当年不属于最优规划且在政策试点
  count if  理论实施 == 0 & 真实实施 == 1  //
  *当年不属于最优规划且不在政策试点
  count if  理论实施 == 0 & 真实实施 == 0  //




*****附录图表*****

use 数据_Firmdata,clear


global Firm_Control "Lev  Age Roa Capital  Cash Growth Mshrrat Shrholder1  Share_indep" 
global City_Control "Gdpt Popt Secondt Waget Edut  Firm_numt Thirdt"	


**表A1**

sum Labor Bigdata $Firm_Control Gdp Pop Second Third  Wage Edu  Firm_num 



**图A1**
	
graph set window fontface "Times New Roman"
graph set window fontfacesans "宋体" // 设置图形输出的字体
// egen mean_y=mean(Labor), by(year Bigdata)
graph twoway (connect mean_y year if Bigdata==1,sort)        ///
     (connect mean_y year if Bigdata==0,sort lpattern(dash)), ///
     xline(2015,lpattern(dash) lcolor(gray))                ///
     ytitle("{stSans:就}""{stSans:业}""{stSans:人}""{stSans:数}", ///
     orientation(h)) xtitle("{stSans:年度}") ///
     ylabel(7(0.2)8,labsize(*0.75)  format(%02.1f)) xlabel(,labsize(*0.75))   ///
     legend(label(1 "{stSans:处理组}") label( 2 "{stSans:控制组}")) ///图例
     xlabel(2010 (1) 2021)  graphregion(color(white)) //白底	


	 
**表A2**	 
	
reghdfe Labor Bigdata_Post  $Firm_Control $City_Control if subfirmin_firmout!=1,absorb(Firm year) cluster(city)
est store m1  	

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control if bigcity!=1 ,absorb(Firm year) cluster(city)
est store m2 	

reghdfe Labor Bdata_newfirm $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)	
est store m3  	
	
reghdfe Labor Bdata_newfirmrate $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)	
est store m4 	
	
reghdfe Labor Bdata_employ $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)	
est store m5  

reghdfe Labor Tele_revenue $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)	
est store m6  
	 
esttab m1 m2 m3 m4 m5 m6 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post Bdata_newfirm Bdata_newfirmrate Bdata_employ Tele_revenue)		 
	 
	 
**表A3**	 

reghdfe Labor Bigdata_Post Highspeed  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m1

reghdfe Labor Bigdata_Post Smartcity  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m2

reghdfe Labor Bigdata_Post Broadband  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m3

reghdfe Labor Bigdata_Post IM  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m4

reghdfe Labor Bigdata_Post AI_PilotZone  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m5

reghdfe Labor Bigdata_Post Highspeed Smartcity Broadband IM  AI_PilotZone  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m6
	
esttab m1 m2 m3 m4 m5 m6 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post Highspeed Smartcity Broadband IM AI_PilotZone )		 
	 	 
	 
**图A2**	 
	 
*-------------------
preserve
global Firm_Control "Lev  Age Roa Capital  Cash Growth Mshrrat Shrholder1  Share_indep"
global City_Control "Gdpt Popt Secondt Waget Edut  Firm_numt Thirdt"

mat b = J(500,1,0) 
mat se = J(500,1,0) 
mat p = J(500,1,0) 
forvalues i=1/500{
use 数据_Firmdata.dta,clear
     qui xtset Firm year  
	 sample 1, count by(city) 
	 sample 63, count   //处理组个体数量，本文中试点城市63个
	 keep city year 
	 rename year policy_year
	 save match_id_year1, replace  
	 qui merge 1:m city using 数据_Firmdata
	 qui xtset Firm year
	 gen treat = (_merge == 3) 
	 gen period = (year >= policy_year) 
	 gen did = treat*period
	 qui reghdfe Labor did  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
*将回归结果赋值到对应矩阵的对应位置
	 mat b[`i',1] = _b[did]
	 mat se[`i',1] = _se[did]
*计算P值并赋值于矩阵
	mat p[`i',1] = 2*ttail(e(df_r), abs(_b[did]/_se[did]))
}
*矩阵转化为向量
svmat b, names(coef)
svmat se, names(se)
svmat p, names(pvalue)
*删除空值并添加标签
drop if pvalue1 == .
label var pvalue1 p值
label var coef1 估计系数
keep coef1 se1 pvalue1 
save palcebo_test,replace
*--------绘图
use palcebo_test,clear

graph set window fontface "Times New Roman"
graph set window fontfacesans "宋体" // 设置图形输出的字体
twoway (kdensity coef1,yaxis(2) color(black)) (scatter pvalue1 coef1, msymbol(smcircle_hollow) mcolor(black)), ///
xlabel(-0.1(0.05)0.1 0.071) ylabel(0(5)20,axis(2)) ylabel(0(0.2)1 0.1,axis(1))  ///
xline(0.071, lwidth(vthin) lp(shortdash)) xtitle("估计系数") ///
yline(0.1,lwidth(vthin) lp(dash)) ///
ytitle("P""值",orientation(horizontal)size(*0.8)) ylabel(, nogrid format(%4.1f) labsize(small))  ///
ytitle("核""密""度" ,orientation(horizontal)  size(*0.8) axis(2)) ylabel(, nogrid format(%4.1f) labsize(small) axis(2)) ///
legend(label(1 "核密度") label( 2 "估计系数")) ///
graphregion(color(white))  
    
restore	 
	 
	 
**表A4**	 
	 
preserve
xtset Firm year
xtbalance , range(2010 2021) 

ddtiming Labor Bigdata_Post,i(Firm) t(year)
restore	 
	 
**表A5**	 

*OLS	 
preserve
xtset Firm year
xtbalance , range(2010 2021) 

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year) cluster(city)
est store m1

esttab m1  ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)	

*CSDID		
csdid Labor $Firm_Control $City_Control , ivar(Firm) time(year) gvar(Policy_year) method(ipw ) agg(simple) 
restore	 
	 
*Stacked DID	

preserve
stackedev 	Labor  d_5 d_4 d_3 d_2  d0 d1-d5 d_1 , cohort(tyear) never_treat(never) time(year) unit_fe(Firm) clust_unit(cityid) covariates($Firm_Control $City_Control)  	
lincom(d0 +d1+d2+ d3+d4+d5)/6	
restore		 
	
*SA	
eventstudyinteract Labor  d_5 d_4 d_3 d_2  d0 d1-d5  , cohort(tyear) control_cohort(never) covariates($Firm_Control $City_Control)  absorb(Firm year) vce(cluster city)

matrix b = e(b_iw)
         matrix V = e(V_iw)
         ereturn post b V
        lincom (d0 + d1 + d2 + d3 + d4+d5)/6
	
*DID Imputation	
did_imputation Labor Firm year tyear , autosample controls($Firm_Control $City_Control)  tol(1) maxit(100) 	
	
	
**表A6**	

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control if _weight!=., absorb(Firm year) cluster(city)
est store m1

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control if psm_merge==3, absorb(Firm year) cluster(city)
est store m2

ivreghdfe Labor (Bigdata_Post =  Water )  $Firm_Control $City_Control ,absorb(Firm year) cluster(city) first
est store m3

ivreghdfe Labor (Bigdata_Post = Disastrous Water)  $Firm_Control $City_Control ,absorb(Firm year) cluster(city) first
est store m4
		
esttab m1 m2 m3 m4  ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)		
	
	
**表A7**	 
	 
reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year city) cluster(city)
est store m1

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year city Indus) cluster(city)
est store m2

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year) cluster(Firm)
est store m3

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year) cluster(city Indus)  
est store m4

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control ,absorb(Firm year) cluster(prov)
est store m5

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control if Prov!=1 ,absorb(Firm year) cluster(city)  
est store m6

reghdfe Labor Bigdata_Post  $Firm_Control $City_Control if ICT_Indus!=1 ,absorb(Firm year) cluster(city)  
est store m7
	 
esttab m1 m2 m3 m4 m5 m6 m7 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)		 


**表A8**

reghdfe Labor Bigdata_Post   $Firm_Control $City_Control if jobdum==1,absorb(Firm year) cluster(city)		
est store m1		

reghdfe Labor Bigdata_Post   $Firm_Control $City_Control if jobdum==0,absorb(Firm year) cluster(city)		
est store m2	

reghdfe Re_task Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m3

reghdfe NonRe_task Bigdata_Post    $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m4

esttab m1 m2 m3 m4 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)		
		
		
// bdiff, group(jobdum) model (reghdfe Labor Bigdata_Post   $Firm_Control $City_Control ,absorb(Firm year) cluster(city)) bs reps(500) detail		
		
		

**表A9**

reghdfe Labor Bigdata_Post SOE   $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m1

reghdfe Labor Bigdata_Post##SOE   $Firm_Control $City_Control  ,absorb(Firm year) cluster(city)
est store m2

esttab m1 m2  ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post 1.Bigdata_Post#1.SOE 1.Bigdata_Post 1.SOE  SOE)	
		

**表A10**		

use 数据_Ctiydata,clear	

global Control "Gdpt Popt Secondt Waget Edut  Firm_numt Thirdt Internett  Fdit Fiscalt Financet"
	
reghdfe lnEmploy Bigdata_Post $Control ,absorb(city year ) cluster(city)
estadd local City_FE "YES"
estadd local Year_FE "YES"
est store m1

reghdfe Bigdataindus_emp Bigdata_Post $Control ,absorb(city year  ) cluster(city)	
estadd local City_FE "YES"
estadd local Year_FE "YES"
est store m2	

reghdfe Labor_supply Bigdata_Post   $Control ,absorb(city year ) cluster(city)
estadd local City_FE "YES"
estadd local Year_FE "YES"
est store m3

esttab m1 m2 m3 ,b(%9.4f) se nogap compress scalars(r2_a N) mtitle star(* 0.1 ** 0.05 *** 0.01) keep(Bigdata_Post)	
				
				
				