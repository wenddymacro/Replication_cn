# 专利无效审查与技术交易：复现包

论文：龙小宁、李季、乔永忠，《创新质量信号、权利稳定性与技术交易——来自专利无效宣告审查决定的经验证据》，《中国工业经济》2025年第7期。

作者提供的论文、ZIP 附件、附录 PDF、数据说明、Stata 数据和程序均已整理。作者原始 `.do` 保留未改；`code/author_runnable.do` 只调整工作路径。

## 复现结果

- 作者完整程序在 Stata/MP 19 中运行至结束，涵盖正文回归、IV、机制/异质性、五组各 500 次分组 bootstrap、500 次 placebo、稳健性及 PPML。
- 表2三列系数为 0.0054929、0.0055752、0.0052146；N 均为 83,036，与论文报告的 0.0055、0.0056、0.0052 一致。
- 现代 DID 补充估计包括 Callaway–Sant’Anna 999 次 multiplier bootstrap、BJS 插补估计、Gardner 两阶段 DID，以及修正处理批次变量后的 Sun–Abraham 事件研究。
- 不同现代估计器结果不完全一致。特别是 BJS 多个前置期显著；C&S 在 −6 至 +6 窗口的处理后平均效应不显著。解读见 [复现报告](report/replication_status.md)。

## 文件夹

- `original/`：论文、作者 ZIP、附录与数据说明。
- `data/author_data.dta`：作者分析数据。
- `code/`：原始程序、路径修正副本、作者全套运行入口、现代 DID 和结果汇总脚本。
- `logs/`：作者及现代 DID 完整运行日志。
- `output/`：事件研究图、事件期汇总数据和 Stata 估计文件。
- `report/replication_status.md`：方法、结果、运行差异与限制。

## 运行入口

作者全套程序：`code/run_author.do`。现代 DID：`code/modern_did.do`。C&S 999 次 bootstrap 及 −6 至 +6 事件窗口：`code/csdid_window.do`。Stata 扩展安装记录：`logs/install_dependencies.log`。
