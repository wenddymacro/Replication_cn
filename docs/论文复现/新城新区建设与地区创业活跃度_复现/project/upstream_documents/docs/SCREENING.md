# 筛选说明（逐篇；供人工或 LLM 智能体使用）

输入：一篇候选论文的全文（`data/text/cie/<paper_id>.txt`），以及附件清单与回归命令
（`data/packages/<paper_id>_inventory.json`、`<paper_id>_regressions.txt`，如有）。
输出：一个 JSON 记录，写入 `data/screening/by_paper/<paper_id>.json`。模板见
`data/screening/TEMPLATE.json`。规则以 `docs/PROTOCOL.md` 第 3 节为准，有疑问时把判断写进 `notes`，
需要统一裁定的写进 `PROTOCOL.md` 第 7 节。

## 第 1 步：论文层面

1. 论文是否估计了个体在**不同日历时点**采纳二元处理的 DiD 或事件研究（至少两个采纳 cohort）？
   - 典型：分批试点（低碳城市、智慧城市、“宽带中国”、自贸区、大数据综合试验区、数字经济示范区……）、
     分年设立的开发区/高新区、分批纳入的名单（“专精特新”、绿色工厂）、企业不同年份的首次事件（上市、并购、
     数字化转型首次披露……）。
   - 只有一个政策时点（如 2015 年统一实施）的两组 DiD 不是交错设计：`eligible_design = false`，`notes` 写“单一时点”。
2. 报告了哪些估计量？（静态 TWFE、TWFE 事件研究、CSA、Sun-Abraham、BJS/did_imputation、de Chaisemartin-
   D'Haultfœuille、堆叠 DiD、Gardner did2s、PSM-DID、合成控制、其他）。
3. 交错设计是主识别策略还是稳健性检验？
4. 数据：公开统计年鉴、CSMAR/Wind/CNRDS 等付费数据库、工业企业数据库、海关数据、专利数据、手工整理。
   附件是否包含所需的分析数据？
5. 附件代码语言（Stata / R / Python / MATLAB / 其他）。

## 第 2 步：设定层面

对正文中**每一个**满足 PROTOCOL 第 3 节的设定记录一条（字段见 `docs/SPEC_SCHEMA.md` 的筛选部分）。
不论系数符号、大小、显著性都要记。

逐列核对（CIE 的基准回归表通常是“(1) 无控制 (2) 加控制 (3) 加更多固定效应 …”）：
- 有随时间变化的控制变量 → 不合格；若这是唯一违反项，记入 `near_miss_controls_only_specs`；
- 有“省份×年份”“行业×年份”固定效应 → 合格（特征对个体固定）；
- 有“城市×时间趋势”、个体线性趋势 → 不合格；
- 平行趋势图/表（事件研究）：记录分箱（如 ≤−5 合并、≥5 合并）、基期（−1 或首期）、是否含控制变量；
- PSM-DID：在匹配后样本上跑 TWFE 合格；用匹配权重不合格；
- 附录中的设定只列在 `appendix_specs` 中。

## 第 3 步：汇总标记

`eligible_design`、`near_miss`、`near_miss_controls_only`、`n_eligible_specs`、`reports_modern_estimator`、
`main_or_robustness`、`data_access`（public / partial / proprietary / none）、`package_status`
（data_and_code / code_only / none / synthetic）、`priority`（1 = 合格且附件含数据；2 = 合格但数据存疑；3 = 不合格）。
