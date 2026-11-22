from pathlib import Path
import pandas as pd,numpy as np,json
R=Path(__file__).resolve().parent
x=pd.read_excel(R/'original/extracted/数据2.xlsx');cols=x.columns[3:]
pub=np.array([.0123,.0459,.0070,.1352,.0057,.1203,.0505,.0528,.0259,.0917,.0211,.0338,.0258,.0468,.1529,.0847,.0695,.0174])
assert len(cols)==len(pub)
z0=x[cols].astype(float);complete=z0.notna().all(axis=1);z=z0.loc[complete].copy();neg=[cols[4],cols[8]]
mins=z.min();span=z.max()-mins;nrm=(z-mins)/span;nrm[neg]=1-nrm[neg]
rows=[];fit=[]
d=pd.read_stata(R/'original/extracted/数据1.dta',convert_categoricals=False)
for eps in [0,1e-6,1e-4,.001,.01]:
 a=nrm+eps;p=a/a.sum();e=-(p*np.log(p.where(p>0,1))).sum()/np.log(len(p));w=(1-e)/(1-e).sum();score=(a*w).sum(axis=1)
 chk=x.loc[complete,['城市','year']].copy();chk['rebuilt']=score;chk=chk.merge(d[['城市','year','Eco_safe']],on=['城市','year'],validate='1:1')
 fit.append(dict(method='global_minmax_entropy',epsilon=eps,max_weight_abs_diff=float(np.max(abs(w-pub))),outcome_rmse=float(np.sqrt(np.mean((chk.rebuilt-chk.Eco_safe)**2))),outcome_max_abs_diff=float(np.max(abs(chk.rebuilt-chk.Eco_safe)))))
 for c,wp,ww in zip(cols,pub,w):rows.append(dict(variable=c,epsilon=eps,published_weight=wp,rebuilt_weight=ww))
pd.DataFrame(rows).to_csv(R/'data/entropy_weights_audit.csv',index=False,encoding='utf-8-sig')
(R/'logs/entropy_audit.json').write_text(json.dumps(dict(raw_indicator_missing=int(z0.isna().sum().sum()),complete_case_rows=int(complete.sum()),full_rows=len(x),printed_weight_sum=float(pub.sum()),comparisons=fit,note='附件未提供熵权构造及缺失填补代码。仅在18指标齐全的行作完整案例敏感性诊断，样本不同，不能将权重或得分差异直接认定为作者错误；不替换原作者Eco_safe，不宣称完成原始指标到指数的精确重建。'),ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(fit,indent=2))
