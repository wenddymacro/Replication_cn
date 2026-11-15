from pathlib import Path
import hashlib,json,shutil
R=Path(__file__).resolve().parent
target=Path('C:/Users/ASUS/Desktop/论文复现/财政风险补偿与知识产权质押融资_复现')
assert target.resolve().is_relative_to(Path('C:/Users/ASUS/Desktop/论文复现').resolve())
files=[p for p in R.rglob('*') if p.is_file() and p.name!='交付文件校验.json']
manifest=[dict(file=str(p.relative_to(R)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in files]
(R/'交付文件校验.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
shutil.copytree(R,target,dirs_exist_ok=True)
for x in manifest:
 assert hashlib.sha256((target/x['file']).read_bytes()).hexdigest()==x['sha256'],x['file']
print('Verified',len(manifest),'files; destination:',target)
