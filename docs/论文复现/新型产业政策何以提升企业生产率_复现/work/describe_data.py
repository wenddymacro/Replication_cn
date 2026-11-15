from pathlib import Path
import pandas as pd,re,json
root=Path(__file__).resolve().parents[1]
d=pd.read_stata(root/'author/listed.dta')
scales={'asset':1e8,'size':1e4,'gdppc':1e4,'innofee':1e8}
variables='TFP chainleader asset size age lev ceo edu gdppc secondary govexp ftd local land local_land searcost travcost clawsuit refund local_export innofee patent lpatent'.split()
text=(root/'work/appendix.txt').read_text(encoding='utf-8')
rows=[]
for name in variables:
    x=d[name]/scales.get(name,1)
    m=re.search(r'(?<![A-Za-z_])'+name+r'\s+(\d+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)',text)
    if not m:raise ValueError(name)
    expected=list(map(float,m.groups()))
    actual=[x.count(),x.mean(),x.std(),x.min(),x.max()]
    row={'variable':name}
    for stat,a,e in zip(['N','mean','sd','min','max'],actual,expected):
        row['actual_'+stat]=a;row['published_'+stat]=e;row[stat+'_match']=abs(a-e)<(0.5 if stat=='N' else .00005)
    rows.append(row)
df=pd.DataFrame(rows)
df.to_csv(root/'output/descriptive_comparison.csv',index=False,encoding='utf-8-sig')
print({s:int(df[s+'_match'].sum()) for s in ['N','mean','sd','min','max']})
print(df.loc[~df[[s+'_match' for s in ['N','mean','sd','min','max']]].all(axis=1)].to_string(index=False))
