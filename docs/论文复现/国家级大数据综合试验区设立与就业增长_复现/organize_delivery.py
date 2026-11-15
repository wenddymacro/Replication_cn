from pathlib import Path
import hashlib,json,shutil
R=Path(__file__).resolve().parent
E=R/'original/_extracted'
items=[]
for p in (R/'original').glob('*.pdf'):
 items.append((p,'论文'))
for p in E.rglob('*'):
 if not p.is_file():continue
 role='原始数据' if p.suffix.lower() in ['.dta','.csv'] else '作者代码' if p.suffix.lower() in ['.do','.txt'] else '附录' if p.name=='附录.pdf' else '说明'
 items.append((p,role))
manifest=[]
for p,role in items:
 q=R/'materials'/role/p.name;q.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(p,q)
 a=hashlib.sha256(p.read_bytes()).hexdigest();assert a==hashlib.sha256(q.read_bytes()).hexdigest()
 manifest.append(dict(file=q.relative_to(R).as_posix(),category=role,bytes=q.stat().st_size,sha256=a))
(R/'materials/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'materials/README.md').write_text('''# 资料分类

- 论文：用户提供的正文PDF，19页扫描版。
- 原始数据：附件原样提供的城市、企业、机器学习分析数据；不是CSMAR等底层原始数据库，也没有擅自重建。
- 作者代码：公开Stata程序与Julia画图文本，原样保存。
- 附录：公开附录PDF，已归档但没有声称全部运行。
- 说明：期刊公开数据使用说明。
- 处理数据位于本包../data/：firm_analysis.csv、city_analysis.csv含作者e(sample)标记与预处理；同目录另存结果CSV。
- 本次估计代码位于../project/code/R/，重跑脚本位于包根目录。

original/另保留原ZIP、PDF及完整解压树；本目录是便于查找的分类副本，manifest.json核对SHA256。请遵守附件中期刊的数据使用说明。
''',encoding='utf-8')
sources=dict(article_url='https://ciejournal.ajcass.com/Magazine/show/?id=117612',
 pdf_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/12//20241231103755WU_FILE_1.pdf',
 zip_url='https://ciejournal.ajcass.com/UploadFile/Issue/201606280001/2024/12//20241231103744WU_FILE_0.zip',
 file_acquisition='用户在本聊天提供Downloads中的PDF与ZIP；本次读取并复制本地原件。',
 http_status=None,http_note='未获取可靠HTTP响应状态；不把文件存在或网页不可访问臆测为HTTP 200、403等。',
 completeness='ZIP CRC通过；全部公开包内文件已解压、分类并校验散列；已核对PDF页数及关键表格。',
 date='2026-11-14')
(R/'logs/sources.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2),encoding='utf-8')
print('Classified and SHA256 verified:',len(items),'source files')
