from pathlib import Path
import pandas as pd,numpy as np,json,math
R=Path(__file__).resolve().parent
rows=[]
for folder in ['specs','specs_controls']:
 for p in (R/f'project/output/{folder}').glob('*.csv'):rows.append(pd.read_csv(p))
a=pd.concat(rows,ignore_index=True)
auth=pd.read_csv(R/'data/author_results.csv').query("spec.str.startswith('B') or spec.str.startswith('M')",engine='python')
out=[]
for _,v in a.iterrows():
 for m in ['twfe','csa','bjs']:
  out.append(dict(spec=v.spec_id,method=m,b_sd=v[m],se_sd=v[m+'_se'],b_raw=v[m]*v.y_sd,se_raw=v[m+'_se']*v.y_sd,p_normal=math.erfc(abs(v[m]/v[m+'_se'])/math.sqrt(2)) if pd.notna(v[m]) and pd.notna(v[m+'_se']) and v[m+'_se']>0 else np.nan,n=v.n,n_units=v.n_units,unbalanced=v.unbalanced,boot_B=v.boot_B))
pd.DataFrame(out).to_csv(R/'data/modern_results_long.csv',index=False,encoding='utf-8-sig')
a.to_csv(R/'data/modern_results_all.csv',index=False,encoding='utf-8-sig')
print(pd.DataFrame(out).query("spec in ['B1','B2','B3']").to_string(index=False))
print('methods finite', {m:int(a[m].notna().sum()) for m in ['twfe','csa','bjs']})
print('bootstrap draws',a.boot_B.unique());print('notes',a[['spec_id','csa_note','bjs_note']].to_string(index=False))
