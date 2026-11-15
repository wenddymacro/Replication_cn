from pathlib import Path
import zipfile,json,hashlib,pandas as pd
from pypdf import PdfReader
R=Path(__file__).resolve().parent
for q in ['处理数据','代码','附录','其他说明','原始数据','work','核验记录']:(R/q).mkdir(exist_ok=True)
manifest=[];audits=[]
zpath=R/'原始附件包/20240919125418WU_FILE_1.zip'
for p in [zpath,next((R/'论文').glob('*.pdf'))]:manifest.append(dict(file=str(p.relative_to(R)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
with zipfile.ZipFile(zpath) as z:
 assert z.testzip() is None
 for inf in z.infolist():
  if inf.is_dir():continue
  rawname=inf.filename
  try:name=rawname.encode('cp437').decode('gb18030')
  except UnicodeError:name=rawname
  assert Path(name).name==name
  cat='处理数据' if name.endswith('.dta') else '代码' if name.endswith('.do') else '附录' if name=='附录.pdf' else '其他说明'
  b=z.read(inf);p=R/cat/name
  if p.exists():assert p.read_bytes()==b
  else:p.write_bytes(b)
  manifest.append(dict(file=str(p.relative_to(R)),zip_member_decoded=name,zip_member_python=rawname,bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
  if name.endswith('.dta'):
   d=pd.read_stata(p,convert_categoricals=False);audits.append(dict(file=name,n=len(d),columns=len(d.columns),names=list(d.columns)))
(R/'核验记录/原始文件_SHA256.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'核验记录/数据结构.json').write_text(json.dumps(audits,ensure_ascii=False,indent=2),encoding='utf-8')
pdfs=[]
for p in list((R/'论文').glob('*.pdf'))+list((R/'附录').glob('*.pdf'))+list((R/'其他说明').glob('*.pdf')):
 b=p.read_bytes();assert b.startswith(b'%PDF-') and b'%%EOF' in b[-2048:]
 reader=PdfReader(p);texts=[page.extract_text() or '' for page in reader.pages]
 (R/'核验记录'/(p.stem+'_文本.txt')).write_text('\n'.join(f'--- PAGE {i+1} ---\n'+s for i,s in enumerate(texts)),encoding='utf-8')
 pdfs.append(dict(file=str(p.relative_to(R)),pages=len(texts),text_pages=sum(bool(t.strip()) for t in texts),signature=True,eof=True))
(R/'核验记录/完整性检查.json').write_text(json.dumps(dict(zip_crc='pass',zip_file_members=8,pdfs=pdfs,data_files_readable=5,http_status=None),ensure_ascii=False,indent=2),encoding='utf-8')
commands=[x.strip() for x in (R/'author_code_readable.txt').read_text(encoding='utf-8').splitlines() if x.strip().startswith('reghdfe caput cityp')]
assert len(commands)==4
out=['clear all','set more off','set processors 1','adopath ++ "../../../replication/chain_policy/output/local_ado"','log using "../核验记录/表2_作者模型核验.log", text replace','use "../处理数据/数据1.dta", clear','gen long row_id=_n','global control_tfe "c.ecodev#i.year c.attention#i.year c.internet#i.year c.oswitch#i.year c.mobile#i.year c.fisupport#i.year"','tempname H','postfile `H\' str10 spec double b se N r2 using "author_table2.dta", replace']
for i,c in enumerate(commands,1):out += [c,f'post `H\' ("T2_{i}") (_b[cityp]) (_se[cityp]) (e(N)) (e(r2))',f'gen byte sample_T2_{i}=e(sample)']
out+=['postclose `H\'','preserve','keep row_id sample_*','export delimited using "sample_flags.csv", replace','restore','use author_table2.dta, clear','export delimited using "author_table2.csv", replace','log close']
(R/'work/check_table2.do').write_text('\n'.join(out),encoding='utf-8')
print(json.dumps(audits,ensure_ascii=False));print(json.dumps(pdfs,ensure_ascii=False))
