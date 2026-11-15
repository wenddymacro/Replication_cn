from pathlib import Path
import pandas as pd,json,re,datetime,hashlib
root=Path(__file__).resolve().parents[1]
main=pd.read_csv(root/'output/main_comparison.csv')
app=pd.read_csv(root/'output/appendix_comparison.csv')
data=json.loads((root/'output/data_audit.json').read_text(encoding='utf-8'))
groups=['g_clus1','g_gc','g_contract','g_clus2','g_mps','g_mayor','g_govpur','g_mstate','g_lpast']
labels=['表4：产业配套','表4：政商关系','表4：专用投资','附表23：产业链配套','附表23：市委书记变更','附表23：市长变更','附表24：本地政府采购','附表24：市属国企','附表24：历史交易经验']
published_diffs=[.0451,.0326,.0676,.0568,.0407,.0690,.0402,.0363,.1373]
published_stars=['*','*','***','**','**','***','**','*','']
orientations=[-1,-1,1,-1,1,1,1,1,-1]
boot=[]
for group,label,pdff,pstar,orient in zip(groups,labels,published_diffs,published_stars,orientations):
    p=root/'output'/f'bootstrap_{group}.log'
    t=p.read_text(encoding='utf-8',errors='replace') if p.exists() else ''
    b=re.search(r'r\(bdiff\)\s*=\s*([-\d.]+)',t) or re.search(r'Observed difference\s*=\s*([-\d.]+)',t)
    pv=re.search(r'r\(p\)\s*=\s*([-\d.]+)',t) or re.search(r'Empirical p-value\s*=\s*([-\d.]+)',t)
    complete=b is not None and pv is not None
    val=float(b[1]) if b else None;pval=float(pv[1]) if pv else None
    stars='***' if pval is not None and pval<.01 else '**' if pval is not None and pval<.05 else '*' if pval is not None and pval<.1 else ''
    boot.append(dict(group=group,label=label,completed=complete,difference=val,p=pval,repetitions=1000,seed=824,published_difference=pdff,oriented_difference=orient*val if complete else None,difference_match=abs(orient*val-pdff)<.00005 if complete else None,published_stars=pstar,actual_stars=stars,stars_match=stars==pstar if complete else None))
