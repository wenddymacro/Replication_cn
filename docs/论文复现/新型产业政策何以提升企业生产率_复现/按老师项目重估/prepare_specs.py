from pathlib import Path
import pandas as pd,json
root=Path(__file__).resolve().parent
project=root/'project'
for p in ['work','data','logs']: (root/p).mkdir(exist_ok=True)
phase1=root.parent/'chain_policy'
if not phase1.exists():phase1=root.parent
source=phase1/'work/author_program.txt'
s=source.read_text(encoding='utf-8');s=s[:s.index('*==============================附录部分')]
commands=[x.strip() for x in s.splitlines() if x.strip().startswith('reghdfe ')]
names=['initial']+[f'T{t}_{j}' for t,k in [(1,4),(2,6),(3,6),(4,6),(5,6)] for j in range(1,k+1)]
assert len(names)==len(commands)
out=['clear all','set more off','set processors 1','adopath ++ "../../chain_policy/output/local_ado"','log using "../logs/sample_flags.log", text replace','use "../../chain_policy/author/listed.dta", clear','gen long row_id=_n','global clist "lnage lnasset lnsize lev edu ceo"','global xlist "lnage lnasset lnsize lev edu ceo lngdppc secondary govexp ftd"']
for name,cmd in zip(names,commands):out += [cmd,f'gen byte sample_{name}=e(sample)']
out+=['keep row_id sample_*','export delimited using "../data/sample_flags.csv", replace','log close']
(root/'work/export_samples.do').write_text('\n'.join(out),encoding='utf-8')
if not (root/'data/sample_flags.csv').exists():
    print('Exporter ready; run Stata then invoke this script again.');raise SystemExit
d=pd.read_stata(phase1/'author/listed.dta');d['row_id']=range(1,len(d)+1)
flags=pd.read_csv(root/'data/sample_flags.csv');d=d.merge(flags,on='row_id',validate='one_to_one')
d.to_csv(root/'data/analysis.csv',index=False,encoding='utf-8')
bench=pd.read_csv(phase1/'output/main_comparison.csv')
paper_id='cie20260904';clist='lnage lnasset lnsize lev edu ceo'.split();xlist=clist+'lngdppc secondary govexp ftd'.split()
records=[];excluded=[]
for name,cmd in zip(names[1:],commands[1:]):
    table,col=map(int,name[1:].split('_'))
    if table==5 or (table==3 and col==6):
        excluded.append(dict(location=f'表{table}第{col}列',reason='处理×分组/特征的异质性交互项，协议第3节排除'));continue
    sample=d[d['sample_'+name]==1]
    controls=[] if table==1 and col==1 else clist if table==1 and col==2 else xlist
    xt=[] if table==1 and col<4 else ['prv','indid']
    b=bench[(bench.table==table)&(bench.column==col)].iloc[0]
    dep=cmd.split()[1]
    spec=dict(paper_id=paper_id,spec_id=name,journal='cie',year=2026,issue=9,data_path='$CIE_RAW/data/analysis.csv',id_var='stkcd',time_var='year',y_var=dep,gvar='chainleader_l',treat_var='chainleader',cluster_var='city',xt_vars=xt,controls=controls,sample_filter=f'sample_{name} == 1',static_or_event='static',published_coef=float(b.published_b),published_se=float(b.published_se),published_n=int(b.published_N),published_source=f'表{table}第{col}列',table=str(table),column=str(col),preferred=table==1 and col==4,in_abstract_intro=table==1,reports_modern_estimator=True,software='Stata',replication_status='exact',notes='作者原始系数已复现；样本先锁定作者e(sample)。行业特征在协议重估时按首期固定，相关差异另记。原文中的TFP已在数据内，无须再次取对数。')
    target=project/'data'/('specs_controls' if controls else 'specs')/f'{paper_id}__{name}.json'
    target.write_text(json.dumps(spec,ensure_ascii=False,indent=2),encoding='utf-8');records.append(spec)
screen=dict(paper_id=paper_id,journal='cie',year=2026,issue=9,title='新型产业政策何以提升企业生产率——来自产业链链长制的证据',screened_from='article_text+package',screener='Codex',screen_date='2026-11-14',staggered_design=True,eligible_design=True,near_miss_controls_only=True,unit='firm',assignment_unit='city×重点产业链匹配企业',time_unit='year',n_cohorts_reported=7,estimators_reported=['twfe_static','twfe_event','CSA','Sun-Abraham','local_projection','dCDH'],reports_modern_estimator=True,main_or_robustness='main',data_access='partial',package_status='data_and_code',software='Stata',eligible_specs=[x for x in records if not x['controls']],near_miss_controls_only_specs=[x for x in records if x['controls']],ineligible_specs=excluded,appendix_specs=[dict(location='附录',notes='作者结果已在第一阶段核对；按协议不计入正文主样本。税调数据未公开。')],n_eligible_specs=1,priority=1,notes='75个行业类别，超过CSA特征60类上限的设定按协议不报告CSA。377家企业行业代码变化，在每设定样本首期固定并记录。')
(project/'data/screening/by_paper'/f'{paper_id}.json').write_text(json.dumps(screen,ensure_ascii=False,indent=2),encoding='utf-8')
print('Created',len(records),'specifications: main',sum(not x['controls'] for x in records),'controls',sum(bool(x['controls']) for x in records))
