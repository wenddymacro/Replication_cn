from pathlib import Path
import hashlib,shutil
R=Path(__file__).resolve().parent
D=Path('C:/Users/ASUS/Desktop/论文复现/国际标准对接如何推动中国企业技术出海_资料与筛选')
assert D.resolve().is_relative_to(Path('C:/Users/ASUS/Desktop/论文复现').resolve())
shutil.copytree(R,D,dirs_exist_ok=True)
files=[p for p in R.rglob('*') if p.is_file()]
for p in files:assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256((D/p.relative_to(R)).read_bytes()).digest()
print('Verified',len(files),'files:',D)
