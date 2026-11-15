from pathlib import Path
import pandas as pd,numpy as np,json,math,shutil,hashlib
R=Path(__file__).resolve().parent
S=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-newarea-run')
for q,n in [(1,5),(2,4),(3,4),(4,4)]:
 a=pd.read_csv(S/f'logs/queue_{q}_status.csv');assert len(a)==n and a.rc.eq(0).all()
mf=list((S/'project/output/specs').glob('*.csv'));xf=list((S/'project/implementation_output/specs_controls').glob('*.csv'))
assert len(mf)==1 and len(xf)==16
m=pd.read_csv(mf[0]);m['pool']='canonical_main_supported'
z=pd.concat([pd.read_csv(p) for p in xf],ignore_index=True);z['pool']='implementation_pending_canonical_pool'
x=pd.concat([m,z],ignore_index=True).sort_values(['spec_id','window']);assert len(x)==18 and x.spec_id.nunique()==17
st=x[x.static_or_event=='static'];assert len(st)==16 and st.boot_B.eq(999).all()
assert x[['twfe','twfe_se','bjs','bjs_se']].notna().all().all()
for p in (R/'project/code/R').glob('*.R'):
 assert p.read_bytes()==(Path('reference/Replication_cn-main/code/R')/p.name).read_bytes()
 assert p.read_bytes()==(S/'project/code/R'/p.name).read_bytes()
for r in json.loads((R/'original/manifest.json').read_text(encoding='utf-8')):assert hashlib.sha256((R/'original'/r['file']).read_bytes()).hexdigest()==r['sha256']
for f in ['output','implementation_output','diagnostics']:shutil.copytree(S/'project'/f,R/'project'/f,dirs_exist_ok=True)
shutil.copytree(S/'logs',R/'logs/modern',dirs_exist_ok=True)
for method in ['twfe','csa','bjs']:
 for suf in ['', '_se']:x[method+suf+'_original_units']=x[method+suf]*x.y_sd
 x[method+'_p_normal']=x.apply(lambda r:math.erfc(abs(r[method]/r[method+'_se'])/math.sqrt(2)) if pd.notna(r[method]) and pd.notna(r[method+'_se']) and r[method+'_se']>0 else np.nan,axis=1)
 x[method+'_leverage_available']=x['G_eff_'+method].notna()&x['L_max_'+method].notna()
 x[method+'_leverage_pass']=(x['G_eff_'+method]>=10)&(x['L_max_'+method]<=.25)
x.to_csv(R/'data/modern_results.csv',index=False,encoding='utf-8-sig')
b=pd.read_csv(R/'project/diagnostics/csa_baseline_basis_comparisons.csv')
for suf in ['','_se']:b['csa'+suf+'_original_units']=b['csa'+suf]*b.y_sd
b['p_normal']=b.apply(lambda r:math.erfc(abs(r.csa/r.csa_se)/math.sqrt(2)) if pd.notna(r.csa) and pd.notna(r.csa_se) and r.csa_se>0 else np.nan,axis=1)
b['role']='separate_baseline_columnspace_diagnostic_not_upstream_replacement'
b.to_csv(R/'data/csa_basis_diagnostic.csv',index=False,encoding='utf-8-sig')
cs=pd.read_csv(R/'project/diagnostics/csa_baseline_columnspace.csv')
assert cs.literal_rank.eq(cs.reduced_rank).all() and cs.literal_rank.eq(cs.combined_rank).all()
comp=pd.read_csv(R/'data/published_comparison.csv');assert len(comp)==27 and comp.status.eq('exact').all()
a=pd.read_csv(R/'data/author_results.csv');main=x[x.spec_id=='T2_1'].iloc[0];pref=x[x.spec_id=='T2_2'].iloc[0];cov=b[b.spec_id=='T2_1'].iloc[0]
event=x[x.spec_id=='F1']
for win in ['pre','post']:
 original=a[(a.spec=='F1')&(a.term==win+'_reported')].b.iloc[0]
 modern=event[event.window==win].twfe_original_units.iloc[0];assert abs(original-modern)<1e-6
