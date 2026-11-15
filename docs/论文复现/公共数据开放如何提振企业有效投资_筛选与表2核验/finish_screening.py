from pathlib import Path
import json,pandas as pd,hashlib
R=Path(__file__).resolve().parent
d=pd.read_stata(R/'处理数据/数据1.dta',convert_categoricals=False);d['row_id']=range(1,len(d)+1)
d=d.merge(pd.read_csv(R/'work/sample_flags.csv'),on='row_id',validate='one_to_one')
res=pd.read_csv(R/'work/author_table2.csv')
published=[(.0124,.0057,6918),(.0025,.0048,11428),(.0201,.0091,3093),(.0048,.0043,15375)]
base='ecodev attention internet oswitch mobile fisupport'.split()
ctrl='size age lev cash cfo top10 sgr msh board indep qturn'.split()
records=[]
for i,(b,se,n) in enumerate(published,1):
 r=res[res.spec==f'T2_{i}'].iloc[0];assert round(r.b,4)==b and round(r.se,4)==se and int(r.N)==n
 x=d[d[f'sample_T2_{i}']==1].sort_values(['id','year'])
 g=x[x.cityp==1].groupby('id').year.min();first=x.groupby('id').year.min()
 transitions=x.groupby('id').cityp.diff().lt(0).sum()
 changing={v:int((x.groupby('id')[v].nunique()>1).sum()) for v in base}
 records.append(dict(spec_id=f'T2_{i}',location=f'表2第{i}列',static_or_event='static',outcome='caput',treatment='cityp',controls=ctrl,baseline_by_year_slopes=base,baseline_characteristics_changing_units=changing,fixed_effects='id+year+六个2010年前定特征×年份斜率',clustering='ids（省份）',coef=b,se=se,n_obs=n,replicated_b=r.b,replicated_se=r.se,replicated_N=int(r.N),replication_status='exact',n_units=int(x.id.nunique()),n_clusters=int(x.ids.nunique()),first_observed_treated_periods={str(int(k)):int(v) for k,v in g.value_counts().sort_index().items()},n_observed_cohorts=int(g.nunique()),n_newly_observed_cohorts=int(g[g>first.reindex(g.index)].nunique()),observed_switch_offs=int(transitions),unbalanced=len(x)!=x.id.nunique()*x.year.nunique(),never_observed_treated_units=int(x.id.nunique()-len(g)),sample_filter=['cz==1','cz==0','xz==1','xz==0'][i-1],notes='该列仅cityp一个政策变量；不凭原始变量名认定入选。前定连续特征×年斜率须原样保留，不能替换为省份×年全套分类固定效应。移动地区企业的特征变化及处理关闭须按协议处理。'))
screen=dict(paper_id='cie202408_publicdata',title='公共数据开放如何提振企业有效投资——基于产能利用视角',year=2024,issue=8,authors=['王海','叶帅','尹俊雅'],screen_date='2026-11-14',screened_from='正文PDF视觉核查+作者程序+作者数据+Stata原模型核验',staggered_design=True,package_status='data_and_code',data_access='public',main_sample_specs=[],n_eligible_main_specs=0,near_miss_controls_only=True,near_miss_controls_only_specs=records,n_secondary_specs=4,priority=1,modern_reestimation_status='not_run',ineligible_specs=[dict(location='表1、表3、表4、表5、表7、表9、表10',reason='原模型同时包含provp和cityp两个政策处理；表9另有非冗余额外可加固定效应'),dict(location='表6、表8',reason='处理×特征交互或多组处理变量，且含额外政策变量')],appendix_specs=[dict(location='附录',notes='另存，不混入正文合格计数')],calendar_mapping=dict(year_index_1=2008,year_index_13=2020,source='正文第5页样本2008–2020及包内year取1–13；按连续年度映射，未来需保留映射记录'),execution_caveats=['上游xt_vars实现为分类交互固定效应，不直接支持连续基期特征×年斜率；现代重估须明确适配或记为暂不能估，不能偷偷改变原设定','不平衡面板中个体首次可观察处理期不一定是真实政策年份；必须结合城市/省份政策状态推断和核对，不能把下表九个观察期直接当作九个真实批次','仅4列作者TWFE原模型已复现，未完成全文原模型、现代CSA/BJS或999次联合自助。'])
(R/'核验记录/筛选结论.json').write_text(json.dumps(screen,ensure_ascii=False,indent=2),encoding='utf-8')
res['published_b']=[p[0] for p in published];res['published_se']=[p[1] for p in published];res['published_N']=[p[2] for p in published];res['status']='exact'
res.to_csv(R/'核验记录/表2_复现核对.csv',index=False,encoding='utf-8-sig')
print(json.dumps(records,ensure_ascii=False,indent=2))
