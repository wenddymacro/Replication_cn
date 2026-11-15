from pathlib import Path
import shutil,json
R=Path(__file__).resolve().parent
shutil.copytree(R.parent/'chain_policy/output/local_ado',R/'dependencies/stata_ado',dirs_exist_ok=True)
FC='size wage lev roe ocf age dual indboa nsoe';CC='gdp second_gdp fiscal_balance finlaon foreign_inv'
rows=[]
def add(sid,cmd,terms):rows.append((sid,cmd,terms))
for i,c in enumerate(['',FC,FC+' '+CC],1):add(f'T2_{i}',f'reghdfe sbf court {c}, absorb(codeid year) cluster(cityid) keepsin',['court'])
for i,y in [(1,'percase1'),(3,'percase2'),(5,'penalty')]:add(f'T3_{i}',f'reghdfe {y} court {CC}, absorb(cityid year) cluster(cityid)',['court'])
for i,cond in [(2,''),(4,'if ifsbcase==1')]:add(f'T3_{i}',f'logit win court word_length {CC} i.cityid i.year i.typeyg i.typebg {cond}, cluster(cityid)',['court'])
for i,c in enumerate(['dloan','dbond','dloanbond'],1):add(f'T4_{i}',f'reghdfe sbf court {c} {FC} {CC}, absorb(codeid year) cluster(cityid) keepsin',['court',c])
for i,c in enumerate(['ct_stress','ct_gdpstress'],1):add(f'T5_{i}',f'reghdfe sbf court##c.{c} {FC} {CC}, absorb(codeid year) cluster(cityid) keepsin',['1.court',f'1.court#c.{c}',c])
for i,c in enumerate(['ct_liuyan','labor_intensity','unemployment','nsoe'],1):add(f'T6_{i}',f'reghdfe sbf court##c.{c} {FC} {CC}, absorb(codeid year) cluster(cityid) keepsin',list(dict.fromkeys(['1.court',f'1.court#c.{c}',c,'nsoe'])))
out=['clear all','set more off','set processors 1','adopath ++ "../dependencies/stata_ado"','log using "../logs/author_body.log", text replace','tempname H', 'postfile `H\' str12 spec str36 term double b se N r2a using "../data/author_results.dta", replace']
for typ in ['firm','city','case']:
 out += ['use data2, clear' if typ=='case' else 'use data1, clear']
 if typ=='city':out+=['duplicates drop cityid year, force']
 out+=['gen long row_id=_n']
 if typ=='firm':
  for v in ['stress','gdpstress','liuyan']:out += [f'quietly sum {v}, meanonly',f'gen double ct_{v}={v}-r(mean)']
 for sid,cmd,terms in rows:
  category='case' if sid in ['T3_2','T3_4'] else 'city' if sid.startswith('T3') else 'firm'
  if category!=typ:continue
  out += [cmd]
  for term in terms:out += [f'post `H\' ("{sid}") ("{term}") (_b[{term}]) (_se[{term}]) (e(N)) (e(r2_a))']
  out += [f'gen byte sample_{sid}=e(sample)']
 if typ=='city':out+=['save "../data/city_author.dta", replace']
 out+=['keep row_id sample_*',f'export delimited using "../data/{typ}_flags.csv", replace']
out+=['postclose `H\'','use "../data/author_results.dta", clear','export delimited using "../data/author_results.csv", replace','log close']
(R/'work/replicate_body.do').write_text('\n'.join(out),encoding='utf-8')
(R/'data/author_models.json').write_text(json.dumps([dict(spec_id=s,command=c,terms=t) for s,c,t in rows],ensure_ascii=False,indent=2),encoding='utf-8')
print('17 author models prepared; SSC center arithmetic reproduced by subtracting full-variable mean.')
