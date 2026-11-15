# 按老师项目重估

请先看[按老师项目重估报告](按老师项目重估报告.md)和[全部设定结果](全部设定结果.md)。这是作者原结果复现之后的独立第二阶段。

共1个正文主样本、20个带控制变量二级样本；每个静态设定联合自助法999次。CSA按协议和实际估计结果记录类别超限、估计失败，未填造结果。主样本三种估计均已得到数值，杠杆筛选通过。详细判断、有效样本差异和代码自身的实现限制见报告。

- `project/data/screening/by_paper/`：论文和逐列筛选记录。
- `project/data/specs/`、`specs_controls/`：1+20个真实论文设定；EXAMPLE文件仅为上游测试样例，不计入分析。
- `project/output/`：正式999次结果、估计量对照、漏斗表、汇总图。
- `data/analysis.csv`、`data/sample_flags.csv`：原数据工作副本与作者实际回归样本标记。
- `logs/`：正式运行、仓库测试、软件版本、源代码锁定记录。
- `upstream/`：上游原文件。估计程序仅补充CSA被跳过时的NA字段；另有`analysis_protocol.R`修复混用边际SE与自助协方差导致的差异方差问题，点估计不变，原脚本与原汇总保留。
- `validation_rerun/`：独立验证交付脚本的结果，联合自助次数为0；它不是正式999次结果，不应混入汇总。

在PowerShell中运行 `./run_protocol.ps1` 可重新计算，默认999次。脚本使用本机已安装的独立R环境，必要时通过 `-RscriptPath` 和 `-RLibrary` 指定自己的R与包库。依赖：data.table、jsonlite、haven、fixest、did、did2s。会在ASCII临时目录计算，避免Windows中文路径问题；结果另存 `rerun_results/`，不覆盖本次冻结报告。

本次只有一篇论文，不能把漏斗中的1篇和单篇结果解释为全刊筛选或文献总体结论。
