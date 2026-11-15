from pathlib import Path
import json,pandas as pd
R=Path(__file__).resolve().parent
d=pd.read_csv(R/'data/firm_analysis.csv');stable=d.groupby('Firm').city.nunique().eq(1)
d['stable_city']=d.Firm.map(stable).astype(int);d.to_csv(R/'data/firm_analysis.csv',index=False,encoding='utf-8')
p=R/'project/data/sensitivity';p.mkdir(exist_ok=True)
s=json.loads((R/'project/data/specs/cie117612__T1_2.json').read_text(encoding='utf-8'))
s.update(spec_id='STABLE_CITY',sample_filter='sample_T1_2 == 1 & stable_city == 1 & keep_absorb == TRUE',preferred=False,published_coef=None,published_se=None,published_n=None,replication_status='supplemental_unpublished_sample',notes='补充敏感性分析：剔除100家城市归属有变化的企业，不能算作作者已发表设定；单独OUT_DIR，不混入正式计数。')
(p/'cie117612__STABLE_CITY.json').write_text(json.dumps(s,ensure_ascii=False,indent=2),encoding='utf-8')
print('Supplemental stable city sample',d[d.sample_T1_2.eq(1)&d.stable_city.eq(1)].shape[0])
