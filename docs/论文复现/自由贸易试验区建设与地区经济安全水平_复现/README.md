# 自由贸易试验区建设与地区经济安全水平

齐文浩、宋长兴、蔡宏波，《中国工业经济》2024 年第 3 期，119–137 页。

**当前状态：正文重估及诊断已运行，严格全流程验收未通过。** 15 个正文设定（1 主样本、14 含控制二级样本）的 TWFE/CSA/BJS 估计和标准误均已得到，各运行 999 次联合自助法；28 个原文/附录静态回归、事件路径及 500 次安慰剂已运行。尚未解释的原文差异和上游协议实现缺口见 [复现报告](复现报告.md) 与 `status.json`，不标记全部完成。

采用老师 Replication_cn 项目协议；冻结的 R 核心文件保持原样，SHA256 见 `logs/upstream_code_hashes.json`。原文数值核对、所有适用估计与诊断、报告及归档结束前，不标记完成。

## 文件与复跑步骤

- `original/`：官网附件原件、完整解压文件及 SHA256 清单。原始文件不改写。
- `prepare.py`：ZIP CRC 检查、安全解压、代码文本转码。
- `audit_data.py`、`inspect_sources.py`、`treatment_audit.py`：字段、样本和政策时点审计。
- `build_author.py`、`work/replicate_body.do`：原作者回归的独立运行副本。正文15列、附录13个静态回归及事件路径；位置对应见 `data/published_comparison.csv`。
- `data/author_results.csv`、`logs/author_models.log`：系数、标准误、t 值、N 和拟合统计量。
- `work/ancillary.do`：附件的前置因素模型与 500 次安慰剂检验。安慰剂在独立运行时指定种子 12345；原程序未在该部分指定独立种子，因此不声称随机图逐点一致。
- `build_specs.py`：准备现代估计输入及 JSON。尚未核对原文时发表值留空，不用作者数据的估计结果冒充发表值。
- `launch.ps1`：在 ASCII 运行目录开启四个后台 R 队列，每个静态设定 999 次联合贝叶斯自助法。
- `collect.ps1`：收集现代估计输出及日志。
- `verify_published.py`：录入原文基准并逐项核对；括号为t值，不冒充SE。收集输出后运行，补齐发表值元数据。
- `project/diagnostics.R`：样本计数、CSA逐格支持、老师的汇总分析及环境版本。
- `project/appendix_event_audit.R`、`balanced_sensitivity.R`：显式标注的补充诊断，不替换作者模型及正文主样本。
- `entropy_audit.py`：原始指标缺失及完整案例敏感性，不声称重建作者指数。
- `make_figures.py`、`finish_report.py`、`validate_data.py`：结果图、报告、数据与源文件一致性核验。

Stata 运行目录为 `work/`。R 工作目录为 `project/`；设置 `R_LIBS_USER`、`CIE_RAW` 和 `OUT_DIR` 后运行 `Rscript --vanilla run_one.R <spec.json> 999`。具体本机路径见 `launch.ps1`。

## 已确认的数据事项

分析数据含 258 个城市、2008–2019 年的 3096 条城市年份记录，以及 1 行无 id/年份的额外记录（作者回归自动排除）。Piolt 是二元吸收态变量，采纳年份为 2013、2015、2017、2018、2019。完整面板可恢复首次处理期，且与所有非缺失 action 一致。南京最后一年 action 缺失；大连 action 全部缺失。恢复处理年份在独立输入列 g_recovered 保存，原始文件不变。Treat 在南宁、崇左、苏州随时间变化，不能直接当成稳定处理组标记。

附件代码存在直接运行问题：城市编码和原 id 重命名冲突；安慰剂部分 clear 后继续运行异质性分析会缺数据；部分变量名使用 Stata 缩写。运行副本按模型分开加载同一原始数据，保留估计式、样本限制及聚类。系数按四位小数截断能恢复正文打印值；通常四舍五入有最后一位差异。表5第3列R²与附表2 Probit结果仍不一致，已保留原始估计，不静默修改。

## 引用及来源

数据及程序来自齐文浩等（2024）在《中国工业经济》官网公开的附件。

- PDF：https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/4//20240418011710WU_FILE_0.pdf
- ZIP：https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/4//20240418011708WU_FILE_1.zip
- 老师协议：https://github.com/wenddymacro/Replication_cn

2026-11-15 使用已验证 Edge 会话；ZIP 下载成功并通过 CRC。用户按 Escape 停止浏览器自动化后提供桌面 PDF，已复制并验证可读取19页。未读取 HTTP 响应头，不编造状态码。
