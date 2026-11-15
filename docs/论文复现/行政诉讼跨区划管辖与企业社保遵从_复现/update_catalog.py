from pathlib import Path
import json
p=Path(__file__).resolve().parents[1]/'did_catalog/did_records.json'
d=json.loads(p.read_text(encoding='utf-8'));m=[r for r in d if r['title']=='行政诉讼跨区划管辖与企业社保遵从'];assert len(m)==1
m[0].update(evidence_level='A',method='二元吸收态交错DID；企业/城市TWFE；另有Logit及处理交互正文列、附录dCDH',data_status='PDF19页、ZIP完整下载；3份dta、Stata代码和附录已核验CRC及SHA256',run_status='正文17作者模型、35系数/SE/N四位小数匹配；5列调整R²不匹配。9协议设定（1主8二级）已完成各999次；CSA/BJS均有点估计与SE',teacher_eligibility='正文9项纳入；2个Logit及6个处理交互模型排除。日期不明2条单期行剔除，完整记录；控制CSA基期处理存在上游文字/代码差异',priority='已完成本轮正文复现；附录未全部独立重跑',evidence_urls='https://finance.xmu.edu.cn/info/1019/75704.htm',notes='2026-11-15：详见replication/jurisdiction_social/复现报告.md。主样本三法正向；偏好含控模型CSA p=.3062、BJS p约.000006。控制现代杠杆未实现，不宣称完整双侧通过。')
p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf-8')
print('Updated active paper only.')
