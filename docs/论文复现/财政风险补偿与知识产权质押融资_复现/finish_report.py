from pathlib import Path
import math
import pandas as pd,numpy as np,json,shutil,hashlib
R=Path(__file__).resolve().parent
S=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-fiscal-run')
files=list((S/'project/output/specs').glob('*.csv'))+list((S/'project/output/specs_controls').glob('*.csv'))
assert len(files)==12,len(files)
for q in range(1,4):
 status=pd.read_csv(S/f'logs/queue_{q}_status.csv');assert len(status)==4 and status.rc.eq(0).all()
x=pd.concat([pd.read_csv(p) for p in files],ignore_index=True)
assert x.boot_B.eq(999).all() and x.spec_id.nunique()==12
assert x.twfe.notna().all() and x.bjs.notna().all()
assert (x.twfe_raw-x.published_coef).abs().le(.000050001).all()
for item in json.loads((R/'original/manifest.json').read_text(encoding='utf-8')):
 assert hashlib.sha256((R/'original'/item['file']).read_bytes()).hexdigest()==item['sha256']
assert (R/'project/code/R/analysis.R').read_bytes()==Path('reference/Replication_cn-main/code/R/analysis.R').read_bytes()
shutil.copytree(S/'project/output',R/'project/output',dirs_exist_ok=True)
shutil.copytree(S/'logs',R/'logs/modern',dirs_exist_ok=True)
b=pd.read_csv(R/'data/published_comparison.csv')
out=x.merge(b[['spec','y','published_N']],left_on='spec_id',right_on='spec',validate='one_to_one').sort_values('spec_id')
for v in ['twfe','twfe_se','csa','csa_se','bjs','bjs_se']:out[v+'_original_units']=out[v]*out.y_sd
for v in ['twfe','csa','bjs']:
 out[v+'_p_normal']=out.apply(lambda r:math.erfc(abs(r[v]/r[v+'_se'])/math.sqrt(2)) if pd.notna(r[v]) and pd.notna(r[v+'_se']) and r[v+'_se']>0 else float('nan'),axis=1)
