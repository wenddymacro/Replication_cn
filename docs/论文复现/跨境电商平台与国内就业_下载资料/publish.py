from pathlib import Path
import shutil,hashlib
R=Path(__file__).resolve().parent
D=Path('C:/Users/ASUS/Desktop/论文复现/跨境电商平台与国内就业_下载资料')
assert D.resolve().is_relative_to(Path('C:/Users/ASUS/Desktop/论文复现').resolve())
shutil.copytree(R,D,dirs_exist_ok=True)
files=[p for p in R.rglob('*') if p.is_file()]
for p in files:assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256((D/p.relative_to(R)).read_bytes()).digest()
print('Verified',len(files),'files:',D)
