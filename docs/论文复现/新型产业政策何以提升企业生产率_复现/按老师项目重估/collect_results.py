from pathlib import Path
import pandas as pd,numpy as np,json,shutil,hashlib,math
from statistics import NormalDist
root=Path(__file__).resolve().parent
run=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-protocol-run')
project=run/'project'
files=list((project/'output/specs').glob('cie*.csv'))+list((project/'output/specs_controls').glob('cie*.csv'))
if len(files)!=21:raise SystemExit(f'Waiting for all outputs: {len(files)}/21')
for p in files:
    d=pd.read_csv(p)
    missing=[c for c in ['G_eff_csa','L_max_csa'] if c not in d]
    if missing:
        assert d.csa_note.str.startswith('csa_skipped_xt_levels').all()
        backup=project/'output/raw_before_schema_fix'/p.name;backup.parent.mkdir(exist_ok=True);shutil.copy2(p,backup)
        for c in missing:d[c]=np.nan
        d.to_csv(p,index=False)
allres=pd.concat([pd.read_csv(p) for p in files],ignore_index=True).sort_values('spec_id')
assert len(allres)==21 and allres.boot_B.eq(999).all()
assert allres[['twfe','twfe_se','bjs','bjs_se']].notna().all().all(),allres[['spec_id','bjs_note']].to_string()
main=allres[allres.spec_id=='T1_1'].iloc[0]
assert pd.notna(main.csa) and pd.notna(main.csa_se)
audit=pd.read_csv(project/'output/design_audit.csv')
assert (audit.n_author_sample==audit.n_protocol_input).all()
original=pd.read_csv(root.parent/'chain_policy/output/main_comparison.csv')
for _,r in allres.iterrows():
    b=original[original.model==r.spec_id].iloc[0]
    assert r.n==b.replicated_N,(r.spec_id,r.n,b.replicated_N)
validation=pd.read_csv(project/'output/validation_schema/specs_controls/cie20260904__T1_4.csv').iloc[0]
v=allres[allres.spec_id=='T1_4'].iloc[0]
schema_checks={c:bool(abs(v[c]-validation[c])<1e-11) for c in ['twfe','twfe_se','bjs','bjs_se','twfe_raw','y_sd']}
assert all(schema_checks.values())
out=project/'output'
allres.to_csv(out/'all_spec_results.csv',index=False,encoding='utf-8-sig')
comparisons=[]
for _,r in allres.iterrows():
    for estimator in ['csa','bjs']:
        if pd.isna(r[estimator]):continue
        cov=r['cov_twfe_'+estimator];fallback=pd.isna(cov);cov=0 if fallback else cov
        joint=(not fallback) and pd.notna(r.bsd_twfe) and pd.notna(r['bsd_'+estimator])
        if joint:
            rho=cov/(r.bsd_twfe*r['bsd_'+estimator]);assert abs(rho)<=1+1e-10
            var=r.bsd_twfe**2+r['bsd_'+estimator]**2-2*cov
        else:var=r.twfe_se**2+r[estimator+'_se']**2-2*cov
        guarded=False
        assert var>0,(r.spec_id,estimator,var)
        diff=r[estimator]-r.twfe;z=diff/math.sqrt(var)
        twpass=r.G_eff_twfe>=10 and r.L_max_twfe<=.25
        G=r['G_eff_'+estimator];L=r['L_max_'+estimator]
        basis='both' if pd.notna(G) else 'twfe_only'
        passed=twpass and (pd.isna(G) or (G>=10 and L<=.25))
        comparisons.append(dict(spec_id=r.spec_id,controls=bool(r.controls),estimator=estimator,twfe=r.twfe,modern=r[estimator],twfe_se=r.twfe_se,modern_se=r[estimator+'_se'],difference=diff,variance_difference=var,z_difference=z,p_difference=2*(1-NormalDist().cdf(abs(z))),flip=np.sign(r[estimator])!=np.sign(r.twfe),sig_flip=(np.sign(r[estimator])!=np.sign(r.twfe)) and abs(z)>1.959963984540054,covariance=cov,covariance_rule='zero_placeholder_v0.1' if fallback else 'joint_bootstrap_999',variance_basis='joint_bootstrap_matrix' if joint else 'analytic_marginals_cov_zero',variance_guard=guarded,screen_basis=basis,pass_screen=passed,se_ratio=r[estimator+'_se']/r.twfe_se))
comp=pd.DataFrame(comparisons);comp.to_csv(out/'all_comparisons.csv',index=False,encoding='utf-8-sig')
for folder in ['output']:
    shutil.copytree(project/folder,root/'project'/folder,dirs_exist_ok=True)
shutil.copytree(run/'logs',root/'logs',dirs_exist_ok=True)
summary=dict(specifications=21,main=1,secondary=20,all_bootstrap_B_999=True,main_csa=float(main.csa),main_bjs=float(main.bjs),main_twfe=float(main.twfe),csa_available=int(allres.csa.notna().sum()),csa_skipped_categories=int(allres.csa_note.fillna('').str.startswith('csa_skipped_xt_levels').sum()),csa_failed=int((allres.csa.isna()&~allres.csa_note.fillna('').str.startswith('csa_skipped_xt_levels')).sum()),bjs_available=int(allres.bjs.notna().sum()),schema_fix_identity_checks=schema_checks,twfe_effective_samples_changed=int((audit.n_twfe_effective!=audit.n_protocol_input).sum()))
(root/'verification.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
