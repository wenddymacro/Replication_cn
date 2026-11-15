from pathlib import Path
import pandas as pd,json
R=Path(__file__).resolve().parent
p=next((R/'original/_extracted').rglob('分支机构层面数据.dta'))
d=pd.read_stata(p,convert_categoricals=False)
print('shape',d.shape,'columns',list(d.columns))
print(d[['pledgee_id','year','DiD','Treat','Post','bank_name_id']].head().to_string(index=False))
print('years',d.year.value_counts().sort_index().to_dict())
print('duplicate unit year',d.duplicated(['pledgee_id','year']).sum())
print('bank_changes',int((d.groupby('pledgee_id').bank_name_id.nunique()>1).sum()))
print('D values',d.DiD.value_counts(dropna=False).to_dict())
print('switch offs',int((d.sort_values(['pledgee_id','year']).groupby('pledgee_id').DiD.diff()<0).sum()))
print('policy columns', [x for x in d.columns if any(k in x.lower() for k in ['year','time','fund','市'])])
for v in ['Treat','Post','DiD','PPL','LnPPL_Num','FirstLoan','FirstLoan_Num','NewPatent','NewPatent_Num']:
 print(v,d[v].describe().to_dict())
(R/'logs').mkdir(exist_ok=True)
d.to_csv(R/'logs/branch_audit_source.csv',index=False,encoding='utf-8')
