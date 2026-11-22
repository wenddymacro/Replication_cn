from pathlib import Path
import pandas as pd
from pypdf import PdfReader
R=Path(__file__).resolve().parent
d=pd.read_stata(R/'original/extracted/数据1.dta',convert_categoricals=False)
cols=['城市','id','year','Treat','Piolt','action','Eco_safe']
print('missing id rows',d[d.id.isna()][cols].to_string(index=False))
print('discrepant treatment rows',d[d.Piolt==1][lambda x:~(x.year>=x.action)][cols].to_string(index=False))
print('varying action',d.groupby('id').action.nunique().value_counts().to_dict())
print('varying treat',d.groupby('id').Treat.nunique().value_counts().to_dict())
for id0 in d[d.Piolt==1][lambda x:~(x.year>=x.action)].id.unique():print(d[d.id==id0][cols].to_string(index=False))
for p in (R/'original/extracted').glob('*.pdf'):
 r=PdfReader(p);s='\n'.join(f'\nPAGE {i+1}\n'+(x.extract_text() or '') for i,x in enumerate(r.pages))
 (R/'logs'/f'{p.stem}.txt').write_text(s,encoding='utf-8');print(p.name,len(r.pages),s[:4000])
x=pd.read_excel(R/'original/extracted/数据2.xlsx');print('xlsx shape',x.shape,'columns',x.columns.tolist());print(x.head(2).to_string())
