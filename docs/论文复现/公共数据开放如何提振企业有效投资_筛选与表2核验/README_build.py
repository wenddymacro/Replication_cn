from pathlib import Path
import json,hashlib,pandas as pd,shutil
R=Path(__file__).resolve().parent
p=R/'核验记录/筛选结论.json';s=json.loads(p.read_text(encoding='utf-8'))
s.update(n_secondary_specs_confirmed=1,confirmed_secondary_specs=['T2_3'],conditional_secondary_candidates=['T2_1','T2_2','T2_4'],n_secondary_candidates=4,n_secondary_specs=1,notes='已确认至少表2第3列符合二级样本结构，其余三列须处理时变前定特征或处理关闭；不将四列候选均宣称最终合格。严格主样本0。')
for r in s['near_miss_controls_only_specs']:r['screen_status']='confirmed_secondary_structure' if r['spec_id']=='T2_3' else 'conditional_secondary_candidate'
d=pd.read_stata(R/'处理数据/数据1.dta',convert_categoricals=False);d['row_id']=range(1,len(d)+1)
d=d.merge(pd.read_csv(R/'work/sample_flags.csv'),on='row_id',validate='one_to_one')
x=d[d.sample_T2_3==1].sort_values(['id','year'])
assert not x.duplicated(['id','year']).any()
prev=x.groupby('id')[['year','cityp','idc']].shift()
rise=x[(x.cityp==1)&(prev.cityp==0)&(x.year-prev.year==1)&(x.idc==prev.idc)]
transition_proof={str(int(k)+2007):int(v) for k,v in rise.groupby('year').id.nunique().items()}
assert len(transition_proof)>=2
assert x.groupby('id').ids.nunique().max()==1
s['confirmed_adjacent_year_0_to_1_firm_counts_T2_3']=transition_proof
s.update(paper_id='cie20240808',screener='Codex',eligible_design=True,n_eligible_specs=0,eligible_specs=[],unit='firm',assignment_unit='city',time_unit='year',main_or_robustness='main',reports_modern_estimator=False)
p.write_text(json.dumps(s,ensure_ascii=False,indent=2),encoding='utf-8')
deps=R/'dependencies/stata_ado';shutil.copytree(R.parent.parent/'replication/chain_policy/output/local_ado',deps,dirs_exist_ok=True)
w=R/'work/check_table2.do';w.write_text(w.read_text(encoding='utf-8').replace('../../../replication/chain_policy/output/local_ado','../dependencies/stata_ado'),encoding='utf-8')
rows=[]
for r in s['near_miss_controls_only_specs']:
 rows.append(f"|{r['spec_id']}|{r['coef']:.4f}|{r['replicated_b']:.8f}|{r['se']:.4f}|{r['replicated_se']:.8f}|{r['n_obs']}|{'二级结构确认' if r['spec_id']=='T2_3' else '条件候选'}|")
