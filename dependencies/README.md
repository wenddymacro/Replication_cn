# Stata 依赖：仓库外安装与精确恢复

## 2026-11-17 实际整理

按老师“原文、附件代码和我们的成果保留，ado不用放进GitHub”的要求，从 Git 跟踪移除 **1704个已核验的第三方依赖文件，共101896080字节（97.18 MiB）**。只操作独立克隆的 weixiao-work，不改作者代码，不合并分支。

这些文件覆盖 csdid、acreg、avar、drdid、ftools、moremata、ivreg2、ranktest、hdfe、xtabond2、xtbalance、事件研究与多期DID等包的已匹配部分。570个与SSC原始字节及SHA-256完全相同，1134个只存在CRLF/LF换行差异；未忽略其他字符差异。SSC来源及逐文件校验和见 migration-manifest.json。官方来源为 http://fmwww.bc.edu/repec/bocode/（HTTPS连接本轮失败，HTTP官方分发可访问）；原字节备份与上游比对独立记录。

并非按包名一刀切：仍保留 **115个原有文件**，包括完整 csdid_legacy（20个）、版本不同或来源未确认的文件，以及 receipts.json、chain_dependency_receipts.json 等审计记录。例如现有 reghdfe 主程序标注6.14.1，SSC本轮主程序为6.13.1，故保留现有主程序。coefplot、bdiff_fast 等未完成同源比对，也保留。保留项不是“已确定冗余”，不得自动删除。

根README与项目README中的研究结论保持原样。Office临时清单已在历史提交删除，本轮未发现仍跟踪的~$文件。15个论文附件ZIP、所有研究数据与作者程序、报告、筛选/审计记录均保留；仅迁出6个已匹配上游的moremata.zip软件分发副本。

## 本地副本及完整备份

取消跟踪使用 git rm --cached，独立克隆里仍保留原来的本地依赖文件与路径。六个依赖目录各增加按文件名精确列出的.gitignore，仅忽略已验证迁出的文件，不忽略整个目录或所有.ado/.do/.dta/.zip/.pdf。115个保留文件继续跟踪。

仓库外完整备份名：Stata依赖完整备份_6c8be74.zip。它包含整理前全部1819个依赖文件，逐成员SHA-256已验证，包括旧版本与审计记录。备份交付在本次Codex聊天的outputs目录，**不会提交到Git**。务必另行妥善保存备份；不要搬动或覆盖桌面原始材料。

## 运行复现之前：先精确恢复依赖

**新克隆不能仅凭保留下来的少数依赖直接运行。** 需先恢复完整依赖集合，避免主程序与组件版本混用。现有独立克隆的本地集合已保留。

在独立weixiao-work仓库中用PowerShell运行：

```powershell
./dependencies/restore_stata.ps1 -ArchivePath '完整备份ZIP的绝对路径'
```

恢复脚本使用migration-manifest.json记录的全部路径、大小与SHA-256，先校验全部成员和现存文件，再只写入缺失文件；现存文件不同则停止，不覆盖。不会写到仓库外，也不会删除文件。备份不包含Stata本体；Stata版本以逐篇报告为准（部分项目记录Stata/MP 19）。

恢复完成后照每篇原有README配置路径、检查which csdid与adopath，运行对应入口。不要改作者原件。csdid_legacy与当前csdid的加载优先级沿用原研究脚本，不能用新版本替换旧版。

## 当前SSC版可选安装

```stata
do dependencies/install_stata.do
```

默认只检查22个包的主命令，不安装。显式加 install-current 才向被忽略的.local-stata-ado安装当前SSC版本；不使用force/replace。这是独立试验环境，**不是精确复现恢复**；版本可能与保留的reghdfe、ivreghdfe、require等不同，不得混入原项目路径。精确复现优先使用外部备份恢复。

本轮仅对安装脚本静态检查，没有运行Stata、安装包或重跑回归。恢复脚本已解析检查并在本地完整依赖集合上校验，未改作者文件。

## 可追溯记录

migration-manifest.json按唯一文件内容和名称分组，记录7个目录、1819个原路径、原字节数/Git blob/SHA-256、上游URL和处理理由；不是大体积依赖本体。外部交付另含逐文件处理清单。原始包元数据示例：csdid分发日期20261105、avar 20150730、moremata 20260111；这些日期不能代替内容校验。Git历史未改写，因此旧历史仍包含依赖，本次减少的是当前版本跟踪内容，不保证历史克隆体积立即下降。