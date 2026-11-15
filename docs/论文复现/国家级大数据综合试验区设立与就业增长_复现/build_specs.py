from pathlib import Path
import pandas as pd,numpy as np,json,hashlib
R=Path(__file__).resolve().parent;P=R/'project';a=pd.read_csv(R/'data/author_results.csv')
FC='Lev Age Roa Capital Cash Growth Mshrrat Shrholder1 Share_indep'.split();CC='Gdpt Popt Secondt Waget Edut Firm_numt Thirdt'.split()
bench={1:([.3654,.0938,.0748,.0713],[.0186,.0296,.0276,.0236],[29343]*4),2:([.0548,1.4102,.1762,.0953,.0760],[.0297,.4721,.0489,.0332,.0336],[3312,3036,3216,3312,2766]),3:([.0538,.0512,.0020,.0576],[.0194,.0262,.0007,.0221],[24582,24582,29343,29343]),4:([-.0035,.1303,.3409,.0977,.0582,.0534],[.0018,.0653,.1370,.0355,.0359,.0240],[24575,28508,7509,11361,12045,29343]),5:([.0875,.1981,.1032,.0377,1.0612],[.0492,.0922,.0355,.0166,.4196],[28680,23709,13923,29343,9821]),6:([.0630,.0622,.0609,.0651,.0829,.1015],[.0266,.0321,.0277,.0313,.0283,.0450],[21536,24730,21747,23789,21636,24683])}
checks=[]
for t,(bs,ss,ns) in bench.items():
 for i,(b,se,n) in enumerate(zip(bs,ss,ns),1):
  rr=a[(a.spec==f'T{t}_{i}')&(a.term=='Bigdata_Post')].iloc[0]
  exact=round(rr.b,4)==b and round(rr.se,4)==se and rr.N==n
  checks.append(dict(spec=f'T{t}_{i}',term='Bigdata_Post',published_b=b,published_se=se,published_N=n,replicated_b=rr.b,replicated_se=rr.se,replicated_N=int(rr.N),status='exact' if exact else 'failed'))
for name,term,b,se,n in [('T3_2','TFP',.5119,.0172,24582),('T3_4','Market_share',6.9833,.8085,29343)]:
 rr=a[(a.spec==name)&(a.term==term)].iloc[0];exact=round(rr.b,4)==b and round(rr.se,4)==se and rr.N==n
 checks.append(dict(spec=name,term=term,published_b=b,published_se=se,published_N=n,replicated_b=rr.b,replicated_se=rr.se,replicated_N=int(rr.N),status='exact' if exact else 'failed'))
bc=pd.DataFrame(checks);bc.to_csv(R/'data/published_comparison.csv',index=False,encoding='utf-8-sig')
assert bc.status.eq('exact').all(),bc[bc.status!='exact'].to_dict('records')
data={};audit=[]
for typ,idv in [('firm','Firm'),('city','city')]:
 d=pd.read_stata(R/f'work/{typ}.dta',convert_categoricals=False);d['row_id']=range(1,len(d)+1)
 d=d.merge(pd.read_csv(R/f'data/{typ}_flags.csv'),on='row_id',validate='one_to_one')
 if typ=='firm':
  varying=d.groupby(idv).Policy_year.nunique();ids=varying[varying>1].index
  g0=d.groupby(idv).Policy_year.first();gobs=d[d.Bigdata_Post==1].groupby(idv).year.min()
  # Stable locations use actual policy dates. For changing assignment, observed first exposure is the only supported unit date.
  g0.loc[ids]=gobs.reindex(ids).fillna(0)
  d['g_analysis']=d[idv].map(g0)
  policy_changes=len(ids)
 else:
  g0=d[d.Bigdata_Post==1].groupby(idv).year.min();d['g_analysis']=d[idv].map(g0).fillna(0);policy_changes=0
 d['keep_absorb']=~((d.g_analysis>0)&(d.year>=d.g_analysis)&(d.Bigdata_Post==0))
 pred=((d.g_analysis>0)&(d.year>=d.g_analysis)).astype(int)
 assert pred[d.keep_absorb].eq(d.loc[d.keep_absorb,'Bigdata_Post']).all()
 d.to_csv(R/f'data/{typ}_analysis.csv',index=False,encoding='utf-8')
 data[typ]=d
 audit.append(dict(dataset=typ,rows=len(d),n_units=int(d[idv].nunique()),policy_year_changes=policy_changes,assignment_locations_changing_units=int((d.groupby(idv).city.nunique()>1).sum()) if typ=='firm' else 0,closed_rows_dropped=int((~d.keep_absorb).sum()),g_analysis_counts=d.g_analysis.value_counts().sort_index().to_dict(),duplicate_unit_year=int(d.duplicated([idv,'year']).sum())))
