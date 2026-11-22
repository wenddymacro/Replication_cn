# 《公共数据开放能否拓展资本跨区域流动距离》复现包

论文：蓝发钦、胡晓敏、徐卓琳，2024年第9期，《中国工业经济》。

论文页：[中国工业经济官网](https://ciejournal.ajcass.com/Magazine/Show?id=97310)

## 文件结构

- `original/`：官网论文、原始作者附件压缩包及解压文件。
- `data/`：作者提供的三份 Stata 数据和运行生成的图表、描述统计与安慰剂结果。
- `code/author_original.do`：作者原始复现程序。
- `code/baseline_author.do`：复核表1基准回归的程序。
- `code/run_author_full.do`：运行作者整套程序的封装脚本。
- `logs/`：环境、基准回归、依赖检查、设计审计和作者脚本运行日志。
- `report/replication_status.md`：结果、限制和复现状态。

## 环境

作者代码在 Stata 中运行。当前环境为 Stata/MP 19，作者程序依赖的 `reghdfe`、`sum2docx`、`logout`、`pwcorr_a`、`coefplot`、`dpplot`、`psmatch2` 均已找到。

作者程序使用中文数据文件名。建议将工作目录设为 `data/`，再运行 `../code/author_original.do`。程序会生成作者表格、附录统计、图形和模拟结果。

## 当前完成情况

作者整套 do 文件已运行至末尾，生成正文与附录相关输出。表1含控制变量回归为 0.1897（标准误 0.0439，N=7,435），与作者安慰剂程序所设基准值相符。作者的 `logout` 命令会关闭外层日志，因此 `logs/author_full.log` 在相关性分析处停止记录；Stata 中程序仍继续完成后续代码。完整情况见状态报告。
