from pathlib import Path
import json
p=Path(__file__).resolve().parents[1]/'did_catalog/did_records.json'
d=json.loads(p.read_text(encoding='utf-8'))
matches=[r for r in d if r['title']=='国家级大数据综合试验区设立与就业增长']
assert len(matches)==1
r=matches[0]
r.update(evidence_level='A',method='2015/2016分批设立试验区的交错DID；企业及城市面板',
 data_status='已核验用户提供PDF及完整公开ZIP；城市、企业和ML分析数据及Stata代码齐备，CRC及SHA256通过',
 run_status='正文30静态回归核对，32印刷系数/SE/N精确匹配；协议30设定已运行，29静态各999次；CSA存在失败与异常值，非全部完成推断',
 teacher_eligibility='1主样本+29二级样本；表1第1列无年份FE排除。迁址日期裁定及不平衡面板CSA协变量文字/代码差异需保留',
 priority='已完成本轮；CSA局限与协议差异待统一规则',
 evidence_urls='https://ciejournal.ajcass.com/Magazine/show/?id=117612',
 notes='2026-11-14：详见replication/bigdata_employment/复现报告.md。上游R字节一致。偏好含控模型BJS正向但5%不显著（正态p=.0683）；原样本CSA时变聚类受限；表2两列CSA异常并已诊断。附录/ML未全部独立重跑。')
p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf-8')
print('Updated active paper only; other catalog entries unchanged.')
