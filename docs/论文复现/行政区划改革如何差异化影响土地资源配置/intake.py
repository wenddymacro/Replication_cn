from pathlib import Path
import zipfile,hashlib,shutil,json
R=Path(__file__).resolve().parent
src=Path('C:/Users/ASUS/Downloads/20250421094645WU_FILE_1.zip')
assert src.exists(),'Download has not finished'
for n in ['original/extracted','logs','work','data']:(R/n).mkdir(parents=True,exist_ok=True)
dst=R/'original'/src.name
if not dst.exists():shutil.copy2(src,dst)
assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(dst.read_bytes()).digest()
with zipfile.ZipFile(dst) as z:
 assert z.testzip() is None
 for i in z.infolist():
  if i.is_dir():continue
  try:n=i.filename.encode('cp437').decode('gb18030')
  except UnicodeError:n=i.filename
  p=(R/'original/extracted'/n).resolve();assert p.is_relative_to((R/'original/extracted').resolve())
  p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(i))
for j,p in enumerate((R/'original/extracted').rglob('*.do'),1):
 for enc in ['utf-8-sig','gb18030']:
  try:s=p.read_bytes().decode(enc);break
  except UnicodeError:continue
 (R/f'logs/author_program_{j}.txt').write_text(s,encoding='utf-8');print(p.name);print(s[:18000])
manifest=[dict(file=p.relative_to(R/'original').as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'original').rglob('*') if p.is_file() and p.name!='manifest.json']
(R/'original/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(manifest,ensure_ascii=False,indent=2))

