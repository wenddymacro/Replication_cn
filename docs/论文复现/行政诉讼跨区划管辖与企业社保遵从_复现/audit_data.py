from pathlib import Path
import pandas as pd,numpy as np,json
R=Path(__file__).resolve().parent
d=pd.read_stata(R/'work/data1.dta',convert_categoricals=False)
e=d.dropna(subset=['codeid','cityid','year','court']).copy()
ev={'pre6':-6,'pre5':-5,'pre4':-4,'pre3':-3,'pre2':-2,'pre1':-1,'current':0,'post1':1,'post2':2,'post3':3,'post4':4,'post5':5}
c=[]
for name,rel in ev.items():
 q=e[e[name]==1][['cityid','year']].copy();q['adoption']=q.year-rel;q['source']=name;c.append(q)
c=pd.concat(c,ignore_index=True)
by=c.groupby('cityid').adoption.agg(['min','max','count']);assert (by['min']==by['max']).all(),by[by['min']!=by['max']]
g=by['min'].to_dict()
# City 51 only has >=6 post-period bins already in 2008. A 2002 upper-bound
# sentinel maps to the identical always-treated class for every static design;
# it is explicitly not a recovered exact historical date.
g[51.0]=2002.0
e['date_unknown']=e.cityid.isin([145.0,256.0])
e['g_recovered']=e.cityid.map(g).fillna(0)
unmapped=e[(e.court==1)&(e.g_recovered==0)&~e.date_unknown]
bad=e[(e.court!=(e.year>=e.g_recovered).mul(e.g_recovered>0))&~e.date_unknown]
print('CITY RECOVERED',by['min'].value_counts().sort_index().to_dict())
print('unmapped treated',len(unmapped),'D mismatch',len(bad),'never cities',e[e.g_recovered==0].cityid.nunique())
print('one obs firms',(e.groupby('codeid').size()==1).sum(),'missing-ID/year rows',len(d)-len(e))
print('city outcome uniqueness',e.groupby(['cityid','year'])[['percase1','percase2','penalty']].nunique().max().to_dict())
print('first raw rows',d.head(2).to_dict('records'))
assert len(unmapped)==len(bad)==0
assert e[e.date_unknown].groupby('codeid').size().eq(1).all() and int(e.date_unknown.sum())==2
e.loc[e.date_unknown,'g_recovered']=np.nan
e[['cityid','g_recovered','date_unknown']].drop_duplicates().sort_values('cityid').to_csv(R/'data/recovered_city_dates.csv',index=False,encoding='utf-8-sig')
(R/'logs/treatment_audit.json').write_text(json.dumps(dict(rows=len(d),usable_id_rows=len(e),missing_id_time_rows=len(d)-len(e),firms=e.codeid.nunique(),cities=e.cityid.nunique(),city_cohorts={int(k):int(v) for k,v in by['min'].value_counts().sort_index().items()},never_cities=e[e.g_recovered==0].cityid.nunique(),D_mismatch=len(bad),unmapped_treated=len(unmapped),city_movers=int((e.groupby('codeid').cityid.nunique()>1).sum())),ensure_ascii=False,indent=2,default=int),encoding='utf-8')
