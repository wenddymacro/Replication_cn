from pathlib import Path
import json,re
R=Path(__file__).resolve().parent
m=json.loads((R/'核验记录/文件清单_SHA256.json').read_text(encoding='utf-8'))
refs=json.loads((R/'核验记录/所需数据引用.json').read_text(encoding='utf-8'))
missing=sorted(set(n for x in refs for n in re.findall(r'dataset_[A-Za-z0-9_]+\.dta',x['text'])))
assert len(m)==8 and len(missing)==12
(R/'核验记录/缺失数据文件清单.json').write_text(json.dumps([dict(file=n,status='not_in_supplied_zip',references=[x for x in refs if n in x['text']]) for n in missing],ensure_ascii=False,indent=2),encoding='utf-8')
old=json.loads((R/'download_log.json').read_text(encoding='utf-8-sig'))
old.update(status='local_files_received_and_verified_code_only',source='用户人工下载后提供本地PDF及ZIP；未声称本轮浏览器自动下载成功',pdf_local_file='论文/跨境电商平台与国内就业——基于企业和地区双重视角的考察.pdf',attachment_local_file='原始附件包/20261027095151221WU_FILE_1.zip',attachment_url=None,http_status=None,files_verified=8,zip_crc='pass',required_data_files_missing=missing,next_action='补齐所需分析数据后再开展回归复现；后续下载继续遵守人工验证码流程')
(R/'download_log.json').write_text(json.dumps(old,ensure_ascii=False,indent=2),encoding='utf-8')
rows='\n'.join(f"|{x['file']}|{x['bytes']:,}|" for x in m)
text=f'''# 跨境电商平台与国内就业——基于企业和地区双重视角的考察

作者：魏浩、卢紫薇。《中国工业经济》2026年第9期，49–72页。

[官网文章页](https://ciejournal.ajcass.com/Magazine/Show?id=123768)

## 当前结论

用户提供的论文PDF及附件ZIP已完整保存并检查。**附件是“代码＋作者运行日志＋附录”，没有原始数据或处理后的分析数据，因此目前不能独立运行回归复现。**作者已有运行日志可以帮助核对设定，不能替代本次独立复现结果。

本次仅整理用户提供的一个附件ZIP；由于官网此前触发验证码，尚未独立确认该文章页是否另有公开附件入口。不能声称已下载该文章的全部公开附件。

## 来源与访问记录

2026-11-14曾沿用用户Microsoft Edge会话访问文章页，但转至 https://ciejournal.ajcass.com/waf_text_verify.html 。按用户要求暂停，没有自动填写验证码、绕过访问控制或重复提交文件下载请求。HTTP状态未能从浏览器UI取得，保留为null，没有猜测为403。

随后用户提供Downloads目录中的PDF及ZIP，本次从本地复制并校验一致，未重新发出同一文件的下载请求。PDF与ZIP实际下载URL未从页面取得，不根据文件名拼接猜测。历史及当前状态见download_log.json。

## 分类保存

|目录|内容及状态|
|---|---|
|论文|正文PDF，24页|
|原始附件包|用户提供的ZIP原件，保持原字节|
|代码|正文程序.do、附录程序.do；原字节保留，未运行或修改|
|附录|附录.pdf，13页|
|其他说明|编辑部使用说明PDF，2页；作者运行日志两份另放子目录|
|原始数据|未提供；目录为空，不代表存在数据|
|处理数据|未提供；目录为空，不代表存在数据|
|核验记录|文件大小、SHA256、CRC与PDF检查、缺失数据引用及文本检查材料|

## 完整性检查

- ZIP能正常打开，6个文件成员CRC全部通过；非压缩总大小与逐成员记录保存。
- 正文24页、附录13页、编辑部说明2页均能解析，各页可提取文本；PDF文件签名与结尾标志检查通过。
- 已渲染并查看正文首页与末页，期刊页码为49及72。该项检查确认文件可读，不是原服务器逐字节对照证明。
- 本地源文件与保存副本SHA256一致。8个原始输入/成员文件的哈希详见核验记录/文件清单_SHA256.json。
- 附件内没有.dta、.csv、.xlsx等数据文件，也没有另一个数据压缩包。

## 仍缺哪些数据

两份Stata程序引用了以下12个数据文件，但均未包含在用户提供的ZIP中：

{chr(10).join('- '+n for n in missing)}

正文基准回归第一份输入即dataset_benchmark.dta。程序仅包含回归调用，不应把作者日志中的回归输出逆推为真实微观数据，也不能用模拟数据代替真实复现。完整代码行号及引用文本见核验记录/缺失数据文件清单.json。

## 原始文件清单

|文件|字节数|
|---|---:|
{rows}

## 与老师项目的衔接

当前记为data_access待补齐、package_status=code_only、replication_status=not_run。代码出现面板固定效应、二元平台参与指标及工具变量模型，但是否具有至少两个真实处理批次、是否吸收态、是否有合格对照组，仍需数据核验；不能仅因使用reghdfe或变量名dd就判定符合交错DID协议。获得数据后，再按老师仓库逐列筛选、锁定作者样本并进行TWFE/CSA/BJS重估。

附件文件中的说明仅作为来源和研究材料。本次没有执行其代码。将来使用数据、程序及附录，应引用论文及《中国工业经济》官网附件。
'''
(R/'README.md').write_text(text,encoding='utf-8')
print('README updated; original files',len(m),'missing data files',len(missing))