pd.DataFrame(boot).to_csv(root/'output/permutation_results.csv',index=False,encoding='utf-8-sig')
done=sum(x['completed'] for x in boot)
metadata=dict(paper_id='cie_2026_09_04',journal='中国工业经济',year=2026,issue=9,pages='73-95',title='新型产业政策何以提升企业生产率——来自产业链链长制的证据',authors=['唐跃桓','黎静霖'],method='staggered DID',main_checked_coefficient_rows=len(main),main_all_checked_values_match=bool(main[['b_match','se_match','N_match','R2_match']].all().all()),appendix_checked_coefficient_rows=len(app),appendix_all_checked_values_match=bool(app[['b_match','se_match','N_match','R2_match']].all().all()),permutation_tests_completed=done,permutation_tests_total=9,permutation_star_mismatches=[r['group'] for r in boot if r['completed'] and not r['stars_match']],tax_survey_microdata_available=False,raw_data_reconstruction_completed=False,analysis_data_available=True,status='主要系数可复现；部分随机检验显著性未复得；税调数据未公开')
(root/'replication_status.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding='utf-8')
status='主要回归与图表已完成；九组重复抽样检验已完成。' if done==9 else f'主要回归与图表已完成；重复抽样检验已完成 {done}/9 组，其余仍在计算。'
boot_mismatches=[r['label'] for r in boot if r['completed'] and not r['stars_match']]
boot_note=('已完成检验的星号与论文一致。' if not boot_mismatches else '以下检验的显著性星号与论文不同，不能宣称全部推断结论均复现：'+ '、'.join(boot_mismatches)+'。')
table='| 表1列号 | 论文系数 | 本次系数 | 论文标准误 | 本次标准误 | 样本量 |\n|---|---:|---:|---:|---:|---:|\n'
for _,r in main[main.table==1].iterrows():table+=f'| ({int(r.column)}) | {r.published_b:.4f} | {r.replicated_b:.8f} | {r.published_se:.4f} | {r.replicated_se:.8f} | {int(r.replicated_N)} |\n'
boot_table='| 检验 | 完成情况 | 论文系数差 | 本次系数差 | 经验 p 值 | 论文星号 | 本次星号 |\n|---|---|---:|---:|---:|---|---|\n'
for r in boot:
    boot_table+=f'| {r["label"]} | '+('1000次完成 | '+f'{r["published_difference"]:.4f} | {r["oriented_difference"]:.4f} | {r["p"]:.3f} | {r["published_stars"] or "无"} | {r["actual_stars"] or "无"}' if r['completed'] else f'计算中 | {r["published_difference"]:.4f} | — | — | {r["published_stars"] or "无"} | —')+' |\n'
report=f'''# 《新型产业政策何以提升企业生产率》复现报告

论文：唐跃桓、黎静霖（2026），《新型产业政策何以提升企业生产率——来自产业链链长制的证据》，《中国工业经济》第9期，第73—95页。

更新：{datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}。{status}

**结论：主要回归系数及所核对附录数值匹配，但两个随机组间检验未复得论文的5%显著性标记。因此属于“主要结果复现、部分推断未复得”，不能表述为整篇所有结果完全一致。**

## 已验证的结果

- 正文表1—5：28个模型、35行核心系数及标准误，全部与论文四位小数一致；对应样本量和R²也全部一致。
- 附录：核对{len(app)}行已公布系数及标准误，对应样本量和R²全部一致。核对范围逐项列于 `output/appendix_comparison.csv`；这不是对所有附录数字的穷尽核对。
- 附表5：23个变量的观测数、均值、样本标准差、最小值、最大值全部与公布精度一致。
- 常规回归程序实际完成181次估计，返回码均为0；包括正文、附录、事件研究及行业分组。三个空间HAC回归另行运行并成功。
- Goodman–Bacon分解：总体系数0.0474526，对应论文0.0475；三类权重及系数均匹配。
- 四类现代DID动态估计已计算并绘图，包括Callaway–Sant’Anna、局部投影、Sun–Abraham、de Chaisemartin–D’Haultfoeuille。论文对这部分仅提供图形，因此不宣称每个动态点与论文数值严格一致。

{table}

基准列(4)的政策系数为0.040032，标准误0.014464，N=23913；可复得论文“生产率提高约4%”的近似表述。这里复现的是作者的估计结果，不等于额外验证了政策外生性或所有识别假设。

## 数据和设定

使用用户提供的全文PDF及压缩包 `20261027095341528WU_FILE_1.zip`。原始文件未经修改，SHA-256见 `original/manifest.json`。

- 上市公司数据：28345行、141变量，4068家企业、279个城市，2014—2023年。
- 延长窗口数据：43193行、18变量，2010—2023年。
- 城市数据：2919行、19变量，2014—2023年。
- 三份数据的面板个体—年份键均无重复；主数据中的政策变量没有从1回到0的处理逆转。

基准模型使用企业固定效应、行业×年份固定效应、省份×年份固定效应，标准误聚类至城市；控制变量、分组条件、年份窗口沿用作者程序。政策冲击同时要求所在城市实施链长制、且企业匹配当地重点产业链，是分期实施的DID。

这是从作者提供的分析数据开始的估计复现。压缩包未提供从CSMAR、企查查、政策文本等原始来源重新清洗、匹配和生成全部分析变量的完整流水线，本次不宣称完成原始数据重建。

## 附录和图形

TWFE事前系数联合检验F(3,256)=0.54，p≈0.6547；未拒绝这些事前系数共同为0，不能据此证明平行趋势成立。

Goodman–Bacon分解结果：

| 比较类型 | 本次系数 | 本次权重 | 论文系数 | 论文权重 |
|---|---:|---:|---:|---:|
| 不同处理时点组 | 0.00355451 | 0.07941133 | 0.0036 | 0.0794 |
| 处理组与从未处理组 | 0.06312786 | 0.90915327 | 0.0631 | 0.9092 |
| 组内成分 | -0.89374447 | 0.01143541 | -0.8937 | 0.0114 |

Bacon分解使用作者的插值、平衡面板及标准TWFE设定，和正文基准的高维固定效应设定不同，因此其0.0475应与附表6对照，不能拿来替代正文0.0400。

![TWFE平行趋势](output/附图4_平行趋势检验.png)

![四种现代DID动态效应](output/modern_did_comparison.png)

四方法图根据本次估计值重绘，保留系数、边际标准误和95%区间，调整了图例及显示布局；绘图仅使用边际方差，不将其用于联合检验。机器可读结果见 `output/modern_coefficients.csv`。

旧版CS的Post_avg为0.047506（SE=0.017426）；跨期估计的Average为0.039554（SE=0.014104）。不同方法的样本、支持范围和聚合权重并不完全相同，不能把这些值直接当成同一估计对象的替换结果。

## 重复抽样检验

九组均按作者设置使用1000次、seed(824)，完整输出保存在各 `output/bootstrap_*.log`。作者程序的 `bdiff` 在此执行费舍尔式随机重分组；其报告的经验p值按该命令的原始公式计算，本次未改为其他双侧检验定义。组0减组1的方向可能与论文按列顺序报告的方向相反，对照时需明确组别。

{boot_table}

{boot_note}

本次附表23“市委书记变更”组p=0.061、附表24“本地政府采购”组p=0.051：均只达到10%，未复得论文的5%显著性标记。表4“产业配套”的未舍入系数差为0.045175，按四位小数为0.0452，与论文0.0451末位不同；论文数字与先将两个组系数分别四舍五入后再相减相符，可能涉及舍入顺序，但未确认其具体来源。

随机检验采用独立模块执行，保留作者模型、1000次及seed(824)。核查发现原始数据已经按企业—年份排列，本次始终使用未改动的分析数据文件，处理状态与批次也逐行一致；但完整软件版本、处理器设置、排序随机状态及整段程序的执行历史未被作者完整锁定。这里将上述差异记录为“本次复现配置下未复得的推断结果”，不将其直接归因为论文错误，也不通过改种子或减少重复次数消除差异。

首次抽样日志的末尾可能出现 `matrix r(p) not found, r(111)`：这是在检验和 `return list` 已完成之后，导出语句把标量p值当成矩阵造成的错误。上表从此前已完整输出的 `r(bdiff)` 和 `r(p)` 恢复；这不是抽样估计失败。交付的重跑脚本已改为导出 `r(P)` 并另存标量，原日志保留。

## 软件兼容和边界

1. 作者注明Stata/MP 18；本机实际运行Stata/MP 19。主要依赖：reghdfe 6.14.1、ftools 2.50.0、ivreg2 4.1.12、ivreghdfe 1.1.2、bdiff 1.04。命令来源、版本和下载文件哈希保存在软件日志及依赖收据中，依赖仅放在本项目目录。
2. 压缩包中的文件名已包含损坏字符。保留原始ZIP，提取后映射为 `listed.dta`、`listed_extended.dta`、`city.dta`、`author.do`、`appendix.pdf`、`usage.pdf`；映射见manifest。
3. 将作者程序的输入输出路径改为本项目相对路径，使用结构化系数导出代替outreg2排版；不改变正文及附录模型设定。作者程序和原始数据保持原样。
4. 当前SSC的csdid 2.0.3（2026-10-30）不能直接接受作者的 `estore()` 语法，且默认面板处理和支持检查与旧版不同。其原样尝试日志 `cs.log` 报告3个ATT(g,t)单元缺失并拒绝聚合。进一步在 `cs_pair.log` 显式设置 `bal(pair)` 后，仍有2018组在2014年的1个单元违反重叠条件，不能直接完成全部单元的聚合。为运行作者原语法，另存[命令作者官方旧版代码](https://github.com/friosavila/csdid_drdid/tree/main/code)中的csdid/drdid 1.71，沿用逐对平衡样本。论文未固定csdid确切版本，因此这部分保留版本与支持范围的不确定性，不能把旧版图形跑通等同于跨版本稳健性验证；未通过静默丢弃失败单元来拼出“成功”的新版结果。
5. 作者使用的旧 `did_multiplegt` 语法现在由 `did_multiplegt_old` 提供。本次仅切换命令入口，保留controls、robust_dynamic、placebo(3)、dynamic(3)、breps(200)、cluster(city)设置；随机区间不要求与原图逐位一致。
6. **附表4的税收调查微观数据未公开**：作者明确仅提供代码；本次跳过该块，不生成替代数据。政策分类表、处理组识别流程图和理论说明属于材料核读，未作为回归复现计数。

## 文件入口与重新运行

- `output/main_comparison.csv`：正文35行逐项对照。
- `output/appendix_comparison.csv`：附录{len(app)}行逐项对照。
- `output/descriptive_comparison.csv`：附表5的115个统计量对照。
- `output/coefficients.csv`：常规回归的全部导出系数及标准误、N、R²、自由度。
- `output/*.ster`：Stata估计结果；`output/*.log`：执行日志；`output/*.png`：重绘图形。
- `author/author.do`：原作者程序；`work/run_*.do`：本次运行程序。

在PowerShell中进入本目录，运行 `./run_all.ps1`。默认运行常规回归、Bacon、LP、SA、旧版CS、空间HAC及审计；加 `-IncludeModernBootstrap` 重跑跨期估计的200次抽样，加 `-IncludePermutationTests` 重跑九组1000次随机检验。抽样部分耗时明显更长。脚本不下载软件、不修改系统ado目录。

验证脚本需要Python和pandas。Stata程序可独立运行；其中 `run_modern_plot.do` 的矩阵来自本次保存结果，若改变数据重新估计，需要先用 `prepare_modern_plot.py` 更新绘图矩阵。

论文与数据引用：唐跃桓、黎静霖（2026），《中国工业经济》第9期，73—95页。数据及程序来自该论文在[《中国工业经济》官网](https://ciejournal.ajcass.com/)公开的附件，本次由用户提供原始下载文件。
'''
(root/'复现报告.md').write_text(report,encoding='utf-8')
# An easy-to-scan copy of every checked headline coefficient.
for title,df,filename in [('正文',main,'正文结果对照.md'),('附录',app,'附录结果对照.md')]:
    out=[f'# {title}结果数值对照','', '| 表 | 列 | 变量 | 论文系数 | 本次系数 | 论文标准误 | 本次标准误 | N | 通过 |','|---|---|---|---:|---:|---:|---:|---:|---|']
    for _,r in df.iterrows():
        passed=all(bool(r[x]) for x in ['b_match','se_match','N_match','R2_match'])
        out.append(f'| {int(r.table)} | {int(r.column)} | {r.term} | {r.published_b:.4f} | {r.replicated_b:.6f} | {r.published_se:.4f} | {r.replicated_se:.6f} | {int(r.replicated_N)} | '+('是' if passed else '否')+' |')
    (root/filename).write_text('\n'.join(out)+'\n',encoding='utf-8')
print(status)
