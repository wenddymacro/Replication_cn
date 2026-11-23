
**********************************************************************
*stata18
**********************************************************************
cd :\数据

global citycons "lngdp-lnhighway" //滞后一期

*******************************正文图表*******************************
**城市面板数据回归
use city17_22, clear

*表3 基准回归结果
reg gini digit_gov, cluster(citycode)
est store m1
reghdfe gini digit_gov, absorb(citycode) cluster(citycode)
est store m2
reghdfe gini digit_gov, absorb(citycode year) cluster(citycode)
est store m3
reghdfe gini digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m4
ivreghdfe gini (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode) first
est store m5
esttab m1 m2 m3 m4 m5, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) ar(4) keep(digit_gov)


*表4 不平等指数分解：区县内vs区县间
reghdfe theil_within digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe theil_within (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m2
reghdfe theil_between digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe theil_between (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表12 异质性分析
*Panel A 政府部门空间集中度
reghdfe gini digit_gov $citycons if concentration==0, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe gini (digit_gov=iv) $citycons if concentration==0, absorb(citycode year) cluster(provcode)
est store m2

reghdfe gini digit_gov $citycons if concentration==1, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe gini (digit_gov=iv) $citycons if concentration==1, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*Panel B 交通基础设施水平
reghdfe gini digit_gov $citycons if transport==0, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe gini (digit_gov=iv) $citycons if transport==0, absorb(citycode year) cluster(provcode)
est store m2

reghdfe gini digit_gov $citycons if transport==1, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe gini (digit_gov=iv) $citycons if transport==1, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*Panel C 网络基础设施水平
reghdfe gini digit_gov $citycons if internet==1, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe gini (digit_gov=iv) $citycons if internet==1, absorb(citycode year) cluster(provcode)
est store m2

reghdfe gini digit_gov $citycons if internet==0, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe gini (digit_gov=iv) $citycons if internet==0, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*Panel D 人力资本水平
reghdfe gini digit_gov $citycons if human_capital==1, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe gini (digit_gov=iv) $citycons if human_capital==1, absorb(citycode year) cluster(provcode)
est store m2

reghdfe gini digit_gov $citycons if human_capital==0, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe gini (digit_gov=iv) $citycons if human_capital==0, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表13 数字政府建设与资本配置效率
reghdfe misallocation digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe misallocation (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m2

reghdfe insufficient digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe insufficient (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


**区县面板数据回归
use county17_22, clear

*表5 数字政府建设与区县夜间灯光强度
reghdfe lnlight digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnlight (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode) first
est store m2
reghdfe lnlight digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnlight (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode) first
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*图1 数字政府建设对区县夜间灯光亮度的影响（分距离）
*a.OLS
reghdfe lnlight digit_gov $citycons if distance>0 & distance<=20, absorb(countycode year) cluster(citycode)
est store m1
reghdfe lnlight digit_gov $citycons if distance>20 & distance<=40, absorb(countycode year) cluster(citycode)
est store m2
reghdfe lnlight digit_gov $citycons if distance>40 & distance<=60, absorb(countycode year) cluster(citycode)
est store m3
reghdfe lnlight digit_gov $citycons if distance>60 & distance<=80, absorb(countycode year) cluster(citycode)
est store m4
reghdfe lnlight digit_gov $citycons if distance>80, absorb(countycode year) cluster(citycode)
est store m5
esttab m1 m2 m3 m4 m5, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) ar(4) keep(digit_gov)

*b.2SLS
ivreghdfe lnlight (digit_gov=iv) $citycons if distance<=20, absorb(countycode year) cluster(provcode) first
est store m1
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>20 & distance<=40, absorb(countycode year) cluster(provcode) first
est store m2
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>40 & distance<=60, absorb(countycode year) cluster(provcode) first
est store m3
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>60 & distance<=80, absorb(countycode year) cluster(provcode) first
est store m4
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>80, absorb(countycode year) cluster(provcode) first
est store m5
esttab m1 m2 m3 m4 m5, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表6  数字政府建设与政务服务效率
*人民网投诉量
reghdfe lncomplaint digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lncomplaint (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lncomplaint digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lncomplaint (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4

*人民网投诉办理时长
reghdfe lntime digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m5
ivreghdfe lntime (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode) first
est store m6
reghdfe lntime digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m7
ivreghdfe lntime (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode) first
est store m8
esttab m1 m2 m3 m4 m5 m6 m7 m8, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表7 数字政府建设与区县生产效率
*Panel A 税收调查企业
reghdfe tfp_tax digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe tfp_tax (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe tfp_tax digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe tfp_tax (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)

*Panel B "新三板"企业
reghdfe tfp_NEED digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe tfp_NEED (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe tfp_NEED digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe tfp_NEED (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表8 数字政府建设与企业进入
*Panel A 新增工商注册企业
reghdfe lnnew_firm digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnnew_firm (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnnew_firm digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnnew_firm (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)

*Panel B 上市公司设立子公司
reghdfe lnsubfirm digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnsubfirm (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnsubfirm digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnsubfirm (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表9 数字政府建设与劳动力流入
*Panel A 全部劳动力
reghdfe lnlabor_total digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnlabor_total (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnlabor_total digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnlabor_total (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)

*Panel B 大专及以下
reghdfe lnlabor_low digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnlabor_low (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnlabor_low digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnlabor_low (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)

*Panel C 大专以上
reghdfe lnlabor_high digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnlabor_high (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnlabor_high digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnlabor_high (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表10 数字政府建设与土地出让
*Panel A 工业用地
reghdfe lnland_industry digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnland_industry (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnland_industry digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnland_industry (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)

*Panel B 商业用地
reghdfe lnland_commercial digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnland_commercial (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnland_commercial digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnland_commercial (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*表11 数字政府建设与城市内部要素流动
*Panel A 在本市设立子公司数量
reghdfe lnsubfirm_district digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lnsubfirm_district (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe lnsubfirm_district digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lnsubfirm_district (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)

*Panel B 是否有市内并购
reghdfe dmerge digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe dmerge (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode)
est store m2
reghdfe dmerge digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe dmerge (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*******************************附录图表*******************************
**城市面板数据回归
use city17_22, clear

*附表12 城市变量释义及描述性统计
sum gini theil cv theil_within theil_between digit_gov $citycons


*附图2
reghdfe gini pre4-post4 $citycons, absorb(citycode year) cluster(provcode)


*附表14 工具变量有效性检验
*控制省级同期政策与投入的影响
reghdfe gini digit_gov policy1 policy2 lndigit_exp_prov ln4G $citycons, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe gini (digit_gov=iv) policy1 policy2 lndigit_exp_prov ln4G $citycons, absorb(citycode year) cluster(provcode) first
est store m2

*其他工具变量(数字政府建设专项财政投入)
ivreghdfe gini (digit_gov=iv2) $citycons, absorb(citycode year) cluster(provcode) first
est store m3

*省份-年份聚类
ivreghdfe gini (digit_gov=iv) $citycons, absorb(citycode year) cluster(prov_year) first
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov policy1 policy2 policy3 lndigit_exp_prov ln4G)


*附表15 其他稳健性检验
*其他竞争性假说
reghdfe gini digit_gov non_tax lnlight_park lninvest $citycons, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe gini (digit_gov=iv) non_tax lnlight_park lninvest $citycons, absorb(citycode year) cluster(provcode) first
est store m2

*控制省份-年份固定效应
reghdfe gini digit_gov $citycons, absorb(citycode provcode#year) cluster(citycode)
est store m3

*其他不平等指数
reghdfe theil digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m4
ivreghdfe theil (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m5
reghdfe cv digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m6
ivreghdfe cv (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m7
esttab m1 m2 m3 m4 m5 m6 m7, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov non_tax lnlight_park lninvest)


*附表18 区县间经济产出差距
*区县GDP之差
reghdfe delta_gdp digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m1
ivreghdfe delta_gdp (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m2

*区县revenue之差
reghdfe delta_revenue digit_gov $citycons, absorb(citycode year) cluster(citycode)
est store m3
ivreghdfe delta_revenue (digit_gov=iv) $citycons, absorb(citycode year) cluster(provcode)
est store m4
esttab m1 m2 m3 m4, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*附表16 基于政策冲击的DID估计结果
use city10_22, clear

reghdfe gini did2 $citycons, absorb(citycode year) cluster(citycode)
est store m1
reghdfe gini did3 $citycons, absorb(citycode year) cluster(citycode)
est store m2
esttab m1 m2, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(did2 did3)

*附图3 平行趋势检验
*a.信息惠民试点政策
reghdfe gini pre2_4-post2_4 $citycons, absorb(citycode year) cluster(citycode)
*b.政务微信公众号
reghdfe gini pre3_4-post3_4 $citycons, absorb(citycode year) cluster(citycode)


**区县面板
use county17_22,clear

*附表13 区县变量释义及描述性统计
sum lnlight-lnland_commercial


*附表17 数字政府建设对区县夜间灯光亮度的影响（分距离）
*Panel A OLS
reghdfe lnlight digit_gov $citycons if distance>0 & distance<=20, absorb(countycode year) cluster(citycode)
est store m1
reghdfe lnlight digit_gov $citycons if distance>20 & distance<=40, absorb(countycode year) cluster(citycode)
est store m2
reghdfe lnlight digit_gov $citycons if distance>40 & distance<=60, absorb(countycode year) cluster(citycode)
est store m3
reghdfe lnlight digit_gov $citycons if distance>60 & distance<=80, absorb(countycode year) cluster(citycode)
est store m4
reghdfe lnlight digit_gov $citycons if distance>80, absorb(countycode year) cluster(citycode)
est store m5
esttab m1 m2 m3 m4 m5, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) ar(4) keep(digit_gov)

*Panel B 2SLS
ivreghdfe lnlight (digit_gov=iv) $citycons if distance<=20, absorb(countycode year) cluster(provcode) first
est store m1
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>20 & distance<=40, absorb(countycode year) cluster(provcode) first
est store m2
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>40 & distance<=60, absorb(countycode year) cluster(provcode) first
est store m3
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>60 & distance<=80, absorb(countycode year) cluster(provcode) first
est store m4
ivreghdfe lnlight (digit_gov=iv) $citycons if distance>80, absorb(countycode year) cluster(provcode) first
est store m5
esttab m1 m2 m3 m4 m5, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


*附表19 数字政府建设与区县经济产出
*人均GDP
reghdfe lngdp_pc digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m1
ivreghdfe lngdp_pc (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode) first
est store m2
reghdfe lngdp_pc digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m3
ivreghdfe lngdp_pc (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode) first
est store m4

*人均财政收入
reghdfe lnrevenue_pc digit_gov $citycons if county==1, absorb(countycode year) cluster(citycode)
est store m5
ivreghdfe lnrevenue_pc (digit_gov=iv) $citycons if county==1, absorb(countycode year) cluster(provcode) first
est store m6
reghdfe lnrevenue_pc digit_gov $citycons if county==0, absorb(countycode year) cluster(citycode)
est store m7
ivreghdfe lnrevenue_pc (digit_gov=iv) $citycons if county==0, absorb(countycode year) cluster(provcode) first
est store m8
esttab m1 m2 m3 m4 m5 m6 m7 m8, nogaps b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) keep(digit_gov)


