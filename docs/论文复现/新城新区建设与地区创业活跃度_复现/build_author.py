from pathlib import Path
import shutil,json
R=Path(__file__).resolve().parent
shutil.copytree(R.parent/'chain_policy/output/local_ado',R/'dependencies/stata_ado',dirs_exist_ok=True)
C='popdensity2006yr* agriareaper2006yr* consratio2006yr* lnindp2006yr* jinrong2006yr*'
rows=[]
def add(sid,y,rhs='',cond='',cluster='city_id',data='city',fe='city_id prov_id##year',terms=None):rows.append(dict(spec=sid,command=f'reghdfe {y} tp {rhs} {cond}, absorb({fe}) vce(cluster {cluster})',terms=terms or ['tp'],data=data))
add('T2_1','lnNo_GSmgfper',cond='if in_sample==1')
add('T2_2','lnNo_GSmgfper',C,cond='if in_sample==1')
add('T2_3','lnNo_GSmgfper',C,cond='if in_sample==1',cluster='prov_id')
add('T3_1','lnNo_GSmgfper',C+' kfq',terms=['tp','kfq'])
add('T3_2','lnNo_GSmgfper',C+' cx',terms=['tp','cx'])
add('T4_1','lnNo_GSmgfper','tpmeanprice_gongye2007 '+C,terms=['tp','tpmeanprice_gongye2007'])
add('T4_2','lnNo_GSmgfper',C,cond='if east==0')
add('T4_3','lnNo_GSmgfper',C,cond='if east==1')
add('T4_4','hhi5',C,data='city-industry',fe='hylb city_id prov_id##year')
add('T4_5','lnNo_GSmgfper','tplngdpper2006 '+C,terms=['tp','tplngdpper2006'])
add('T4_6','lnNo_GSmgfper','tplngdpperpre '+C,terms=['tp','tplngdpperpre'])
for i,y in enumerate(['zhuan','duo','density1','density2','thirdind','thirdindemp'],1):add(f'T5_{i}',y,C)
for i,y in enumerate(['avglife','life3rate','ksi','Score','zhichu'],1):add(f'T6_{i}',y,C)
out=['version 16','clear all','set more off','set processors 1','adopath ++ "../dependencies/stata_ado"','log using "../logs/author_body.log", text replace',f'global cyear {C}','tempname H','postfile `H\' str12 spec str32 term double b se N r2a using "../data/author_results.dta", replace']
for typ in ['city','city-industry']:
 out += [f'use "{typ}.dta", clear','gen long row_id=_n']
 if typ=='city':out += ['reghdfe lnNo_GSmgfper tp $cyear, absorb(city_id prov_id##year) vce(cluster city_id)','gen byte in_sample=e(sample)','gen double tpmeanprice_gongye2007=tp*meanprice_gongye2007','gen double tplngdpper2006=tp*lngdpper2006','gen double tplngdpperpre=tp*lngdpperpre']
 for r in rows:
  if r['data']!=typ:continue
  out += [r['command']]
  for t in r['terms']:out += [f'post `H\' ("{r["spec"]}") ("{t}") (_b[{t}]) (_se[{t}]) (e(N)) (e(r2_a))']
  out += [f'gen byte sample_{r["spec"]}=e(sample)']
 if typ=='city':
  out+=['gen double dist=year-firstyear']
  for i in range(2,9):out+=[f'gen byte evpre{i}=dist==-{i}']
  for i in range(9):out+=[f'gen byte evpost{i}=dist=={i}']
  ev=[f'evpre{i}' for i in range(8,1,-1)]+[f'evpost{i}' for i in range(9)]
  out+=['reghdfe lnNo_GSmgfper $cyear '+' '.join(ev)+', absorb(city_id prov_id##year) vce(cluster city_id)','gen byte sample_F1=e(sample)']
  for t in ev:out+=[f'post `H\' ("F1") ("{t}") (_b[{t}]) (_se[{t}]) (e(N)) (e(r2_a))']
  for window,terms in [('pre',['evpre4','evpre3','evpre2']),('post',[f'evpost{i}' for i in range(5)])]:
   out += ['lincom ('+'+'.join(terms)+f')/{len(terms)}',f'post `H\' ("F1") ("{window}_reported") (r(estimate)) (r(se)) (e(N)) (e(r2_a))']
 out += ['keep row_id sample_*',f'export delimited using "../data/{typ}_flags.csv", replace']
out += ['postclose `H\'','use "../data/author_results.dta", clear','export delimited using "../data/author_results.csv", replace','log close']
(R/'work/replicate_body.do').write_text('\n'.join(out),encoding='utf-8')
(R/'data/author_models.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print('22 body static models, 27 printed coefficients; F1 full regression and displayed-window averages prepared. Paper table numbering overrides outdated author code headings.')
