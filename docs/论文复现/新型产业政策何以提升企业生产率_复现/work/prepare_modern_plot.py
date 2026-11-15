from pathlib import Path
import re,pandas as pd
root=Path(__file__).resolve().parents[1]
log=(root/'output/dd.log').read_text(encoding='utf-8')
dd=[]
for term,key in [(f'Effect_{i}',f'effect_{i}') for i in range(4)]+[('Average','effect_average')]+[(f'Placebo_{i}',f'placebo_{i}') for i in range(1,4)]:
    b=float(re.search(r'e\('+key+r'\)\s*=\s*([-\d.]+)',log)[1])
    se=float(re.search(r'e\(se_'+key+r'\)\s*=\s*([-\d.]+)',log)[1])
    dd.append(dict(term=term,b=b,se=se))
# Recover all eight full-precision results from Stata's saved ereturn listing;
# the first export mistakenly treated its column vectors as row vectors.
pd.DataFrame(dd).to_csv(root/'output/dd.csv',index=False)
pd.DataFrame(dd).to_stata(root/'output/dd.dta',write_index=False,version=118)
sets={name:pd.read_csv(root/'output'/f'{name}.csv') for name in ['cs_legacy','lp','sa','dd']}
out=['clear all','set more off','set obs 20','adopath ++ "../output/local_ado"','log using "../output/modern_plot.log", text replace','estimates use "../output/T1_4.ster"']
for name,df in sets.items():
    df=df[~df.term.isin(['Pre_avg','Post_avg','Average'])]
    if name=='dd':
        out += [f'matrix {name}_b = ('+' \\ '.join(str(x) for x in df.b)+')',f'matrix {name}_v = ('+' \\ '.join(str(x*x) for x in df.se)+')',f'matrix rownames {name}_b = '+' '.join(df.term),f'matrix rownames {name}_v = '+' '.join(df.term)]
    else:
        out += [f'matrix {name}_b = ('+', '.join(str(x) for x in df.b)+')',f'matrix {name}_v = ('+', '.join(str(x*x) for x in df.se)+')',f'matrix colnames {name}_b = '+' '.join(df.term),f'matrix colnames {name}_v = '+' '.join(df.term)]
out += ['''event_plot cs_legacy_b#cs_legacy_v lp_b#lp_v sa_b#sa_v dd_b#dd_v, stub_lag(Tp# post# post# Effect_#) stub_lead(Tm# pre# pre# Placebo_#) shift(0) plottype(scatter) together alpha(0.05) noautolegend ciplottype(rcap) graph_opt(xline(0, lcolor(black%45) lpattern(dash)) yline(0, lcolor(black%45)) graphregion(color(white)) bgcolor(white) xlabel(-4(1)3) ylabel(-0.1(0.1)0.2) ytitle("Estimate") xtitle("Event time") legend(order(1 "Callaway & Sant'Anna" 3 "Local projections" 5 "Sun & Abraham" 7 "de Chaisemartin & D'Haultfoeuille") cols(2) pos(6) ring(1) size(vsmall)) xsize(10) ysize(5.5)) lag_opt1(msymbol(Oh) color(black)) lag_ci_opt1(color(black)) lag_opt2(msymbol(Sh) color(black)) lag_ci_opt2(color(black)) lag_opt3(msymbol(d) color(black)) lag_ci_opt3(color(black)) lag_opt4(msymbol(t) color(black)) lag_ci_opt4(color(black))''','graph export "../output/modern_did_comparison.png", width(2000) replace','display "COMPLETE_modern_plot"','log close']
(root/'work/run_modern_plot.do').write_text('\n'.join(out),encoding='utf-8')
rows=[]
for name,df in sets.items():
    for _,r in df.iterrows():rows.append(dict(method=name,**r.to_dict()))
pd.DataFrame(rows).to_csv(root/'output/modern_coefficients.csv',index=False,encoding='utf-8-sig')
print('Recovered full DD result vector and generated plot runner')
