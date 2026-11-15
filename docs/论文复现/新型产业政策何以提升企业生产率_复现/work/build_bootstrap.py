from pathlib import Path
root=Path(__file__).resolve().parents[1]
groups=['g_clus1','g_gc','g_contract','g_clus2','g_mps','g_mayor','g_govpur','g_mstate','g_lpast']
for group in groups:
    text=f'''clear all
set more off
set processors 1
adopath ++ "../output/local_ado"
log using "../output/bootstrap_{group}.log", text replace
use "../author/listed.dta", clear
global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"
xtset city
bdiff, group({group}) model(reghdfe TFP chainleader $xlist, absorb(stkcd prv#year indid#year) vce(cluster city)) reps(1000) first detail seed(824)
return list
matrix list r(P)
file open result using "../output/bootstrap_{group}.txt", write replace
file write result "bdiff=" (r(bdiff)) " p=" (r(p)) _n
file close result
display "COMPLETE_bootstrap_{group}"
log close
'''
    (root/'work'/f'run_bootstrap_{group}.do').write_text(text,encoding='utf-8')
print('Generated nine author-specification 1000-repetition permutation tests')
