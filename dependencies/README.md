# Stata 依赖与安全安装

本说明对应 `weixiao-work` 的保守整理。现有依赖全部保留：本轮无法完成 SSC 上游逐文件下载及字节比对，不能证明没有本地修改，也不能保证当前上游仍提供同一版本。不要用最新版覆盖已有研究环境。

## 已发现的包

通过现有 `.pkg` 清单识别：csdid、acreg、avar、bacondecomp、bdiff、did_multiplegt、did_multiplegt_dyn、did_multiplegt_old、did_multiplegt_stat、drdid、event_plot、eventstudyinteract、ftools、hdfe、ivreg2、ivreghdfe、moremata、ranktest、reghdfe、require、xtabond2、xtbalance。另有 coefplot、tsvmat、estfe 等文件，归属及修改情况尚待核验，不能只凭文件名删除。

现有包元数据中的 Distribution-Date：csdid 为 20261105、avar 为 20150730、moremata 为 20260111。这些是包清单的分发日期，不是对上游真实性或完整版本一致性的证明。其余包及 `csdid_legacy` 的精确版本仍待逐文件核实。

## 保留的目录

下列五个论文目录的 `dependencies/stata_ado/` 各有 300 个文件：

- 公共数据开放如何提振企业有效投资_筛选与表2核验
- 国家级大数据综合试验区设立与就业增长_复现
- 新城新区建设与地区创业活跃度_复现
- 行政诉讼跨区划管辖与企业社保遵从_复现
- 财政风险补偿与知识产权质押融资_复现

以上均位于 `docs/论文复现/`。另保留 `新型产业政策何以提升企业生产率_复现/output/local_ado/`（299个文件）和 `output/csdid_legacy/`（20个文件）。合计1819个文件、107846664字节。旧 csdid 与当前 csdid 不得混用；运行前用 `which csdid` 和 `adopath` 确认加载路径。

## 安装脚本的用法与边界

从仓库根目录在 Stata 中运行：

```stata
do dependencies/install_stata.do
```

默认只检查命令是否可见，不安装、不改动已有依赖，也不能代替对每篇论文完整运行环境的检查。完整包清单见上文；脚本提供 csdid、drdid、acreg、avar 四个核心包的可选 SSC 安装入口。

如明确需要一个与保留材料隔离的**当前版试验环境**：

```stata
do dependencies/install_stata.do install-current
```

这会尝试通过 Stata 的 SSC 命令将四个核心包安装到根目录下 `.local-stata-ado/`，不使用 replace/force，也不修改论文程序。该目录已被精确忽略。SSC 网站 https://fmwww.bc.edu/repec/bocode/ 本轮访问失败，安装可用性和最新版结果尚未实测；脚本仅作静态审查。此入口不是版本锁定安装，也不承诺与保留版本相同。未安装完整依赖前不得声称复现环境齐备。安装结束后按需在新的 Stata 会话执行 `adopath + "<仓库绝对路径>/.local-stata-ado"`，先检查版本与结果，再决定是否用于研究。

后续迁出 Git 的门槛：核实每个包的权威来源、版本、完整文件列表、逐文件 SHA-256；比对现有副本与上游；确认自定义修补与许可；验证安装恢复。满足后才按精确路径取消跟踪，并为该路径增加忽略规则。当前七个目录未加入忽略规则，避免隐藏仍需保留的研究依赖。
