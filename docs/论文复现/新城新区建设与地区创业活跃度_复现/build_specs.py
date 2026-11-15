from pathlib import Path
import pandas as pd,numpy as np,json,shutil,hashlib
R=Path(__file__).resolve().parent
B={}
def put(s,t,b,se,n):B[(s,t)]=(b,se,n)
for i,b,se in [(1,.1363,.0565),(2,.1331,.0532),(3,.1331,.0513)]:put(f'T2_{i}','tp',b,se,1610)
for i,b,se,v,bv,sv in [(1,.1332,.0529,'kfq',-.0851,.0606),(2,.1257,.0526,'cx',-.4670,.1598)]:put(f'T3_{i}','tp',b,se,1610);put(f'T3_{i}',v,bv,sv,1610)
for i,b,se,n in [(1,.0127,.0804,980),(2,.1079,.0580,1140),(3,.1359,.1143,470),(4,.0024,.0014,18236),(5,1.4860,.6686,1610),(6,1.4349,.7030,1610)]:put(f'T4_{i}','tp',b,se,n)
for i,v,b,se,n in [(1,'tpmeanprice_gongye2007',.2461,.1321,980),(5,'tplngdpper2006',-.1377,.0687,1610),(6,'tplngdpperpre',-.1345,.0736,1610)]:put(f'T4_{i}',v,b,se,n)
for i,b,se,n in [(1,-.0110,.6194,1610),(2,.0099,.0500,1610),(3,-1.0986,.7049,1561),(4,-1.0685,.7128,1561),(5,.9107,.5788,1636),(6,.6874,.7462,1639)]:put(f'T5_{i}','tp',b,se,n)
for i,b,se,n in [(1,-.1414,.0616,1640),(2,-.0155,.0082,1640),(3,.0129,.0130,1610),(4,-.0024,.0014,1288),(5,-.6170,.4177,1035)]:put(f'T6_{i}','tp',b,se,n)
a=pd.read_csv(R/'data/author_results.csv');comp=[]
for _,r in a[a.spec!='F1'].iterrows():
 b,se,n=B[(r.spec,r.term)];ok=f'{r.b:.4f}'==f'{b:.4f}' and f'{r.se:.4f}'==f'{se:.4f}' and r.N==n
 comp.append(dict(spec=r.spec,term=r.term,published_b=b,published_se=se,published_N=n,replicated_b=r.b,replicated_se=r.se,replicated_N=r.N,status='exact' if ok else 'mismatch'))
comp=pd.DataFrame(comp);comp.to_csv(R/'data/published_comparison.csv',index=False,encoding='utf-8-sig')
assert len(comp)==27 and comp.status.eq('exact').all(),comp[comp.status!='exact']
d=pd.read_stata(R/'work/city.dta',convert_categoricals=False);d['row_id']=np.arange(1,len(d)+1)
d=d.merge(pd.read_csv(R/'data/city_flags.csv'),on='row_id',validate='1:1')
d['g_analysis']=d.firstyear.fillna(0)
assert d.groupby('city_id').prov_id.nunique().eq(1).all()
assert d.groupby('city_id').g_analysis.nunique().eq(1).all()
assert d.tp.eq(((d.year>=d.g_analysis)&d.g_analysis.gt(0)).astype(int)).all()
base=['popdensity2006','agriareaper2006','consratio2006','lnindp2006','jinrong2006']
assert d.groupby('city_id')[base].nunique().le(1).all().all()
ctrl=[v for p in base for v in d.columns if v.startswith(p+'yr')]
assert len(ctrl)==50
# Verify each provided numeric interaction, rather than treating unique-valued
# continuous baseline characteristics as categorical FE identifiers.
err=[];baseline_discrepancy={}
for v in base:
 basis=d[[f'{v}yr{j}' for j in range(1,11)]].sum(axis=1,min_count=1)
 assert basis.groupby(d.city_id).nunique().le(1).all(),v
 baseline_discrepancy[v]=float((basis-d[v]).abs().max())
 for j in range(1,11):
  col=f'{v}yr{j}';expected=basis*d.year.eq(2005+j)
  q=(d[col]-expected).abs();err.append(float(q.max()))
