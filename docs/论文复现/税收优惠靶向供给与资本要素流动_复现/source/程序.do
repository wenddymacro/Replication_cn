********************************************************************************
**霍文希、谢贞发《税收优惠靶向供给与资本要素流动——来自税务服务专员制度的证据》**
**运行软件Stata/MP 17.0*********************************************************
********************************************************************************
use 数据1,clear
xtset idcitycp year
global  con  "size lev roa perr dual bigstock lrgdp2014t third2014t loan2014t"

***表1****
reghdfe ydcom_add1 did3  if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_add1 did3 lrgdp2014t third2014t loan2014t if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe ydcom_add1 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe ydcom_add1 did3  if treat3==1|ntreat==1,a(year#id year#prov_son id#city_son) cl(citycp)
est sto m4
esttab m1 m2 m3 m4 using 表1.rtf ,keep(did3) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表2***
reghdfe ydcom_add1 did1 if treat1==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_add1 did1 $con if treat1==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe ydcom_add1 did2 if treat2==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe ydcom_add1 did2 $con if treat2==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
esttab m1 m2 m3 m4 using 表2.rtf ,keep(did1 did2) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表3***
reghdfe ydcom_add1 c.did3#c.dis_1 c.did3#c.dis_2 c.did3#c.dis_3 c.did3#c.dis_4 c.did3#c.dis_5 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_add1 c.did3#c.envir_1 c.did3#c.envir_2 c.did3#c.envir_3 c.did3#c.envir_4 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
esttab m1 m2 using 表3.rtf ,keep(c.did3#c.dis_1 c.did3#c.dis_2 c.did3#c.dis_3 c.did3#c.dis_4 c.did3#c.dis_5 c.did3#c.envir_1 c.did3#c.envir_2 c.did3#c.envir_3 c.did3#c.envir_4) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表4***
reghdfe ydcom_add1 did3 $con if treat3==1&deep==0|ntreat==1&deep==0,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_add1 did3 $con if treat3==1&deep==1|ntreat==1&deep==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe Fydcom_q1 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe Fydcom_q2 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
reghdfe Fydcom_q3 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m5
reghdfe Fydcom_q4 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m6
esttab m1 m2 m3 m4 m5 m6 using 表4.rtf ,keep(did3) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表5***
reghdfe ydcom_add1 c.did3##c.gqrd $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_add1 c.did3##c.addac $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe ydcom_add1 c.did3##c.assetac $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe ydcom_add1 c.did3##c.survat $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
esttab m1 m2 m3 m4 using 表5.rtf ,keep(c.did3#c.gqrd c.did3#c.addac c.did3#c.survat c.did3#c.assetac did3 gqrd addac assetac survat) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表6***
reghdfe mcost_g did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_dum1 c.did3##c.zdcost_g $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe muncer_g did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe ydcom_dum1 c.did3##c.uncer_g $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
reghdfe mtaxb_g did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m5
reghdfe ydcom_dum1 c.did3##c.taxb_g $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m6
esttab m1 m2 m3 m4 m5 m6 using 表6.rtf ,keep(c.did3#c.zdcost_g c.did3#c.uncer_g c.did3#c.taxb_g did3 zdcost_g uncer_g taxb_g) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表7***
reghdfe Fpoor c.did3##c.ydcom_dum1 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe Fconjy_all c.did3##c.ydcom_dum1 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe Fconjy_qz c.did3##c.ydcom_dum1 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe Fconjy_fqz c.did3##c.ydcom_dum1 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
reghdfe ydcom_add1 c.did3#c.cyjj1 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m5
reghdfe ydcom_add1 c.did3#c.cyjj2 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m6
reghdfe ydcom_dum1 c.did3#c.cyjj1 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m7
reghdfe ydcom_dum1 c.did3#c.cyjj2 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m8
esttab m1 m2 m3 m4 m5 m6 m7 m8 using 表7.rtf ,keep(c.did3#c.ydcom_dum1 did3 ydcom_dum1 c.did3#c.cyjj1 c.did3#c.cyjj2) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***表8***
use 数据2,clear
global con "size lev roa perr dual bigstock lrgdp2014t third2014t loan2014t"
xtset id year
reghdfe Fbdcom    did $con ,a(year id) cl(id)
est sto m1
reghdfe Fbdcom_50 did $con ,a(year id) cl(id)
est sto m2
reghdfe Fppe      did $con ,a(year id) cl(id)
est sto m3
reghdfe Frd       did $con ,a(year id) cl(id)
est sto m4
esttab m1 m2 m3 m4 using 表8.rtf ,keep(did) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***附表1***
use 数据1,clear
xtset idcitycp year
global  con  "size lev roa perr dual bigstock lrgdp2014t third2014t loan2014t"
sum ydcom_add1 did3 if treat3==1
sum2docx ydcom_add1 did3 using 描述性统计a.docx if treat3==1,replace stats (N mean(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f)) title("描述性统计a")

sum ydcom_add1 did1 if treat1==1
sum2docx ydcom_add1 did1 using 描述性统计b.docx if treat1==1,replace stats (N mean(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f)) title("描述性统计b")

sum ydcom_add1 did2 if treat2==1
sum2docx ydcom_add1 did2 using 描述性统计c.docx if treat2==1,replace stats (N mean(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f)) title("描述性统计c")

sum ydcom_add1 if ntreat==1
sum2docx ydcom_add1 using 描述性统计d.docx if ntreat==1,replace stats (N mean(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f)) title("描述性统计d")

sum size lev roa perr dual bigstock lrgdp2014 third2014 loan2014 if treat1==1|treat2==1|treat3==1|ntreat==1
sum2docx size lev roa perr dual bigstock lrgdp2014 third2014 loan2014 using 描述性统计e.docx if treat1==1|treat2==1|treat3==1|ntreat==1,replace stats (N mean(%9.4f) sd(%9.4f) min(%9.4f) max(%9.4f)) title("描述性统计e")

***附图3***
//仅异地//
reghdfe ydcom_add1 pre_4_y pre_3_y pre_2_y pre_1_y post_0_y post_1_y post_2_y post_3_y $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)

coefplot, baselevels keep(pre_4_y pre_3_y pre_2_y pre_1_y post_0_y post_1_y post_2_y post_3_y) order(pre_4_y pre_3_y pre_2_y pre_1_y post_0_y post_1_y post_2_y post_3_y) omitted vertical coeflabels(pre_4_y = "-4" pre_3_y = "-3" pre_2_y = "-2" pre_1_y = "-1" post_0_y = "0" post_1_y = "+1" post_2_y = "+2" post_3_y = "+3") level(90) yline(0,lcolor(edkblue*0.8)) c(l) xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(,labsize(*1)) xlabel(,labsize(*1)) legend(label(1 `"90%{fontface "宋体":置信区间}"') label(2 `"{fontface "宋体": 估计系数}"') rows(1) order(1 2) ) ytitle("政策动态经济效应", size(middle)) xtitle("政策时点", size(middle)) ciopts(lpattern(dash) recast(rline) msize(medium)) msymbol(circle_hollow) scheme(s1mono)

//本地异地//
reghdfe ydcom_add1 pre_4_by pre_3_by pre_2_by pre_1_by post_0_by post_1_by post_2_by post_3_by $con if treat1==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)

coefplot, baselevels keep(pre_4_by pre_3_by pre_2_by pre_1_by post_0_by post_1_by post_2_by post_3_by) order(pre_4_by pre_3_by pre_2_by pre_1_by post_0_by post_1_by post_2_by post_3_by) omitted vertical coeflabels(pre_4_by = "-4" pre_3_by = "-3" pre_2_by = "-2" pre_1_by = "-1" post_0_by = "0" post_1_by = "+1" post_2_by = "+2" post_3_by = "+3") level(90) yline(0,lcolor(edkblue*0.8)) c(l) xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(,labsize(*1)) xlabel(,labsize(*1)) legend(label(1 `"90%{fontface "宋体":置信区间}"') label(2 `"{fontface "宋体": 估计系数}"') rows(1) order(1 2) ) ytitle("政策动态经济效应", size(middle)) xtitle("政策时点", size(middle)) ciopts(lpattern(dash) recast(rline) msize(medium)) msymbol(circle_hollow) scheme(s1mono)

//仅本地//
reghdfe ydcom_add1 pre_4_b pre_3_b pre_2_b pre_1_b post_0_b post_1_b post_2_b post_3_b $con if treat2==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)

coefplot, baselevels keep(pre_4_b pre_3_b pre_2_b pre_1_b post_0_b post_1_b post_2_b post_3_b) order(pre_4_b pre_3_b pre_2_b pre_1_b post_0_b post_1_b post_2_b post_3_b) omitted vertical coeflabels(pre_4_b = "-4" pre_3_b = "-3" pre_2_b = "-2" pre_1_b = "-1" post_0_b = "0" post_1_b = "+1" post_2_b = "+2" post_3_b = "+3") level(90) yline(0,lcolor(edkblue*0.8)) c(l) xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(,labsize(*1)) xlabel(,labsize(*1)) legend(label(1 `"90%{fontface "宋体":置信区间}"') label(2 `"{fontface "宋体": 估计系数}"') rows(1) order(1 2) ) ytitle("政策动态经济效应", size(middle)) xtitle("政策时点", size(middle)) ciopts(lpattern(dash) recast(rline) msize(medium)) msymbol(circle_hollow) scheme(s1mono)

***附表2***
reghdfe ydcom_add50 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_dum1 did3 $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe ydcom_add1 did3 c.mmsize#c.year c.mmlev#c.year c.mmroa#c.year c.mmperr#c.year c.mmdual#c.year c.mmbigstock#c.year lrgdp2014t third2014t loan2014t if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe ydcom_add1 did3 $con if treat3==1&pro_city==0&pro_city_son==0|ntreat==1&pro_city==0&pro_city_son==0,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
reghdfe ydcom_add1 did3 $con if treat3==1&monindus==0|ntreat==1&monindus==0,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m5
esttab m1 m2 m3 m4 m5 using 附表2.rtf ,keep(did3) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap

***异质性处理效应_权重分解***
twowayfeweights ydcom_add1 idcitycp year did3 if treat3==1|ntreat==1, controls($con) type(feTR)

***附表3***
reghdfe ydcom_add1 did3 finaccdid finaccdid_son $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m1
reghdfe ydcom_add1 did3 digtax digtax_son $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m2
reghdfe ydcom_add1 did3 busendid busendid_son $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m3
reghdfe ydcom_add1 did3 taxsodid $con if treat3==1|ntreat==1,a(year#prov year#prov_son id#city_son) cl(citycp)
est sto m4
esttab m1 m2 m3 m4 using 附表3.rtf ,keep(did3 finaccdid finaccdid_son digtax digtax_son busendid busendid_son taxsodid) replace b(%6.4f) se(%6.4f) ar2(4) star(* 0.1 ** 0.05 *** 0.01) compress nogap