from pathlib import Path
import pandas as pd
R=Path(__file__).resolve().parent
a=pd.read_csv(R/'data/author_results.csv');rows=[]
p=pd.read_csv(R/'data/published_comparison.csv')
for _,x in p.iterrows():rows.append(dict(spec=x.spec,term='DiD',published_b=x.published_b,published_se=x.published_se,published_N=x.published_N))
for table,terms,inter_b,inter_se,main_b,main_se,ns in [
 (2,['DiD_Fund_Size']*2+['DiD_Fund_GovShare']*2+['DiD_Fund_Manage']*2,[.1741,.2765,.0952,.1423,.0502,.0192],[.0808,.1153,.0270,.0312,.0134,.0180],[-.0378,-.0446,-.0468,-.0654,.0060,.0321],[.0183,.0247,.0181,.0194,.0119,.0167],[42815]*2+[42525]*2+[53620]*2),
 (3,['DiD_Fund_RiskShare']*2+['DiD_Fund_Structure']*2+['DiD_Fund_RC']*2,[.1350,.1331,.0579,.0697,.0540,.0658],[.0472,.0537,.0116,.0142,.0123,.0152],[-.0168,-.0135,-.0001,-.0051,.0254,.0223],[.0221,.0254,.0099,.0120,.0073,.0083],[52532]*2+[55655]*2+[55551]*2)]:
 for i in range(6):
  for term,b,se in [(terms[i],inter_b[i],inter_se[i]),('DiD',main_b[i],main_se[i])]:rows.append(dict(spec=f'T{table}_{i+1}',term=term,published_b=b,published_se=se,published_N=ns[i]))
for i,terms in enumerate([[('DiD',.0283,.0067),('DiDHighCET1',.0488,.0136)],[('DiD',.0282,.0080),('DiDHighCET1',.0554,.0172)],[('Treat_Ratio',.0807,.1223)],[('Treat_Ratio',-.1821,.1962)]],1):
 for term,b,se in terms:rows.append(dict(spec=f'T5_{i}',term=term,published_b=b,published_se=se,published_N=57205 if i<3 else 690))
v=pd.DataFrame(rows).merge(a,on=['spec','term'],validate='one_to_one')
v['exact']=(v.b.round(4)==v.published_b)&(v.se.round(4)==v.published_se)&(v.N==v.published_N)
v.to_csv(R/'data/all_body_comparison.csv',index=False,encoding='utf-8-sig')
print('Body models',v.spec.nunique(),'coefficients',len(v),'exact',int(v.exact.sum()))
print(v[~v.exact].to_string(index=False))
