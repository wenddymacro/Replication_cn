*-----------------------------------------------------------------------------------
use "data_city_before.dta"

//删除没有发行过任何城投债的城市
gen is_missing = missing(bondnew_h)
bysort province city: egen total_missing = total(is_missing)
bysort province city: egen total_years = count(year)
drop if total_missing == total_years
drop is_missing total_missing total_years

//公共财政部分
gen fiscalrevene=f1/10000
replace fiscalrevene=公共财政收入 if fiscalrevene==.
replace 政府性基金收入=土地出让收入 if 政府性基金收入==.
rename 政府性基金收入 fundrevene
rename 国有资本经营收入 capitalrevene
rename 转移支付收入 transfer
rename 土地出让收入 landrevene
rename 财政自给率 fiscalratio
label variable fiscalrevene "公共财政收入(亿元)=税收收入+非税收收入"
label variable fundrevene "政府性基金收入(亿元)"
label variable capitalrevene "国有资本经营收入(亿元)"
label variable transfer "转移支付收入(亿元)=一般性转移支付收入+专项转移支付收入+上级补助收入+返还性收入"
label variable landrevene "土地出让收入（亿元）"
egen fiscal=rowtotal(fiscalrevene fundrevene capitalrevene)
label variable fiscal "地方政府拥有的财政资源（亿元）：公共财政收入+政府性基金收入+国有资本经营收入"
gen lnfiscal=ln(fiscal) //地方政府拥有的财政资源
gen fiscal_GDP=fiscal/(GDP/10000)
drop fiscalratio
gen fiscalratio=(fiscalrevene/f2)*100
label variable fiscalratio "财政自给率"
gen fiscalgap=(f2/10000)-(f1/10000) //一般财政预算缺口
label variable fiscalgap "一般财政预算缺口（亿元）"
gen fiscalgap_ratio=fiscalgap/(f1/10000)
label variable fiscalgap_ratio "一般财政预算缺口比率"
drop 公共财政收入-省份

//控制变量
gen lnpop=ln(pop) //人口
gen lnGDP=ln(GDP) //经济发展水平
gen lnRevene=ln(revene) //工业收入
gen lnCos=ln(cos) //消费
gen lnIncome=ln(income) //工资水平
gen lninvest=ln(invest) //固定资产投资水平
gen lnperGDP=ln(perGDP)
gen lnloan=ln(debt)

//生成滞后变量
xtset city year

//滞后
foreach var in fiscalgap_ratio fiscal_GDP lnpop lnGDP lninvest DLratio GDPg achhi sec qchhi {
    gen `var'_z =L.`var'
}

//年份
drop if year<2003

//缩尾
winsor2 bondnew_h bondold_h bankloan_h trustnew_h trustold_h rentnew_h rentold_h othernew_h otherold_h,cut(1 99) replace

local vars bondnew_c bondold_c bondnew_d bondold_d bondnew_h bondold_h bondnew_t bondold_t trustnew_c trustold_c trustnew_d trustold_d trustnew_h trustold_h trustnew_t trustold_t rentnew_c rentold_c rentnew_d rentold_d rentnew_h rentold_h rentnew_t rentold_t othernew_c otherold_c othernew_d otherold_d othernew_h otherold_h othernew_t otherold_t

//替换缺失值
foreach var in `vars' {
    replace `var' = 0 if missing(`var')
}

//地市级
gen debtnew_c=bondnew_c+trustnew_c+othernew_c+rentnew_c
label variable debtnew_c "地级市政府债务新增（亿元）"

gen feibiaonew_c=trustnew_c+othernew_c+rentnew_c
label variable feibiaonew_c "地级市政府非标融资新增（亿元）"

gen debtold_c=bondold_c+trustold_c+otherold_c+rentold_c
label variable debtold_c "地级市政府债务存量（亿元）"

gen feibiaoold_c=trustold_c+otherold_c+rentold_c
label variable feibiaoold_c "地级市政府非标融资存量（亿元）"

//区县级
gen debtnew_d=bondnew_d+trustnew_d+othernew_d+rentnew_d
label variable debtnew_d "地级市政府债务新增（亿元）"

gen feibiaonew_d=trustnew_d+othernew_d+rentnew_d
label variable feibiaonew_d "地级市政府非标融资新增（亿元）"

gen debtold_d=bondold_d+trustold_d+otherold_d+rentold_d
label variable debtold_d "地级市政府债务存量（亿元）"

gen feibiaoold_d=trustold_d+otherold_d+rentold_d
label variable feibiaoold_d "地级市政府非标融资存量（亿元）"

//地市及区县级
gen debtnew_h=bondnew_h+trustnew_h+othernew_h+rentnew_h
label variable debtnew_h "地级市及以下政府债务新增（亿元）"

gen feibiaonew_h=trustnew_h+othernew_h+rentnew_h
label variable feibiaonew_h "地级市及以下政府非标融资新增（亿元）"

gen debtold_h=bondold_h+trustold_h+otherold_h+rentold_h
label variable debtold_h "地级市及以下政府债务存量（亿元）"

gen feibiaoold_h=trustold_h+otherold_h+rentold_h
label variable feibiaoold_h "地级市及以下政府非标融资存量（亿元）"

//省市区
gen debtnew_t=bondnew_t+trustnew_t+othernew_t+rentnew_t
label variable debtnew_t "省市区政府债务新增（亿元）"

gen feibiaonew_t=trustnew_t+othernew_t+rentnew_t
label variable feibiaonew_t "省市区政府非标融资新增（亿元）"

