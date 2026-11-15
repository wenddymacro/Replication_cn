from pathlib import Path
import pandas as pd,numpy as np,json,shutil,hashlib
R=Path(__file__).resolve().parent
FC='size wage lev roe ocf age dual indboa nsoe'.split();CC='gdp second_gdp fiscal_balance finlaon foreign_inv'.split()
B={}
def bench(s,t,b,se,n):B[(s,t)]=(b,se,n)
for i,b,se in [(1,.0065,.0033),(2,.0073,.0032),(3,.0080,.0034)]:bench(f'T2_{i}','court',b,se,26595)
for i,b,se,n in [(1,.0094,.0040,1579),(2,.1568,.0918,33415),(3,.0039,.0022,1579),(4,.2184,.1296,13928),(5,.0154,.0087,1042)]:bench(f'T3_{i}','court',b,se,n)
for i,b,se,v,bv,sv in [(1,.0071,.0033,'dloan',.1190,.0085),(2,.0079,.0034,'dbond',.0312,.0150),(3,.0070,.0033,'dloanbond',.1102,.0078)]:bench(f'T4_{i}','court',b,se,26595);bench(f'T4_{i}',v,bv,sv,26595)
for i,v,b,se,bi,si,bv,sv,n in [(1,'ct_stress',.0080,.0033,.0262,.0151,-.0367,.0120,26595),(2,'ct_gdpstress',.0073,.0034,.1580,.0813,-.1203,.0501,26589)]:
 for t,x,y in [('1.court',b,se),(f'1.court#c.{v}',bi,si),(v,bv,sv)]:bench(f'T5_{i}',t,x,y,n)
vals=[(1,'ct_liuyan',.0096,.0024,.0942,.0352,-.0625,.0273,-.0096,.0060,19261),(2,'labor_intensity',.0036,.0034,.0089,.0032,-.0111,.0026,-.0210,.0052,26595),(3,'unemployment',.0008,.0039,.0128,.0055,-.0034,.0038,-.0217,.0054,25159),(4,'nsoe',-.0081,.0037,.0252,.0037,-.0324,.0058,-.0324,.0058,26595)]
for i,v,b,se,bi,si,bv,sv,bn,sn,n in vals:
 for t,(x,y) in dict([('1.court',(b,se)),(f'1.court#c.{v}',(bi,si)),(v,(bv,sv)),('nsoe',(bn,sn))]).items():bench(f'T6_{i}',t,x,y,n)
a=pd.read_csv(R/'data/author_results.csv');comp=[]
for _,v in a.iterrows():
 b,se,n=B[(v.spec,v.term)];ok=f'{v.b:.4f}'==f'{b:.4f}' and f'{v.se:.4f}'==f'{se:.4f}' and v.N==n
 comp.append(dict(spec=v.spec,term=v.term,published_b=b,published_se=se,published_N=n,replicated_b=v.b,replicated_se=v.se,replicated_N=v.N,status='exact' if ok else 'mismatch'))
comp=pd.DataFrame(comp);comp.to_csv(R/'data/published_comparison.csv',index=False,encoding='utf-8-sig')
assert len(comp)==35 and comp.status.eq('exact').all(),comp[comp.status!='exact']
dates=pd.read_csv(R/'data/recovered_city_dates.csv')
for typ in ['firm','city']:
 d=pd.read_stata(R/('work/data1.dta' if typ=='firm' else 'data/city_author.dta'),convert_categoricals=False)
 if typ=='firm':
  d['row_id']=np.arange(1,len(d)+1);flags=pd.read_csv(R/'data/firm_flags.csv');d=d.merge(flags,on='row_id',validate='1:1')
 d=d.merge(dates,on='cityid',how='left',validate='m:1')
 d['date_known']=d.g_recovered.notna()
 d.to_csv(R/f'data/{typ}_analysis.csv',index=False,encoding='utf-8')
specs=[]
for sid,y,ctrl,typ in [('T2_1','sbf',[],'firm'),('T2_2','sbf',FC,'firm'),('T2_3','sbf',FC+CC,'firm'),('T3_1','percase1',CC,'city'),('T3_3','percase2',CC,'city'),('T3_5','penalty',CC,'city')]+[(f'T4_{i}','sbf',[v]+FC+CC,'firm') for i,v in enumerate(['dloan','dbond','dloanbond'],1)]:
 b,se,n=B[(sid,'court')];t,c=sid[1:].split('_')
 sp=dict(paper_id='cie20250407',spec_id=sid,journal='cie',year=2025,issue=4,table=t,column=c,
  data_path=f'$CIE_RAW/data/{typ}_analysis.csv',id_var='codeid' if typ=='firm' else 'cityid',time_var='year',y_var=y,gvar='g_recovered',treat_var='court',cluster_var='cityid',xt_vars=[],controls=ctrl,
  sample_filter=f'sample_{sid} == 1 & date_known == TRUE',static_or_event='static',published_coef=b,published_se=se,published_n=n,published_source=f'表{t}第{c}列',preferred=sid=='T2_3',in_abstract_intro=sid.startswith('T2'),reports_modern_estimator=True,software='Stata/SE 17.0',replication_status='exact',
  notes='作者e(sample)先核对。利用精确事件期哑变量恢复城市政策日期；city51以2002上界哨兵保留一直处理分类，不视作确切年份。city145/256各一个单期企业观测，尾箱只能确定日期上界，缺乏精确日期，本轮共同输入剔除这2行并单列样本差异。保留其余作者单期企业；不额外滞后已提供的控制变量。')
 folder='specs_controls' if ctrl else 'specs';(R/f'project/data/{folder}/cie20250407__{sid}.json').write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8');specs.append(sp)
models=json.loads((R/'data/author_models.json').read_text(encoding='utf-8'))
for m in models:
 m['teacher_status']='main' if m['spec_id']=='T2_1' else 'secondary_controls_only' if m['spec_id'] in [s['spec_id'] for s in specs] else 'excluded_nonlinear' if m['spec_id'] in ['T3_2','T3_4'] else 'excluded_treatment_interaction'
screen=R/'project/data/screening/by_paper';screen.mkdir(parents=True,exist_ok=True)
(screen/'cie20250407.json').write_text(json.dumps(dict(title='行政诉讼跨区划管辖与企业社保遵从',main=1,secondary=8,body_models=models,appendix_separate=True,appendix_event_not_in_body_count=True),ensure_ascii=False,indent=2),encoding='utf-8')
for p in Path('reference/Replication_cn-main/code/R').glob('*.R'):shutil.copy2(p,R/'project/code/R'/p.name)
for p in ['README.md','docs/PROTOCOL.md','docs/SCREENING.md','docs/REPLICATION.md','docs/SPEC_SCHEMA.md']:
 q=R/'project/upstream_documents'/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(Path('reference/Replication_cn-main')/p,q)
shutil.copy2(R.parent/'bigdata_employment/project/runtime_info.R',R/'project/runtime_info.R')
(R/'logs/upstream_code_hashes.json').write_text(json.dumps([dict(file=p.name,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'project/code/R').glob('*.R')],indent=2),encoding='utf-8')
print('35 reported coefficients/SE/N exactly match. Formal: 1 main + 8 controls = 9 static specifications.')
