from pathlib import Path
import json,shutil
R=Path(__file__).resolve().parent
p=R/'project/data/screening/by_paper/cie123767.json'
s=json.loads(p.read_text(encoding='utf-8'))
specs=[json.loads(x.read_text(encoding='utf-8')) for x in sorted((R/'project/data').glob('spec*/*.json'))]
def record(x):
 return dict(spec_id=x['spec_id'],location=x['published_source'],static_or_event='static',outcome=x['y_var'],outcome_transform='already in author data',treatment_definition='城市设立知识产权质押融资风险补偿基金后DiD=1；首次年份start_year',fixed_effects='分支机构 + 银行×年份' if x['xt_vars'] else '分支机构 + 年份',xt_vars=x['xt_vars'],controls=x['controls'],weights='unweighted',clustering='分支机构',coef=x['published_coef'],se=x['published_se'],n_obs=x['published_n'],preferred=x['preferred'],in_abstract_or_intro=x['in_abstract_intro'],notes=x['notes'])
s.update(screener='Codex',screen_date='2026-11-14',screened_from='article_text+package',near_miss=False,near_miss_controls_only=True,near_miss_reason='十个正文设定仅因时变控制变量进入二级样本',policy_or_event='城市知识产权质押融资风险补偿基金分期设立，2014–2020七个样本内新批次，另有2011已处理组',unit='bank_branch',assignment_unit='city',time_unit='year',n_cohorts_reported=7,estimators_reported=['twfe_static','twfe_event_appendix'],reports_modern_estimator=False,main_or_robustness='main',data_sources=['专利质押登记','金融许可证','城市政策文件','CSMAR','Wind'],data_access='public',eligible_specs=[record(x) for x in specs if not x['controls']],near_miss_controls_only_specs=[record(x) for x in specs if x['controls']],priority=1)
s['notes']=s['notes'].replace('银行448类','作者样本内银行338类')
p.write_text(json.dumps(s,ensure_ascii=False,indent=2),encoding='utf-8')
deps=R/'dependencies/stata_ado'
shutil.copytree(R.parent/'chain_policy/output/local_ado',deps,dirs_exist_ok=True)
w=R/'work/replicate_body.do';t=w.read_text(encoding='utf-8').replace('../../chain_policy/output/local_ado','../dependencies/stata_ado');w.write_text(t,encoding='utf-8')
docs=R/'project/docs';docs.mkdir(exist_ok=True)
for name in ['PROTOCOL.md','SCREENING.md','REPLICATION.md','SPEC_SCHEMA.md']:
 shutil.copy2(Path('reference/Replication_cn-main/docs')/name,docs/name)
shutil.copy2('reference/Replication_cn-main/README.md',R/'project/UPSTREAM_README.md')
print('Screening schema completed; Stata dependencies and upstream documents included.')
