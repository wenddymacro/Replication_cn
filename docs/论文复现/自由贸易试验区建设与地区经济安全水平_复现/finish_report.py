from pathlib import Path
import pandas as pd,numpy as np,json,math
R=Path(__file__).resolve().parent
c=pd.read_csv(R/'data/published_comparison.csv');a=pd.read_csv(R/'data/modern_results_all.csv');m=pd.read_csv(R/'data/modern_results_long.csv');audit=json.loads((R/'logs/treatment_audit.json').read_text(encoding='utf-8'));ent=json.loads((R/'logs/entropy_audit.json').read_text(encoding='utf-8'))
def md(d):
 s=['| '+' | '.join(map(str,d.columns))+' |','|'+'---|'*len(d.columns)]
 for row in d.itertuples(index=False,name=None):s.append('| '+' | '.join(str(v) for v in row)+' |')
 return '\n'.join(s)
base=m[m.spec.isin(['B1','B2','B3'])][['spec','method','b_raw','se_raw','p_normal','n']].copy()
for col in ['b_raw','se_raw','p_normal']:base[col]=base[col].map(lambda v:f'{v:.6f}')
bc=c[c.body].copy();v=a[a.spec_id=='B1'].iloc[0]
report=f'''# 自由贸易试验区建设与地区经济安全水平：复现报告

齐文浩、宋长兴、蔡宏波，《中国工业经济》2024 年第 3 期，119–137 页。执行日期：2026-11-15。

## 验收结论

**正文 15 个设定的原文对照、三法重估、999 次联合自助法、支持单元与样本诊断、结果汇总和分类归档已执行；严格的全流程验收尚未通过，不能标记“全部复现完成”。**

正文 15 个处理系数都与发表值相差小于 0.0001，N 全部相同；全部系数和 t 值按四位小数截断均与正文一致。按通常四舍五入，只有 {int((bc.status=='exact_printed_b_t_N').sum())}/15 个设定的系数/t/N同时精确，其余最后一位差异保留为 approximate。发表括号是 t 值，不能误作标准误；现代分析的 SE 来自实际回归。表 5 第（3）列 R² 发表 .0498、附件回归 .0051156，该差异尚未解释。

对主结论，未控制变量设定 TWFE 与 BJS 正向且正常近似 p<.05，CSA 正向但 p=.3942。作者偏好的含控制设定 TWFE/BJS 仍正向，原版程序的不平衡面板 CSA 为负但不显著。**后者不能直接解释为“现代 DID 推翻原结论”**：控制变量基期处理存在协议文字与程序行为的差异；也不能把不显著解释成效果为零。

## 资料及数据检查

官网 ZIP CRC 通过，5 个内部文件均解压并记录 SHA256；原文 19 页，附录 5 页，已阅读全部正文并逐表核查。`original/` 保留原件；`materials/` 分为论文、原始数据、处理数据、作者代码、附录、说明、原始附件。文件来源及下载证据见 `logs/sources.json`，未获得响应头，HTTP 状态留空。

数据有 258 城市×12 年=3096 条有效城市年份记录；另 1 行无 id/年份，作者回归自动剔除。控制变量缺失使基准样本变为 3018 条，为不平衡面板。完整面板 Piolt 为二元吸收态；首次处理年份及城市数是 2013:1、2015:6、2017:13、2018:2、2019:12。政策前后均有对照，正文设计符合交错 DID 筛选条件。

南京最后一年及大连全部 action 缺失，不能将这些城市误认作从未处理。通过完整 Piolt 路径恢复的 g 与所有非缺失 action 一致；`data/recovered_city_dates.csv` 保存城市级证据。Treat 在南宁、崇左和苏州随时间变化，事件研究作者代码因此与统一 g 定义存在差别。保留作者原始列和回归，未静默修正原件。

Excel 中 18 项原始指标共有 {ent['raw_indicator_missing']} 个缺失单元；未公开缺失填补和熵权指数构造脚本。完整案例敏感性使用 {ent['complete_case_rows']} 行，不能替代作者样本，**不能声称已从原始指标精确重建 Eco_safe**。老师协议允许使用公开的分析数据，本次正式回归使用作者提供的 Eco_safe；原始数据构造仍是来源限制。

## 设定筛选与原文对照

正文表 3 三列、表 4 两列、表 5 六列、表 6 四列，共 15 个静态设定。B1（表 3 第1列）进入主样本，其余 14 个含随时间变化控制变量的设定进入二级样本，均重估。不能用 B1 替代 B2/B3。

附表和附图均在线上附录，未计入正文主样本。另独立运行 13 个附录静态回归（含 500 次重复抽样推断），10 个事件期系数、随机效应 Probit 和 500 次安慰剂。连续 Treatnryear、其他政策变量、处理×分组交互和非线性 Probit 不进入正文合格设定。原代码依赖运行上下文且含重复命名/清空数据后的引用问题，独立驱动程序逐模型加载原始数据；交互项经逐行乘积验证一致。

表格按发表的系数、t、N 核对，详细表见 `data/published_comparison.csv`。所有 28 个静态处理系数/N 都在最后一位精度内匹配；部分附录 t 值也有最后一位差异，未篡改结果。

{md(bc[['spec','table','column','published_b','published_t','published_N','status','R2_match']])}

附表2 Probit 的原代码结果与发表值不一致：例如 Popu 发表3.1953/t4.2809、原代码3.173821/z4.625362；Capi发表5.3887、原代码5.739617。模型已收敛；独立加入 L. 控制变量的测试也未恢复发表值，不能凭正文“滞后一阶”描述擅自替换作者代码结果。正文含控制基准的数值能由附件现有控制列恢复，缺乏构造脚本证明是否已预先滞后，因此保留原列并标注这一限制。

## 三种估计量结果

均以作者 e(sample) 为共同输入，按样本内加权总体标准差标准化 y；同样城市与年份固定效应、城市聚类。下表转换回原始 y 单位；p 是正态近似，不是原 Stata 的有限样本 t 检验。完整 45 行在 `data/modern_results_long.csv`。

{md(base)}

15 项 TWFE、CSA、BJS 点估计及 SE 均为有限数值；每个静态设定 boot_B=999。CSA 自身标准误使用 did 的999次乘子自助法；联合贝叶斯自助法仅主样本计算 TWFE–CSA 协方差，14项控制设定未计算该协方差，不能写成“全部 CSA 协方差已完成”。TWFE–BJS 协方差15项均计算。随机种子及核心算法沿用老师原代码。

![含控制基准估计](figures/baseline_comparison.png)

## 支持、杠杆与权重

主样本 B1：TWFE G_eff={v.G_eff_twfe:.3f}, Lmax={v.L_max_twfe:.3f}；CSA {v.G_eff_csa:.3f}/{v.L_max_csa:.3f}；BJS {v.G_eff_bjs:.3f}/{v.L_max_bjs:.3f}。两项比较均通过 G_eff≥10、Lmax≤.25 的双侧杠杆筛选。主样本没有负 TWFE 权重；因此 CSA 与 TWFE 的差异不能仅归因为负权重。

含控制的14项，老师代码未实现现代估计量的杠杆计算。原 analysis.R 的 pass_screen 会在此时采用 twfe_only；这些结果保留供审查，但**不能称已通过双方完整杠杆筛选**。

CSA 的有效处理后单元：B1/B2各18/18，B3为11/11，多数机制列18/18；表6前三列因2017–2019窗口只剩3/3个后处理比较单元。没有隐藏删除 NA 后只剩少数单元的情况，但多个早期 cohort 城市数量很少，主样本处理前 Wald 检验因协方差奇异未返回，不能宣称通过联合前趋势检验。具体警告及每格估计见 `project/diagnostics/csa_support.json`、`csa_cells.csv`。

表6前三列存在20个样本初期已处理城市，BJS各删除60条不可插补记录；CSA也排除一直处理城市，故其目标样本不同于TWFE。R fixest还会删除个别单期城市：M9/M10/M11实际TWFE样本分别730/731/728，与作者731/732/730不同，系数接近但SE有限样本修正略变。见 `sample_counts.csv`，不宣称三法实际估计行数全部完全相同。

## 关键协议限制及补充诊断

老师文字规定含控制 CSA 使用 g−1 协变量，但原版代码在不平衡面板设置 allow_unbalanced_panel=TRUE。[did 官方文档](https://bcallaway11.github.io/did/reference/DIDparams.html)说明，此路径用各期协变量，并非统一固定在 g−1。保持核心文件字节一致，不将这个实现差异藏在结果里。`project/output/` 是原版代码结果，尚需老师确定含控制不平衡面板的正式口径，才能按用户要求通过严格全流程验收。

独立完整面板补充诊断：B2改用212个全期完整城市、2544行后，TWFE=.12578 SD、CSA=−.08389 SD、BJS=.14722 SD，CSA p约.469。这里同时改变样本和协变量处理，不能把变化全部归因于协变量基期，也未替换原文主结果；见 `balanced_B2_supplement.csv`。

作者附图事件路径按原 action/Treat 代码恢复；统一修复 g 的事件路径仅列为补充，不冒充作者模型。补充 BJS 处理前分箱均值为 .20703 SD，SE .06422，提示该诊断下前趋势值得关注。事件研究采用解析标准误，没有套用“999次事件研究联合自助法”的说法。

![作者事件研究重绘](figures/author_event.png)

![安慰剂诊断](figures/placebo.png)

## 汇总分析与复跑

老师原 analysis.R 生成散点图、相关系数、反号率、显著反号率、SE比和负权重统计。二级样本CSA对14项中7项反号，BJS无反号；这些只是当前实现的描述统计，不能在协变量口径和杠杆限制未解决前当作正式推翻比例。只有一篇论文，论文等权等于单篇设定平均；逐篇剔除后没有论文，跨论文相关区间、特征解释回归不可识别，明确不适用。

本篇漏斗：候选1→有完整附件1→符合交错设计1→有可用分析数据1→已重估正文15设定1篇→严格全流程验收通过0篇。未声称这是一份全期刊检索统计。

复跑脚本、JSON、日志、环境版本、原始文件校验见 README、`logs/final_validation.json`。老师核心R脚本与 `reference/Replication_cn-main/code/R` 字节相同；2026-11-15尝试读取远程PROTOCOL失败(Cache miss)，不声称本次已验证远程最新版本。

**尚未关闭事项**：表5第3列R²；附表2Probit发表值；原始指标到Eco_safe的构造；原文控制变量滞后的构造证据；含控制不平衡CSA协变量口径及现代杠杆缺口。已给出具体证据，不通过修改作者数据或老师核心算法掩盖这些问题。
'''
(R/'复现报告.md').write_text(report,encoding='utf-8')
status=dict(paper='cie20240307',date='2026-11-15',status='not_fully_completed',body_original_models=15,body_modern_specs=15,main=1,secondary=14,static_joint_bootstrap_B=999,all_three_estimates_and_SE_finite=True,source_discrepancies=['T5_c3_R2','appendix_probit','raw_index_construction_not_identified','lagged_covariate_construction_not_verified'],protocol_gaps=['unbalanced_CSA_covariate_timing','controlled_modern_leverage_not_implemented','controlled_TWFE_CSA_joint_covariance_not_computed'],full_completion_claim=False)
(R/'status.json').write_text(json.dumps(status,ensure_ascii=False,indent=2),encoding='utf-8')
print('Report and explicit incomplete status saved.')
