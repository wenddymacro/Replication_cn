from pathlib import Path
import zipfile,shutil,hashlib,json
R=Path(__file__).resolve().parent
for q in ['original/extracted','work','logs','data','project/code/R','project/data/specs','project/data/specs_controls']:(R/q).mkdir(parents=True,exist_ok=True)
p=Path('C:/Users/ASUS/Downloads/20250325100806WU_FILE_0.zip');q=R/'original'/p.name
if not q.exists():shutil.copy2(p,q)
assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256(q.read_bytes()).digest()
with zipfile.ZipFile(q) as z:
 assert z.testzip() is None
 for it in z.infolist():
  if it.is_dir():continue
  try:n=it.filename.encode('cp437').decode('gb18030')
  except UnicodeError:n=it.filename
  d=(R/'original/extracted'/n).resolve();assert d.is_relative_to((R/'original/extracted').resolve())
  d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes(z.read(it))
for p in (R/'original/extracted').rglob('*.dta'):shutil.copy2(p,R/'work'/p.name)
p=next((R/'original/extracted').rglob('*.do'));b=p.read_bytes()
for enc in ['utf-8-sig','gb18030']:
 try:s=b.decode(enc);break
 except UnicodeError:pass
s=s.replace('\r\n','\n').replace('\r','\n')
(R/'logs/author_program.txt').write_text(s,encoding='utf-8')
print(s)
