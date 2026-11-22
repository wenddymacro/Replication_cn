from pathlib import Path
import pandas as pd,numpy as np,json
R=Path(__file__).resolve().parent
d=pd.read_stata(R/'original/extracted/数据1.dta',convert_categoricals=False)
d['row_id']=np.arange(1,len(d)+1);d=d[d.id.notna()].copy()
g=d[d.Piolt==1].groupby('id').year.min();d['g_recovered']=d.id.map(g).fillna(0)
assert ((d.year>=d.g_recovered)&(d.g_recovered>0)).astype(int).eq(d.Piolt).all()
assert not d.duplicated(['id','year']).any()
known=d.action.notna();assert d.loc[known,'action'].eq(d.loc[known,'g_recovered']).all()
out=[]
for i,x in d.groupby('id'):
 out.append(dict(id=int(i),city=x['城市'].iloc[0],g=int(x.g_recovered.iloc[0]),n=len(x),missing_action=int(x.action.isna().sum()),treat_varies=x.Treat.nunique()>1))
pd.DataFrame(out).to_csv(R/'data/recovered_city_dates.csv',index=False,encoding='utf-8-sig')
audit=dict(rows=len(d),units=d.id.nunique(),years=[int(d.year.min()),int(d.year.max())],duplicate_id_year=0,absorbing=True,g_matches_all_observed_Piolt=True,known_action_matches_g=True,cohorts=g.value_counts().sort_index().to_dict(),missing_or_partial_action=[v for v in out if v['g']>0 and v['missing_action']>0],varying_Treat=[v for v in out if v['treat_varies']],omitted_empty_id_rows=1)
(R/'logs/treatment_audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf-8')
d.to_csv(R/'data/analysis_dates.csv',index=False,encoding='utf-8');print(json.dumps(audit,ensure_ascii=False,indent=2))
