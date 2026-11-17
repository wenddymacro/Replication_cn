# 现代双重差分估计量会改变中文期刊的已发表结论吗？——《中国工业经济》复现项目

本项目参照 Proserpio (2026)《Do Modern Difference-in-Differences Estimators Change Published Findings in
Business Research?》（代码：https://github.com/dadepro/modern-did）以及该文所沿用的 Hull (2026) 协议，
对**中文经济学期刊**中已发表的交错（多期、渐进）双重差分设定，用三种估计量重新估计并比较：

- 双向固定效应 **TWFE**（作者原设定）；
- **Callaway & Sant'Anna (2021)** DiD 平均估计量；
- **Borusyak, Jaravel & Spiess (2024)** 插补估计量（以 Gardner 两阶段 `did2s` 计算标准误）。

第一阶段只做 **《中国工业经济》**：该刊官网随文公开“数据与代码”附件，是中文期刊中最接近
*Management Science*/*Marketing Science* 公开复现档案的来源。

> 历史状态（2026-11-09，当前进度见下文）：v0.1 框架。协议、筛选与复现说明、数据整理脚本、R 估计代码与汇总分析都已就绪，并已在模拟数据上
> 跑通。**真实论文的框架、全文与附件尚未下载**：官网有 WAF 人机验证，需要在浏览器里手动保存（`docs/DOWNLOAD.md`）。

## 与原项目的差异

| | Proserpio (2026) | 本项目 |
|---|---|---|
| 期刊 | Management Science、Marketing Science 等 | 中国工业经济（之后加入其他中文期刊） |
| 框架来源 | OpenAlex + INFORMS 全文检索 | CIE 官网目录页（手动保存）/ 知网题录 |
| 关键词 | difference-in-differences, staggered, Callaway… | 双重差分、多期/多时点/渐进/交错 DID、事件研究、平行趋势、csdid、did_imputation… |
| 附件语言 | Stata 30 篇、R 8 篇 | 预计绝大多数为 Stata |
| 主要障碍 | 合成/脱敏数据 | 几乎每列都有**随时间变化的控制变量**（按 Hull 规则不合格），以及 CSMAR/Wind 等付费数据未随附件公开 |

因为控制变量这一点，**带控制变量的二级样本**（PROTOCOL 第 5 节）在本项目中和主样本同样重要。

## 目录

```
docs/
  PROTOCOL.md        协议：框架、候选、合格性规则、估计、分析，以及按时间追加的裁定日志
  DOWNLOAD.md        如何从 CIE 官网手动获取目录、全文与附件
  SCREENING.md       逐篇筛选说明（人工或 LLM 智能体）
  REPLICATION.md     逐篇复现说明
  SPEC_SCHEMA.md     设定 JSON 字段与输出列
code/
  01_build_frame.py        解析保存的目录页/文章页（及可选的知网题录）→ data/frame/frame.csv
  02_pdf_to_text.py        PDF → 文本（pdftotext）
  03_candidates.py         中英文关键词与代码信号 → 候选与 Tier
  04_package_intake.py     附件解压（GBK 文件名）、文件清单、回归命令摘录、现代估计量命令识别
  05_screening_summary.py  汇总筛选记录，生成漏斗表
  R/estimators.R           TWFE、CSA、BJS、杠杆筛选、负权重、联合贝叶斯自助法
  R/run_spec.R             逐设定重估
  R/analysis.R             汇总比较：相关系数、反号比例、显著反号、标准误之比、散点图
  R/simulate_example.R     模拟交错面板（测试用）
  R/test_estimators.R      估计量的正确性检查
data/
  frame/ candidates/ hits/ packages/   脚本生成
  screening/by_paper/                  每篇一个筛选 JSON（模板 data/screening/TEMPLATE.json）
  specs/ specs_controls/               每个设定一个 JSON（EXAMPLE__* 为模拟示例）
  replication_logs/                    每篇复现日志
  example/sim_panel.csv                模拟数据
output/                                重估结果、表格、图
```

早期框架使用 `data/text/` 和 `$CIE_RAW`（默认 `~/cie_raw`）管理外部材料；当前分支另在 `docs/论文复现/` 保留逐篇附件、作者代码和复现成果。论文 PDF 不再全局忽略；添加任何材料前仍须核实来源和公开共享权限。

## 流程

```bash
# 0. 依赖：Python 3（仅标准库）、poppler-utils（pdftotext）、可选 7z/unar（解 rar）
#    R ≥ 4.3：data.table, jsonlite, haven, fixest, did, did2s（读 xlsx/parquet 另需 readxl/arrow）
#    测试环境：R 4.3.3、fixest 0.14.2、did 2.5.1、did2s（R 4.3 下其依赖 CVXR 需装存档版 1.0-15，系统需 libglpk-dev）
export CIE_RAW=~/cie_raw          # 手动保存的页面、PDF、附件所在目录（docs/DOWNLOAD.md）

python3 code/01_build_frame.py
python3 code/02_pdf_to_text.py
python3 code/04_package_intake.py
python3 code/03_candidates.py     # 在 04 之后运行，可用到附件代码信号
# 筛选：按 docs/SCREENING.md 为每篇候选写 data/screening/by_paper/<paper_id>.json
# 复现：按 docs/REPLICATION.md 为每个合格设定写 data/specs/<paper_id>__<spec_id>.json
Rscript code/R/run_spec.R data/specs/<paper_id>__<spec_id>.json 999   # 999 = 自助法次数（静态设定）
Rscript code/R/analysis.R
python3 code/05_screening_summary.py
```

用模拟数据检查环境：

```bash
Rscript code/R/simulate_example.R
Rscript code/R/test_estimators.R
for s in data/specs/EXAMPLE__*.json data/specs_controls/EXAMPLE__*.json; do Rscript code/R/run_spec.R $s; done
INCLUDE_EXAMPLE=1 Rscript code/R/analysis.R
```

## 下一步

1. 核实 CIE 数据与代码公开政策的生效期，确定窗口与截止日（写入 PROTOCOL 第 7 节）。
2. 手动保存窗口内各期目录页与文章页 → 建框架；下载候选论文全文与附件。
3. 筛选（可以分批交给 LLM 智能体，按 `docs/SCREENING.md`），每个判断都写进 JSON 与裁定日志。
4. 复现与重估；汇总。
5. 扩展到《经济研究》《管理世界》等期刊（需先审计它们的数据公开情况）。

## weixiao-work 材料管理与当前进度（2026-11-17）

本分支的逐篇工作在 `docs/论文复现/`，包括原作者材料、筛选与核验记录、自写程序、回归输出及报告；不修改 main 或其他成员分支。上文早期框架状态是历史记录，不代表这些材料尚未收集。

- 公共数据开放：现有 README 记录表2作者结果核对，现代重估尚未完成。
- 国际标准对接：现有 README 记录资料核验与筛选，不纳入交错 DID 重估。
- 跨境电商：现有附件只有代码、作者日志与附录，缺研究数据，尚不能独立复现。
- 新型产业政策、新城新区、大数据试验区、行政诉讼、财政风险补偿：各自保存阶段性复现材料；具体完成范围、失败项、NA、抽样次数与偏离，以各目录 README、复现报告和研究裁定为准。本次文件整理没有重跑回归，也不新增任何已完成的实证结论。

### 数据来源与引用

使用逐篇目录中的来源记录、下载日志、原始文件校验和及编辑部说明定位论文与附件；缺失 URL 不按文件名猜测。作者分析数据不等同于底层原始数据库，作者日志不等同于本项目独立运行结果。引用论文及期刊官网附件出处；可下载不自动表示获准 GitHub 再分发，商业数据库或权限不明材料须人工确认。本轮未自动处理这类附件。

### 环境与复现入口

Stata 依赖清单及隔离安装入口见 [dependencies/README.md](dependencies/README.md)。保留七个已有依赖目录和旧版兼容文件，当前安装脚本不能替代精确版本恢复。部分项目说明使用 Stata/MP 19；R/Python 依赖沿用上文，并以逐篇记录的实际环境为准。

先读每篇 README/报告，取得合法数据并配置本机路径，再按原有 `run_all.ps1`、`rerun_modern.ps1` 或该篇报告指定入口运行；仅在工作副本适配路径，保留作者原程序。先核对作者模型和样本，再按协议进行 TWFE/CSA/BJS；保存随机种子、bootstrap 次数、日志与失败说明。不得把未运行、缺数据或失败的设定写成成功复现。

### 文件保留规则

Office `~$` 锁文件不入库；不能只凭文件名删除正式文档。已核验本轮基线没有这种文件，旧临时清单已删除，无需重复删除。论文、作者程序、原始附件、研究数据、研究代码、筛选/审计记录及结果全部保留；不能整体清空 work、logs 或 output。新本地安装目录 `.local-stata-ado/` 精确忽略，现有来源或修改状态不明的依赖继续跟踪。ZIP 仅在 SHA-256 完全一致、保留副本可用、引用和权限均明确后才能另行清理；本轮21个ZIP全部保留。

当前提交树没有独立 PDF 文件；部分 ZIP 内有 PDF，不能认定全部论文正文已有仓库备份。核实原件与共享许可后再添加，不能从桌面自动搬移、覆盖或删除材料。