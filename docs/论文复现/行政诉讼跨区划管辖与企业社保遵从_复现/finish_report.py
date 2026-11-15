from pathlib import Path
import pandas as pd,numpy as np,json,math,shutil,hashlib
R=Path(__file__).resolve().parent
S=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-jurisdiction-run')
files=list((S/'project/output/specs').glob('*.csv'))+list((S/'project/output/specs_controls').glob('*.csv'))
assert len(files)==9
x=pd.concat([pd.read_csv(p) for p in files],ignore_index=True).sort_values('spec_id')
assert len(x)==9 and x.spec_id.nunique()==9 and x.boot_B.eq(999).all()
assert x[['twfe','twfe_se','csa','csa_se','bjs','bjs_se']].notna().all().all()
assert x.reports_modern_estimator.all()
for p in (R/'project/code/R').glob('*.R'):
 assert p.read_bytes()==(Path('reference/Replication_cn-main/code/R')/p.name).read_bytes()
 assert p.read_bytes()==(S/'project/code/R'/p.name).read_bytes()
for v in json.loads((R/'original/manifest.json').read_text(encoding='utf-8')):
 assert hashlib.sha256((R/'original'/v['file']).read_bytes()).hexdigest()==v['sha256']
shutil.copytree(S/'project/output',R/'project/output',dirs_exist_ok=True)
shutil.copytree(S/'project/diagnostics',R/'project/diagnostics',dirs_exist_ok=True)
shutil.copytree(S/'logs',R/'logs/modern',dirs_exist_ok=True)
for m in ['twfe','csa','bjs']:
 for suf in ['', '_se']:x[m+suf+'_original_units']=x[m+suf]*x.y_sd
 x[m+'_p_normal']=x.apply(lambda r:math.erfc(abs(r[m]/r[m+'_se'])/math.sqrt(2)),axis=1)
 x[m+'_leverage_available']=x['G_eff_'+m].notna()&x['L_max_'+m].notna()
 x[m+'_leverage_pass']=(x['G_eff_'+m]>=10)&(x['L_max_'+m]<=.25)