assert max(err)<.001,max(err)
d.to_csv(R/'data/city_analysis.csv',index=False,encoding='utf-8')
audit=dict(rows=len(d),cities=d.city_id.nunique(),years=sorted(d.year.unique().tolist()),never_cities=int(d[d.g_analysis==0].city_id.nunique()),cohort_cities={int(k):int(v) for k,v in d.drop_duplicates('city_id').g_analysis.value_counts().sort_index().items()},D_mismatch=0,switch_off_rows=int((d.sort_values(['city_id','year']).groupby('city_id').tp.diff()<0).sum()),baseline_features_fixed=True,interaction_max_abs_error=max(err),interaction_basis_vs_named_baseline_max_diff=baseline_discrepancy)
(R/'logs/treatment_audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2,default=int),encoding='utf-8')
models=json.loads((R/'data/author_models.json').read_text(encoding='utf-8'));excluded=['T3_1','T3_2','T4_1','T4_4','T4_5','T4_6']
specs=[]
for m in models:
 sid=m['spec'];m['teacher_status']='excluded_extra_treatment' if sid.startswith('T3') else 'excluded_treatment_interaction' if sid in ['T4_1','T4_5','T4_6'] else 'excluded_nonredundant_additive_FE' if sid=='T4_4' else 'canonical_main_supported' if sid=='T2_1' else 'eligible_baseline_interactions_implementation_pool_pending'
 if sid in excluded:continue
 y=m['command'].split()[1];t,c=sid[1:].split('_');b,se,n=B[(sid,'tp')]
 sp=dict(paper_id='cie20250307',spec_id=sid,journal='cie',year=2025,issue=3,data_path='$CIE_RAW/data/city_analysis.csv',id_var='city_id',time_var='year',y_var=y,gvar='g_analysis',treat_var='tp',cluster_var='prov_id' if sid=='T2_3' else 'city_id',xt_vars=['prov_id'],controls=[] if sid=='T2_1' else ctrl,sample_filter=f'sample_{sid} == 1',static_or_event='static',published_coef=b,published_se=se,published_n=n,published_source=f'原文表{t}第{c}列',table=t,column=c,preferred=sid=='T2_2',in_abstract_intro=sid.startswith('T2'),reports_modern_estimator=True,software='Stata version16',replication_status='exact',notes='原文表号为准。省份为固定类别；真实firstyear，不改首次观察日期。50个数值控制列为5个固定2006特征×10年虚拟变量，原样保留。controls字段仅为精确保留数值结构的实现，不能据此自动归为时变控制二级样本；该组的最终主样本登记待解决连续特征支持差异。')
 folder='specs' if sid=='T2_1' else 'implementation';(R/f'project/data/{folder}').mkdir(parents=True,exist_ok=True)
 (R/f'project/data/{folder}/cie20250307__{sid}.json').write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8');specs.append(sp)
sp=dict(specs[1]);sp.update(spec_id='F1',sample_filter='sample_F1 == 1',static_or_event='event',published_coef=None,published_se=None,published_n=int(a[a.spec=='F1'].N.iloc[0]),published_source='原文图1',table='F1',column='path',preferred=False,in_abstract_intro=False,event_structure=dict(pre_min=-8,post_max=8,ref=[-1],ends='ref'),reported_pre=[-4,-3,-2],reported_post=[0,1,2,3,4],notes='eventdd inrange仅限绘图显示；完整回归包含-8至8、基期-1。独立报告窗口-4至4均值包装调用原版估计器函数，不修改函数。')
(R/'project/data/implementation/cie20250307__F1.json').write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8')
screen=R/'project/data/screening/by_paper';screen.mkdir(parents=True,exist_ok=True)
(screen/'cie20250307.json').write_text(json.dumps(dict(title='新城新区建设与地区创业活跃度',author_static_models=22,eligible_static=16,eligible_event=1,canonical_main_currently_supported=1,implementation_comparisons_pending_pool=16,near_miss_controls_only=False,models=models,event=dict(spec='F1',estimation_window=[-8,8],display_window=[-4,4])),ensure_ascii=False,indent=2),encoding='utf-8')
for p in Path('reference/Replication_cn-main/code/R').glob('*.R'):shutil.copy2(p,R/'project/code/R'/p.name)
for p in ['README.md','docs/PROTOCOL.md','docs/SCREENING.md','docs/REPLICATION.md','docs/SPEC_SCHEMA.md']:
 q=R/'project/upstream_documents'/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(Path('reference/Replication_cn-main')/p,q)
shutil.copy2(R.parent/'jurisdiction_social/project/runtime_info.R',R/'project/runtime_info.R')
print('27 coefficients/SE/N matched; 1 canonical static +15 literal-control static comparisons +1 event comparison prepared.')
