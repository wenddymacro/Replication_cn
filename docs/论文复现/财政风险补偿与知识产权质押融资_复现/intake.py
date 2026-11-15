from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path(__file__).resolve().parent
O=R/'original';O.mkdir(exist_ok=True)
inputs=['财政风险补偿与知识产权质押融资——来自银行分支机构的证据.pdf','20261027095009507WU_FILE_1.zip']
for name in inputs:
 src=Path('C:/Users/ASUS/Downloads')/name;dst=O/name
 if not dst.exists():shutil.copy2(src,dst)
 assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(dst.read_bytes()).digest()
E=O/'_extracted';E.mkdir(exist_ok=True)
with zipfile.ZipFile(O/inputs[1]) as z:
 for info in z.infolist():
  target=(E/info.filename).resolve()
  assert target.is_relative_to(E.resolve())
  if info.is_dir():target.mkdir(parents=True,exist_ok=True)
  else:
   target.parent.mkdir(parents=True,exist_ok=True)
   if not target.exists():target.write_bytes(z.read(info))
files=[dict(file=str(p.relative_to(O)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in O.rglob('*') if p.is_file() and p.name!='manifest.json']
(O/'manifest.json').write_text(json.dumps(files,ensure_ascii=False,indent=2),encoding='utf-8')
do=next(E.rglob('*.do'));raw=do.read_bytes()
for enc in ['utf-8-sig','gb18030']:
 try:s=raw.decode(enc);break
 except UnicodeDecodeError:continue
(R/'author_code_readable.txt').write_text(s,encoding='utf-8')
print('encoding',enc,'files',len(files))
print(s[:17500])
