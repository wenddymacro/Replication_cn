from pathlib import Path
import hashlib,shutil
R=Path(__file__).resolve().parent
D=Path('C:/Users/ASUS/Desktop/论文复现/公共数据开放如何提振企业有效投资_筛选与表2核验')
assert D.resolve().is_relative_to(Path('C:/Users/ASUS/Desktop/论文复现').resolve())
shutil.copytree(R,D,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__'))
files=[p for p in R.rglob('*') if p.is_file() and '__pycache__' not in p.parts]
for p in files:assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256((D/p.relative_to(R)).read_bytes()).digest()
print('Verified',len(files),'files:',D)
