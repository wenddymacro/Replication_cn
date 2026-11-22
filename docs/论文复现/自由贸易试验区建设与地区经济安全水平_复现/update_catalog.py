from pathlib import Path
import json
p=Path(__file__).resolve().parents[1]/'did_catalog/did_records.json'
d=json.loads(p.read_text(encoding='utf-8'));m=[r for r in d if r['title'].startswith('自由贸易试验区建设与地区经济安全水平')];assert len(m)==1
m[0].update(evidence_level='A',method='城市层面二元吸收态交错DID；2013/2015/2017/2018/2019五cohort',data_status='PDF19页、ZIP内5文件完整；Stata处理数据、Excel指标、作者代码、附录5页；CRC/SHA256通过',run_status='正文15列三法点估计/SE及各999次已运行；28个原文/附录静态回归和500次安慰剂已运行。严格全流程验收未通过',teacher_eligibility='正文1主样本+14含控制二级样本；附录单列。控制CSA不平衡协变量口径与文字协议有差异，现代杠杆尚未实现',priority='未完全完成，不计入全流程完成数量',notes='2026-11-15：见replication/fta_security/复现报告.md及status.json。正文系数/N近打印精度，截断四位恢复b/t；T5_c3 R²、附表2 Probit、指数构造与控制滞后证据仍未关闭。偏好模型BJS正且p=.0284；原版CSA负且p=.1921，不能直接宣称推翻原结论。')
p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf-8');print('Updated only FTA paper; strict status remains incomplete.')
