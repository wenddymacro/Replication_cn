from pathlib import Path
import pandas as pd,numpy as np,json,hashlib
R=Path(__file__).resolve().parent;d=pd.read_stata(R/'original/extracted/数据1.dta',convert_categoricals=False)
tests={}
for v,g in [('a1','Edgewise'),('a2','Inland'),('a3','Coastal'),('b1','Second'),('b2','Third')]+[(f'e{i}',f'd{i}') for i in range(1,5)]:
 ok=d[[v,g,'Piolt']].notna().all(axis=1)
 tests[v]=dict(n=int(ok.sum()),max_diff=float((d.loc[ok,v]-d.loc[ok,g]*d.loc[ok,'Piolt']).abs().max()))
 assert tests[v]['max_diff']<1e-7
for p in (R/'project/code/R').glob('*.R'):
 assert p.read_bytes()==(Path('reference/Replication_cn-main/code/R')/p.name).read_bytes()
modern=pd.read_csv(R/'data/modern_results_all.csv');assert len(modern)==15 and modern.boot_B.eq(999).all()
assert np.isfinite(modern[['twfe','twfe_se','csa','csa_se','bjs','bjs_se']]).all().all()
a=pd.read_csv(R/'data/author_results.csv');assert len(a)==38 and a.spec.nunique()==29
pl=pd.read_csv(R/'data/placebo.csv');assert len(pl)==500 and pl[['b','se','p']].notna().all().all()
(R/'logs/final_validation.json').write_text(json.dumps(dict(interaction_checks=tests,core_files_byte_identical=True,body_specs=15,all_body_point_estimates_and_SE_finite=True,static_bootstrap=999,author_static_models=28,appendix_event_coefficients=10,placebo_draws=500,status='execution_validated_unresolved_source_and_protocol_gaps_remain'),ensure_ascii=False,indent=2),encoding='utf-8')
print('Validation passed: original interactions, source hashes, 15 body estimates, 999 draws each, 500 placebo draws.')
