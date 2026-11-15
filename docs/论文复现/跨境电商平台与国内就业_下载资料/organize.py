from pathlib import Path
import zipfile,hashlib,json,shutil,re,datetime
from pypdf import PdfReader
import pypdfium2 as pdfium
R=Path(__file__).resolve().parent
for name in ['论文','原始附件包','原始数据','处理数据','代码','附录','其他说明/作者运行日志','核验记录']:(R/name).mkdir(parents=True,exist_ok=True)
names=['跨境电商平台与国内就业——基于企业和地区双重视角的考察.pdf','20261027095151221WU_FILE_1.zip']
manifest=[]
def sha(b):return hashlib.sha256(b).hexdigest()
def put(b,dst,source,member=None):
 assert dst.resolve().is_relative_to(R.resolve())
 if dst.exists():assert dst.read_bytes()==b, f'Existing file differs: {dst}'
 else:dst.write_bytes(b)
 manifest.append(dict(file=str(dst.relative_to(R)),bytes=len(b),sha256=sha(b),source=source,zip_member=member))
for i,name in enumerate(names):
 src=Path('C:/Users/ASUS/Downloads')/name
 put(src.read_bytes(),R/('论文' if i==0 else '原始附件包')/name,'user_supplied:'+str(src))
zpath=R/'原始附件包'/names[1]
with zipfile.ZipFile(zpath) as z:
 assert z.testzip() is None
 for info in z.infolist():
  if info.is_dir():continue
  p=Path(info.filename);assert not p.is_absolute() and '..' not in p.parts
  cat='代码' if p.suffix=='.do' else '其他说明/作者运行日志' if p.suffix=='.log' else '附录' if p.name=='附录.pdf' else '其他说明'
  put(z.read(info),R/cat/p.name,str(zpath),info.filename)
audit=[]
for p in [R/'论文'/names[0],R/'附录/附录.pdf',R/'其他说明/《中国工业经济》编辑部关于公开数据附件的使用说明.pdf']:
 b=p.read_bytes();assert b.startswith(b'%PDF-') and b'%%EOF' in b[-2048:]
 doc=PdfReader(p);text='\n'.join(f'--- PAGE {i+1} ---\n'+(page.extract_text() or '') for i,page in enumerate(doc.pages))
 (R/'核验记录'/(p.stem+'_文本.txt')).write_text(text,encoding='utf-8')
 audit.append(dict(file=str(p.relative_to(R)),pages=len(doc.pages),encrypted=doc.is_encrypted,nonempty_text_pages=sum(bool(page.extract_text().strip()) for page in doc.pages),signature=True,eof=True))
 if p.parent.name=='论文':
  image_doc=pdfium.PdfDocument(str(p))
  for idx in [0,len(image_doc)-1]:image_doc[idx].render(scale=1.0).to_pil().save(R/'核验记录'/f'paper_page_{idx+1}.png')
refs=[]
for p in (R/'代码').glob('*.do'):
 b=p.read_bytes()
 for enc in ['utf-8-sig','gb18030']:
  try:t=b.decode(enc);break
  except UnicodeDecodeError:continue
 (R/'核验记录'/(p.stem+'_可读.txt')).write_text(t,encoding='utf-8')
 for no,line in enumerate(t.splitlines(),1):
  if re.search(r'(^\s*(use|merge|append|import|cd|global)\b)|\.dta',line,re.I):refs.append(dict(code=p.name,line=no,text=line))
(R/'核验记录/所需数据引用.json').write_text(json.dumps(refs,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'核验记录/文件清单_SHA256.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
(R/'核验记录/完整性检查.json').write_text(json.dumps(dict(zip_crc='pass',zip_members=len(manifest)-2,pdfs=audit,source='用户人工下载后提供，非本轮浏览器自动下载',http_status=None,notes='文件结构及校验通过不等于已重跑复现；附件没有分析数据'),ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(audit,ensure_ascii=False,indent=2))
print(json.dumps(refs,ensure_ascii=False,indent=2))
