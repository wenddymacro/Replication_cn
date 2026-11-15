from pathlib import Path
import zipfile,io,pandas as pd
R=Path(__file__).resolve().parent
with zipfile.ZipFile(R/'原始附件包/20240919125418WU_FILE_1.zip') as z:
 for inf in z.infolist():
  n=inf.filename
  try:name=n.encode('cp437').decode('gb18030')
  except (UnicodeError,LookupError):name=n
  if n.endswith('.do'):
   b=z.read(n)
   for enc in ['utf-8-sig','gb18030','utf-16']:
    try:s=b.decode(enc);break
    except UnicodeError:continue
   (R/'author_code_readable.txt').write_text(s,encoding='utf-8')
  if n.endswith('.dta'):
   d=pd.read_stata(io.BytesIO(z.read(n)),convert_categoricals=False)
   print(name,d.shape,list(d.columns))
   if name=='数据1.dta':
    for v in ['provp','cityp','ecodev','attention','internet','oswitch','mobile','fisupport']:
     print('VAR',v,'levels',d[v].nunique(),'range',d[v].min(),d[v].max(),'changing_units',int((d.groupby('id')[v].nunique()>1).sum()))
    for v in ['provp','cityp']:print('FIRST_TREAT',v,d[d[v]==1].groupby('id').year.min().value_counts().sort_index().to_dict())
    for v in ['cz','xz']:
     for val in [0,1]:
      a=d[d[v]==val];g=a[a.cityp==1].groupby('id').year.min()
      print('SUBSET',v,val,'n',len(a),'D',a.cityp.value_counts().to_dict(),'cohorts',g.value_counts().sort_index().to_dict(),'switch_offs',int((a.sort_values(['id','year']).groupby('id').cityp.diff()<0).sum()),'years',a.year.min(),a.year.max())
