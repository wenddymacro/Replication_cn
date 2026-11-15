from pathlib import Path
import pandas as pd,numpy as np,json,hashlib,shutil,math
R=Path(__file__).resolve().parent
S=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-bigdata-run')
files=list((S/'project/output/specs').glob('*.csv'))+list((S/'project/output/specs_controls').glob('*.csv'))
assert len(files)==30,len(files)
for q,n in [(1,8),(2,8),(3,7),(4,7)]:
 d=pd.read_csv(S/f'logs/queue_{q}_status.csv');assert len(d)==n and d.rc.eq(0).all()
assert pd.read_csv(S/'logs/sensitivity_status.csv').rc.eq(0).all()
x=pd.concat([pd.read_csv(p) for p in files],ignore_index=True)
assert len(x)==31 and x.spec_id.nunique()==30
st=x[x.static_or_event=='static'];assert len(st)==29 and st.boot_B.eq(999).all()
for p in (R/'project/code/R').glob('*.R'):
 assert p.read_bytes()==(Path('reference/Replication_cn-main/code/R')/p.name).read_bytes(),p.name
for it in json.loads((R/'original/manifest.json').read_text(encoding='utf-8')):
 assert hashlib.sha256((R/'original'/it['file']).read_bytes()).hexdigest()==it['sha256']
shutil.copytree(S/'project/output',R/'project/output',dirs_exist_ok=True)
shutil.copytree(S/'project/sensitivity_output',R/'project/sensitivity_output',dirs_exist_ok=True)
shutil.copytree(S/'logs',R/'logs/modern',dirs_exist_ok=True)
for m in ['twfe','csa','bjs']:
 x[m+'_original_units']=x[m]*x.y_sd
 x[m+'_se_original_units']=x[m+'_se']*x.y_sd
 x[m+'_p_normal']=x.apply(lambda r:math.erfc(abs(r[m]/r[m+'_se'])/math.sqrt(2)) if pd.notna(r[m]) and pd.notna(r[m+'_se']) and r[m+'_se']>0 else float('nan'),axis=1)
 x[m+'_inference_available']=x[m].notna()&x[m+'_se'].notna()&(x[m+'_se']>0)
 x[m+'_leverage_pass']=(x['G_eff_'+m]>=10)&(x['L_max_'+m]<=.25)
x['csa_point_source']=np.where(x.csa.isna(),'unavailable',np.where(x.csa_note.fillna('').str.contains('did_error'),'upstream_cell_fallback','did_package'))
x=x.sort_values(['spec_id','window']);x.to_csv(R/'data/modern_results.csv',index=False,encoding='utf-8-sig')
ss=pd.read_csv(next((S/'project/sensitivity_output/specs').glob('*.csv')))
for m in ['twfe','csa','bjs']:
 ss[m+'_original_units']=ss[m]*ss.y_sd
 ss[m+'_se_original_units']=ss[m+'_se']*ss.y_sd
ss.to_csv(R/'data/stable_city_sensitivity.csv',index=False,encoding='utf-8-sig')
main=x[x.spec_id=='T1_2'].iloc[0];pref=x[x.spec_id=='T1_4'].iloc[0]
bc=pd.read_csv(R/'data/published_comparison.csv');assert bc.status.eq('exact').all() and len(bc)==32
def f(v):return 'NA' if pd.isna(v) else f'{v:.6f}'
def model_label(name):
 if name=='F1':return '图1'
 t,c=name[1:].split('_');return f'表{t}第{c}列'
def table(d,original=False):
 suf='_original_units' if original else ''
 lines=['|设定|窗口|N|TWFE|CSA|CSA SE|BJS|BJS SE|','|---|---|---:|---:|---:|---:|---:|---:|']
 for _,r in d.iterrows():lines.append('|'+ '|'.join([model_label(r.spec_id),r.window,str(int(r.n)),f(r['twfe'+suf]),f(r['csa'+suf]),f(r['csa_se'+suf]),f(r['bjs'+suf]),f(r['bjs_se'+suf])])+'|')
 return '\n'.join(lines)
