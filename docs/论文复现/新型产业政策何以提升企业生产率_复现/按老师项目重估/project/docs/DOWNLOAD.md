# 获取 CIE 目录、全文与附件

《中国工业经济》官网（https://ciejournal.ajcass.com）有 WAF 人机验证。本项目**不自动抓取、也不绕过验证**，
所有页面和文件都在浏览器里正常访问后手动保存。脚本只解析本地文件。请遵守官网的使用条款；全文 PDF 与附件
受版权保护，**不提交到本仓库**（`.gitignore` 已排除 `raw/`）。

## 目录结构（本地，不入库）

默认根目录为 `~/cie_raw`，可用环境变量 `CIE_RAW` 改到别处：

```
~/cie_raw/
  issues/      各期目录页，文件名 YYYY_NN.html（如 2025_03.html）
  articles/    文章详情页，文件名 <官网id>.html（如 123769.html）
  pdf/         全文 PDF，文件名 <paper_id>.pdf（如 cie123769.pdf）
  packages/    附件（数据与代码），每篇一个目录 <paper_id>/，压缩包原样放入，脚本会解压到 _extracted/
```

## 步骤

1. **各期目录**：打开 `https://ciejournal.ajcass.com/Magazine/GetIssueContentList?Year=2025&Issue=3`
   （改 Year、Issue），浏览器“另存为 → 网页，仅 HTML”，存到 `issues/2025_03.html`。逐期重复。
2. **文章页**：目录页里每篇文章链接为 `/Magazine/Show?id=NNN`，打开后另存为 `articles/NNN.html`。
   文章页通常含摘要、关键词、PDF 下载与“附件/数据与代码”下载链接。
3. **全文与附件**：在文章页下载 PDF 存为 `pdf/cieNNN.pdf`；下载附件存到 `packages/cieNNN/`。
4. 运行：
   ```
   python3 code/01_build_frame.py          # 解析 issues/ 与 articles/ → data/frame/frame.csv
   python3 code/02_pdf_to_text.py          # pdf/ → data/text/（不入库）
   python3 code/03_candidates.py           # 关键词分层 → data/candidates/candidates.csv
   python3 code/04_package_intake.py       # 附件清单与回归命令 → data/packages/
   ```

建议先按年份分批（例如先做 2020–2025），只下载候选论文的 PDF 与附件：步骤 1–2 建框架，
用摘要信号（Tier 3）和题名初筛后，再下载候选的 PDF 与附件。

## 备选：知网题录

若官网目录不便，可从知网导出题录，整理为 `data/frame/frame_manual.csv`，列为：

```
paper_id,year,issue,seq,title,authors,abstract,keywords,site_id,pages
```

`01_build_frame.py` 会把它与官网解析结果合并（以 `site_id` 或 年-期-题名 匹配）。
