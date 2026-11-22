from pathlib import Path
import shutil,json
R=Path(__file__).resolve().parent
shutil.copy2(R/'original/extracted/数据1.dta',R/'work/data1.dta')
C='Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal'
models=[('B1',f'xtreg Eco_safe Piolt i.year, fe vce(robust)','Piolt'),('B2',f'xtreg Eco_safe Piolt {C} i.year, fe vce(robust)','Piolt'),('B3',f'xtreg Eco_safe Piolt {C} i.year if Direct==1, fe vce(robust)','Piolt')]
for i,y in enumerate('CapitalMismatch Labormismatch Agg_e Agg_i Agg_T1 Agg_T2 Agg_T3 Agg_T4 Healthindex Affinityindex Integrityindex Ceindex'.split(),1):models.append((f'M{i}',f'xtreg {y} Piolt {C} i.year, fe vce(robust)','Piolt'))
models += [('A3_1',f'xtreg Eco_safe Treatnryear {C} i.year, fe vce(robust)','Treatnryear'),('A3_3',f'xtreg Eco_safe Piolt {C} i.year if Pilot2020==1, fe vce(robust)','Piolt'),('A3_4',f'xtreg Eco_safe Piolt {C} Boradid Tefidid i.year, fe vce(robust)','Piolt')]
for i,v in enumerate(['a3','a2','a1','b1','b2'],1):
 cc=C.replace(' Coastal','') if i<=3 else C
 models.append((f'A4_{i}',f'xtreg Eco_safe {v} {cc} i.year, fe vce(robust)',v))
for i in range(1,5):models.append((f'A5_{i}',f'xtreg Eco_safe e{i} {C} i.year, fe vce(robust)',f'e{i}'))
out=['clear all','set more off','set processors 1','log using "../logs/author_models.log", text replace','use data1, clear','xtset id year','gen long row_id=_n','tempname H', 'postfile `H\' str16 spec str36 term double b se t N r2 within_r2 using "../data/author_results.dta", replace']
for sid,cmd,v in models:
 out += [cmd,f'post `H\' ("{sid}") ("{v}") (_b[{v}]) (_se[{v}]) (_b[{v}]/_se[{v}]) (e(N)) (e(r2_o)) (e(r2_w))',f'gen byte sample_{sid}=e(sample)']
out+=['save "../data/author_work.dta", replace','preserve','keep row_id sample_*','export delimited using "../data/sample_flags.csv", replace','restore']
out+=['bootstrap, reps(500) seed(12345): xtreg Eco_safe Piolt '+C+' i.year, fe robust', 'post `H\' ("A3_2") ("Piolt") (_b[Piolt]) (_se[Piolt]) (_b[Piolt]/_se[Piolt]) (e(N)) (e(r2_o)) (e(r2_w))']
out+=['gen double policy=year-action','replace policy=-6 if policy < -6','replace policy=4 if policy>4','forvalues i=6(-1)2 {','gen byte pre_`i\'=(policy==-`i\' & Treat==1)','}','gen byte current=(policy==0 & Treat==1)','forvalues i=1/4 {','gen byte post_`i\'=(policy==`i\' & Treat==1)','}','xtreg Eco_safe pre_* current post_* i.year, fe robust']
for v in ['pre_'+str(i) for i in range(6,1,-1)]+['current']+['post_'+str(i) for i in range(1,5)]:out += [f'post `H\' ("AF1") ("{v}") (_b[{v}]) (_se[{v}]) (_b[{v}]/_se[{v}]) (e(N)) (e(r2_o)) (e(r2_w))']
out += ['postclose `H\'','use "../data/author_results.dta", clear','export delimited using "../data/author_results.csv", replace','log close']
(R/'work/replicate_body.do').write_text('\n'.join(out),encoding='utf-8')
(R/'data/author_models.json').write_text(json.dumps([dict(spec_id=s,command=c,term=v) for s,c,v in models],ensure_ascii=False,indent=2),encoding='utf-8')
print('Prepared',len(models),'static models plus bootstrap and appendix event path')