gen debtold_t=bondold_t+trustold_t+otherold_t+rentold_t
label variable debtold_t "省市区政府债务存量（亿元）"

gen feibiaoold_t=trustold_t+otherold_t+rentold_t
label variable feibiaoold_t "省市区政府非标融资存量（亿元）"

foreach var in debtnew_h feibiaonew_h bondnew_h trustnew_h rentnew_h othernew_h {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtold_h feibiaoold_h bondold_h trustold_h rentold_h otherold_h {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtnew_c feibiaonew_c bondnew_c trustnew_c rentnew_c othernew_c {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtold_c feibiaoold_c bondold_c trustold_c rentold_c otherold_c {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtnew_d feibiaonew_d bondnew_d trustnew_d rentnew_d othernew_d {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtold_d feibiaoold_d bondold_d trustold_d rentold_d otherold_d {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtnew_t feibiaonew_t bondnew_t trustnew_t rentnew_t othernew_t {
	gen `var'_l = ln(`var'+1)
}

foreach var in debtold_t feibiaoold_t bondold_t trustold_t rentold_t otherold_t {
	gen `var'_l = ln(`var'+1)
}


foreach var in bankloan_c bankloan_d bankloan_h {
	egen `var'_m=mean(`var')
	egen `var'_sd=sd(`var')
	gen `var'_z = (`var'-`var'_m )/`var'_sd 
}


xtset city year

egen debt_h_new=rowtotal(debtnew_h bank_c)
label variable debt_h_new "市区政府债务总量增量（亿元）"

egen debt_h_old=rowtotal(debtold_h bankloan_h)
label variable debt_h_old "市区政府债务总量存量（亿元）"

save "data_city_after.dta"

*--------------------------------------------------------------------------------------------
use "data_province_before.dta",clear
egen debtnew_s=rowtotal(bondnew_s trustnew_s rentnew_s othernew_s)
egen debtold_s=rowtotal(bondold_s trustold_s rentold_s otherold_s)

egen debtnew_p=rowtotal(bondnew_p trustnew_p rentnew_p othernew_p)
egen debtold_p=rowtotal(bondold_p trustold_p rentold_p otherold_p)

egen feibiaonew_p=rowtotal(trustnew_p rentnew_p othernew_p)
egen feibiaoold_p=rowtotal(trustold_p rentold_p otherold_p)

replace bondnew_p=0 if bondnew_p==.
replace bondold_p=0 if bondold_p==.

//取对数
gen debtnew_p_l=ln(debtnew_p+1)
gen debtold_p_l=ln(debtold_p+1)

gen bondnew_p_l=ln(bondnew_p+1)
gen bondold_p_l=ln(bondold_p+1)

gen feibiaonew_p_l=ln(feibiaonew_p+1)
gen feibiaoold_p_l=ln(feibiaoold_p+1)

//取标准化
foreach var in debtnew_p debtold_p {
	egen `var'_m=mean(`var')
	egen `var'_sd=sd(`var')
	gen `var'_z = (`var'-`var'_m )/`var'_sd //Z-score变换
}

foreach var in bankloan_p {
	egen `var'_m=mean(`var')
	egen `var'_sd=sd(`var')
	gen `var'_z = (`var'-`var'_m )/`var'_sd //Z-score变换
}

drop if 省份=="北京市"|省份=="天津市"|省份=="重庆市"|省份=="上海市"
drop if 省份=="西藏自治区"

gen event=1 if 省份=="安徽省"&year>=2005
replace event=1 if 省份=="江苏省"&year>=2007
replace event=1 if 省份=="吉林省"&year>=2007
replace event=1 if 省份=="黑龙江省"&year>=2009
replace event=1 if 省份=="陕西省"&year>=2009
replace event=1 if 省份=="湖北省"&year>=2010
replace event=1 if 省份=="湖南省"&year>=2010
replace event=1 if 省份=="甘肃省"&year>=2011
replace event=1 if 省份=="贵州省"&year>=2012
replace event=1 if 省份=="河南省"&year>=2014
replace event=1 if 省份=="江西省"&year>=2015
replace event=1 if 省份=="四川省"&year>=2020
replace event=1 if 省份=="辽宁省"&year>=2021
replace event=1 if 省份=="山西省"&year>=2021
replace event=0 if event==.

drop if year<2003|year>2018

save "data_province_after.dta"

*--------------------------------------------------------------------------------------------
use "data_firm_before.dta",clear
drop if city==.
drop if prov==2 
drop if prov==11|prov==12|prov==31|prov==50 //删掉直辖市
drop if city==21|city==22|city==33|city==1200 //删掉直辖市
drop if control==3 //删掉中央企业

xtset panelid year

gen fixed_assets=(gdzchj/Index1)*100 //调整后的固定资产价格

gen inv1=fixed_assets-L.fixed_assets  
gen inv2=fixed_assets-0.95*L.fixed_assets  //考虑折旧

winsor2 inv1 inv2 ,cut(1 99) replace 

gen lnage=ln(age)
gen lnsize=ln(zczj) 
gen lev=fzhj/zczj 
gen liquidity=ldzchj/zczj
egen ind=group(ind3) 
gen profit=lrze/fzhj 

gen lnage_z=L.lnage
gen lnsize_z=L.lnsize
gen lev_z=L.lev
gen liquidity_z=L.liquidity
gen inv1_z=L.inv1
gen profit_z=L.profit

save "data_firm_after.dta",replace
