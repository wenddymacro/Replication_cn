	
	*软件版本：Stata/MP 18.0 for Windows (64-bit x86-64)

	use "./数据/上市公司数据.dta", clear
	global clist "lnage lnasset lnsize lev edu ceo"                              
	global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"  
	
	reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
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
	reghdfe TFP chainleader , absorb(stkcd year) vce(cluster city)
	est store e011
	/* Column 2 企业、年份固定效应+企业控制变量 */
	reghdfe TFP chainleader $clist , absorb(stkcd year) vce(cluster city)
	est store e012
	/* Column 3 企业、年份固定效应+企业、城市控制变量 */
	reghdfe TFP chainleader $xlist , absorb(stkcd year) vce(cluster city)
	est store e013
	/* Column 4 企业、行业-时间、省份-时间固定效应+企业、城市控制变量 */
	reghdfe TFP chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e014
	outreg2 [e01*] using ".\图表\表1_基准回归结果.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace 

	*************************************************************
	***                                                       ***
	*** 表 2 链长制对供应链布局调整、协调投资和交易成本的影响 ***  
	***                                                       ***
	*************************************************************
	
	/* Column 1 本地交易占比 */
	reghdfe local chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city) 
	est store e021
	/* Column 2 土地出让规模 */	
	reghdfe lnland chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e022
	/* Column 3 与获土地企业交易 */
	reghdfe local_land chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e023
	/* Column 4 信息搜寻成本 */	
	reghdfe searcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e024
	/* Column 5 差旅谈判费用 */	
	reghdfe travcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e025
	/* Column 6 和解撤诉案件 */		
	reghdfe clawsuit chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e026
	outreg2 [e02*] using ".\图表\表2_链长制对供应链布局调整、协调投资和交易成本的影响.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace

	*************************************************************
	***                                                       ***
	***    表 3 链长制对本地供应链匹配质量与研发合作的影响    ***  
	***                                                       ***
	*************************************************************
	
	/* Column 1 应收退货和质量赔款占比 */	
	reghdfe refund chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e031
	/* Column 2 与本地有出口经验企业交易 */
	reghdfe local_export chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e032
	/* Column 3 研发费用 */		
	reghdfe lninnofee chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e033
	/* Column 4 专利申请量 */	
	reghdfe patent chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e034
	/* Column 5 本地合作专利申请量 */
	reghdfe lpatent chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e035
	/* Column 6 链上专利影响 */	
	reghdfe lpatent c.chainleader##c.c_lpatent $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e036
	outreg2 [e03*] using ".\图表\表3_链长制对本地供应链匹配质量与研发合作的影响.xls", keep(chainleader c.chainleader##c.c_lpatent) stats(coef se) dec(4) nolabel nocons replace

	*************************************************************
	***                                                       ***
	***               表 4 适应不良风险的考察                 ***  
	***                                                       ***
	*************************************************************	
	
	/* Column 1 产业链完善 */	
	reghdfe TFP chainleader $xlist if g_clus1==1, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e041
	/* Column 2 产业链不完善 */	
	reghdfe TFP chainleader $xlist if g_clus1==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e042
	/* Column 3 政商关系好 */	
	reghdfe TFP chainleader $xlist if g_gc==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e043
	/* Column 4 政商关系差 */	
	reghdfe TFP chainleader $xlist if g_gc==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e044
	/* Column 5 专用性投资低 */	
	reghdfe TFP chainleader $xlist if g_contract==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e045
	/* Column 6 专用性投资高 */	
	reghdfe TFP chainleader $xlist if g_contract==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e046
	outreg2 [e04*] using ".\图表\表4_适应不良风险的考察.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace			

	//组间系数差异检验
	xtset, clear
	xtset city
	bdiff, group(g_clus1) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
	
	xtset, clear
	xtset city
	bdiff, group(g_gc) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
	
	xtset, clear
	xtset city
	bdiff, group(g_contract) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)

	*************************************************************
	***                                                       ***
	***           表 5 要素型协调与组织型协调的影响           ***  
	***                                                       ***
	*************************************************************	
	
	/* Column 1 协调工具-生产率 */	
	reghdfe TFP c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e051
	/* Column 2 协调工具-本地布局 */		
	reghdfe local c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e052
	/* Column 3 协调工具-信息搜寻成本 */		
	reghdfe searcost c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e053
	/* Column 4 协调工具-差旅谈判成本 */		
	reghdfe travcost c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e054
	/* Column 5 协调工具-应收退货和质量赔款 */	
	reghdfe refund c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store e055
	/* Column 6 协调工具-本地合作专利 */	
	reghdfe lpatent c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)		
	est store e056
	outreg2 [e05*] using ".\图表\表5_要素型协调与组织型协调的影响.xls", keep(c.chainleader#c.org c.chainleader#c.res) stats(coef se) dec(4) nolabel nocons replace	
	
	

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
		use "./数据/城市数据.dta", clear
		reghdfe chaincol chainleader_c lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)   
		outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader_c) stats(coef se) dec(4) nolabel nocons replace
	restore
	/* Column 2 产业链协作补贴 */		
	reghdfe q_chainsub chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
	/* Column 3 服务对接次数 */		
	reghdfe survey chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
	/* Column 4 行业组织-城市层面 */
	preserve 
		use "./数据/城市数据.dta", clear
		reghdfe socialorg chainleader_c lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)   
		outreg2 using ".\图表\附表3_链长制的微观协调.xls", keep(chainleader_c) stats(coef se) dec(4) nolabel nocons append
	restore
	//注：为与企业层面政策变量chainleader相区分，代码中城市层面的政策变量命名为chainleader_c。

	*************************************************************
	***                                                       ***
	***               附图 1 & 2 补贴与信贷变化               ***  
	***                                                       ***
	*************************************************************

	//补贴总额	
	bys treat year: egen subsidy_m=mean(subsidy)
	twoway (line subsidy_m year if treat==1, lcolor(black) lpattern(solid)) ///
		   (line subsidy_m year if treat==0, lcolor(black) lpattern(dash)) ///
		   , ///
		   legend(label(1 `"{fontface "宋体":处理组}"') ///
				  label(2 `"{fontface "宋体":控制组}"') ///
				  ring(0) pos(1) col(1)) ///
		   xscale(range(2013.5 2023.5)) /// 
		   xtitle(`"{fontface "宋体":年份}"') ///
		   ytitle(`"{fontface "宋体":补贴总额（万元）}"') ///
		   xlabel(2014(1)2023) ///
		   graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
	graph export "./图表/附图1_处理组和控制组补贴总额变化趋势.png", as(png) replace
	
	//产业链补贴	
	bys treat year: egen chainsub_m=mean(chainsub)
	twoway (line chainsub_m year if treat==1, lcolor(black) lpattern(solid)) ///
		   (line chainsub_m year if treat==0, lcolor(black) lpattern(dash)) ///
		   , ///
		   legend(label(1 `"{fontface "宋体":处理组}"') ///
				  label(2 `"{fontface "宋体":控制组}"') ///
				  ring(0) pos(1) col(1)) ///
		   xscale(range(2013.5 2024)) /// 
		   xtitle(`"{fontface "宋体":年份}"') ///
		   ytitle(`"{fontface "宋体":产业链协作补贴额（万元）}"') ///
		   xlabel(2014(1)2023) ///
		   graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
	graph export "./图表/附图1_处理组和控制组产业链协作补贴额变化趋势.png", as(png) replace
	
	//借款总额
	bys treat year: egen loan_m=mean(loan) 
	twoway (line loan_m year if treat==1, lcolor(black) lpattern(solid)) ///
		   (line loan_m year if treat==0, lcolor(black) lpattern(dash)) ///
		   , ///
		   legend(label(1 `"{fontface "宋体":处理组}"') ///
				  label(2 `"{fontface "宋体":控制组}"') ///
				  ring(0) pos(1) col(1)) ///
		   xscale(range(2013.5 2023.5)) /// 
		   xtitle(`"{fontface "宋体":年份}"') ///
		   ytitle(`"{fontface "宋体":借款总额（万元）}"') ///
		   xlabel(2014(1)2023) ///
		   graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
	graph export "./图表/附图2_处理组和控制组借款总额变化趋势.png", as(png) replace
	
	//长期借款占比
	bys treat year: egen q_longloan_m=mean(q_longloan) 
	twoway (line q_longloan_m year if treat==1, lcolor(black) lpattern(solid)) ///
		   (line q_longloan_m year if treat==0, lcolor(black) lpattern(dash)) ///
		   , ///
		   legend(label(1 `"{fontface "宋体":处理组}"') ///
				  label(2 `"{fontface "宋体":控制组}"') ///
				  ring(0) pos(1) col(1)) ///
		   xscale(range(2013.5 2023.5)) /// 
		   xtitle(`"{fontface "宋体":年份}"') ///
		   ytitle(`"{fontface "宋体":长期借款占总负债比例}"') ///
		   xlabel(2014(1)2023) ///
		   graphregion(color(white)) plotregion(color(white) margin(zero)) name(mygraph, replace)
	graph export "./图表/附图2_处理组和控制组长期借款占比变化趋势.png", as(png) replace
	
	*************************************************************
	***                                                       ***
	***           附表 4 基于税调数据样本的补充检验           ***  
	***                                                       ***
	*************************************************************
	
	preserve
		use "./数据/税调数据.dta", clear
		global zlist "lnasset lnsize lnage lev lngdppc secondary govexp ftd"
		reghdfe TFP_ts chainleader $zlist, absorb(id prv#year) vce(cluster city)	
		est store ef041
		reghdfe patent_ts chainleader $zlist, absorb(id prv#year) vce(cluster city)
		est store ef042
		outreg2 [ef04*] using ".\图表\附表4_基于税调数据样本的补充检验.xls", keep(chainleader) dec(4) nolabel nocons replace	
	restore
	
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
		outreg2 using ".\图表\附表5_主要变量描述性统计.xls", replace sum(log) dec(4) keep(TFP chainleader asset size age lev ceo edu gdppc secondary govexp ftd local land local_land searcost travcost clawsuit refund local_export innofee patent lpatent)
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
		
		reghdfe TFP pre$num1-pre2 post0-post$num2 pre1 $xlist, absorb(stkcd prv#year indid#year) vce(cluster city) 
		est store ec_ols_1
		event_plot ec_ols_1, stub_lag(post#) stub_lead(pre#) shift(0) plottype(scatter) together alpha(0.05) noautolegend ciplottype(rcap) ///
		graph_opt(xline(0, lcolor(black%45) lpattern(dash)) yline(0, lcolor(black%45)) graphregion(color(white)) bgcolor(white) xscale(range(-4.5(1)3.5)) xlabel(-4(1)3, labsize(4)) ylabel(,format(%3.2f) angle(0) labsize(4)) ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"' `"{fontface "宋体":系}"' `"{fontface "宋体":数}"',orientation(horizontal) size(4)) xtitle(`"{fontface "宋体":时期}"',size(4)) ///
		legend(label(1 `"{fontface "宋体":估计系数值}"') label(2 `"{fontface "宋体":置信区间}"') row(1) col(2) ring(1) pos(6) region(lcolor(black)) size(4)) xsize(10) ysize(5)) ///
		lag_opt1(msymbol(d) color(black) msize(1.8)) lag_ci_opt1(color(black) lwidth(0.4)) 
		graph export "./图表/附图4_平行趋势检验.png", as(png) replace
	restore
	
	*************************************************************
	***                                                       ***
	***           附表 6 & 附图 5 Goodman-Bacon分解           ***  
	***                                                       ***
	*************************************************************
	
	preserve
		keep $xlist chainleader_l TFP chainleader stkcd year indid prv city cityname esample
		xtset stkcd year
		bysort stkcd: egen temp_prv=max(prv)
		bysort stkcd: egen temp_indid=max(indid)
		bysort stkcd: egen temp_chainleader_l=max(chainleader_l)
		bysort stkcd: egen temp_city=max(city)
		bysort stkcd: egen temp2_city=min(city)
		replace prv=temp_prv if prv==.
		replace indid=temp_indid if indid==.
		replace chainleader_l=temp_chainleader_l if chainleader_l==.
		replace city=temp_city if city==.
		
		gen poschange=temp_city-temp2_city
		drop if poschange~=0

		// 插值	
		foreach var of global xlist{
			by stkcd: ipolate `var' year, gen(ipo_`var') epolate
		}
		by stkcd: ipolate TFP year, gen(TFP_ipo) epolate
		
		// 平衡面板
		xtbalance , range(2014 2023) miss(ipo_*)
		
		// 回归+分解
		bacondecomp TFP_ipo chainleader ipo_* ,ddetail vce(r)
		graph export "./图表/附图5_Goodman-Bacon分解的权重.png",replace 
	restore
	
	*************************************************************
	***                                                       ***
	***         附图 6 平行趋势检验:异质性效应处理方法        ***
	***                                                       ***
	*************************************************************
	
	//生成动态效应的变量
	local num1=4
	local num2=3

	replace chainleader_l=. if chainleader_l==0
	gen event=year-chainleader_l
	
	gen setup_mis=chainleader_l
	replace setup_mis=0 if setup_mis==.
	
	tab event
	
	replace event=-`num1' if event<=-`num1'
	replace event=`num2' if event>=`num2'
	
	forvalues i=`num1'(-1)1{
		gen pre`i'=0
		replace pre`i'=1 if event==-`i'
	}
	
	forvalues i=0(1)`num2'{
		gen post`i'=0
		replace post`i'=1 if event==`i'
	}
	
	
	/* Method 1 组群—时间ATT估计量：Callaway & Sant'Anna (2021) */
	csdid TFP $xlist, ivar(stkcd) time(year) gvar(setup_mis) method(dripw) long2 cluster(city)
	estat event, window(-3 3) estore(cs_est)

	estimates restore cs_est
	matrix cs_b = e(b)
	matrix cs_v = e(V)

	// long2下-1期为基期、不单独估计；若结果中无Tm1，则补0
	if missing(colnumb(cs_b, "Tm1")) {
		local cn : colnames cs_b
		matrix cs_b = cs_b, (0)
		matrix colnames cs_b = `cn' Tm1
		local k = colsof(cs_v)
		matrix cs_v = (cs_v, J(`k', 1, 0)) \ J(1, `k' + 1, 0)
		matrix colnames cs_v = `cn' Tm1
		matrix rownames cs_v = `cn' Tm1
	}	
	
	/* Method 2 局部投影法：Dube et al.(2025) */ 
    xtset stkcd year
	// new_treat=1 只在企业首次进入处理的当年出现
    gen new_treat = D.chainleader

    matrix lpdid_b = J(1, 8, 0)
    matrix lpdid_v = J(8, 8, 0)
    matrix colnames lpdid_b = pre4 pre3 pre2 pre1 post0 post1 post2 post3
    matrix rownames lpdid_v = pre4 pre3 pre2 pre1 post0 post1 post2 post3
    matrix colnames lpdid_v = pre4 pre3 pre2 pre1 post0 post1 post2 post3

    // 事前安慰剂：Y_(t-h)-Y_(t-1)，h=4,3,2
    foreach h in 4 3 2 {
        gen dy_m`h' = L`h'.TFP - L.TFP

        reghdfe dy_m`h' new_treat L.($xlist) ///
            if new_treat == 1 | chainleader == 0, ///
            absorb(prv#year indid#year) vce(cluster city)

        local p = 5 - `h'
        matrix lpdid_b[1, `p'] = _b[new_treat]
        matrix lpdid_v[`p', `p'] = _se[new_treat]^2
    }

    // 事后动态效应：Y_(t+h)-Y_(t-1)，h=0,1,2,3
    forvalues h = 0/3 {
        if `h' == 0 {
            gen dy_p0 = TFP - L.TFP
            local clean "chainleader == 0"
        }
        else {
            gen dy_p`h' = F`h'.TFP - L.TFP
            local clean "F`h'.chainleader == 0"
        }

        reghdfe dy_p`h' new_treat L.($xlist) ///
            if new_treat == 1 | (`clean'), ///
            absorb(prv#year indid#year) vce(cluster city)

        local p = `h' + 5
        matrix lpdid_b[1, `p'] = _b[new_treat]
        matrix lpdid_v[`p', `p'] = _se[new_treat]^2
    }
	
	
	/* Method 3 交叉权重法：Sun & Abraham (2021) */
	gen cohort=chainleader_l

	eventstudyinteract TFP pre4-pre2 post0 post1-post3 pre1, cohort(cohort) control_cohort(no_treat) covariates($xlist) absorb(i.stkcd i.indid#i.year i.prv#i.year) vce(cluster city)
	
	// 将省略的 -1 期补为 0，同时保留其余系数的完整协方差结构
	matrix temp_sa_b = e(b_iw)
	matrix temp_sa_v = e(V_iw)
	matrix define b_zero=(0)
	matrix colnames b_zero = pre1
	matrix define se_zero=(0)
	matrix sa_b=temp_sa_b[1,1..3],b_zero,temp_sa_b[1,4..8]
	matrix sa_v=temp_sa_v[1,1],temp_sa_v[2,2],temp_sa_v[3,3],se_zero,temp_sa_v[4,4],temp_sa_v[5,5],temp_sa_v[6,6],temp_sa_v[7,7],temp_sa_v[8,8]
	matrix colnames sa_v = pre4 pre3 pre2 pre1 post0 post1 post2 post3

	/* Method 4 跨期处理效应估计量：De Chaisemartin & D'Haultfoeuille (2026) */ 
	did_multiplegt TFP stkcd year chainleader, controls($xlist) robust_dynamic placebo(3) dynamic(3) breps(200) cluster(city)
	matrix dd_b = e(estimates)
	matrix dd_v = e(variances)
	
	
	event_plot cs_b#cs_v lpdid_b#lpdid_v sa_b#sa_v dd_b#dd_v, ///
	stub_lag(Tp# post# post# Effect_#) stub_lead(Tm# pre# pre# Placebo_#) ///
	shift(0) plottype(scatter) together alpha(0.05) noautolegend ciplottype(rcap) ///
	graph_opt(xline(0, lcolor(black%45) lpattern(dash)) yline(0, lcolor(black%45)) graphregion(color(white)) bgcolor(white) xscale(range(-4.5(1)3.5)) xlabel(-4(1)3, labsize(4)) ylabel(-0.1(0.1)0.2, angle(0) format(%3.2f) labsize(4))  ytitle(`"{fontface "宋体":估}"' `"{fontface "宋体":计}"' `"{fontface "宋体":系}"' `"{fontface "宋体":数}"',orientation(horizontal) size(4)) xtitle(`"{fontface "宋体":相对冲击发生时间}"',size(4)) ///
	legend(order(1 "Callaway & Sant'Anna(2021)" 3 "Dube et al.(2025)" ///
				 5 "Sun & Abraham(2021)" 7 "De Chaisemartin & D'Haultfoeuille(2026)") cols(2) ring(1) pos(6) region(lcolor(black))) xsize(10) ysize(5.5)) ///
	lag_opt1(msymbol(Oh) color(black) msize(1.8))    lag_ci_opt1(color(black) lwidth(0.4)) ///
	lag_opt2(msymbol(Sh) color(black) msize(1.8))    lag_ci_opt2(color(black) lwidth(0.4)) ///
	lag_opt3(msymbol(d)  color(black) msize(1.8))    lag_ci_opt3(color(black) lwidth(0.4)) ///
	lag_opt4(msymbol(t)  color(black) msize(1.8))    lag_ci_opt4(color(black) lwidth(0.4))
	
	graph export "./图表/附图6_平行趋势检验：异质性处理效应稳健估计量.png", as(png) replace
		

	*************************************************************
	***                                                       ***
	***              附表 7 处理组自选择问题检验              ***  
	***                                                       ***
	*************************************************************
	
	//第（1）—（3）列-城市层面
	preserve 
		use "./数据/城市数据.dta", clear
		keep if year>=2014 & year<=2016
		reghdfe treat city_TFP lngdppc secondary govexp ftd, absorb(prv) vce(cluster city)
		outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(city_TFP lngdppc secondary govexp ftd) stats(coef se) dec(4) nolabel nocons replace
	restore	
	preserve
		use "./数据/城市数据.dta", clear
		keep if year>=2014 & year<=2016
		reghdfe treat city_TFP_gr lngdppc secondary govexp ftd, absorb(prv) vce(cluster city)
		outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(city_TFP_gr lngdppc secondary govexp ftd) stats(coef se) dec(4) nolabel nocons append
	restore	
	preserve 
		use "./数据/城市数据.dta", clear
		keep if year==2014 
		reghdfe treat city_TFP_chg lngdppc secondary govexp ftd, absorb(prv) vce(cluster city)
		outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(city_TFP_chg lngdppc secondary govexp ftd) stats(coef se) dec(4) nolabel nocons append
	restore			
	//第（4）—（6）列-企业层面
	preserve 
		keep if year>=2014 & year<=2016
		reghdfe treat TFP $xlist, absorb(prv indid) vce(cluster city)
		outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(TFP $xlist) stats(coef se) dec(4) nolabel nocons append
	restore
	preserve 
		keep if year>=2014 & year<=2016
		reghdfe treat TFP_gr $xlist, absorb(prv indid) vce(cluster city)
		outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(TFP_gr $xlist) stats(coef se) dec(4) nolabel nocons append
	restore
	preserve 
		keep if year==2014 
		reghdfe treat TFP_chg $xlist, absorb(prv indid) vce(cluster city)
		outreg2 using ".\图表\附表7_处理组自选择问题的检验.xls", keep(TFP_chg $xlist) stats(coef se) dec(4) nolabel nocons append
	restore

	*************************************************************
	***                                                       ***
	***           附表 8 基于事前生产率趋势的分组回归         ***  
	***                                                       ***
	*************************************************************

	/* Column 1 城市事前生产率增速-高 */	
	reghdfe TFP chainleader $xlist if g_cTFP_d==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef081
	/* Column 2 城市事前生产率增速-低 */	
	reghdfe TFP chainleader $xlist if g_cTFP_d==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef082
	/* Column 3 行业小类事前生产率增速-高 */	
	reghdfe TFP chainleader $xlist if g_sTFP_d==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef083
	/* Column 4 行业小类事前生产率增速-低 */	
	reghdfe TFP chainleader $xlist if g_sTFP_d==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef084
	/* Column 5 行业中类事前生产率增速-高 */	
	reghdfe TFP chainleader $xlist if g_mTFP_d==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef085
	/* Column 6 行业中类事前生产率增速-低 */	
	reghdfe TFP chainleader $xlist if g_mTFP_d==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef086
	outreg2 [ef08*] using ".\图表\附表8_基于事前生产率趋势的分组回归.xls", keep(chainleader) dec(4) nolabel nocons replace

	*************************************************************
	***                                                       ***
	***        附表 9 基于考核压力和晋升激励的分组检验        ***  
	***                                                       ***
	*************************************************************
	
	/* Column 1 考核压力-高 */
	reghdfe TFP chainleader $xlist if g_perf==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef091
	/* Column 2 考核压力-低 */
	reghdfe TFP chainleader $xlist if g_perf==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef092
	/* Column 3 晋升激励-高 */
	reghdfe TFP chainleader $xlist if g_promo==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef093
	/* Column 4 晋升激励-低 */
	reghdfe TFP chainleader $xlist if g_promo==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef094
	outreg2 [ef09*] using ".\图表\附表9_基于考核压力和晋升激励的分组检验.xls", keep(chainleader) dec(4) nolabel nocons replace
	
	*************************************************************
	***                                                       ***
	***       附表 10 仅保留严格响应上层推动样本的检验        ***  
	***                                                       ***
	*************************************************************
	
	/* Column 1 剔除先于省份实施 */
	reghdfe TFP chainleader_na $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef101
	/* Column 2 剔除省份最早实施 */
	reghdfe TFP chainleader_nf $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef102
	/* Column 3 同省份密集实施 */	
	reghdfe TFP chainleader_f $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef103
	outreg2 [ef10*] using ".\图表\附表10_仅保留严格响应上层推动样本的检验.xls", keep(chainleader_na chainleader_nf chainleader_f) dec(4) nolabel nocons replace
	
	*************************************************************
	***                                                       ***
	***              附表 11 调整处理组识别方法1              ***  
	***                                                       ***
	*************************************************************

	/* Column 1 链条解构匹配 */	
	reghdfe TFP chainleader_d $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef111
	/* Column 2 匹配主营业务 */	
	reghdfe TFP chainleader_m $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef112
	/* Column 3 剔除综合行业 */		
	reghdfe TFP chainleader $xlist if ind_d~="S", absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef113
	/* Column 4 语义匹配 */	
	reghdfe TFP chainleader_k $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef114
	/* Column 5 与LLM并集 */	
	reghdfe TFP chainleader_kw $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef115
	/* Column 6 与LLM交集 */
	reghdfe TFP chainleader_kt $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef116
	outreg2 [ef11*] using ".\图表\附表11_调整处理组识别方法1.xls", keep(chainleader_d chainleader_m chainleader chainleader_k chainleader_kw chainleader_kt) stats(coef se) dec(4) nolabel nocons replace	
	
	*************************************************************
	***                                                       ***
	***              附表 12 调整处理组识别方法2              ***  
	***                                                       ***
	*************************************************************

	/* Column 1 保留模糊词 */	
	reghdfe TFP chainleader_w1 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef121	
	/* Column 2 剔除模糊词 */	
	reghdfe TFP chainleader_t1 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef122	
	/* Column 3 任一年匹配 */	
	reghdfe TFP chainleader_w2 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef123
	/* Column 4 全年份匹配 */	
	reghdfe TFP chainleader_t2 $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef124
	outreg2 [ef12*] using ".\图表\附表12_调整处理组识别方法2.xls", keep(chainleader_w1 chainleader_t1 chainleader_w2 chainleader_t2) stats(coef se) dec(4) nolabel nocons replace	

	*************************************************************
	***                                                       ***
	***            附表 13 排除同期冲击与替代解释1            ***  
	***                                                       ***
	*************************************************************
	
	/* Column 1 控制突发公共卫生事件 */
	reghdfe TFP chainleader lncovid $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef131
	/* Column 2 控制出口管制 */		
	reghdfe TFP chainleader BIS $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef132
	/* Column 3 控制纵向一体化 */	
	reghdfe TFP chainleader vas $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef133
	/* Column 4 控制纵向并购 */	
	reghdfe TFP chainleader merge $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef134
	/* Column 5 控制书记变更 */	
	reghdfe TFP chainleader $xlist d_mps if year<=2022, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef135
	/* Column 6 控制市长变更 */	
	reghdfe TFP chainleader $xlist d_mayor if year<=2022, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef136
	outreg2 [ef13*] using ".\图表\附表13_排除同期冲击与替代解释1.xls", keep(chainleader lncovid BIS vas merge d_mps d_mayor) stats(coef se) dec(4) nolabel nocons replace
	
	*************************************************************
	***                                                       ***
	***            附表 14 排除同期冲击与替代解释2            ***  
	***                                                       ***
	*************************************************************

	/* Column 1 控制五年规划 */
	reghdfe TFP chainleader plan $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef141
	/* Column 2 控制开发区政策 */
	reghdfe TFP chainleader lndevezone $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef142
	/* Column 3 控制创新集群政策 */
	reghdfe TFP chainleader techzone $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef143
	/* Column 4 控制央企链长 */	
	reghdfe TFP chainleader firm_cl $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef144
	outreg2 [ef14*] using ".\图表\附表14_排除同期冲击与替代解释2.xls", keep(chainleader plan lndevezone techzone firm_cl) stats(coef se) dec(4) nolabel nocons replace

	*************************************************************
	***                                                       ***
	***                附表 15 溢出效应检验1                  ***  
	***                                                       ***
	*************************************************************		

	global W_controls "W_lnage W_lnasset W_lnsize W_lev W_edu W_ceo W_lngdppc W_secondary W_govexp W_ftd"
	
	/* Column 1 溢出效应检验 */
	reghdfe TFP chainleader LocalSpill SpatialSpill100 SpatialSpill200 SpatialSpill300 $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef151
	/* Column 2 空间滞后模型SLX */		
	reghdfe TFP chainleader W_chainleader $xlist $W_controls, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef152
	/* Column 3 空间杜宾模型SDM */		
	ivreghdfe TFP chainleader W_chainleader $xlist $W_controls (W_TFP = W2_chainleader), absorb(stkcd prv#year indid#year) cluster(city)
	est store ef153
	outreg2 [ef15*] using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader LocalSpill SpatialSpill100 SpatialSpill200 SpatialSpill300 W_chainleader W_TFP) stats(coef se) dec(4) nolabel nocons replace	
	/* Column 4-6 空间相关标准误 */		
	preserve
		egen indid_year = group(indid year)
		drop if missing(纬度) | missing(经度)
		acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(100) pfe1(stkcd) pfe2(indid_year) dropsingletons
		outreg2 using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append	
		acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(200) pfe1(stkcd) pfe2(indid_year) dropsingletons
		outreg2 using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
		acreg TFP chainleader $xlist, spatial latitude(纬度) longitude(经度) dist(300) pfe1(stkcd) pfe2(indid_year) dropsingletons
		outreg2 using ".\图表\附表15_溢出效应检验1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
	restore	
	
	*************************************************************
	***                                                       ***
	***                附表 16 溢出效应检验2                  ***  
	***                                                       ***
	*************************************************************	
	
	/* Column 1 控制组:同城市非实施产业链 */	
	reghdfe TFP chainleader $xlist if c_city_nind==1, absorb(stkcd prv#year indid#year) vce(cluster city)  
	est store ef161
	/* Column 2 控制组:非实施城市 */	
	reghdfe TFP chainleader $xlist if c_ncity==1, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef162
	/* Column 3 控制组:实施行业非实施城市 */	
	reghdfe TFP chainleader $xlist if c_ncity_ind==1, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef163
	/* Column 4 与本地的外地迁入企业交易占总交易数比*/
	reghdfe local_in chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef164
	/* Column 5 与本地的外地迁入企业交易占本地交易数比*/
	reghdfe local_inl chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef165
	outreg2 [ef16*] using ".\图表\附表16_溢出效应检验2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
	
	*************************************************************
	***                                                       ***
	***                附表 17 溢出效应检验3                  ***  
	***                                                       ***
	*************************************************************
	
	preserve 
		use "./数据/城市数据.dta", clear
		/* Column 1 企业进入 */
		reghdfe lnnewreg chainleader_c SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)
		est store ef171
		/* Column 2 发明专利 */
		reghdfe lncity_patent chainleader_c SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd, absorb(city year) vce(cluster city)
		est store ef172
		/* Column 3 企业进入-未实施链长制地区 */
		reghdfe lnnewreg SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd if treat==0, absorb(city year) vce(cluster city)
		est store ef173
		/* Column 4 发明专利-未实施链长制地区 */
		reghdfe lncity_patent SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300 lngdppc secondary govexp ftd if treat==0, absorb(city year) vce(cluster city)
		est store ef174
		outreg2 [ef17*] using ".\图表\附表17_溢出效应检验3.xls", keep(chainleader_c SpatialSpill_c100 SpatialSpill_c200 SpatialSpill_c300) stats(coef se) dec(4) nolabel nocons replace
	restore

	*************************************************************
	***                                                       ***
	***                附表 18 其他稳健性检验1                ***  
	***                                                       ***
	*************************************************************

	/* Column 1 更换OP法 */
	reghdfe TFP_OP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef181
	/* Column 2 更换ACF法 */
	reghdfe TFP_ACF chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef182
	/* Column 3 更换GMM法 */
	reghdfe TFP_GMM chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef183
	/* Column 4 市场份额 */
	reghdfe MS chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef184
	/* Column 5 市场加成率 */
	reghdfe PMR chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef185
	/* Column 6 控制市场份额 */
	reghdfe TFP chainleader MS $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef186
	/* Column 7 控制价格加成率 */
	reghdfe TFP chainleader PMR $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef187
	outreg2 [ef18*] using ".\图表\附表18_其他稳健性检验1.xls", keep(chainleader MS PMR) stats(coef se) dec(4) nolabel nocons replace
	
	*************************************************************
	***                                                       ***
	***                 附表 19 其他稳健性检验2               ***  
	***                                                       ***
	*************************************************************

	/* Column 1 更换核心解释变量（下半年推后） */
	reghdfe TFP chainleader_h $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef191
	/* Column 2 更换核心解释变量（以政府工作报告和政府文件中更早年份）*/
	reghdfe TFP chainleader_r $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef192
	/* Column 3 剔除上市公司少于5家城市 */
	reghdfe TFP chainleader $xlist if m_firm>=5, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef193
	/* Column 4 剔除上市公司少于10家城市 */
	reghdfe TFP chainleader $xlist if m_firm>=10, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef194
	outreg2 [ef19*] using ".\图表\附表19_其他稳健性检验2.xls", keep(chainleader_h chainleader_r chainleader) stats(coef se) dec(4) nolabel nocons replace	
	/* Column 5 改变样本窗口 */
	preserve
		use "./数据/上市公司数据_延长窗口期.dta", clear
		reghdfe TFP chainleader $xlist if zxs~=1, absorb(stkcd prv#year indid#year) vce(cluster city)
		outreg2 using ".\图表\附表19_其他稳健性检验2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
	restore
	/* Column 6 未剔除直辖市 */
	preserve
		use "./数据/上市公司数据_延长窗口期.dta", clear
		reghdfe TFP chainleader $xlist if year>=2014, absorb(stkcd prv#year indid#year) vce(cluster city)	
		outreg2 using ".\图表\附表19_其他稳健性检验2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons append
	restore
	
	*************************************************************
	***                                                       ***
	***                 附图 7 异质性分析结果                 ***  
	***                                                       ***
	*************************************************************	
	
	//行业门类-分组	
	foreach var in A B C D E F G I K L M N Q R S {
			reghdfe TFP chainleader $xlist if ind_d=="`var'", absorb(stkcd prv#year indid#year) vce(cluster city)
			est store e1`var'
	}
			 
	//合并建筑业(E)和房地产业(K)
	reghdfe TFP chainleader $xlist if ind_d=="E" | ind_d=="K", absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e1EK
	
	//合并其他服务业(L M N P Q R)
	reghdfe TFP chainleader $xlist if ind_d=="L" | ind_d=="M" | ind_d=="N" | ind_d=="P" | ind_d=="Q" | ind_d=="R", absorb(stkcd prv#year indid#year) vce(cluster city)
	est store e1QT
	
	coefplot e1A || e1B || e1C || e1D || e1F || e1G || e1I || e1EK || e1QT, ///
         keep(chainleader) ///
         xline(0) ///
         levels(90) ///
         graphregion(color(white)) ///
         bycoefs byopts(xrescale) ///
		 ylabel(1 `"{fontface "宋体":农、林、牧、渔业}"' ///
				2 `"{fontface "宋体":采矿业}"' ///
			    3 `"{fontface "宋体":制造业}"' ///
				4 `"{fontface "宋体":电力、热力、燃气及水生产和供应业}"' ///
				5 `"{fontface "宋体":批发和零售业}"' ///
				6 `"{fontface "宋体":交通运输、仓储和邮政业}"' ///
				7 `"{fontface "宋体":信息传输、软件和信息技术服务业}"' ///
				8 `"{fontface "宋体":建筑业和房地产业}"' ///
				9 `"{fontface "宋体":其他服务业}"', angle(horizontal)) ///
         xlabel(-1(0.5)1) ///
         msize(small) /// 
         mcolor(black) ///
         lcolor(black) /// 
         lpattern(solid) ///
         ciopts(lcolor(black) lpattern(solid)) ///
         xscale(range(-1 1)) ///
         legend(off) ///
         name(coefplot_chain, replace)
	graph export "./图表/附图7_行业异质性分析结果a.png", as(png) replace
	
	
	//制造业-分组
	foreach var in C13 C14 C15 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 C28 C29 C30 C31 C32 C33 C34 C35 C36 C37 C38 C39 C40 C41 C42 {
		reghdfe TFP chainleader $xlist if ind=="`var'", absorb(stkcd prv#year indid#year) vce(cluster city)
		est store e1`var'
	}	

	coefplot e1C13 || e1C14 || e1C15 || e1C17 || e1C18 || e1C19 || e1C21 || e1C22 || e1C23 || e1C24 || e1C25 || e1C26 || e1C27 || e1C28 || e1C29 || e1C30 || e1C31 || e1C32 || e1C33 || e1C34 || e1C35 || e1C36 || e1C37 || e1C38 || e1C39 || e1C40 || e1C41, ///
			 keep(chainleader) ///
			 xline(0) ///
			 levels(90) ///
			 graphregion(color(white)) ///
			 bycoefs byopts(xrescale) ///
			 ylabel(1 `"{fontface "宋体":农副食品加工业}"' ///  
					2 `"{fontface "宋体":食品制造业}"' ///
					3 `"{fontface "宋体":酒、饮料和精制茶制造业}"' ///
					4 `"{fontface "宋体":纺织业}"' /// 
					5 `"{fontface "宋体":纺织服装、服饰业}"' ///
					6 `"{fontface "宋体":皮革、毛皮、羽毛及其制品和制鞋业}"' ///
					7 `"{fontface "宋体":家具制造业}"' ///
					8 `"{fontface "宋体":造纸及纸制品业}"' ///
					9 `"{fontface "宋体":印刷和记录媒介复制业}"' ///
					10 `"{fontface "宋体":文教、工美、体育和娱乐用品制造业}"' ///
					11 `"{fontface "宋体":石油加工、炼焦及核燃料加工业}"' ///
					12 `"{fontface "宋体":化学原料及化学制品制造业}"' ///
					13 `"{fontface "宋体":医药制造业}"' ///
					14 `"{fontface "宋体":化学纤维制造业}"' /// 
					15 `"{fontface "宋体":橡胶和塑料制品业}"' ///
					16 `"{fontface "宋体":非金属矿物制品业}"' ///
					17 `"{fontface "宋体":黑色金属冶炼及压延加工业}"' ///
					18 `"{fontface "宋体":有色金属冶炼及压延加工业}"' ///
					19 `"{fontface "宋体":金属制品业}"' ///
					20 `"{fontface "宋体":通用设备制造业}"' ///
					21 `"{fontface "宋体":专用设备制造业}"' ///
					22 `"{fontface "宋体":汽车制造业}"' ///
					23 `"{fontface "宋体":铁路、船舶、航空航天和其它运输设备制造业}"' /// 
					24 `"{fontface "宋体":电气机械及器材制造业}"' ///
					25 `"{fontface "宋体":计算机、通信和其他电子设备制造业}"' ///
					26 `"{fontface "宋体":仪器仪表制造业}"' ///
					27 `"{fontface "宋体":其他制造业}"', angle(horizontal)) ///
			 xlabel(-1(0.5)1) ///
			 msize(small) /// 
			 mcolor(black) ///
			 lcolor(black) /// 
			 lpattern(solid) ///
			 ciopts(lcolor(black) lpattern(solid)) ///
			 xscale(range(-1 1)) ///
			 legend(off) ///
			 name(coefplot_chain, replace)
	graph export "./图表/附图7_行业异质性分析结果b.png", as(png) replace			
		
	*************************************************************
	***                                                       ***
	***             附表 20 行业异质性的原因分析              ***  
	***                                                       ***
	*************************************************************

	/* Column 1 外部风险-高 */		
	reghdfe TFP chainleader $xlist if g_incf==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef201
	/* Column 2 外部风险-低 */	
	reghdfe TFP chainleader $xlist if g_incf==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef202
	/* Column 3 技术密集-高 */	
	reghdfe TFP chainleader $xlist if g_tech==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef203
	/* Column 4 技术密集-低 */	
	reghdfe TFP chainleader $xlist if g_tech==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef204
	/* Column 5 产业链上游 */	
	reghdfe TFP chainleader $xlist if g_pos==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef205
	/* Column 6 产业链中下游 */	
	reghdfe TFP chainleader $xlist if g_pos==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef206
	/* Column 7 行业竞争程度-高 */	
	reghdfe TFP chainleader $xlist if g_hhl==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef207
	/* Column 8 行业竞争程度-低 */	
	reghdfe TFP chainleader $xlist if g_hhl==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef208
	outreg2 [ef20*] using ".\图表\附表20_行业异质性的原因分析.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
		
	*************************************************************
	***                                                       ***
	***             附表 21 减少交易摩擦的补充证据            ***  
	***                                                       ***
	*************************************************************

	/* Column 1 管理与销售成本 */	
	reghdfe cost_ms chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef211
	/* Column 2 管理与销售成本-剔除无关项 */	
	reghdfe cost_t chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef212
	/* Column 3 管理与销售成本-控制战略变革 */	
	reghdfe cost_ms chainleader strategy $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef213
	/* Column 4 管理与销售成本-控制业务调整 */	
	reghdfe cost_ms chainleader change $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef214
	/* Column 5 履约监督费用 */	
	reghdfe supcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef215
	/* Column 6 三项费用加和 */	
	reghdfe totalcost chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef216
	/* Column 7 上市公司原告 */	
	reghdfe clawsuit_y chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef217
	/* Column 8 上市公司被告 */	
	reghdfe clawsuit_b chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef218
	outreg2 [ef21*] using ".\图表\附表21_减少交易摩擦的补充证据.xls", keep(chainleader strategy change) stats(coef se) dec(4) nolabel nocons replace		
	
	*************************************************************
	***                                                       ***
	***        附表 22 改善本地供应链匹配质量的补充证据       ***  
	***                                                       ***
	*************************************************************

	/* Column 1 交易对象平均劳动生产率 */	
	reghdfe profitpc chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef221
	/* Column 2 与本地高新技术企业交易 */	
	reghdfe local_hte chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef222
	/* Column 3 与本地专精特新企业交易 */	
	reghdfe local_si chainleader $xlist , absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef223
	outreg2 [ef22*] using ".\图表\附表22_改善本地供应链匹配质量的补充证据.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
	
	*************************************************************
	***                                                       ***
	***            附表 23 适应不良风险的补充证据1            ***  
	***                                                       ***
	*************************************************************

	/* Column 1 产业配套-好 */	
	reghdfe TFP chainleader $xlist if g_clus2==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef231
	/* Column 2 产业配套-差 */	
	reghdfe TFP chainleader $xlist if g_clus2==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef232
	/* Column 3 市委书记调整频率-低 */
	reghdfe TFP chainleader $xlist if g_mps==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef233
	/* Column 4 市委书记调整频率-高 */	
	reghdfe TFP chainleader $xlist if g_mps==1, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef234
	/* Column 5 市长调整频率-低 */		
	reghdfe TFP chainleader $xlist if g_mayor==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef235
	/* Column 6 市长调整频率-高 */	
	reghdfe TFP chainleader $xlist if g_mayor==1, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef236
	outreg2 [ef23*] using ".\图表\附表23_适应不良风险的补充证据1.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
	
	//组间系数差异检验
	xtset, clear
	xtset city
	bdiff, group(g_clus2) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
	
	xtset, clear
	xtset city
	bdiff, group(g_mps) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
	
	xtset, clear
	xtset city
	bdiff, group(g_mayor) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
		
	*************************************************************
	***                                                       ***
	***            附表 24 适应不良风险的补充证据2            ***  
	***                                                       ***
	*************************************************************
	
	/* Column 1 本地采购-低 */	
	reghdfe TFP chainleader $xlist if g_govpur==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef241
	/* Column 2 本地采购-高 */	
	reghdfe TFP chainleader $xlist if g_govpur==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef242
	/* Column 3 市属国企占比-低 */
	reghdfe TFP chainleader $xlist if g_mstate==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef243
	/* Column 4 市属国企占比-高 */
	reghdfe TFP chainleader $xlist if g_mstate==1, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef244
	/* Column 5 有历史交易经验 */
	reghdfe TFP chainleader $xlist if  g_lpast==1, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef245
	/* Column 6 无历史交易经验 */
	reghdfe TFP chainleader $xlist if  g_lpast==0, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef246
	outreg2 [ef24*] using ".\图表\附表24_适应不良风险的补充证据2.xls", keep(chainleader) stats(coef se) dec(4) nolabel nocons replace
	
	//组间系数差异检验
	xtset, clear
	xtset city
	bdiff, group(g_govpur) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
	
	xtset, clear
	xtset city
	bdiff, group(g_mstate) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
	
	xtset, clear
	xtset city
	bdiff, group(g_lpast) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)	
	
	*************************************************************
	***                                                       ***
	***     附表 26 要素型协调与组织型协调的影响：补充证据    ***  
	***                                                       ***
	*************************************************************

	/* Column 1 产业链协作补贴 */	
	reghdfe q_chainsub c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef261
	/* Column 2 调研对接次数 */	
	reghdfe survey c.chainleader#c.res c.chainleader#c.org $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef262
	outreg2 [ef26*] using ".\图表\附表26_要素型协调与组织型协调的影响：补充证据.xls", keep(c.chainleader#c.res c.chainleader#c.org) stats(coef se) dec(4) nolabel nocons replace

	*************************************************************
	***                                                       ***
	***             附表 27 政策设计与差异化战略              ***  
	***                                                       ***
	*************************************************************	
	
	/* Column 1 产业链规划数量 */		
	reghdfe TFP c.chainleader#c.num_h c.chainleader#c.num_l $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef271
	/* Column 2 发展战略 */	
	reghdfe TFP c.chainleader#c.adv_h c.chainleader#c.adv_l $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)
	est store ef272
	/* Column 3 发展战略-经济发达 */	
	reghdfe TFP c.chainleader#c.adv_h c.chainleader#c.adv_l $xlist if g_gdp==1 , absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef273
	/* Column 4 发展战略-经济欠发达 */	
	reghdfe TFP c.chainleader#c.adv_h c.chainleader#c.adv_l $xlist if g_gdp==0, absorb(stkcd prv#year indid#year) vce(cluster city)	
	est store ef274
	outreg2 [ef27*] using ".\图表\附表27_政策设计与差异化战略.xls", keep(c.chainleader#c.num_h c.chainleader#c.num_l c.chainleader#c.adv_h c.chainleader#c.adv_l) stats(coef se) dec(4) nolabel nocons replace
	