(R/'logs/treatment_audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf-8')
commands=[x.strip() for x in (R/'logs/author_program.txt').read_text(encoding='utf-8').split('**图2**')[0].splitlines() if x.strip().startswith('reghdfe ')]
names=[f'T1_{i}' for i in range(1,5)]+['F1']+[f'T{t}_{i}' for t,k in [(2,5),(3,4),(4,6),(5,5),(6,6)] for i in range(1,k+1)]
specs=[]
for name,cmd in zip(names,commands):
 if name=='T1_1':continue
 typ='city' if name.startswith('T2_') else 'firm';event=name=='F1'
 t,col=('1','1') if event else name[1:].split('_')
 controls=[] if name=='T1_2' else FC if name=='T1_3' else CC if typ=='city' else FC+CC
 if name=='T3_2':controls=controls+['TFP']
 if name=='T3_4':controls=controls+['Market_share']
 bb=None if event else next(r for r in checks if r['spec']==name and r['term']=='Bigdata_Post')
 sp=dict(paper_id='cie117612',spec_id=name,journal='cie',data_path=f'$CIE_RAW/data/{typ}_analysis.csv',id_var='city' if typ=='city' else 'Firm',time_var='year',y_var=cmd.split()[1],gvar='g_analysis',treat_var='Bigdata_Post',cluster_var='city',xt_vars=[],controls=controls,sample_filter=f'sample_{name} == 1 & keep_absorb == TRUE',static_or_event='event' if event else 'static',published_coef=None if event else bb['published_b'],published_se=None if event else bb['published_se'],published_n=None if event else bb['published_N'],published_source='图1' if event else f'表{t}第{col}列',table='F1' if event else t,column=col,preferred=name=='T1_4',in_abstract_intro=name.startswith('T1_') or name.startswith('T6_'),reports_modern_estimator=True,software='Stata',replication_status='exact' if not event else 'exact_author_code_no_printed_point_values',notes='先锁定作者e(sample)。稳定政策赋值企业使用真实2015/2016政策日期；41家Policy_year变化企业改用首次观察到的单位暴露日期，明确记录时点不确定性。处理后关闭的行按协议删除。前期城市特征×时间趋势作为作者数值控制项原样保留，非无约束个体趋势。事件窗口外按作者哑变量实际编码并入参照。')
 if event:sp['event_structure']=dict(pre_min=-5,post_max=5,ref=[-1],ends='ref')
 target=P/'data'/('specs_controls' if controls else 'specs')/f'cie117612__{name}.json';target.write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8');specs.append(sp)
screen=dict(paper_id='cie117612',title='国家级大数据综合试验区设立与就业增长',year=2024,issue=12,journal='cie',authors=['沈坤荣','乔刚','谭睿鹏'],screened_from='article_visual+package+data+author_TWFE',screen_date='2026-11-14',screener='Codex',staggered_design=True,eligible_design=True,near_miss_controls_only=True,policy_or_event='贵州2015；其余国家大数据综合试验区2016；作者定义及赋值保留',unit='firm_or_city',assignment_unit='city',time_unit='year',n_cohorts_reported=2,main_or_robustness='main',data_access='public',package_status='data_and_code',software='Stata',reports_modern_estimator=True,estimators_reported=['TWFE','CSA_appendix','SA_appendix','BJS_appendix','stacked_appendix'],eligible_specs=[s for s in specs if not s['controls']],near_miss_controls_only_specs=[s for s in specs if s['controls']],ineligible_specs=[dict(location='表1第1列',reason='没有年份固定效应'),dict(location='图2、表7',reason='机器学习优化与策略标签计数，不是协议线性DID')],appendix_specs=[dict(location='附表A1–A10及附图',notes='另存；不计正文现代DID重估数')],n_eligible_specs=1,notes='正文1项主样本，28项静态控制变量二级样本，1条事件路径二级样本。事件d_1是常数1被吸收，真实参考包含-1及窗口外，不能错误合并端点。企业迁址41家政策日期变化，公开数据无法精确识别缺失间隔中的迁址日期；g_analysis为明确预处理选择，详见treatment_audit。')
(P/'data/screening/by_paper/cie117612.json').write_text(json.dumps(screen,ensure_ascii=False,indent=2),encoding='utf-8')
ml=pd.read_stata(R/'work/ml.dta',convert_categoricals=False)
print('ML columns',list(ml.columns))
print('Validated static coefficients',len(checks),'models',bc.spec.nunique(),'specs',len(specs),'main',sum(not s['controls'] for s in specs))
print(json.dumps(audit,ensure_ascii=False,indent=2))
hashes=[dict(file=str(p.relative_to(P)),sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (P/'code/R').glob('*.R')]
(R/'logs/upstream_code_hashes.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
