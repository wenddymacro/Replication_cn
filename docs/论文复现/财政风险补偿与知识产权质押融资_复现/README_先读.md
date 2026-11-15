# 这篇论文的复现文件

先阅读[复现报告](复现报告.md)，再看[研究裁定与执行说明](研究裁定与执行说明.md)。

正文28个作者模型、42个报告系数均精确匹配；按老师项目划分为2个主样本设定、10个控制变量二级样本设定，均完成999次联合自助。CSA可用10列、依规则跳过2列，BJS可用12列。

基准正向效应保持；表4四项风险容忍度机制在CSA下不再达到5%显著水平，BJS下仍显著。不能把方向一致理解为全部结论稳健。

重点文件：

- data/all_body_comparison.csv：正文作者模型核对，包含系数、标准误、样本量和匹配标记。
- data/modern_results.csv：12个设定的TWFE、CSA、BJS结果、标准误、原单位结果及诊断。
- project/output/tables/comparison_summary.csv：上游原版汇总。
- project/output/figures/：上游散点图。
- project/data/specs/、specs_controls/：逐列设定。
- original/：原始PDF、ZIP和附件。

重跑现代估计：在PowerShell运行本目录的 `./rerun_modern.ps1`。默认使用本机已安装的R和包库，其他机器用参数 `-RscriptPath`、`-RLibrary` 指定路径。每次输出到新的临时目录，不覆盖本次正式结果。

重跑作者正文模型：以本目录的work为Stata工作目录，执行 `do replicate_body.do`。所需Stata扩展程序已附在dependencies/stata_ado。它只运行正文28个模型，不代表附录匹配、安慰剂和全部图形均已重跑。

这是单篇试跑，不是全刊任务完成报告。数据和程序源自王姝勋、杜鹏程、李威（2026），使用时应引用论文及《中国工业经济》官网附件。
