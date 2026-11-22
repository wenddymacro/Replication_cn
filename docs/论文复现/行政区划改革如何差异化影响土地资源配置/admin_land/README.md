# 行政区划改革论文复现材料

论文与附件副本位于 `original/`，作者附件解压后位于 `original/extracted/`。完整工作记录、当前数值和未完成项见 [`report/replication_status.md`](report/replication_status.md)。

## 当前状态

目前只能认定为公开随机4%样本的部分复现。作者程序已重估主要表格，但执行在安慰剂及城市层面脚本中报错；Oster 稳健性程序缺 `psacalc2`。TWFE、BJS和自定义CSA点估计已运行；CSA标准误和项目要求的999次联合簇贝叶斯bootstrap仍未完成。由于原文全样本与数据均受限，无法声称数值完全复现原文。

## 文件结构

- `original/`：用户提供的原文、附件及解压内容
- `work/author_run/`：作者程序副本、运行日志、RTF结果、中间Stata文件
- `data/`：按作者基准筛选条件生成的公开样本分析文件
- `code/R/`：项目协议的现代DID估计器副本和单规格运行脚本
- `output/`：协议估计结果
- `logs/`：R运行日志
- `report/replication_status.md`：复现与偏差说明