counts={m:dict(points=int(x[m].notna().sum()),with_se=int(x[m+'_inference_available'].sum())) for m in ['csa','bjs']}
main_bjs_pos=bool(main.bjs>0) if pd.notna(main.bjs) else None
missing_csa=x[x.csa.isna()|x.csa_se.isna()]
flip_bjs=x[x.bjs.notna()&(np.sign(x.bjs)!=np.sign(x.twfe))]
sigloss=x[(x.twfe_p_normal<.05)&(x.bjs_p_normal>=.05)]
notes=['|设定|窗口|CSA说明|BJS说明|','|---|---|---|---|']
for _,r in x.iterrows():notes.append(f'|{model_label(r.spec_id)}|{r.window}|{r.csa_note if pd.notna(r.csa_note) else "无"}|{r.bjs_note if pd.notna(r.bjs_note) else "无"}|')
summary=dict(specifications=30,result_rows=31,main_specifications=1,secondary_static=28,secondary_event=1,static_bootstrap_B=999,static_bootstrap_specs=29,author_static_models=30,author_reported_coefficients_exact=32,estimator_counts=counts,bjs_opposite_direction_rows=len(flip_bjs),twfe_sig5_bjs_not_sig5_rows=len(sigloss),sensitivity_separate=True,upstream_R_unchanged=True)
(R/'data/completion_summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
report=f'''# 国家级大数据综合试验区设立与就业增长：复现报告

沈坤荣、乔刚、谭睿鹏，《中国工业经济》2024年第12期，5–23页。[官网文章页](https://ciejournal.ajcass.com/Magazine/show/?id=117612)。执行依据：[老师Replication_cn项目](https://github.com/wenddymacro/Replication_cn)。

## 完成范围与主要结论

已独立复现正文30个静态回归和图1作者事件路径。30个政策系数、表3两个中介系数及其SE、N全部与印刷四位小数一致。按协议排除表1第1列后，重估30个正文设定：主样本1个、带控制变量静态二级样本28个、事件路径二级样本1个。29个静态设定各运行999次联合聚类贝叶斯自助；事件路径按上游解析推断，未声称也取得999次联合协方差。

主样本（表1第2列）按协议预处理后，TWFE为{f(main.twfe)}，BJS为{f(main.bjs)}，均为结果变量标准差单位。BJS{'保持正向' if main_bjs_pos else '未保持正向' if main_bjs_pos is not None else '未能估计'}。CSA保留了上游无协变量单元均值回退点估计{f(main.csa)}，但SE缺失：did包因城市聚类随部分企业迁址变化而报错。**因此不能说三种方法都成功、或三种方法都显著。**

作者偏好含控制变量模型（表1第4列）的标准化TWFE为{f(pref.twfe)}、BJS为{f(pref.bjs)}；CSA点估计和SE分别为{f(pref.csa)}、{f(pref.csa_se)}。是否显著请看data/modern_results.csv，不能仅凭正向作判断。

该偏好模型BJS的SE为{f(pref.bjs_se)}，正态近似p={pref.bjs_p_normal:.4f}，在5%水平不显著；TWFE的p={pref.twfe_p_normal:.4f}。因此，**原论文主要正向系数在BJS下保留了方向，但偏好模型的5%显著性没有保留**。这是处理后样本、相应标准误方法下的单系数比较，不等于两种估计量之间的差异已经显著。

31行结果（静态29行、事件前后各1行）中：CSA有{counts['csa']['points']}个有限点估计，{counts['csa']['with_se']}行同时有可用SE；BJS有{counts['bjs']['points']}个有限点估计，{counts['bjs']['with_se']}行同时有可用SE。BJS与TWFE异号{len(flip_bjs)}行；TWFE正态近似5%显著而BJS不显著{len(sigloss)}行。这些是设定/窗口计数，不是独立论文数量；总体“反号且差异显著”等以原版汇总文件为准。

本轮唯一的BJS/TWFE异号行是图1的处理前汇总，不能说成政策实施后效应反转；全部29个静态设定的BJS与TWFE方向一致。

## 原模型核对

表1第2列原文0.0938（0.0296），N=29343；独立Stata复现0.09379257（0.02961441），N=29343。表1第4列原文0.0713（0.0236），独立复现0.07131078（0.02356931），N=29343。

全部32个印刷系数的核对见data/published_comparison.csv。作者图1逐点系数见data/author_results.csv中F1行；图中无逐点印刷数值，故只称原代码重算，不声称图形坐标逐字匹配。原程序采用Stata；本轮Stata19，作者软件版本与依赖另见原附件。

表7使用作者MLdata给定的实际/理论实施标签核对，计数58、5、14、53、164均匹配，见data/table7_counts.csv。这不等于独立训练机器学习模型或重新求解最优政策。

## 主结果换回原单位

下表系数与SE乘以相应回归样本的结果变量标准差；主回归Labor是员工人数对数。原单位是对数点，不应直接标作百分点。CSA SE缺失保留NA，不用回退点估计的自助标准差偷偷替代。

{table(x[x.spec_id.isin(['T1_2','T1_3','T1_4'])],True)}

## 全部协议重估：标准差单位

{table(x)}

变量名、原单位估计、SE、正态近似p值、负权重、G_eff、L_max、具体错误及输出可用性均在data/modern_results.csv。正态近似p值用于便捷描述单个系数；与上游“TWFE与现代估计之差的显著性”不同。

## CSA异常值与协议文字／代码差异

表2第3、5列CSA分别为5.594056、4.847610个结果变量标准差，明显高于对应TWFE的0.144841、0.072627。它们是原版程序实际输出，未删改，**暂不据此认定政策效应被大幅放大**。

已独立重新调用相同程序确认这些值，并导出ATT(g,t)单元、对照样本设计矩阵和拟合对象，见project/diagnostics/。这两列是不平衡城市面板；各单元对照设计矩阵均满秩（8列、秩8），所以不能简单归因为完全共线或不可识别。软件另警告2015年处理组很小。单元点估计偏大，并不是CSV读取或聚合列错位造成。

关键实现差异：老师PROTOCOL第5.4节文字要求CSA采用处理前基期g−1协变量，但原版代码对不平衡面板调用allow_unbalanced_panel=TRUE。[did官方文档](https://bcallaway11.github.io/did/reference/DIDparams.html)说明，此路径使用各期协变量，区别于平衡面板的基期取值。作者控制项包含城市特征×时间趋势，故该区别会影响数值。这里同时遵循了“冻结上游代码”和“公开记录协议差异”：**没有暗改程序，也没有声称这两列已满足文字要求的基期控制处理**。进一步形成项目最终汇总前，应由老师确认不平衡面板控制变量的统一规则。

单列数值诊断（不计正式30项，不作为替代结论）：相同样本不加协变量时，两列CSA为0.180423、0.070224；将控制项固定在单位首次观察值时为0.164881、0.052801；限制为完整面板后为0.124185、0.056135。前两种改变控制设定，第三种改变样本，均不能冒称原模型或g−1取值的精确实现。结果见project/diagnostics/csa_variants.csv；据此只能判断巨大点估计对控制项处理／面板路径高度敏感，不能单独证明哪项机制导致偏差。

## 样本、日期与迁址裁定

企业数据29343行、3618家企业，2010–2021年；城市数据3432行、286个城市。原文政策有2015、2016两批。不能把晚进入样本企业的首次可观察处理年份当作新政策年份。

100家企业城市发生变化，其中41家的Policy_year随企业年份变化。对恒定政策赋值企业保留真实政策日期；对这41家企业用首次可观察的企业政策暴露期，缺失区间内准确迁址时点无法从附件确定，属于本轮明确记录的预处理裁定，而非仓库强制规定。此选择会产生部分2017–2021年的企业暴露cohort，不能声称是新增政策批次。

在锁定每列作者e(sample)后，再按协议删除首次暴露后关闭的0处理行；企业全数据共34行。主样本最终N={int(main.n)}。每列原作者N和现代输入N因此可能不同；现代输入不是宣称未经调整的作者原样本。删除后重建处理状态与作者Bigdata_Post逐行一致。

作者城市聚类原样保留。迁址造成部分企业的城市聚类变量随时间变化，did::att_gt不支持这一输入，因此企业原样本的CSA失败或只有单元均值回退点估计；不能改企业聚类、删控制变量、或用补充样本来掩盖。

## 稳定城市补充分析（不计正式30项）

为观察迁址问题，另剔除100家城市归属发生变化的企业，对主结果进行补充估计。输入基于作者主样本，采用稳定地点真实政策日期，全部保存在project/sensitivity_output；不计正式论文已发表设定，不用它替代上面的原样本结果。

补充样本N={int(ss.n.iloc[0])}、cohort数={int(ss.n_cohorts.iloc[0])}。标准化TWFE={f(ss.twfe.iloc[0])}，CSA={f(ss.csa.iloc[0])}（SE={f(ss.csa_se.iloc[0])}），BJS={f(ss.bjs.iloc[0])}（SE={f(ss.bjs_se.iloc[0])}）。具体成功/失败和杠杆仍以data/stable_city_sensitivity.csv为准，不能因为得到点估计便声称通过全部诊断。

## 图1与推断限制

作者d_1恒为1并被固定效应吸收；d_5、d5只表示恰好-5和+5，不是端点分箱，窗口外-6和+6实际并入参照。协议设为窗口[-5,5]、基期-1、ends=ref。41家迁址政策赋值变化企业使用本轮企业暴露日期后，其事件相对期可能与作者原哑变量不同，重构TWFE不得误称原图精确匹配。原作者路径另存。

本轮保持上游R估计、汇总代码字节一致，无估计器补丁、无额外方差修正版。控制变量现代估计量杠杆未计算时，原版标twfe_only；只能说通过TWFE一侧。控制变量模型TWFE–CSA协方差和事件联合协方差未由v0.1计算，上游汇总按0处理。主样本CSA缺少SE，不能进行完整的显著性或SE比率比较；联合自助给出的bsd_csa仅按原版保留。

主样本TWFE负权重观测占已处理行{100*main.neg_rows:.3f}%，负权重绝对量占比{100*main.neg_abs:.3f}%；其TWFE的G_eff={main.G_eff_twfe:.2f}、L_max={main.L_max_twfe:.4f}，BJS的G_eff={main.G_eff_bjs:.2f}、L_max={main.L_max_bjs:.4f}。通过杠杆规则只说明该规则下的支持情况，不验证平行趋势或其他识别假设。

## 逐项估计说明

{chr(10).join(notes)}

## 文件、来源与重跑

original/保留用户提供PDF、ZIP和解压原件，SHA256见original/manifest.json；ZIP CRC已通过。正文是19页扫描PDF，文字提取为空，采用关键页渲染视觉核对；日志保存页图。附录为研究材料，未运行其中全部稳健性、匹配、随机安慰剂和图形。

project/data保存1主样本、29二级样本JSON；project/output为上游正式逐项结果、汇总、散点图；data/modern_results.csv是附加可读汇总。logs/modern保存各模型日志、队列退出状态、R版本；logs/upstream_code_hashes.json记录代码来源，研究裁定.md记录判断与限制。

rerun_modern.ps1默认999次静态联合自助，在新的临时目录重跑冻结输入，不覆盖正式结果；需要R及data.table、fixest、did、did2s等包，可用-RscriptPath、-RLibrary参数指定环境。作者回归在work目录执行replicate_body.do，依赖已附在dependencies/stata_ado。

已完成的是公开分析数据层面的正文TWFE复现与协议现代重估，不是底层CSMAR/Wind/Choice数据库重建、全部附录复现或全刊任务完成。研究成果引用论文及《中国工业经济》官网附件，不能将作者数据或日志视为本次自建来源。
'''
(R/'复现报告.md').write_text(report,encoding='utf-8')
(R/'README.md').write_text('''# 从这里开始

先读复现报告.md和研究裁定.md。

已核对正文30个静态模型、32个印刷系数全部匹配；已重估30个正文协议设定，其中29个静态设定各999次联合自助。事件路径按上游解析推断。

原样本CSA存在时变城市聚类限制，不能称全部估计成功。稳定城市敏感性分析单列，不混入正式计数。现代结果、具体失败、样本变化和结论以报告及data/modern_results.csv为准。

偏好含控制模型BJS保持正向但5%不显著。表2两列CSA异常大，已核查并保留原始结果；不平衡面板协变量处理存在上游文字／代码差异，详见报告，不据此宣称三方法全面稳健。

主要文件：data/published_comparison.csv（作者核对）、data/modern_results.csv（正式现代结果）、data/stable_city_sensitivity.csv（补充分析）、project/output/tables/comparison_summary.csv（上游汇总）、original/（原件）、logs/（过程与版本）。

materials/按论文、原始数据、作者代码、附录、说明分类；处理数据在data/。这里“原始数据”指作者公开附件原件，不是底层商业数据库。来源及获取方式见logs/sources.json，分类副本SHA256见materials/manifest.json。

rerun_modern.ps1可重跑。附录安慰剂/匹配及机器学习模型未全部独立重跑，未宣称全篇所有分析均已完成。
''',encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2));print(x[['spec_id','window','twfe','csa','csa_se','bjs','bjs_se']].to_string(index=False));print('Sensitivity',ss[['twfe','csa','csa_se','bjs','bjs_se']].to_dict('records'))
