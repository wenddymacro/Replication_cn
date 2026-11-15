from pathlib import Path
import csv,json,shutil
R=Path(__file__).resolve().parent
S=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-jurisdiction-run')
files=list((S/'project/output/specs').glob('*.csv'))+list((S/'project/output/specs_controls').glob('*.csv'))
assert len(files)==9
for q,n in [(1,3),(2,2),(3,2),(4,2)]:
 with (S/f'logs/queue_{q}_status.csv').open(newline='',encoding='utf-8') as h:rows=list(csv.DictReader(h))
 assert len(rows)==n and all(x['rc']=='0' for x in rows),(q,rows)
audit=[]
for p in files:
 with p.open(newline='',encoding='utf-8') as h:rows=list(csv.reader(h))
 k=rows[0].index('reports_modern_estimator');original=[r[:] for r in rows]
 if any(r[k].lower()!='true' for r in rows[1:]):
  backup=S/'logs/before_metadata_correction'/p.name;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,backup)
  for r in rows[1:]:r[k]='TRUE'
  with p.open('w',newline='',encoding='utf-8') as h:csv.writer(h,lineterminator='\n').writerows(rows)
  assert all([v for j,v in enumerate(a) if j!=k]==[v for j,v in enumerate(b) if j!=k] for a,b in zip(original,rows))
  audit.append(p.name)
for folder in ['specs','specs_controls']:
 for p in (R/f'project/data/{folder}').glob('*.json'):shutil.copy2(p,S/f'project/data/{folder}'/p.name)
(S/'logs/metadata_correction.json').write_text(json.dumps(dict(field='reports_modern_estimator',value=True,reason='正文及附录报告dCDH；初始录入false更正为true。仅元数据；全部其他CSV字符串字段逐格保持一致，无数值改写；原输出备份另存。',changed_files=audit),ensure_ascii=False,indent=2),encoding='utf-8')
print('Validated 9/9 jobs and corrected metadata only:',len(audit))
