from pathlib import Path
import hashlib,json,difflib
R=Path(__file__).resolve().parent
p=R/'project/code/R/estimators.R'; original_bytes=Path('reference/Replication_cn-main/code/R/estimators.R').read_bytes(); original=original_bytes.decode('utf-8').replace('\r\n','\n')
old='":", paste(xt[big], collapse = ","))))'
new='":", paste(xt[big], collapse = ",")), G_eff = NA_real_, L_max = NA_real_))'
assert original.count(old)==1
patched=original.replace(old,new)
u=R/'project/code/upstream';u.mkdir(exist_ok=True)
(u/'estimators.R').write_bytes(original_bytes)
p.write_bytes(patched.encode('utf-8'))
diff=''.join(difflib.unified_diff(original.splitlines(True),patched.splitlines(True),fromfile='upstream/estimators.R',tofile='R/estimators.R'))
(R/'logs/compatibility.patch').write_text(diff,encoding='utf-8')
scratch=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-fiscal-run/project/code/R/estimators.R')
scratch.write_bytes(patched.encode('utf-8'))
(R/'logs/compatibility.json').write_text(json.dumps(dict(reason='CSA >60类跳过分支缺少杠杆字段，补齐NA以保证输出与汇总schema；估计方法未变',original_sha256=hashlib.sha256(original_bytes).hexdigest(),patched_sha256=hashlib.sha256(patched.encode()).hexdigest()),ensure_ascii=False,indent=2),encoding='utf-8')
print(diff)
