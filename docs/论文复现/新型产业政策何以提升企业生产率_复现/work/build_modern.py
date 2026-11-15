from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=(root/'work/modern_source.txt').read_text(encoding='utf-8')
common='''clear all
set more off
set processors 1
set seed 824
adopath ++ "../output/local_ado"
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
'''
def write(name,body):
    (root/'work'/f'run_{name}.do').write_text(common+f'log using "../output/{name}.log", text replace\n'+body+f'\ndisplay "COMPLETE_{name}"\nlog close\n',encoding='utf-8')
def exportmat(b,v,name,diag=False):
    return f'''
matrix bb={b}
matrix vv={v}
postfile coef str40 term double b se using "../output/{name}.dta", replace
local terms : colnames bb
local j=0
foreach term of local terms {{
local ++j
post coef ("`term'") (bb[1,`j']) (sqrt(vv[{"1,`j'" if diag else "`j',`j'"}]))
}}
postclose coef
preserve
use "../output/{name}.dta", clear
export delimited using "../output/{name}.csv", replace
restore
'''
bacon=source[:source.index('//生成动态效应的变量')]
bacon=bacon.replace('./图表/','../output/')
bacon=bacon.replace('bacondecomp TFP_ipo chainleader ipo_* ,ddetail vce(r)','bacondecomp TFP_ipo chainleader ipo_* ,ddetail vce(r)\nereturn list\nreturn list\ncapture estimates save "../output/bacon.ster", replace')
write('bacon','quietly reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)\ngen esample=e(sample)\n'+bacon)
prep=source[source.index('//生成动态效应的变量'):source.index('/* Method 1')]
cs=source[source.index('csdid TFP'):source.index('/* Method 2')]
cs_original=cs
cs=cs.replace('estat event, window(-3 3) estore(cs_est)','estat event, window(-3 3) post\nestimates store cs_est')
write('cs',prep+cs+'\nestimates save "../output/cs.ster", replace\n'+exportmat('cs_b','cs_v','cs'))
write('cs_legacy','adopath ++ "../output/csdid_legacy"\n'+prep+cs_original+'\nestimates save "../output/cs_legacy.ster", replace\n'+exportmat('cs_b','cs_v','cs_legacy'))
lp=source[source.index('xtset stkcd year',source.index('/* Method 2')):source.index('/* Method 3')]
write('lp',prep+lp+exportmat('lpdid_b','lpdid_v','lp'))
sa=source[source.index('gen cohort='):source.index('// 将省略的 -1')]
write('sa',prep+sa+'\nmatrix list e(b_iw)\nmatrix list e(V_iw)\n'+exportmat('e(b_iw)','e(V_iw)','sa'))
dd=source[source.index('did_multiplegt TFP'):source.index('event_plot cs_b')]
# Current SSC splits the legacy estimator into did_multiplegt_old. Keep all estimation options.
dd=dd.replace('did_multiplegt TFP','did_multiplegt_old TFP')
write('dd',prep+dd+'\nereturn list\nmatrix list dd_b\nmatrix list dd_v\n'+exportmat("dd_b'","dd_v'",'dd',True))
print('Generated five estimator runners')
