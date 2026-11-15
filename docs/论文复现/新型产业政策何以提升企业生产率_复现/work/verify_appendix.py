from pathlib import Path
import re,json
import pandas as pd
root=Path(__file__).resolve().parents[1]
lines=(root/'work/appendix.txt').read_text(encoding='utf-8').splitlines()
c=pd.read_csv(root/'output/coefficients.csv')
spatial=pd.read_csv(root/'output/spatial.csv') if (root/'output/spatial.csv').exists() else pd.DataFrame()
nums=lambda s:[float(x) for x in re.findall(r'(?<![A-Za-z])[-+]?\d+\.\d+|(?<![A-Za-z])\b\d+\b',s)]
indices=[i for i,s in enumerate(lines) if re.match(r'^chainleader(?:_c)?\s+[-\d]',s)]
tables=[3,4,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
assert len(indices)==len(tables),(len(indices),len(tables))
rows=[]
for table,index in zip(tables,indices):
    if table==4:continue
    bs=nums(lines[index]);ses=nums(lines[index+1])
    ni=next(i for i in range(index+1,len(lines)) if lines[i].startswith('观测数'))
    ns=nums(lines[ni]);rs=nums(lines[ni+1][2:])
    assert len(bs)==len(ses),(table,bs,ses)
    for col,(b,se) in enumerate(zip(bs,ses),1):
        if table==15 and col>3:
            if spatial.empty:continue
            r=spatial[spatial.radius==(col-3)*100].iloc[0]
            model=f'spatial_{(col-3)*100}';term='chainleader'
        else:
            model=f'A{table}_{col}'
            data=c[c.model==model]
            assert len(data)>0,model
            if table==15: data=data[data.term=='chainleader']
            r=data.iloc[0];term=r.term
        row=dict(table=table,column=col,model=model,term=term,published_b=b,replicated_b=r.b,published_se=se,replicated_se=r.se,published_N=int(ns[col-1]),replicated_N=int(r.N),published_R2=rs[col-1],replicated_R2=r.r2)
        row.update(b_match=abs(r.b-b)<.00005,se_match=abs(r.se-se)<.00005,N_match=int(r.N)==int(ns[col-1]),R2_match=abs(r.r2-rs[col-1])<.00005)
        rows.append(row)
def add(table,col,term,b,se,n,r2):
    model=f'A{table}_{col}'
    r=c[(c.model==model)&(c.term==term)].iloc[0]
    row=dict(table=table,column=col,model=model,term=term,published_b=b,replicated_b=r.b,published_se=se,replicated_se=r.se,published_N=n,replicated_N=int(r.N),published_R2=r2,replicated_R2=r.r2)
    row.update(b_match=abs(r.b-b)<.00005,se_match=abs(r.se-se)<.00005,N_match=int(r.N)==n,R2_match=abs(r.r2-r2)<.00005)
    rows.append(row)
# Appendix 7 prints its controls as well as the six focal pre-treatment variables.
core7=['city_TFP','city_TFP_gr','city_TFP_chg','TFP','TFP_gr','TFP_chg']
ns7=[565,551,183,5403,5062,1591];rs7=[.2603,.2518,.2486,.1545,.1636,.1709]
start=next(i for i,l in enumerate(lines) if l.startswith('city_TFP -'))
end=next(i for i in range(start,len(lines)) if lines[i].startswith('观测数'))
for i in range(start,end):
    m=re.match(r'^([a-zA-Z_]+)\s+([-\d.].*)',lines[i])
    if not m:continue
    term=m[1];bs=nums(m[2]);ses=nums(lines[i+1])
    assert len(bs)==len(ses)
    cols=[core7.index(term)+1] if term in core7 else list(range(4,7)) if len(bs)==3 else list(range(1,7))
    assert len(cols)==len(bs)
    for col,b,se in zip(cols,bs,ses):add(7,col,term,b,se,ns7[col-1],rs7[col-1])
for col,(b,se) in enumerate(zip([.3277,.0464],[.1104,.0682]),1):
    add(26,col,'c.chainleader#c.res',b,se,[23856,23858][col-1],[.2738,.4587][col-1])
for col,(b,se) in enumerate(zip([.1535,.1277],[.0867,.0757]),1):
    add(26,col,'c.chainleader#c.org',b,se,[23856,23858][col-1],[.2738,.4587][col-1])
for col,hi,lo,hb,hs,lb,ls in [(1,'num_h','num_l',.0170,.0206,.0643,.0207),(2,'adv_h','adv_l',.0325,.0213,.0480,.0174),(3,'adv_h','adv_l',.0468,.0266,.0443,.0273),(4,'adv_h','adv_l',.0149,.0394,.0600,.0326)]:
    for term,b,se in [(hi,hb,hs),(lo,lb,ls)]:add(27,col,'c.chainleader#c.'+term,b,se,[23913,23913,11419,12390][col-1],[.9318,.9318,.9401,.9316][col-1])
for k,(bs,ses) in enumerate([([.0261,-.0129,-.0251,.0087],[.0322,.0398,.0571,.0834]),([.0208,.0212,-.0144,-.0815],[.0367,.0423,.0773,.0827]),([.0047,-.0642,.0714,.0074],[.0340,.0413,.0578,.0874])],1):
    for col,(b,se) in enumerate(zip(bs,ses),1):add(17,col,f'SpatialSpill_c{k*100}',b,se,[2889,2888,869,868][col-1],[.9795,.9516,.9905,.9446][col-1])
additional=[
    (13,1,'lncovid',.0062,.0043),(13,2,'BIS',-.0426,.0717),(13,3,'vas',-.3026,.0274),(13,4,'merge',-.0016,.0060),(13,5,'d_mps',.0054,.0059),(13,6,'d_mayor',-.0013,.0052),
    (14,1,'plan',.0056,.0163),(14,2,'lndevezone',.0092,.0093),(14,3,'techzone',.0176,.0188),(14,4,'firm_cl',-.0834,.0571),
    (15,1,'LocalSpill',-.0047,.0128),(15,1,'SpatialSpill100',.0073,.0134),(15,1,'SpatialSpill200',.0060,.0116),(15,1,'SpatialSpill300',.0068,.0166),(15,2,'W_chainleader',.0403,.0477),(15,3,'W_chainleader',.0693,.0569),(15,3,'W_TFP',-.4071,.4496),
    (18,6,'MS',5.6440,.3815),(18,7,'PMR',.0593,.0181),(21,3,'strategy',.0270,.0034),(21,4,'change',-.0174,.0086)]
for table,col,term,b,se in additional:
    ref=next(r for r in rows if r['table']==table and r['column']==col)
    add(table,col,term,b,se,ref['published_N'],ref['published_R2'])
df=pd.DataFrame(rows)
df.to_csv(root/'output/appendix_comparison.csv',index=False,encoding='utf-8-sig')
summary={k:int(df[k].sum()) for k in ['b_match','se_match','N_match','R2_match']};summary['rows']=len(df)
(root/'output/appendix_verification_summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print(summary)
print(df[~df[['b_match','se_match','N_match','R2_match']].all(axis=1)].to_string(index=False))
