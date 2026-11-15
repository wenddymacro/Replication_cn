from pathlib import Path
import json
p=Path(__file__).resolve().parents[1]/'did_catalog/did_records.json';d=json.loads(p.read_text(encoding='utf-8'))
m=[r for r in d if r['title']=='新城新区建设与地区创业活跃度'];assert len(m)==1
m[0].update(evidence_level='A',method='2007–2014八批新城开建，二元吸收态；城市FE+省份×年FE，固定2006连续特征×年份',data_status='正文19页及完整ZIP已核验；2份dta、Stata代码、附录齐备，CRC及SHA256通过',run_status='正文22静态模型、27印刷系数/SE/N匹配；图1完整路径及展示均值重算；1规范主设定+16实现对照，16静态各999次。尚未完成全部规范入池',teacher_eligibility='明确1主设定；另16组固定连续特征×年份的编码/入池衔接待解决，不能自动计为普通时变控制二级。正文其他6列依规则排除',priority='已完成本轮原文核对与计算；连续特征交互实现/规范入池待衔接',evidence_urls='https://econpub.xmu.edu.cn/research/index.php?p_id=5018&ser_id=2',notes='2026-11-15：详见replication/newarea_startup/复现报告.md。主BJS正向但p=.0709；原CSA仅6/44处理后单元可估。含原50列CSA均失败，另有基期空间诊断，不覆盖原结果。核心R字节一致，图1另有公开窗口驱动。附录未全部重跑。')
p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding='utf-8');print('Updated active paper only.')
