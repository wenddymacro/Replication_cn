from pathlib import Path
import json,pandas as pd
from pypdf import PdfReader
R=Path(__file__).resolve().parent
for name in ['附录.pdf','《中国工业经济》编辑部关于公开数据附件的使用说明.pdf']:
 p=next((R/'original/_extracted').rglob(name));pdf=PdfReader(p)
 (R/'logs'/('appendix_text.txt' if name=='附录.pdf' else 'data_use_notice.txt')).write_text('\n'.join(f'--- PAGE {i+1} ---\n'+(p.extract_text() or '') for i,p in enumerate(pdf.pages)),encoding='utf-8')
 print(name,len(pdf.pages),'pages')
d=pd.read_csv(R/'data/analysis.csv');out=[]
for p in sorted((R/'project/data').glob('spec*/*.json')):
 s=json.loads(p.read_text(encoding='utf-8'));x=d[d['sample_'+s['spec_id']]==1]
 out.append(dict(spec=s['spec_id'],n=len(x),units=x.pledgee_id.nunique(),clusters=x.pledgee_id.nunique(),banks=x.bank_name_id.nunique(),cohorts=sorted(x.loc[x.policy_g>2011,'policy_g'].unique().tolist()),always_treated_rows=int(((x.policy_g>0)&(x.policy_g<=2011)).sum()),never_treated_rows=int((x.policy_g==0).sum()),max_duplicate_unit_year=int(x.duplicated(['pledgee_id','year']).sum()),unbalanced=len(x)!=x.pledgee_id.nunique()*x.year.nunique()))
(R/'data/design_audit.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
print(pd.DataFrame(out).to_string(index=False))
