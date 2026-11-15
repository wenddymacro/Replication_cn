from pathlib import Path
import json,hashlib,shutil,pandas as pd
R=Path(__file__).resolve().parent
# Record fit-statistic discrepancies separately from the coefficient/SE/N checks.
published={'T2_1':.6099,'T2_2':.6230,'T2_3':.6240,'T3_1':.5980,'T3_3':.4904,'T3_5':.5226,'T4_1':.6364,'T4_2':.6241,'T4_3':.6361,'T5_1':.6246,'T5_2':.6247,'T6_1':.6488,'T6_2':.6248,'T6_3':.6265,'T6_4':.6264}
a=pd.read_csv(R/'data/author_results.csv').drop_duplicates('spec');out=[]
for sid,v in published.items():
 r=a[a.spec==sid].iloc[0];out.append(dict(spec=sid,published_adjR2=v,replicated_adjR2=r.r2a,status='exact_4dp' if f'{r.r2a:.4f}'==f'{v:.4f}' else 'different_4dp'))
pd.DataFrame(out).to_csv(R/'data/fit_statistics_comparison.csv',index=False,encoding='utf-8-sig')
log=(R/'logs/author_body.log').read_text(encoding='utf-8',errors='replace')
assert 'Pseudo R2     = 0.1800' in log and 'Pseudo R2     = 0.1444' in log
(R/'logs/logit_fit_statistics.json').write_text(json.dumps(dict(T3_2=dict(published=.1800,log_value=.1800),T3_4=dict(published=.1444,log_value=.1444)),indent=2),encoding='utf-8')
dates=pd.read_csv(R/'data/recovered_city_dates.csv');audit=json.loads((R/'logs/treatment_audit.json').read_text(encoding='utf-8'))
audit.update(date_unknown_cities=[145,256],date_unknown_single_observation_rows=2,always_treated_upper_bound_sentinel={'51':2002},exact_date_not_claimed_for_sentinel=True)
(R/'logs/treatment_audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf-8')
items=[(R/'original/行政诉讼跨区划管辖与企业社保遵从.pdf','论文')]
for p in (R/'original/extracted').rglob('*'):
 if not p.is_file():continue
 role='原始数据' if p.suffix=='.dta' else '作者代码' if p.suffix=='.do' else '附录' if p.name=='附录.pdf' else '说明'
 items.append((p,role))
for p,role in items:
 q=R/'materials'/role/p.name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256(q.read_bytes()).digest()
manifest=[dict(file=p.relative_to(R/'original').as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'original').rglob('*') if p.is_file() and p.name!='manifest.json']
(R/'original/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
sources=dict(date='2026-11-15',title='行政诉讼跨区划管辖与企业社保遵从',author_page='https://finance.xmu.edu.cn/info/1019/75704.htm',pdf_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2025/4//20250421095002WU_FILE_0.pdf',zip_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2025/4//20250423105511WU_FILE_0.zip',acquisition='已有用户验证的Edge会话下载成功，随后用户附上本地ZIP和桌面PDF；使用用户确认文件。',http_status=None,http_note='浏览器显示下载成功但未获取网络层响应码，不编造200。',complete='ZIP CRC通过；6个包内文件全部解压；正文PDF19页，附录8页；原件SHA256已记录。',upstream_snapshot='reference/Replication_cn-main；核心文件此前2026-11-14联网核验；本次网页工具访问GitHub及raw返回Cache miss，不能声称重新确认11月15日远程最新状态。')
(R/'logs/sources.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2),encoding='utf-8')
failures=[dict(title=t,url=u,http_status=404,status_evidence='Edge正文显示404 - 找不到文件或目录；未抓取网络响应头',attempts=1) for t,u in [
 ('产业用地审批改革与资源配置效率','https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2023/10//20231011104313WU_FILE_1.zip'),
 ('地方绿色信贷贴息政策效果研究','https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2023/10//20231010095057WU_FILE_1.zip')]]
(R/'logs/other_candidate_failures.json').write_text(json.dumps(failures,ensure_ascii=False,indent=2),encoding='utf-8')
print('Classified',len(items),'source files; fit-statistic differences:',[v['spec'] for v in out if v['status']!='exact_4dp'])
