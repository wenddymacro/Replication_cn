# 从这里开始

先读复现报告.md和研究裁定.md。

已核对正文30个静态模型、32个印刷系数全部匹配；已重估30个正文协议设定，其中29个静态设定各999次联合自助。事件路径按上游解析推断。

原样本CSA存在时变城市聚类限制，不能称全部估计成功。稳定城市敏感性分析单列，不混入正式计数。现代结果、具体失败、样本变化和结论以报告及data/modern_results.csv为准。

偏好含控制模型BJS保持正向但5%不显著。表2两列CSA异常大，已核查并保留原始结果；不平衡面板协变量处理存在上游文字／代码差异，详见报告，不据此宣称三方法全面稳健。

主要文件：data/published_comparison.csv（作者核对）、data/modern_results.csv（正式现代结果）、data/stable_city_sensitivity.csv（补充分析）、project/output/tables/comparison_summary.csv（上游汇总）、original/（原件）、logs/（过程与版本）。

materials/按论文、原始数据、作者代码、附录、说明分类；处理数据在data/。这里“原始数据”指作者公开附件原件，不是底层商业数据库。来源及获取方式见logs/sources.json，分类副本SHA256见materials/manifest.json。

rerun_modern.ps1可重跑。附录安慰剂/匹配及机器学习模型未全部独立重跑，未宣称全篇所有分析均已完成。
