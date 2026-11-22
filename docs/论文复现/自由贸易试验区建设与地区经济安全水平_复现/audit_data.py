from pathlib import Path
import pandas as pd,json
R=Path(__file__).resolve().parent
d=pd.read_stata(R/'original/extracted/数据1.dta',convert_categoricals=False)
(R/'logs/columns.json').write_text(json.dumps({c:dict(dtype=str(d[c].dtype),missing=int(d[c].isna().sum()),unique=int(d[c].nunique()),sample=d[c].dropna().head(3).astype(str).tolist()) for c in d},ensure_ascii=False,indent=2),encoding='utf-8')
print(d.shape);print(d.columns.tolist())
for c in ['id','year','Piolt','Treat','action','ryear','Treatnryear','Direct','Pilot2020','Coastal','Boradid','Tefidid']:
 print(c, d[c].value_counts(dropna=False).to_dict() if c in d else 'ABSENT')
print('duplicates',d.duplicated(['id','year']).sum())
print('period counts',d.groupby('id').size().value_counts().to_dict())
print('adoption',d.groupby('id').action.first().value_counts(dropna=False).to_dict())
print('treatment match',pd.crosstab(d.Piolt,((d.year>=d.action)&(d.action!=2333)).astype(int)).to_dict())
print('xlsx sheets',pd.ExcelFile(R/'original/extracted/数据2.xlsx').sheet_names)
d.to_csv(R/'data/analysis_original.csv',index=False,encoding='utf-8')
