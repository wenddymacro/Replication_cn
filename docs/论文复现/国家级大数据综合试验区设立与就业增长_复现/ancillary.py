from pathlib import Path
import pandas as pd,json,shutil
R=Path(__file__).resolve().parent
d=pd.read_stata(R/'work/ml.dta',convert_categoricals=False)
r=d['真实实施'];t=d['理论实施']
actual=[int(r.eq(1).sum()),int((r.eq(1)&t.eq(1)).sum()),int((r.eq(0)&t.eq(1)).sum()),int((r.eq(1)&t.eq(0)).sum()),int((r.eq(0)&t.eq(0)).sum())]
expected=[58,5,14,53,164]
assert actual==expected,(actual,expected)
pd.DataFrame(dict(item=['实际试点','试点且最优','非试点且最优','试点但非最优','非试点且非最优'],published=expected,replicated=actual)).to_csv(R/'data/table7_counts.csv',index=False,encoding='utf-8-sig')
for p in ['README.md','docs/PROTOCOL.md','docs/SCREENING.md','docs/REPLICATION.md','docs/SPEC_SCHEMA.md']:
 q=R/'project/upstream_documents'/p;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(Path('reference/Replication_cn-main')/p,q)
shutil.copy2(R.parent/'fiscal_risk/project/runtime_info.R',R/'project/runtime_info.R')
shutil.copytree(R.parent/'chain_policy/output/local_ado',R/'dependencies/stata_ado',dirs_exist_ok=True)
p=R/'work/replicate_body.do';p.write_text(p.read_text(encoding='utf-8').replace('../../chain_policy/output/local_ado','../dependencies/stata_ado'),encoding='utf-8')
print('Table7 supplied-policy-label counts match:',actual,'; ML model NOT independently refit.')