x['csa_covariate_rule']=np.where(x.controls,'upstream_unbalanced_current_period_covariates','no_covariates')
diag=pd.read_csv(R/'project/diagnostics/sample_counts.csv')
x=x.merge(diag[['spec','twfe_actual_N','input_singleton_units','bjs_nonimputable_rows']],left_on='spec_id',right_on='spec',validate='1:1').drop(columns='spec')
x.to_csv(R/'data/modern_results.csv',index=False,encoding='utf-8-sig')
comp=pd.read_csv(R/'data/published_comparison.csv');assert len(comp)==35 and comp.status.eq('exact').all()
fit=pd.read_csv(R/'data/fit_statistics_comparison.csv');fitdiff=fit[fit.status!='exact_4dp']
main=x[x.spec_id=='T2_1'].iloc[0];pref=x[x.spec_id=='T2_3'].iloc[0]
flip=x[np.sign(x.csa)!=np.sign(x.twfe)]
sigloss_c=x[(x.twfe_p_normal<.05)&(x.csa_p_normal>=.05)]
sigloss_b=x[(x.twfe_p_normal<.05)&(x.bjs_p_normal>=.05)]
summary=dict(title='行政诉讼跨区划管辖与企业社保遵从',date='2026-11-15',author_body_models=17,printed_coefficients_exact=35,formal_specs=9,main_specs=1,secondary_specs=8,bootstrap_B=999,bootstrap_specifications=9,csa_points_and_se=9,bjs_points_and_se=9,csa_opposite_direction_specs=flip.spec_id.tolist(),twfe_sig5_csa_not_sig5=sigloss_c.spec_id.tolist(),twfe_sig5_bjs_not_sig5=sigloss_b.spec_id.tolist(),adjusted_R2_differences=fitdiff.spec.tolist(),upstream_R_byte_identical=True,unknown_date_rows_excluded=2,appendix_not_fully_rerun=True)
(R/'data/completion_summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
def f(v):return 'NA' if pd.isna(v) else f'{v:.6f}'
def name(s):t,c=s[1:].split('_');return f'表{t}第{c}列'
def table(d,orig=False):
 suf='_original_units' if orig else ''
 lines=['|设定|输入N / TWFE实际N|TWFE（SE）|CSA（SE）|BJS（SE）|','|---|---:|---:|---:|---:|']
 for _,v in d.iterrows():
  vals=[name(v.spec_id),f'{int(v.n)} / {int(v.twfe_actual_N)}']+[f'{f(v[m+suf])}（{f(v[m+"_se"+suf])}）' for m in ['twfe','csa','bjs']]
  lines.append('|'+ '|'.join(vals)+'|')
 return '\n'.join(lines)
sr=pd.read_csv(R/'project/output/tables/comparison_summary.csv')
report=f'''# 行政诉讼跨区划管辖与企业社保遵从：复现报告

潘越、陈怡萍、梁伟娟、余厚之，《中国工业经济》2025年第4期，118–136页。[作者单位页面](https://finance.xmu.edu.cn/info/1019/75704.htm)。日期：2026-11-15。

## 本轮完成与主要发现

已独立重算正文表2–6的17个作者回归模型，包括原始Logit和异质性交互模型；核对35个印刷系数及对应标准误、样本量，均按印刷四位小数精确匹配。拟合统计量另查：15个线性模型中有{len(fitdiff)}列调整R²在四位小数上不同，因此不说整张表所有统计量完全一致。Logit两列的Pseudo R²与原文一致。

按[老师Replication_cn项目](https://github.com/wenddymacro/Replication_cn)筛选，正式重估9个正文静态设定：1个无控制主样本、8个带控制二级样本。每项999次联合聚类贝叶斯自助；三种估计量9项均得到点估计与SE。原版estimators.R、run_spec.R、analysis.R等逐字节保持一致。没有把Logit、处理×分组交互或线上附录混进正文合格设定。

**主样本三种方法均为正，CSA/BJS的点估计高于TWFE；作者偏好含控制模型的CSA在5%水平不显著，BJS仍显著为正。不能概括成所有结论在三种方法下均稳健。**

## 原作者核对与现代主结果

表2第1列作者TWFE为0.006549105（SE 0.003287178），N=26595，对应印刷0.0065（0.0033）。表2第3列作者偏好TWFE为0.007960873（SE 0.003358776），N=26595，对应印刷0.0080（0.0034）。全部35项核对见data/published_comparison.csv。

以下为现代共同输入的**原结果变量单位**，不是标准差单位；sbf为缴费率比例，因此乘100才是百分点。现代输入对2条政策日期无法辨认的单期观测作了明确剔除，详见下节。

{table(x[x.spec_id.str.startswith('T2')],True)}

表2第1列CSA正态近似p={main.csa_p_normal:.6f}，BJS p={main.bjs_p_normal:.6f}。偏好表2第3列CSA p={pref.csa_p_normal:.4f}，BJS p={pref.bjs_p_normal:.6f}。例如，偏好BJS原单位{f(pref.bjs_original_units)}相当于约{pref.bjs_original_units*100:.3f}个百分点；CSA点估计仍为正，但其不确定性较大。

这里的单系数正态近似p值用于描述，和检验“TWFE与现代估计量之差”不同；不能从一显著一不显著推断两者差异显著。

## 全部正式现代结果：样本标准差单位

{table(x)}

CSA与TWFE异号的设定：{'、'.join(name(s) for s in flip.spec_id)}，均是城市机制回归，不能写成主结果反转。CSA对应单系数是否显著见CSV，原版上游“显著反号”比较及筛选结果见project/diagnostics/controls_comparisons.csv。TWFE在5%显著而CSA不显著共{len(sigloss_c)}项；TWFE显著而BJS不显著共{len(sigloss_b)}项。这些是设定数，不是独立论文数。

主样本的TWFE/CSA/BJS杠杆均通过规则：G_eff分别为{main.G_eff_twfe:.2f}/{main.G_eff_csa:.2f}/{main.G_eff_bjs:.2f}，L_max分别为{main.L_max_twfe:.4f}/{main.L_max_csa:.4f}/{main.L_max_bjs:.4f}。8个控制模型现代估计量杠杆未由上游实现，原汇总标twfe_only，只能说通过TWFE侧，不能声称双侧均通过。CSA/BJS“9项有点估计与SE”和“9项全通过完整筛选”是两件事。

主样本负权重观测占已处理观测{main.neg_rows*100:.3f}%，负权重绝对量占比{main.neg_abs*100:.3f}%。不能仅根据这一指标判定因果识别成立或失效。

## 样本、日期与软件处理

公开企业表26604行，其中9行缺少必要ID/年份；作者基准26595行、3015家企业、246城。回归数据实际2008–2021年；原文初始样本描述2007–2021并滞后控制，直接使用作者处理后数值，未擅自再次滞后。企业没有迁址，court没有1→0。

城市真实改革年优先由作者精确事件期哑变量恢复，而非用企业首次在样本中被观察为处理的年份。日期恢复逐城市一致，逐行验证保留数据中的重建D与court一致。city51仅有>=6期尾箱，用2002上界哨兵保证其在所有年度被归为一直处理，不能声称2002为确切改革年。

city145、256各一个2021年单期企业观测，只有尾箱、无法确定精确日期。本轮共同现代输入剔除此2行，企业列输入26593，属于明确的分析裁定，并非老师代码强制删除。城市机制样本不受影响。其他单期企业保留在输入；fixest实际TWFE又自动删除单期FE观察，故必须同时看输入N与实际nobs。主样本TWFE实际N={int(main.twfe_actual_N)}，与作者keepsin保留单期观察的26595不同；原作者核对在这一步之前完成。

BJS按上游规则删除无可识别未处理固定效应的观察，主样本删除{int(main.bjs_nonimputable_rows)}行；CSA由did处理一直处理观察。所有三法用同一冻结输入，但有效估计样本并非完全相同。输入、实际nobs、单期单位数和BJS删除数见project/diagnostics/sample_counts.csv，不能隐去这些差异后将全部变化只归因于估计公式。

## 上游协议文字／代码差异与推断边界

保留此前已经识别的上游差异：PROTOCOL第5.4节要求CSA以g−1控制项入模，而原版对不平衡面板使用allow_unbalanced_panel=TRUE。[did官方文档](https://bcallaway11.github.io/did/reference/DIDparams.html)说明此路径使用各期协变量。8个带控制设定均标明该实施方式；未擅自修改原版代码，也未声称已同时满足文字中的基期控制规则。需要老师统一规则后再确定跨论文最终汇总口径。

999次联合自助对含控模型重算TWFE和BJS，TWFE–CSA联合协方差尚未实现，原版汇总按0处理；报告没有将该协方差标为已估出。控制现代杠杆缺失保留NA。上游代码保持原版，相关限制不能因数值输出成功就省略。

论文报告dCDH类稳健估计，元数据reports_modern_estimator=true。初始录入false已在汇总前更正，仅改该布尔字段，所有其他CSV字符串字段逐格保持一致，原输出备份和说明见logs/modern/before_metadata_correction与metadata_correction.json。未改动点估计、SE、协方差或任何估计器代码。

## 原表拟合统计量差异

调整R²未完全匹配的列：{'、'.join(name(s) for s in fitdiff.spec)}。具体数值见data/fit_statistics_comparison.csv。作者软件为Stata/SE17，本轮Stata19；代码/依赖版本与自由度实现等可能影响拟合统计量，未独立证明具体原因，不凭此推断论文存在错误。35个系数/SE/N精确匹配结论只限这些已核对统计量。

## 文件与重跑

- original/：用户确认的19页正文PDF、原ZIP和全部6个解压原件，SHA256清单。ZIP CRC通过。
- materials/：按论文、原始数据、作者代码、附录、说明分类。这里原始数据指作者公开的分析表，不是底层CSMAR/Wind库。
- data/：作者核对、恢复政策日期、处理后的分析数据和modern_results.csv。处理数据含e(sample)标志，不覆盖作者原件。
- project/data/：9个JSON和逐列筛选记录；project/code/R/：老师原版R代码；project/upstream_documents/：协议等冻结文件。
- project/output/：正式逐项结果、原版汇总及散点图；logs/：Stata/R日志、运行版本和来源；研究裁定.md：所有预处理判断。

rerun_modern.ps1默认999次，在新的临时目录重跑9项，不覆盖本次正式结果；可通过参数指定R和包库。作者正文回归在work目录执行replicate_body.do，依赖已附在dependencies/stata_ado。

本轮完成公开分析数据层面的正文复现和9项现代重估，未独立重建底层商业数据库，也未运行线上附录全部稳健性、dCDH、1000次安慰剂或边际效应图。不是对全刊任务已经完成的声明。
'''
(R/'复现报告.md').write_text(report,encoding='utf-8')
(R/'README.md').write_text('''# 从这里开始

论文：行政诉讼跨区划管辖与企业社保遵从（《中国工业经济》2025年第4期，118–136页）。

先读[复现报告](复现报告.md)和[研究裁定](研究裁定.md)。

正文17个作者模型已运行，35个印刷系数及对应SE/N精确匹配；5列调整R²仍有四位小数差异。按老师规则重估9个正文静态设定（1主、8含控），每项999次联合自助，CSA/BJS均9项有点估计与SE。

主样本CSA/BJS保持正向；偏好含控模型CSA不再5%显著、BJS仍显著。控制模型的现代杠杆未实现，并存在不平衡面板协变量的上游文字/代码差异，详见报告。不能称三法所有结论均稳健或全部通过完整筛选。

materials/分类保存论文、原始公开分析数据、作者代码、附录和说明；处理数据和结果在data/；原始ZIP及SHA256在original/。来源及失败URL见logs/。重跑入口rerun_modern.ps1；作者回归work/replicate_body.do。附录与底层数据库未全部独立复现。
''',encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
print(x[['spec_id','twfe_original_units','csa_original_units','csa_p_normal','bjs_original_units','bjs_p_normal']].to_string(index=False))
