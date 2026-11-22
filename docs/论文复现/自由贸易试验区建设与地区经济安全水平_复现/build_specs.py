from pathlib import Path
import pandas as pd,json,shutil,hashlib
R=Path(__file__).resolve().parent;P=R/'project'
for n in ['code/R','data/specs','data/specs_controls','data/specs_appendix','diagnostics']:(P/n).mkdir(parents=True,exist_ok=True)
d=pd.read_csv(R/'data/analysis_dates.csv').merge(pd.read_csv(R/'data/sample_flags.csv'),on='row_id',validate='1:1')
d.to_csv(R/'data/analysis.csv',index=False,encoding='utf-8')
C='Popu Capi Phys Econ Infra Inter Urban Consum Act Coastal'.split()
models=json.loads((R/'data/author_models.json').read_text(encoding='utf-8'));a=pd.read_csv(R/'data/author_results.csv')
for m in models:
 sid=m['spec_id'];main=sid=='B1';formal=sid.startswith(('B','M'))
 if not formal:continue
 y=m['command'].split()[1];v=a[a.spec==sid].iloc[0]
 sp=dict(paper_id='cie20240307',spec_id=sid,journal='cie',year=2024,issue=3,table='pending_PDF',column=sid,data_path='$CIE_RAW/data/analysis.csv',id_var='id',time_var='year',y_var=y,gvar='g_recovered',treat_var='Piolt',cluster_var='id',xt_vars=[],controls=[] if main else C,sample_filter=f'sample_{sid} == 1',static_or_event='static',published_coef=None,published_se=None,published_n=None,published_source='待原文核对，不将作者数据估计值冒充发表值',preferred=sid=='B2',in_abstract_intro=sid.startswith('B'),reports_modern_estimator=False,software='Stata MP 16.0',replication_status='not_run',notes='原文核对完成前属于方法运行核查；日期由完整平衡面板Piolt恢复，所有已知action与恢复日期一致；未修改原始文件。')
 folder='specs' if main else 'specs_controls';(P/f'data/{folder}/cie20240307__{sid}.json').write_text(json.dumps(sp,ensure_ascii=False,indent=2),encoding='utf-8')
for p in Path('reference/Replication_cn-main/code/R').glob('*.R'):shutil.copy2(p,P/'code/R'/p.name)
for p in ['README.md','docs/PROTOCOL.md','docs/SCREENING.md','docs/REPLICATION.md','docs/SPEC_SCHEMA.md']:
 q=P/'upstream_documents'/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(Path('reference/Replication_cn-main')/p,q)
for p in ['run_one.R','run_queue.R','runtime_info.R','export_comparisons.R']:shutil.copy2(R.parent/'jurisdiction_social/project'/p,P/p)
(R/'logs/upstream_code_hashes.json').write_text(json.dumps([dict(file=p.name,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (P/'code/R').glob('*.R')],indent=2),encoding='utf-8')
print('15 body candidate specifications; source numerical metadata pending PDF verification.')
if (R/'logs/published_benchmarks.json').exists():
 import runpy
 runpy.run_path(str(R/'verify_published.py'),run_name='__main__')
