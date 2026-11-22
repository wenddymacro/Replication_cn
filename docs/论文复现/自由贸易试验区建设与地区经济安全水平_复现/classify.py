from pathlib import Path
import shutil,json,hashlib
R=Path(__file__).resolve().parent
for p in (R/'original').rglob('*'):
 if not p.is_file() or p.suffix=='.json':continue
 role='论文' if p.parent==R/'original' and p.suffix=='.pdf' else '原始数据' if p.suffix=='.xlsx' else '处理数据' if p.suffix=='.dta' else '作者代码' if p.suffix=='.do' else '附录' if p.name=='附录.pdf' else '说明' if p.suffix=='.pdf' else '原始附件'
 q=R/'materials'/role/p.name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
manifest=[dict(file=p.relative_to(R/'original').as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'original').rglob('*') if p.is_file() and p.name!='manifest.json']
(R/'original/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
models=json.loads((R/'data/author_models.json').read_text(encoding='utf-8'))
for m in models:
 sid=m['spec_id']
 m['location']='body' if sid.startswith(('B','M')) else 'online_appendix'
 m['teacher_status']='main' if sid=='B1' else 'secondary_controls_only' if sid.startswith(('B','M')) else 'appendix_controls_only' if sid=='A3_3' else 'appendix_excluded_continuous_treatment' if sid=='A3_1' else 'appendix_excluded_other_treatments' if sid=='A3_4' else 'appendix_excluded_treatment_interaction'
models += [dict(spec_id='A3_2',location='online_appendix',teacher_status='appendix_bootstrap_inference_same_model_B2'),dict(spec_id='AF1',location='online_appendix',teacher_status='appendix_event_dates_inconsistent_with_Piolt_no_silent_substitution'),dict(spec_id='A2',location='online_appendix',teacher_status='excluded_probit')]
screen=dict(paper_id='cie20240307',title='自由贸易试验区建设与地区经济安全水平——基于地级市的经验证据',main_static=1,secondary_static=14,body_event=0,models=models,modern_estimator_reported=False,body_pages_reviewed=list(range(1,20)),appendix_separate=True,source_data_available=True)
p=R/'project/data/screening/by_paper/cie20240307.json';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(screen,ensure_ascii=False,indent=2),encoding='utf-8')
sources=dict(date='2026-11-15',pdf_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/4//20240418011710WU_FILE_0.pdf',zip_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/4//20240418011708WU_FILE_1.zip',zip_crc='passed',zip_file_count=5,pdf_pages=19,appendix_pages=5,pdf_acquisition='已验证Edge会话打开原文；用户按Escape停止浏览器自动化并提供桌面PDF，使用该本地文件',http_status=None,http_note='未取得网络响应头，不编造HTTP状态',upstream_snapshot='reference/Replication_cn-main；此前2026-11-14核对远程核心；本次不声称已核验11月15日最新远程版本')
(R/'logs/sources.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2),encoding='utf-8')
print('Materials classified; screening: 1 main + 14 secondary body static specs.')