out['screen_twfe_pass']=(out.G_eff_twfe>=10)&(out.L_max_twfe<=.25)
out['screen_bjs_basis']=np.where(out.G_eff_bjs.isna(),'twfe_only','both')
out['screen_csa_basis']=np.where(out.csa.isna(),'unavailable',np.where(out.G_eff_csa.isna(),'twfe_only','both'))
out.to_csv(R/'data/modern_results.csv',index=False,encoding='utf-8-sig')
def fmt(v):return '未估计' if pd.isna(v) else f'{v:.6f}'
table=['|设定|结果变量|N|TWFE|CSA|BJS|','|---|---|---:|---:|---:|---:|']
for _,r in out.iterrows():table.append(f'|{r.spec_id}|{r.y}|{int(r.n)}|{fmt(r.twfe)}|{fmt(r.csa)}|{fmt(r.bjs)}|')
notes=['|设定|CSA说明|BJS说明|','|---|---|---|']
for _,r in out.iterrows():notes.append(f'|{r.spec_id}|{str(r.csa_note) if pd.notna(r.csa_note) else "无"}|{str(r.bjs_note) if pd.notna(r.bjs_note) else "无"}|')
positive=all(out[v].dropna().gt(0).all() for v in ['twfe','csa','bjs'])
body=pd.read_csv(R/'data/all_body_comparison.csv');assert body.exact.all() and body.spec.nunique()==28 and len(body)==42
main=out[~out.controls]
for v in ['twfe','csa','bjs']:assert ((main['G_eff_'+v]>=10)&(main['L_max_'+v]<=.25)).all()
report=f'''# 财政风险补偿与知识产权质押融资：复现报告

已完成正文原模型复现及老师项目要求的12个正文设定重估。原模型28列、42个报告系数全部与原文印刷精度一致；12个设定均完成999次联合聚类贝叶斯自助。

论文：王姝勋、杜鹏程、李威（2026），《财政风险补偿与知识产权质押融资——来自银行分支机构的证据》，《中国工业经济》第9期，27–48页。[官网](https://ciejournal.ajcass.com/Magazine/Show?id=123767)。执行依据：[老师项目](https://github.com/wenddymacro/Replication_cn)。

## 目前可以得出的结论

{'这12个设定中，TWFE、所有成功估计的CSA及BJS系数均为正，未出现符号反转。就这篇论文、这些正文设定而言，换用现代DID估计量没有推翻正向效应的方向。' if positive else '现代估计量存在方向差异，请逐项查下表及原版汇总，不能概括为全部稳健。'}估计值大小有所变化；同向不代表数值相等，也不代表识别假设已经验证。单篇试跑不能外推为《中国工业经济》的总体结论。

此外，表4四个风险容忍度机制设定在CSA下均不再达到5%显著水平；同四列BJS仍达到5%显著水平。因此，基准正向结论保持，但不能概括为所有机制结论都稳健。这里采用估计系数/标准误的双侧正态近似检验；逐项p值另列于data/modern_results.csv。这是对单个系数的显著性描述，与老师项目的“反号且差异显著”指标不同。

## 原模型核对

用Stata19运行作者正文中的模型，保留控制变量、固定效应和聚类方式；数据来自用户提供的原始附件。软件版本较作者标注的Stata18新。表1、表4共12列的系数、标准误及N均精确匹配四位小数；另14个交互项模型和2个连续暴露度模型也已复现，全部42个报告系数匹配。详细数值见 data/all_body_comparison.csv 和 logs/author_body.log。

表1 Panel A第4列：原文0.0381（0.0062），N=57391；复现0.038094（0.006217），N=57391。表1 Panel B第4列：原文0.0393（0.0074），复现0.039308（0.007388），N=57391。

## 协议样本划分

- 主样本2个：表1 Panel A/B第1列，分别为PPL、LnPPL_Num。它们是作者实际发表的无控制变量模型。
- 二级样本10个：表1 Panel A/B第2–4列及表4第1–4列，保留全部原控制变量。表1第3列采用银行×年份固定效应。
- 不纳入现代DID比较：表2六列、表3六列、表5前两列属于处理×特征交互项；表5后两列为连续政策暴露度。
- 附表/附图已阅读和存档，未将其混入正文计数；本轮未完整重跑附录的匹配、安慰剂及所有图表。

## 三种估计量比较

下表是仓库定义的结果变量标准差单位，适合比较方法。括号标准误及换回原单位的估计值均在 data/modern_results.csv。T1_1–4对应Panel A第1–4列，T1_5–8对应Panel B第1–4列。

{chr(10).join(table)}

CSA可用{int(out.csa.notna().sum())}/12，BJS可用{int(out.bjs.notna().sum())}/12。表1两个银行×年固定效应设定有338个银行类别，超过协议60类上限，CSA按规则跳过，没有删固定效应或控制变量以强行估计。

## 设计和诊断

样本2011–2020年，完整基准数据84747行、9108个分支机构、448家银行。2014–2020年七个新处理批次；分支机构×年无重复、处理没有关闭。使用真实政策日期start_year构造首次处理期，避免不平衡面板中把首次观测的处理年份当作政策年份；与作者DiD逐行相符。

完整基准面板中，18家在样本首期已处理的分支机构对应177行观测，不能直接用于现代方法的未处理基期。CSA按程序删除样本首期已处理机构；BJS对没有可识别反事实的观测另行删除，含后进入样本但没有未处理期的机构，删除数量逐列记录如下。各方法输入均为作者e(sample)，内部识别支持的进一步处理由各估计程序完成，不把输入相同误写为最终利用观测完全相同。

主样本两个设定的TWFE负权重观测占已处理观测的{100*main.neg_rows.iloc[0]:.3f}%，负权重绝对量占比{100*main.neg_abs.iloc[0]:.3f}%。主样本TWFE、CSA、BJS均通过G_eff≥10且L_max≤0.25的双侧杠杆规则。二级样本的现代估计量杠杆在上游v0.1尚未实现，原版汇总标twfe_only，不可称双侧通过。

联合自助B=999、种子1。无控制变量主样本的TWFE–CSA、TWFE–BJS协方差均有输出；带控制变量时上游未计算TWFE–CSA联合协方差，汇总按0处理，不能将其称为已取得的联合协方差。所有BJS联合协方差均保留。统计比较以 project/output/tables/comparison_summary.csv 及 project/output/specs_main.csv 的上游原版输出为准。

{chr(10).join(notes)}

## 代码来源与边界

估计程序来自老师仓库冻结快照，SHA256见 logs/upstream_code_hashes.json。仅对CSA大于60类时的跳过分支补齐两个NA杠杆字段，解决输出缺列，原文件在 project/code/upstream，补丁在 logs/compatibility.patch。analysis.R逐字保持上游原版，不使用此前另写的方差修正版。上游原版数值或方法限制原样记录，不能据此宣称整套实现经过额外方法学验证。

已完成的是公开分析数据层面的正文复现及协议重估；未从底层专利登记、金融许可证等原始数据库重新构建作者数据。未完成全刊筛选、非候选抽查或跨论文比较。附件使用说明和出处完整保留，研究成果应引用论文及官网数据程序附件。

## 文件和重跑

- original/：用户提供的PDF、ZIP、解压原件及SHA256。
- data/all_body_comparison.csv：正文28列、42个报告系数核对。
- data/modern_results.csv：12个设定的完整估计、标准误、诊断及原单位结果。
- project/data/：逐列设定JSON及筛选记录；project/output/：仓库原版结果、汇总和散点图。
- logs/：Stata日志、R日志、版本、哈希和补丁。
- 先读研究裁定与执行说明.md。rerun_modern.ps1以已锁定的作者样本重新运行现代估计，默认999次，结果写到新的临时目录。须安装所列R包，当前机器路径已配置。作者原模型可在work目录运行replicate_body.do；需要相邻chain_policy/output/local_ado中的Stata依赖，交付时另附一份到dependencies/stata_ado。
'''
(R/'复现报告.md').write_text(report,encoding='utf-8')
print('Validated',len(out),'modern specs; CSA',out.csa.notna().sum(),'BJS',out.bjs.notna().sum(),'all positive',positive)
print(out[['spec_id','twfe','csa','bjs','csa_note','bjs_note']].to_string(index=False))
