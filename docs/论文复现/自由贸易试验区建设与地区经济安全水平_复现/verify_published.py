from pathlib import Path
import pandas as pd,numpy as np,json
R=Path(__file__).resolve().parent
# Manually transcribed from body pp129,133,134 and appendix pp3,4; parentheses are t, not SE.
B={
'B1':(3,1,.0085,2.1428,3096,.5588),'B2':(3,2,.0081,2.0319,3018,.5592),'B3':(3,3,.0082,1.8031,2970,.5579),
'M1':(4,1,-.1250,-1.8729,3016,.0508),'M2':(4,2,-.0551,-2.0450,3006,.0282),
'M3':(5,1,1.1305,1.8796,3018,.0746),'M5':(5,2,3.1213,2.2986,3014,.1809),'M6':(5,3,1.9311,2.6225,3014,.0498),'M7':(5,4,1.2978,2.6391,3015,.0622),'M8':(5,5,1.0877,2.1986,3013,.1119),'M4':(5,6,.3213,1.9816,3018,.1852),
'M9':(6,1,8.8765,2.6262,731,.2565),'M10':(6,2,6.4951,1.9524,732,.2109),'M11':(6,3,13.9119,2.2889,730,.0756),'M12':(6,4,.9289,2.8699,2510,.5826),
'A3_1':('A3',1,.0018,3.2962,3018,.5622),'A3_2':('A3',2,.0081,2.2559,3018,.5592),'A3_3':('A3',3,.0087,2.1853,2899,.5604),'A3_4':('A3',4,.0068,1.7923,3018,.5610),
'A4_1':('A4',1,.0111,1.8971,3018,.5593),'A4_2':('A4',2,.0048,.3885,3018,.5581),'A4_3':('A4',3,.0026,.5019,3018,.5581),'A4_4':('A4',4,.0050,.8737,2763,.4015),'A4_5':('A4',5,.0120,1.8627,2763,.4015),
'A5_1':('A5',1,-.0023,-.3001,3018,.5580),'A5_2':('A5',2,-.0291,-2.5638,3018,.5594),'A5_3':('A5',3,-.0015,-.1967,3018,.5580),'A5_4':('A5',4,.0153,3.3633,3018,.5611)}
a=pd.read_csv(R/'data/author_results.csv');rows=[]
for sid,(table,col,b,t,n,r2) in B.items():
 v=a[a.spec==sid].iloc[0]
 rnd=lambda x:f'{x:.4f}'
 trunc=lambda x:np.trunc(x*1e4)/1e4
 exact=rnd(v.b)==rnd(b) and rnd(v.t)==rnd(t) and v.N==n
 near=abs(v.b-b)<1e-4 and abs(v.t-t)<1e-3 and v.N==n
 rows.append(dict(spec=sid,table=table,column=col,body=sid.startswith(('B','M')),published_b=b,published_t=t,published_N=n,published_R2=r2,replicated_b=v.b,replicated_se=v.se,replicated_t=v.t,replicated_N=int(v.N),replicated_within_R2=v.within_r2,coefficient_round_match=rnd(v.b)==rnd(b),coefficient_trunc_match=abs(trunc(v.b)-b)<1e-9,t_round_match=rnd(v.t)==rnd(t),t_trunc_match=abs(trunc(v.t)-t)<1e-9,N_match=v.N==n,R2_match=rnd(v.within_r2)==rnd(r2),status='exact_printed_b_t_N' if exact else 'approximate_last_digit' if near else 'mismatch'))
comp=pd.DataFrame(rows);comp.to_csv(R/'data/published_comparison.csv',index=False,encoding='utf-8-sig')
print(comp[['spec','status','coefficient_trunc_match','t_trunc_match','R2_match']].to_string(index=False))
assert comp.N_match.all() and (comp.replicated_b-comp.published_b).abs().lt(1e-4).all()
for folder in ['specs','specs_controls']:
 for p in (R/f'project/data/{folder}').glob('*.json'):
  sp=json.loads(p.read_text(encoding='utf-8'));sid=sp['spec_id'];v=comp[comp.spec==sid].iloc[0]
  sp.update(table=str(v.table),column=str(v.column),published_coef=float(v.published_b),published_se=None,published_n=int(v.published_N),published_t=float(v.published_t),published_source=f'正文表{v.table}第{v.column}列；括号为t值，未发表SE',replication_status='exact' if v.status=='exact_printed_b_t_N' else 'approximate',notes='系数/N与附件代码核对；部分发表值呈截断而非四舍五入，逐项记录差异，不将t值误当SE。处理时点g由完整Piolt面板恢复。正文描述滞后控制，附件直接使用现有变量；缺乏构造脚本证明这些变量是否已滞后，不擅自再滞后。')
  p.write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8')
  q=R/f'project/output/{folder}/cie20240307__{sid}.csv'
  if q.exists():
   z=pd.read_csv(q);z['published_coef']=v.published_b;z['published_se']=np.nan;z.to_csv(q,index=False)
(R/'logs/published_benchmarks.json').write_text(json.dumps(B,ensure_ascii=False,indent=2),encoding='utf-8')
