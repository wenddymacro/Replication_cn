from pathlib import Path
import zipfile,hashlib,shutil,json
R=Path(__file__).resolve().parent
for n in ['original/extracted','logs','data','work','project/code/R','project/data/specs','project/data/specs_controls']:(R/n).mkdir(parents=True,exist_ok=True)
src=Path('C:/Users/ASUS/Downloads/20250423105511WU_FILE_0.zip')
q=R/'original'/src.name
if not q.exists():shutil.copy2(src,q)
assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(q.read_bytes()).digest()
with zipfile.ZipFile(q) as z:
 assert z.testzip() is None
 for i in z.infolist():
  if i.is_dir():continue
  try:n=i.filename.encode('cp437').decode('gb18030')
  except UnicodeError:n=i.filename
  p=(R/'original/extracted'/n).resolve();assert p.is_relative_to((R/'original/extracted').resolve())
  p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(i))
p=next((R/'original/extracted').rglob('*.do'))
b=p.read_bytes()
for enc in ['utf-8-sig','gb18030']:
 try:s=b.decode(enc);break
 except UnicodeError:pass
(R/'logs/author_program.txt').write_text(s,encoding='utf-8')
for i,p in enumerate(sorted((R/'original/extracted').rglob('*.dta')),1):shutil.copy2(p,R/f'work/data{i}.dta')
manifest=[dict(file=p.relative_to(R/'original').as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'original').rglob('*') if p.is_file() and p.name!='manifest.json']
(R/'original/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print(s)
