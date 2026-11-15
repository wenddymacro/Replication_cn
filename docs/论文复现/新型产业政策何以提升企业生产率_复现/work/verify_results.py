from pathlib import Path
import pandas as pd,json,re
root=Path(__file__).resolve().parents[1]
spec={
1:([.0437,.0422,.0512,.0400],[.0185,.0145,.0152,.0145],[25082,24262,23969,23913],[.8916,.9190,.9195,.9318]),
2:([.0546,.0727,.0184,-.0024,-.0005,.0177],[.0256,.0413,.0104,.0009,.0003,.0072],[4312,26918,4204,26914,26914,26918],[.8276,.4643,.7686,.8912,.8479,.2601]),
3:([-.0007,.0321,.1562,3.3074,.5615,.5588],[.0003,.0118,.0869,1.5659,.2381,.3629],[26914,4204,26918,26639,26918,10573],[.2653,.8301,.9469,.7986,.7267,.7760]),
4:([.0421,-.0030,.0577,.0251,.0443,-.0233],[.0143,.0234,.0167,.0252,.0235,.0199],[8695,8962,10886,12069,8016,8127],[.9382,.9426,.9413,.9317,.9406,.9426]),
5:([.0365,.0923,-.0021,-.0009,-.0003,.3513],[.0130,.0354,.0013,.0004,.0003,.4182],[21177,3802,23856,23856,23856,23858],[.9328,.8331,.8924,.8475,.2814,.7370])}
extra={
'T3_6': [('c.chainleader#c.c_lpatent',.0028,.0009)],
**{f'T5_{i+1}':[('c.chainleader#c.org',b,s)] for i,(b,s) in enumerate(zip([.0509,.0513,-.0038,-.0011,-.0005,.9251],[.0279,.0494,.0017,.0005,.0002,.4058]))}}
c=pd.read_csv(root/'output/coefficients.csv')
checks=[]
for table,(bs,ses,ns,r2s) in spec.items():
    for col,(b,se,n,r2) in enumerate(zip(bs,ses,ns,r2s),1):
        model=f'T{table}_{col}'
        term='c.chainleader#c.res' if table==5 else 'chainleader'
        expected=[(term,b,se)]+extra.get(model,[])
        for term,b,se in expected:
            row=c[(c.model==model)&(c.term==term)].iloc[0]
            result=dict(table=table,column=col,model=model,term=term,published_b=b,replicated_b=row.b,published_se=se,replicated_se=row.se,published_N=n,replicated_N=int(row.N),published_R2=r2,replicated_R2=row.r2)
            result.update(b_match=abs(row.b-b)<.00005,se_match=abs(row.se-se)<.00005,N_match=int(row.N)==n,R2_match=abs(row.r2-r2)<.00005)
            checks.append(result)
df=pd.DataFrame(checks);df.to_csv(root/'output/main_comparison.csv',index=False,encoding='utf-8-sig')
summary={k:int(df[k].sum()) for k in ['b_match','se_match','N_match','R2_match']};summary['coefficient_rows']=len(df)
summary['unique_models']=int(df.model.nunique())
statuses=(root/'output/model_status.txt').read_text()
summary['successful_models']=statuses.count('rc=0\n')
summary['failed_models']=re.findall(r'(\S+) rc=([1-9]\d*)',statuses)
(root/'output/verification_summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
print(df.loc[~df[['b_match','se_match','N_match','R2_match']].all(axis=1)].to_string(index=False))
# Inspect only supplied analytic data, not reconstruction from source databases.
audit={}
for p in (root/'author').glob('*.dta'):
    d=pd.read_stata(p)
    item=dict(rows=len(d),variables=len(d.columns),years=sorted(map(int,d.year.dropna().unique())))
    key=['city','year'] if p.stem=='city' else ['stkcd','year']
    item['duplicate_panel_years']=int(d.duplicated(key).sum())
    if p.stem=='listed':
        item['firms']=int(d.stkcd.nunique());item['cities']=int(d.city.nunique())
        item['treatment_values']=sorted(map(float,d.chainleader.unique()))
        item['treatment_reversals']=int((d.sort_values(key).groupby('stkcd').chainleader.diff()<0).sum())
        item['firms_with_changing_cohort']=int((d.groupby('stkcd').chainleader_l.nunique(dropna=False)>1).sum())
        implied=((d.chainleader_l>0)&d.year.ge(d.chainleader_l)).astype(int)
        item['treatment_cohort_inconsistent_rows']=int(d.chainleader.ne(implied).sum())
        item['treated_cohorts']=sorted(map(int,d.chainleader_l.dropna().unique()))
    audit[p.name]=item
(root/'output/data_audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf-8')
print(audit)