summary=dict(title='新城新区建设与地区创业活跃度',date='2026-11-15',author_static_models=22,printed_coefficients_exact=27,author_event_path_recomputed=True,table1_numeric_cells_exact=24,canonical_main_supported=1,implementation_pool_specs=16,combined_specs=17,combined_result_rows=18,static_specs=16,static_B=999,original_csa_points=int(x.csa.notna().sum()),original_csa_with_se=int((x.csa.notna()&x.csa_se.notna()).sum()),bjs_points_and_se=int((x.bjs.notna()&x.bjs_se.notna()).sum()),basis_diagnostic_with_se=int((b.csa.notna()&b.csa_se.notna()).sum()),main_csa_valid_post_cells=int(cov.valid_post_cells),main_csa_total_post_cells=int(cov.total_post_cells),core_R_unchanged=True,canonical_pool_assignment_pending_for_baseline_interactions=True,event_reported_window_driver_explicit=True,appendix_not_fully_reproduced=True)
(R/'data/completion_summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
def f(v):return 'NA' if pd.isna(v) else f'{v:.6f}'
def label(s):
 if s=='F1':return '图1'
 t,c=s[1:].split('_');return f'表{t}第{c}列'
def table(d,raw=False):
 suf='_original_units' if raw else ''
 out=['|原文设定|窗口|输入N|TWFE（SE）|CSA（SE）|BJS（SE）|','|---|---|---:|---:|---:|---:|']
 for _,v in d.iterrows():out.append('|'+ '|'.join([label(v.spec_id),v.window,str(int(v.n))]+[f'{f(v[k+suf])}（{f(v[k+"_se"+suf])}）' for k in ['twfe','csa','bjs']])+'|')
 return '\n'.join(out)
bt=['|设定|窗口|基期空间CSA（SE，SD单位）|有效处理后单元/总数|','|---|---|---:|---:|']
for _,v in b.iterrows():bt.append('|'+ '|'.join([label(v.spec_id),v.window,f'{f(v.csa)}（{f(v.csa_se)}）','NA' if pd.isna(v.valid_post_cells) else f'{int(v.valid_post_cells)}/{int(v.total_post_cells)}'])+'|')
report=f'''# 新城新区建设与地区创业活跃度：本轮复现报告

陈勇兵、胡佳雯、陈永安，《中国工业经济》2025年第3期，116–134页。[作者单位记录](https://econpub.xmu.edu.cn/research/index.php?p_id=5018&ser_id=2)。执行日期：2026-11-15。

## 已完成与尚不能宣称完成的部分

正文22个静态回归及图1完整事件路径已独立重算；27个印刷政策/交互及表3其他政策系数、对应SE和N全部与印刷四位小数匹配。表1六变量的均值、样本SD、最小值、最大值共24项以及N匹配。图1未印刷逐点数值，称作者代码等价重算，不称图上坐标逐字匹配。

现代计算已执行17组：1个老师原版框架可直接归档的主设定（表2第1列），另15个静态设定及1个事件路径以保留原数值控制结构的实现对照单列。16个静态设定均999次联合聚类贝叶斯自助；事件路径按原版解析函数推断，没有虚构999次事件联合协方差。

**规范入池尚有一项框架支持问题，不能称全篇已经完成规范项目登记。** 除表2第1列外，相关控制是固定2006特征×年份虚拟变量。按老师协议允许固定特征交互的条款理解，应保留这些设定核查，不能只看controls字段非空就自动当作普通时变控制二级样本。原版xt_vars按类别处理，不能把连续特征的每个不同数值当成类别，这会改成近乎城市×年份饱和固定效应。本轮用原50个数值列计算TWFE/BJS与CSA尝试，单列implementation_output；原版汇总的controls标签是实现分组，**不是已确认的二级样本分类**。16组的规范入池衔接仍待解决。

原版R核心文件保持字节一致；图1单独的驱动只调用原版估计器函数，保留完整回归分箱而选择作者展示窗口均值。该驱动公开保存，不冒称只运行原版run_spec.R即可同时表示两个窗口。

## 关键结果与解读范围

表2第1列：TWFE原单位{f(main.twfe_original_units)}、SE {f(main.twfe_se_original_units)}；BJS为{f(main.bjs_original_units)}、SE {f(main.bjs_se_original_units)}，正态近似p={main.bjs_p_normal:.4f}。方向仍为正，但BJS未达到5%显著水平；不能仅由显著性变化认定两种估计量之间的差异显著。

原版CSA为{f(main.csa_original_units)}、SE {f(main.csa_se_original_units)}，p={main.csa_p_normal:.4f}。**CSA仅有{int(cov.valid_post_cells)}/{int(cov.total_post_cells)}个处理后组期单元可估，聚合只覆盖2007–2009年最早三批的部分单元；不能把它解释为全样本原目标总体的完整CSA效应。** 6/44是单元计数比例，不是按处理观测数加权的覆盖率。原版aggte(na.rm=TRUE)会使用可估单元，本轮保留这一行为并显式披露。

含原数值控制的偏好表2第2列：TWFE={f(pref.twfe_original_units)}，BJS={f(pref.bjs_original_units)}、SE {f(pref.bjs_se_original_units)}，p={pref.bjs_p_normal:.4f}。原版CSA聚合失败，保留NA而不填零。其余实现对照同样不能据此概括“三种方法全部稳健”或直接认定论文整体被推翻。

结果变量lnNo_GSmgfper已经取过对数，本轮未再次取log。原单位系数是对数点，不是百分点。三个方法共用冻结输入，但BJS按上游支持规则删除部分观察，CSA另有可估单元限制，有效估计总体不完全相同。

## 规范主设定及偏好模型：原单位

{table(x[x.spec_id.isin(['T2_1','T2_2','T2_3'])],True)}

表2第2、3列在下表以数值实现对照展示，不与规范主样本计数混合。

## 全部数值计算：结果变量标准差单位

{table(x)}

规范主设定结果位于project/output；其余16组位于project/implementation_output，两者没有合并做正式样本汇总。data/modern_results.csv增加pool字段便于联合审阅，不改变原版逐项文件。

## CSA矩阵问题与单列的基期空间诊断

原50个控制列由5个固定特征分别乘以10个年份虚拟变量构成。在任一g−1单元内，大量年份列恒为0，原版did对照回归会出现奇异或病态矩阵；15个静态实现对照及事件CSA均未取得原版有限估计。错误保存在各模型日志。省份类别在处理后缺少未处理支持也造成可估单元缺失，不能将问题只归因为零列。

额外作了独立诊断：从作者实际50个交互列恢复5个固定基期数值，在CSA基期回归中使用同一线性协变量空间。逐单元检验原矩阵、化简矩阵以及二者拼接矩阵的秩相同（project/diagnostics/csa_baseline_columnspace.csv）。TWFE/BJS仍保留原50列，诊断不会替换原输出。对不平衡面板，这是按协议文字使用固定基期特征的计算诊断，与原版实际各期协变量路径也有差别，不能不加说明地替换。

诊断共{int((b.csa.notna()&b.csa_se.notna()).sum())}/18行有有限点估计与SE，但支持仍很有限（包括表2只有6/44）；表6第5列仍失败。以下只作技术核查，**不是完成规范CSA重估的替代证明**：

{chr(10).join(bt)}

原数据还存在一个必须保留的事实：实际交互列所隐含的两项基期值与同名基期列并不完全相同，agriareaper2006最大差0.47、consratio2006最大差3.94，其他三项相同。没有查明差异形成原因，不臆定为缩尾。本轮保留原交互列，未用同名基期列重新生成后替换作者模型。

## 图1：回归窗口与展示窗口

作者使用eventdd的inrange、leads(4)、lags(4)。核查[该软件原始代码](https://github.com/damiancclarke/eventdd/blob/main/eventdd.ado)，inrange限制绘图展示，不截断完整lead/lag回归。数据实际相对期为−8至8，原代码提取系数矩阵第55–62列正好对应−4、−3、−2、0、1、2、3、4。

本轮Stata保留−8至−2、0至8共16个哑变量，基期−1；展示前均值为−4/−3/−2的均值、后均值为0–4的均值。R驱动保留同样完整bins再调用未修改的twfe_event/bjs_event/csa_event计算报告窗口。TWFE两个均值换回原单位与Stata相差均小于1e−6；标准误可因软件有限样本自由度校正略异。原始逐期路径和均值在data/author_results.csv。

BJS处理前窗口均值为{f(event[event.window=='pre'].bjs_original_units.iloc[0])}，SE {f(event[event.window=='pre'].bjs_se_original_units.iloc[0])}，正态近似p={event[event.window=='pre'].bjs_p_normal.iloc[0]:.4f}；这是处理前均值描述，不是全部前导项的联合检验，提示需要继续检查动态识别，不能写成平行趋势已被验证。

## 原文表号与筛选

附件把原文表4/5/6标成程序表3/4/5，原文正文表3两列位于程序“附表4”。本轮以原文为准补齐22个静态模型；原文表3两列仍需复现，但因加入其他政策处理变量，不进入协议现代比较。表4第1/5/6列含处理×特征交互，排除。表4第4列含城市和行业的非冗余可加FE，没有城市—行业单位FE，按协议排除，未私自改成另一种模型。其余16个静态列及图1完整记录，没有因为不显著或符号而省略。

## 样本与推断

原城市表1740行、174城，2006–2015年；政策2007–2014年8批，15个从未处理城市，无处理关闭。firstyear直接作为真实政策年份，缺失对应从未处理，逐行验证tp一致。表2共同作者样本1610行、161城，含14个从未处理城，未改为全174城。其余列各取原作者e(sample)。省份在城市内固定，省份×年份FE保留。

主设定BJS因省份×年份未处理支持等原因删除405行，保留上游bjs_nonimputable_dropped记录。主设定TWFE G_eff={main.G_eff_twfe:.2f}、L_max={main.L_max_twfe:.4f}；BJS G_eff={main.G_eff_bjs:.2f}、L_max={main.L_max_bjs:.4f}，二者通过相应阈值。CSA杠杆未实现，原汇总是twfe_only，不称三者双侧全通过。

本篇所有设定都有xt_vars（省份），原版联合自助仅在无xt且无controls时计算CSA部分，因此本篇TWFE–CSA联合协方差缺失，原版汇总采用0；999次联合自助实际给出TWFE/BJS部分。CSA自身did乘子自助是另一件事。事件联合协方差没有计算。原版控制模型现代杠杆同样保留NA。

部分不平衡结果还受上游协议文字与代码的已知差异影响：文字要求CSA控制取g−1，原代码allow_unbalanced_panel=TRUE的[官方行为](https://bcallaway11.github.io/did/reference/DIDparams.html)则用各期协变量。本轮不暗改原版；基期空间诊断另列，不混入原输出。

## 文件与重跑

original保留用户确认的19页正文、ZIP及全部5个解压原件；ZIP CRC通过，SHA256见清单。materials按论文、原始公开分析数据、作者代码、附录、使用说明分类。这里原始数据指附件分析表，不是工商注册、工业企业等底层数据库。

data保存作者核对、图1路径、现代计算和CSA诊断；project/data保存主设定、实现对照及逐列筛选；project/code/R是老师原版；project/run_event_reported.R是公开的报告窗口驱动。project/output仅规范主设定，project/implementation_output仅技术实现对照。logs保存Stata/R、软件版本、来源和失败信息。

rerun_modern.ps1在新临时目录重跑，不覆盖正式结果，默认16项静态各999次。原作者回归在work中执行replicate_body.do。复现已覆盖正文静态及事件路径，没有声称重建底层数据库或重跑附录所有平衡性、安慰剂、did_imputation和趋势稳健性。
'''
(R/'复现报告.md').write_text(report,encoding='utf-8')
(R/'README.md').write_text('''# 从这里开始

论文：新城新区建设与地区创业活跃度，《中国工业经济》2025年第3期。

先读复现报告.md。正文22个静态回归、27个印刷系数/SE/N匹配；图1按完整回归与展示窗口分别重算。

现代计算：1个规范主设定 +16组独立实现对照（15静态、1事件）。16项静态各999次联合自助。固定连续特征×年份在原版框架中的规范入池衔接尚未解决；实现对照不能自动作为普通时变控制二级样本。

主设定BJS为正但5%不显著；CSA仅6/44处理后单元可估，不能作完整总体结论。原50列控制的CSA失败保留NA，另有不覆盖原结果的基期空间诊断。详见报告和data/csa_basis_diagnostic.csv。

资料在materials/分类；原件和SHA256在original/；处理数据、结果在data/；规范输出project/output/，实现对照project/implementation_output/，各自单列。入口rerun_modern.ps1。附录未全部重跑，不宣称全篇已完成规范项目登记。
''',encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2));print('main p-values',main[['twfe_p_normal','csa_p_normal','bjs_p_normal']].to_dict())