readme=f'''# 公共数据开放如何提振企业有效投资——基于产能利用视角

王海、叶帅、尹俊雅，《中国工业经济》2024年第8期，137–153页。

## 筛选结论

**这篇可用于老师项目的带控制变量二级样本：至少表2第3列已核实。严格无控制变量主样本为0列。**其余表2三列作为条件候选保留，不能把整篇所有回归一并算作合格。

依据为老师Replication_cn仓库PROTOCOL.md第3节与SCREENING.md：允许单一二元交错处理、个体和年份固定效应、固定前定特征×年份；仅因时变控制变量违反主样本规则时进入二级样本。表2是按分组限制样本后估计单一cityp系数，并非在回归中加入“处理×分组”交互项。

表2第3列核验要点：

- 作者回归包含cityp一个政策变量、11个企业控制变量、企业和年份固定效应、六个2010年前定特征×年份的连续斜率；按省份聚类。
- 真实作者回归样本为3093行、385家企业、25个省份聚类；有178家从未观察到处理的企业。不平衡面板，没有重复企业年份。
- 六个前定特征在该列回归样本的每家企业内均不变；省份聚类也不随企业年份变化。没有cityp由1退回0。
- 不仅观察到了多个首次处理期，还对同一企业、同一城市、相邻年度的0→1转换做了核查。按年份映射，转换企业数为：{json.dumps(transition_proof,ensure_ascii=False)}。因此，多批次证据不是简单把企业缺失期间后的首次观测当成真实政策发生时点。
- 该列仍含企业时变控制变量，故归二级样本，不冒充严格主样本。数据year为1–13，正文样本期为2008–2020，连续年度映射为year+2007；映射保留在筛选JSON中。

## 已完成的作者结果核对

在Stata19上原样运行表2四个作者模型，保持原控制变量、样本限制、固定效应及省份聚类。系数、标准误和样本量全部按原文四位小数精确匹配。

|设定|原文系数|复现系数|原文SE|复现SE|N|筛选状态|
|---|---:|---:|---:|---:|---:|---|
{chr(10).join(rows)}

原文第8页（期刊144页）表2，模型与前定特征说明见第6页（期刊142页）。已查看这些页的渲染图，而不是依赖OCR数值猜测。该正文PDF是扫描件，pypdf无法提取正文文字，不把空文本误判为文件损坏。

## 其余设定如何处理

- 表1等基准和大多数正文模型同时加入provp和cityp两个政策处理变量，不符合“无额外处理变量”的规则，不能擅自删除一个政策后声称复现原设定。
- 表6、表8包含处理交互或多个分组处理项；表9还存在额外可加固定效应，均单独记录排除理由。
- 表2第1、2、4列分别有6、18、28家企业的前定地区特征在本列样本内变化；第2、4列还观察到1、3次处理由1退回0。后续必须先按协议处理固定特征和关闭期间，再锁定现代估计样本并记录偏离，当前只标为条件候选。
- 附录不混入正文合格计数。

## 尚未完成

尚未运行CSA、BJS或999次联合自助；尚未完成全篇全部回归与附录复现。这里只确认了项目入选结构和表2四列作者结果。

现代重估另有明确实现限制：上游xt_vars目前构造分类特征×年份固定效应，而本文是连续基期特征×年份斜率，二者不是同一个控制空间。后续必须保留原斜率结构，明确适配或如实记录暂不能估，不能静默替换为省份×年份全套固定效应。不平衡面板的真实政策日期、估计支持和杠杆筛选仍须在现代估计前检查。

## 文件分类与完整性

- 论文/：17页正文PDF，来源为用户提供桌面文件；另保留已观测的官网PDF URL。
- 原始附件包/：ZIP原件，8个文件成员CRC全部通过。
- 处理数据/：数据1–5.dta，分别18959、16158、4275、11314、17190行，均能读取。不能把这些分析数据误称为全部底层原始数据。
- 代码/：作者程序.do原件，字节不变；原编码UTF-8。ZIP文件名为旧中文编码，解压时仅纠正文件名显示，映射保留在哈希清单。
- 附录/：15页附录PDF；其他说明/：2页编辑部说明。
- 原始数据/：未见独立底层原始数据库，目录为空。
- work/check_table2.do：本次核验用的工作副本，仅执行表2四列；Stata扩展程序附在dependencies/stata_ado。
- 核验记录/：文件SHA256、完整性检查、数据结构、正文关键页图像、筛选JSON、Stata日志及核对CSV。

本地PDF和ZIP与用户提供文件SHA256相同；原始文件哈希见核验记录/原始文件_SHA256.json。HTTP状态未从浏览器UI取得，保留为null，不编造200。

## 官网文件定位

[PDF](https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/9//20240919125409WU_FILE_0.pdf)

[附件ZIP](https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/9//20240919125418WU_FILE_1.zip)

曾通过用户原有Edge会话观察下载；本次以用户提供的桌面PDF及ZIP为核验原件，不再请求下载。未自动填写验证码或绕过访问控制。使用材料应引用论文及《中国工业经济》官网附件。
'''
(R/'README.md').write_text(readme,encoding='utf-8')
for a in json.loads((R/'核验记录/原始文件_SHA256.json').read_text(encoding='utf-8')):assert hashlib.sha256((R/a['file']).read_bytes()).hexdigest()==a['sha256']
print('Confirmed secondary T2_3; conditional T2_1,T2_2,T2_4; no main specs.')
print('Adjacent 0->1 proof:',transition_proof)
