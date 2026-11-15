from pathlib import Path
import zipfile,hashlib,json,io
import pandas as pd
from pypdf import PdfReader
import pypdfium2 as pdfium
R=Path(__file__).resolve().parent
for q in ['论文','原始附件包','原始数据','处理数据/主回归数据','处理数据/作图数据','代码/主程序','代码/作图程序','附录','其他说明','核验记录']:(R/q).mkdir(parents=True,exist_ok=True)
manifest=[]
def put(b,p,source,member=None):
 assert p.resolve().is_relative_to(R.resolve())
 if p.exists():assert p.read_bytes()==b
 else:p.write_bytes(b)
 manifest.append(dict(file=str(p.relative_to(R)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),source=source,zip_member=member))
inputs=['国际标准对接如何推动中国企业技术出海.pdf','20261027100110131WU_FILE_1.zip']
for i,n in enumerate(inputs):
 src=Path('C:/Users/ASUS/Downloads')/n;put(src.read_bytes(),R/('论文' if i==0 else '原始附件包')/n,str(src))
data_audit=[]
with zipfile.ZipFile(R/'原始附件包'/inputs[1]) as z:
 assert z.testzip() is None
 for inf in z.infolist():
  if inf.is_dir():continue
  p=Path(inf.filename);assert not p.is_absolute() and '..' not in p.parts
  if p.suffix=='.dta':q='处理数据/作图数据' if '作图数据与程序' in p.parts else '处理数据/主回归数据'
  elif p.suffix in ['.do','.py']:q='代码/作图程序' if '作图数据与程序' in p.parts else '代码/主程序'
  elif p.name=='附录.pdf':q='附录'
  else:q='其他说明'
  b=z.read(inf);dest=R/q/p.name;put(b,dest,str(R/'原始附件包'/inputs[1]),inf.filename)
  if p.suffix in ['.do','.py']:
   for enc in ['utf-8-sig','gb18030']:
    try:s=b.decode(enc);break
    except UnicodeDecodeError:continue
   (R/'核验记录'/(p.stem+'_可读.txt')).write_text(s,encoding='utf-8')
  if p.suffix=='.dta':
   d=pd.read_stata(io.BytesIO(b),convert_categoricals=False)
   data_audit.append(dict(file=str(dest.relative_to(R)),rows=len(d),columns=len(d.columns),variables=list(d.columns)))
pdf_checks=[]
for p in list((R/'论文').glob('*.pdf'))+list((R/'附录').glob('*.pdf'))+list((R/'其他说明').glob('*.pdf')):
 b=p.read_bytes();assert b.startswith(b'%PDF-') and b'%%EOF' in b[-2048:]
 doc=PdfReader(p);texts=[x.extract_text() or '' for x in doc.pages]
 (R/'核验记录'/(p.stem+'_文本.txt')).write_text('\n'.join(f'--- PAGE {i+1} ---\n'+s for i,s in enumerate(texts)),encoding='utf-8')
 pdf_checks.append(dict(file=str(p.relative_to(R)),pages=len(doc.pages),nonempty_text_pages=sum(bool(t.strip()) for t in texts),signature=True,eof=True))
paper=pdfium.PdfDocument(str(R/'论文'/inputs[0]))
for idx in [0,10,11]:paper[idx].render(scale=1.3).to_pil().save(R/'核验记录'/f'paper_page_{idx+1}.png')
d=pd.read_stata(R/'处理数据/主回归数据/数据.dta',convert_categoricals=False)
g=d[d.did==1].groupby('id').year.min()
screen=dict(paper_id='cie123771',title='国际标准对接如何推动中国企业技术出海',year=2026,issue=9,authors=['冯帆','马皓巍'],article_url='https://ciejournal.ajcass.com/Magazine/Show?id=123771',screened_from='article_text+package+data',staggered_design=False,eligible_design=False,near_miss_controls_only=False,package_status='data_and_code',data_access='public',replication_status='not_run',policy_year=2015,observed_first_treatment_counts={str(int(k)):int(v) for k,v in g.value_counts().sort_index().items()},n_observed_cohorts=int(g.nunique()),n_data_rows=len(d),n_firms=int(d.id.nunique()),duplicate_id_year=int(d.duplicated(['id','year']).sum()),switch_offs=int((d.sort_values(['id','year']).groupby('id').did.diff()<0).sum()),eligible_specs=[],ineligible_specs=[dict(location='表1第1–2列及其余SIM模型',reason='SIM是连续标准对接强度，非二元交错处理'),dict(location='表1第3–4列',reason='工具变量一阶段及2SLS'),dict(location='表1第5列及配套动态DID',reason='2015年统一政策冲击，仅一个处理批次')],source_locations=['正文PDF第11页（期刊129页）表1','正文PDF第12页（期刊130页）内生性处理第（2）部分','主回归数据did按id计算首次为1的year'],notes='不将不同年份企业进入样本误判为真实政策批次；本包主数据核查显示全部927个处理企业首次处理均为2015。原始底层国家标准、专利记录未作为独立源数据提供；dta按用途归入处理数据。数据和代码可读不等于作者结果已独立复现。')
(R/'核验记录/筛选结论.json').write_text(json.dumps(screen,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'核验记录/数据结构.json').write_text(json.dumps(data_audit,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'核验记录/文件清单_SHA256.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'核验记录/完整性检查.json').write_text(json.dumps(dict(zip_crc='pass',zip_file_members=len(manifest)-2,pdfs=pdf_checks,source='用户提供本地下载文件；本轮没有重新下载',http_status=None,attachment_url=None,sha256_verified=True),ensure_ascii=False,indent=2),encoding='utf-8')
print('Original files',len(manifest),'data files',len(data_audit));print(json.dumps(pdf_checks,ensure_ascii=False));print(json.dumps(screen,ensure_ascii=False,indent=2))
