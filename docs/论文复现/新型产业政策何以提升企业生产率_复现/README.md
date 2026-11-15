# 从这里开始

先看 [复现报告](复现报告.md)，再看 [正文对照](正文结果对照.md) 和 [附录对照](附录结果对照.md)。报告会明确区分数值匹配、图形复现、重复抽样结果及未公开数据造成的限制。

- `original/`：用户提供的全文PDF、ZIP原件及哈希。
- `author/`：附件原始内容，文件名映射为可读的英文名，数据和作者程序内容未改。
- `work/`：本次适配的Stata程序、数值核验及报告生成脚本。
- `output/`：回归结果、系数对照、日志、图形与本地软件依赖。
- `pages/`：核读论文表格和附录时生成的页面图片。

本机为Stata/MP 19。进入本文件夹，在PowerShell运行 `./run_all.ps1`；若Stata安装路径不同，使用 `-StataPath` 指定。较耗时的随机检验需显式加 `-IncludePermutationTests`，跨期DID的200次抽样需加 `-IncludeModernBootstrap`。每项也可以在Stata中先将工作目录切换到 `work` 后，单独运行对应的 `run_*.do`。

常规数值核验：依次运行 `work/verify_results.py`、`work/verify_appendix.py`、`work/describe_data.py`。依赖Python、pandas；读取原文另需pypdf，渲染另需pypdfium2。已生成的CSV、Markdown和PNG可以直接阅读。

不要将本次从作者分析数据出发的估计复现表述成从原始数据库开始的数据重建。附表4税收调查数据未提供，不能复现。论文和官网附件的引用方式见报告及 `author/usage.pdf`。

## 按老师项目完成的第二阶段

统一重估现已完成，请查看 [按老师项目重估/按老师项目重估报告.md](按老师项目重估/按老师项目重估报告.md)。此前复现报告保留为作者原结果核对，不能与统一重估混称。

