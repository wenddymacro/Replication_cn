from pathlib import Path
import csv,json,hashlib
root=Path(__file__).resolve().parent
project=root/'project';upstream=root.parents[1]/'reference/Replication_cn-main'
paper='cie20260904'
def write_csv(path,rows):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open('w',encoding='utf-8-sig',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
recpath=project/'data/screening/by_paper'/f'{paper}.json'
rec=json.loads(recpath.read_text(encoding='utf-8'));rec['near_miss']=True
rec['near_miss_reason']='存在20个仅因时变控制变量进入二级样本的正文设定；该论文同时有1个主样本设定。'
recpath.write_text(json.dumps(rec,ensure_ascii=False,indent=2),encoding='utf-8')
write_csv(project/'data/frame/frame.csv',[dict(paper_id=paper,journal='cie',year=2026,issue=9,title=rec['title'],research=1,source='user_supplied_pdf_and_package',id_note='provisional year_issue_order ID; official article ID unavailable')])
write_csv(project/'data/candidates/candidates.csv',[dict(paper_id=paper,tier=1,signals='DID+staggered+CSA+Sun-Abraham')])
write_csv(project/'data/packages/manifest.csv',[dict(paper_id=paper,package_status='data_and_code',notes='analysis data available; tax survey microdata withheld')])
log='''

- （2026-11-14，本次单篇试运行）对象为唐跃桓、黎静霖（2026）《新型产业政策何以提升企业生产率》，第9期73—95页。仅为单篇输入框架，截止日为2026-11-14；漏斗中的1篇不能解释成全刊检索总数。官网文章ID未取得，暂用cie20260904，并保留与第一阶段cie_2026_09_04的映射。
- （2026-11-14）逐列筛选：表1(1)进入主样本；表1(2)—(4)、表2(1)—(6)、表3(1)—(5)、表4(1)—(6)进入时变控制二级样本，共20列。表3(6)和表5六列含处理交互/额外处理项，排除。在线附录设定单列，不混入正文计数。
- （2026-11-14）保留作者原数据与程序，单独导出正文各列的e(sample)，以同一分析数据和样本标记输入三估计量。使用真实首次处理年份chainleader_l，不用不平衡面板内首次观测到D=1的年份替代。先按作者样本限制，再按prep_data固定行业首期值；因此协议规范化后的TWFE可能不同于作者原设定，不能与第一阶段作者结果复现混称。
- （2026-11-14）本文仅在附录报告动态路径和现代估计图；正文未提供事件路径数值，不计额外正文事件研究设定。省份不变；行业部分企业变化，按协议固定。特征类别数超过60的设定跳过CSA，保留具体note；did无法估计的单元/设定也原样记失败，不删除控制变量或更换比较组以强行取得数值。
- （2026-11-14）修复框架一个输出模式问题：csa_static在类别超限分支未返回hullw/G_eff/L_max，造成后续打印或汇总缺列。仅补NA字段，不修改估计公式、样本、类别阈值。保存原始上游版本及哈希，并用B=0规范化分支验证与既有999次运行的点估计及SE一致。
- （2026-11-14）遵循v0.1实现边界：带控制变量的现代估计量影响系数未实现时，其杠杆为NA，汇总明确标注twfe_only，不能称为双边杠杆通过。联合自助法999次；二级样本CSA协方差不受此实现支持时，按项目第5节第一版约定以0作比较并标明，不称已计算其联合协方差。单篇不能计算有意义的跨论文相关性或leave-one-paper-out区间。
'''
protocol=project/'docs/PROTOCOL.md'
text=protocol.read_text(encoding='utf-8')
if '本次单篇试运行' not in text:protocol.write_text(text+log,encoding='utf-8')
text=protocol.read_text(encoding='utf-8')
if '联合差异方差一致性' not in text:
    protocol.write_text(text+'\n- （2026-11-14，联合差异方差一致性）原analysis.R混用解析边际标准误与自助协方差，实际发生负差异方差；其将相关系数压到0.999的处理不用于本报告。保留原脚本和原汇总，新增analysis_protocol.R：有999次联合矩阵时，差异方差统一用bsd_twfe²+bsd_modern²−2cov；未计算CSA联合协方差时仍显式按0约定。R/Python独立核对全部比较行的一致性，不改变任何点估计或重选自助种子。\n',encoding='utf-8')
lock=[]
for rel in ['README.md','docs/PROTOCOL.md','docs/REPLICATION.md','docs/SCREENING.md','docs/SPEC_SCHEMA.md','code/R/estimators.R','code/R/run_spec.R','code/R/analysis.R','code/R/test_estimators.R']:
    old=upstream/rel;new=project/rel
    lock.append(dict(path=rel,upstream_sha256=hashlib.sha256(old.read_bytes()).hexdigest(),used_sha256=hashlib.sha256(new.read_bytes()).hexdigest(),unchanged=old.read_bytes()==new.read_bytes()))
write_csv(root/'logs/source_lock.csv',lock)
derived=project/'code/R/analysis_protocol.R'
if derived.exists():
    lock.append(dict(path='code/R/analysis_protocol.R (derived from analysis.R)',upstream_sha256=hashlib.sha256((upstream/'code/R/analysis.R').read_bytes()).hexdigest(),used_sha256=hashlib.sha256(derived.read_bytes()).hexdigest(),unchanged=False))
    write_csv(root/'logs/source_lock.csv',lock)
(root/'upstream').mkdir(exist_ok=True)
(root/'upstream/estimators_original.R').write_bytes((upstream/'code/R/estimators.R').read_bytes())
(root/'upstream/analysis_original.R').write_bytes((upstream/'code/R/analysis.R').read_bytes())
print('Screening metadata and adjudication log finalized')
