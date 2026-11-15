from pathlib import Path
import pandas as pd,json
root=Path(__file__).resolve().parent
formal=pd.read_csv(root/'project/output/all_spec_results.csv').set_index('spec_id')
files=list((root/'validation_rerun/output/specs').glob('cie*.csv'))+list((root/'validation_rerun/output/specs_controls').glob('cie*.csv'))
assert len(files)==21
smoke=pd.concat([pd.read_csv(p) for p in files]).set_index('spec_id')
checks=[]
for key in formal.index:
    for name in ['twfe','twfe_se','csa','csa_se','bjs','bjs_se','twfe_raw','y_sd']:
        a,b=formal.loc[key,name],smoke.loc[key,name]
        ok=(pd.isna(a) and pd.isna(b)) or abs(a-b)<1e-10
        assert ok,(key,name,a,b)
        checks.append(dict(spec_id=key,field=name,match=bool(ok)))
pd.DataFrame(checks).to_csv(root/'logs/runner_point_revalidation.csv',index=False)
statuses=[]
for p in (root/'validation_rerun/logs').glob('queue_*_status.csv'):statuses.append(pd.read_csv(p))
assert len(statuses)==4 and pd.concat(statuses).rc.eq(0).all()
for ctrl,label in [(False,'main'),(True,'controls')]:
    s=formal[formal.controls==ctrl]
    row=dict(sample=label,specs=len(s),TWFE=int(s.twfe.notna().sum()),BJS=int(s.bjs.notna().sum()),CSA=int(s.csa.notna().sum()),CSA_skipped=int(s.csa_note.fillna('').str.startswith('csa_skipped_xt_levels').sum()),CSA_failed=int((s.csa.isna()&~s.csa_note.fillna('').str.startswith('csa_skipped_xt_levels')).sum()))
    if not ctrl:rows=[row]
    else:rows.append(row)
pd.DataFrame(rows).to_csv(root/'project/output/tables/estimator_availability.csv',index=False)
summary=json.loads((root/'verification.json').read_text(encoding='utf-8'))
summary.update(delivery_runner_specs_passed=21,point_and_se_revalidation_checks=len(checks),point_and_se_revalidation_all_passed=True)
rp=pd.concat([pd.read_csv(root/'project/output/main_comparisons.csv'),pd.read_csv(root/'project/output/controls_comparisons.csv')])
py=pd.read_csv(root/'project/output/all_comparisons.csv')
joined=rp.merge(py,on=['spec_id','estimator'],suffixes=('_r','_py'),validate='one_to_one')
assert len(joined)==len(py)
assert ((joined.vdiff-joined.variance_difference).abs()<1e-10).all()
assert ((joined.z_diff-joined.z_difference).abs()<1e-9).all()
assert (joined.sig_flip_r==joined.sig_flip_py).all()
summary['coherent_joint_variance_r_python_checks_passed']=True
summary['comparison_rows_checked']=len(joined)
(root/'verification.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print('21 delivery reruns clean; all',len(checks),'point/SE comparisons match the formal 999-draw results')
