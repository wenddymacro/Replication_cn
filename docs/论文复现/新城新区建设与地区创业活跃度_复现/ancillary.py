from pathlib import Path
import pandas as pd,json,hashlib,shutil
R=Path(__file__).resolve().parent
d=pd.read_csv(R/'data/city_analysis.csv');d=d[d.sample_T2_2==1]
ref={'lnNo_GSmgfper':(.3176,.9671,-3.8903,4.6852),'popdensity2006':(881.4875,839.8127,13,5073.46),'agriareaper2006':(1.5259,1.5799,.05,11.96),'consratio2006':(6.7115,7.5801,.13,44.33),'lnindp2006':(14.3797,1.4374,9.4806,18.5970),'jinrong2006':(2.3713,.9999,.2395,7.0931)}
out=[]
for v,vals in ref.items():
 actual=[d[v].mean(),d[v].std(ddof=1),d[v].min(),d[v].max()]
 for stat,pub,got in zip(['mean','sample_sd','min','max'],vals,actual):out.append(dict(variable=v,stat=stat,published=pub,replicated=got,status='exact_4dp' if f'{pub:.4f}'==f'{got:.4f}' else 'different_4dp'))
pd.DataFrame(out).to_csv(R/'data/table1_comparison.csv',index=False,encoding='utf-8-sig')
items=[(R/'original/新城新区建设与地区创业活跃度.pdf','论文')]
for p in (R/'original/extracted').rglob('*'):
 if not p.is_file():continue
 role='原始数据' if p.suffix=='.dta' else '作者代码' if p.suffix=='.do' else '附录' if p.name=='附录.pdf' else '说明'
 items.append((p,role))
for p,role in items:
 q=R/'materials'/role/p.name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256(q.read_bytes()).digest()
manifest=[dict(file=p.relative_to(R/'original').as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'original').rglob('*') if p.is_file() and p.name!='manifest.json']
(R/'original/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
sources=dict(date='2026-11-15',title='新城新区建设与地区创业活跃度',author_page='https://econpub.xmu.edu.cn/research/index.php?p_id=5018&ser_id=2',pdf_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2025/3//20250325100816WU_FILE_1.pdf',zip_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2025/3//20250325100806WU_FILE_0.zip',acquisition='优先已有用户验证Edge会话；ZIP下载完成且用户再次附上；PDF已在浏览器成功加载，随后用户提供桌面文件，本轮使用用户确认的PDF。未重复提交下载请求，未出现或操作验证码。',http_status=None,http_note='浏览器显示成功，但未读取网络层响应头，不编造HTTP200。',complete='ZIP CRC通过；5个包内文件全解压；正文19页、附录4页。',upstream_snapshot='reference/Replication_cn-main，核心文件此前2026-11-14核验；本轮保持字节一致，不声称11月15日重新核验远程最新版本。',eventdd_reference='https://github.com/damiancclarke/eventdd/blob/main/eventdd.ado',eventdd_observation='inrange只限制绘图显示，不限制回归中完整lead/lag范围；按作者dist全范围-8..8重算，报告-4..4。')
(R/'logs/sources.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'logs/upstream_code_hashes.json').write_text(json.dumps([dict(file=p.name,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'project/code/R').glob('*.R')],indent=2),encoding='utf-8')
print('Table1 exact cells:',sum(v['status']=='exact_4dp' for v in out),'of',len(out),'; classified source files',len(items))
