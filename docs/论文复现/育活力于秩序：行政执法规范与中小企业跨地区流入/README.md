# 项目复现：育活力于秩序

原文、作者附件及完整解压材料位于 `original/`。复现记录和限制见 [`report/replication_status.md`](report/replication_status.md)。

## 状态

作者主数据和 Stata 程序已在附件中。表1基准回归成功复跑，处理批次审计显示7个可识别的处理批次及从未处理组。TWFE、Callaway–Sant’Anna、BJS及动态事件研究已按项目主规格估计；999次联合簇bootstrap已运行，但CSA联合协方差未能生成。作者全部机制、安慰剂、稳健性表格尚未全量重跑，故项目状态不是“全篇完整复现”。

## 目录

- `original/`：论文、附件ZIP、解压材料和作者代码/数据
- `data/analysis.dta`：现代估计输入主样本
- `code/R/`：协议估计代码副本
- `specs/`：主样本和动态设定
- `specs_controls/`：含时变控制的secondary设定
- `output/`：协议估计CSV结果
- `logs/`：作者基准回归及队列审计日志
- `report/`：详细结果、适用范围和未完成项
