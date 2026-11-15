# 复现说明（逐篇；供人工或 LLM 智能体使用）

目标：对一篇已筛入的论文，从附件复现已发表的 TWFE 估计，并为每个合格设定写一个 spec JSON，
供 `code/R/run_spec.R` 用 TWFE、CSA 与 BJS 重估。

## 输入
- 筛选记录：`data/screening/by_paper/<paper_id>.json`
- 附件：`$CIE_RAW/packages/<paper_id>/_extracted/`（只读，**不得修改作者文件**）
- 回归命令摘录：`data/packages/<paper_id>_regressions.txt`
- 全文：`data/text/cie/<paper_id>.txt`

## 步骤
1. 读附件说明（`README`、`说明.txt`、`readme.docx` 等），找到 (a) 合格回归所用的分析数据，(b) 生成对应表列的代码。
2. 若附件含分析数据（`.dta/.csv/.xlsx/.rds`）直接使用；若只有原始数据与构造代码，先运行构造代码生成分析数据。
   需要修改时复制到 `$CIE_RAW/_work/<paper_id>/` 后再改，并在复现日志中写明。
   - Stata 代码常见命令：`reghdfe y did $controls, absorb(id year) vce(cluster city)`、`xtreg ... fe`、
     `areg ... absorb()`、`coefplot` 画平行趋势图。中文变量标签与 GBK 编码：`haven::read_dta(encoding = "GBK")`
     （`run_spec.R` 会在 UTF-8 读取失败时自动重试 GBK）。
   - 若数据来自付费数据库且附件未提供，记 `package_status = "code_only"`，不重估。
3. 复现 TWFE：运行作者回归或等价的 `fixest::feols`，与印刷值比较，记录 精确 / 近似（同号且 10% 内）/ 失败。
4. 识别面板结构：个体 id、日历时间、首次处理期（或可由其推出的 0/1 处理变量）、权重、聚类变量、
   与时间交互的不随时间变化特征（如省份×年份 FE 中的省份）。确认至少两个采纳 cohort、处理是吸收态
   （若会关闭，`run_spec.R` 会删除关闭后的期间）。
5. 每个合格设定写一个 JSON 到 `data/specs/<paper_id>__<spec_id>.json`（字段见 `docs/SPEC_SCHEMA.md`）。
   带随时间变化控制变量的设定写到 `data/specs_controls/`，并填 `controls` 字段。
   不要“编造”作者没有报告过的无控制变量设定。
6. 运行 `Rscript code/R/run_spec.R data/specs/<paper_id>__<spec_id>.json`，检查 `output/specs/` 中的结果。
   把 `twfe_raw`（原始单位的 TWFE）与印刷值比较；若差异超过四舍五入，先排查样本与固定效应定义。
7. 写复现日志 `data/replication_logs/<paper_id>.md`：运行了什么、与作者设定的偏差、spec_id 与表列的对应。

## 约束
不修改附件中的作者文件；每篇工作自成一体；失败如实记录。
