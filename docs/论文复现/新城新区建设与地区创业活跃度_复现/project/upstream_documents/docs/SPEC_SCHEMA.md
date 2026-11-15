# 设定（spec）JSON 字段

每个合格设定一个文件：`data/specs/<paper_id>__<spec_id>.json`（主样本）或
`data/specs_controls/<paper_id>__<spec_id>.json`（带随时间变化控制变量的二级样本）。
示例：`data/specs/EXAMPLE__sim_static.json`、`data/specs/EXAMPLE__sim_event.json`。

| 字段 | 必填 | 说明 |
|---|---|---|
| `paper_id` | 是 | 如 `cie123769` |
| `spec_id` | 是 | 论文内唯一，建议 `T3_c1`（表 3 第 1 列）、`F2`（图 2） |
| `journal` | 是 | `cie` |
| `data_path` | 是 | 分析数据路径；可写 `$CIE_RAW/...`，运行时替换为环境变量 `CIE_RAW`（默认 `~/cie_raw`）。支持 `.dta/.csv/.rds/.parquet/.xlsx` |
| `id_var` | 是 | 个体变量（企业代码、城市代码……） |
| `time_var` | 是 | 日历时间（整数，年或连续编号的季度/月份） |
| `y_var` | 是 | 被解释变量 |
| `treat_var` / `gvar` | 二选一 | `treat_var`：0/1 处理变量（吸收态；若关闭，关闭后的期间会被删除）。`gvar`：首次处理期（缺失/0/Inf = 从未处理），与 `time_var` 同单位。**不平衡面板优先用 `gvar`**（真实政策年份）：用 `treat_var` 时，若个体恰好缺失政策当年的观测，首次处理期会被推后到下一个观测年 |
| `weight_var` | 否 | 分析权重，空串表示无 |
| `cluster_var` | 否 | 聚类变量，空串表示按 `id_var` 聚类 |
| `xt_vars` | 否 | 不随时间变化、与时间固定效应交互的特征（如 `["province"]` 表示省份×年份 FE） |
| `controls` | 否 | 随时间变化的控制变量（只用于 `specs_controls/`；主样本必须为空） |
| `sample_filter` | 否 | R `data.table` 表达式，如 `"year >= 2008 & year <= 2019"` |
| `log_y` | 否 | `""` / `"log"` / `"log1p"`（作者在回归中对 y 取对数而数据中未取时使用） |
| `static_or_event` | 是 | `"static"` 或 `"event"` |
| `event_structure` | 事件研究必填 | `{"pre_min": -5, "post_max": 5, "ref": [-1], "ends": "bin"}`。`ends`：`"bin"` 窗口外的相对期合并到端点分箱（CIE 常见写法“−5 期及以前合并为 −5 期”）；`"drop"` 删除窗口外的处理组观测；`"ref"` 窗口外并入参照组 |
| `published_coef` / `published_se` / `published_n` | 否 | 印刷值（无则 `null`）；事件研究可填处理后各期均值或留空 |
| `published_source` | 否 | 如“表 3 第 (1) 列” |
| `table` / `column` | 是 | 位置 |
| `preferred` | 是 | 是否作者偏好（基准）设定 |
| `in_abstract_intro` | 是 | 结论是否出现在摘要或引言 |
| `reports_modern_estimator` | 是 | 论文是否报告 CSA/SA/BJS/did2s/dCDH |
| `software` | 否 | 作者代码语言 |
| `replication_status` | 是 | `exact` / `approximate` / `failed` / `not_run`，加简短说明 |
| `notes` | 否 | 所有偏差与判断 |

## 输出（`output/specs/<paper_id>__<spec_id>.csv`）

静态设定一行；事件研究两行（`window = post` 与 `pre`）。列：

`twfe, twfe_se, csa, csa_se, csa_hullw, bjs, bjs_se`（被解释变量已标准化为回归样本内单位标准差）、`twfe_raw`（原单位 TWFE，
用于与印刷值比较）、`y_sd`、`neg_rows`、`neg_abs`（负权重）、`G_eff_twfe, L_max_twfe, G_eff_bjs, L_max_bjs,
G_eff_csa, L_max_csa`（杠杆筛选）、`n, n_units, n_cohorts, share_never, share_always, unbalanced`、`csa_note, bjs_note`。
