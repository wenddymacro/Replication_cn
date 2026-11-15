from pathlib import Path
import pandas as pd,json,hashlib,shutil
R=Path(__file__).resolve().parent; P=R/'project'
d=pd.read_stata(R/'work/branch.dta',convert_categoricals=False);d['row_id']=range(1,len(d)+1)
f=pd.read_csv(R/'data/sample_flags.csv');d=d.merge(f,on='row_id',validate='one_to_one')
print('start_year',d.start_year.value_counts(dropna=False).sort_index().to_dict())
d['policy_g']=d.start_year.where(d.Treat==1,0).fillna(0)
assert (d.DiD.eq((d.policy_g.gt(0)&d.year.ge(d.policy_g)).astype(int))).all()
assert d.groupby('pledgee_id').policy_g.nunique().max()==1
d.to_csv(R/'data/analysis.csv',index=False,encoding='utf-8')
a=pd.read_csv(R/'data/author_results.csv')
city='City_TotalLoan City_BankHHI City_ST City_Patent City_GDP'.split();full=city+'Branch_Age Bank_Size Bank_ROA Bank_CAR Bank_Nplra'.split()
bs=[.0265,.0286,.0340,.0381,.0286,.0315,.0408,.0393,.0283,.0242,.0121,.0158]
ses=[.0050,.0050,.0064,.0062,.0059,.0059,.0077,.0074,.0053,.0051,.0043,.0073]
ns=[84747,84747,83660,57391]*2+[57391]*4
ys=['PPL']*4+['LnPPL_Num']*4+['FirstLoan','FirstLoan_Num','NewPatent','NewPatent_Num']
names=[f'T1_{i}' for i in range(1,9)]+[f'T4_{i}' for i in range(1,5)]
records=[];bench=[]
for i,(name,y,b,se,n) in enumerate(zip(names,ys,bs,ses,ns)):
 c=[] if i in [0,4] else city if i in [1,2,5,6] else full
 xt=['bank_name_id'] if i in [2,6] else []
 row=a[(a.spec==name)&(a.term=='DiD')].iloc[0]
 exact=round(row.b,4)==b and round(row.se,4)==se and row.N==n
 bench.append(dict(spec=name,y=y,published_b=b,published_se=se,published_N=n,replicated_b=row.b,replicated_se=row.se,replicated_N=int(row.N),status='exact' if exact else 'failed'))
 t,col=name[1:].split('_');col=str(int(col)-4) if t=='1' and int(col)>4 else col
 sp=dict(paper_id='cie123767',spec_id=name,journal='cie',data_path='$CIE_RAW/data/analysis.csv',id_var='pledgee_id',time_var='year',y_var=y,gvar='policy_g',treat_var='DiD',weight_var='',cluster_var='pledgee_id',xt_vars=xt,controls=c,sample_filter=f'sample_{name} == 1',static_or_event='static',published_coef=b,published_se=se,published_n=n,published_source=f'表{t}第{col}列'+('Panel B' if i in range(4,8) else 'Panel A' if i<4 else ''),table=t,column=col,preferred=i in [3,7],in_abstract_intro=True,reports_modern_estimator=False,software='Stata',replication_status='exact' if exact else 'failed',notes='原始作者e(sample)锁定；政策日期采用数据start_year，避免不平衡面板首次观测处理年份偏移；对数结果变量已在作者数据生成，不再取对数；银行归属在分支内恒定。')
 (P/'data'/('specs_controls' if c else 'specs')/f'cie123767__{name}.json').write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8');records.append(sp)
pd.DataFrame(bench).to_csv(R/'data/published_comparison.csv',index=False,encoding='utf-8-sig')
screen=dict(paper_id='cie123767',title='财政风险补偿与知识产权质押融资——来自银行分支机构的证据',year=2026,issue=9,journal='cie',screened_from='full_text+author_package',staggered_design=True,eligible_design=True,data_access='full',package_status='data_and_code',software='Stata',eligible_specs=[s['spec_id'] for s in records if not s['controls']],near_miss_controls_only_specs=[s['spec_id'] for s in records if s['controls']],ineligible_specs=[dict(location='表2第1–6列、表3第1–6列、表5第1–2列',reason='处理×特征交互项'),dict(location='表5第3–4列',reason='Treat_Ratio为连续政策暴露强度，不是0/1吸收态处理')],appendix_specs=[dict(location='附表4–16及附图',reason='按协议与正文样本分开记录，未纳入12个正文设定的现代估计量比较')],n_eligible_specs=2,notes='正文28列已运行作者回归；其中12列纳入协议现代估计量重估。T1_3和T1_7为银行×年FE，银行448类>60，按协议跳过CSA。')
(P/'data/screening/by_paper/cie123767.json').write_text(json.dumps(screen,ensure_ascii=False,indent=2),encoding='utf-8')
manifest=[dict(file=str(p.relative_to(P)),sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (P/'code/R').glob('*.R')]
(R/'logs/upstream_code_hashes.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(pd.DataFrame(bench).to_string(index=False))
