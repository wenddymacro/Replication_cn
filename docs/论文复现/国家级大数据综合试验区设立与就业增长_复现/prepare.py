from pathlib import Path
import zipfile,hashlib,json,shutil,re,pandas as pd
from pypdf import PdfReader
R=Path(__file__).resolve().parent
for q in ['original','original/_extracted','work','data','logs','project/code/R','project/data/specs','project/data/specs_controls','project/data/screening/by_paper']:(R/q).mkdir(parents=True,exist_ok=True)
inputs=['20241231103744WU_FILE_0.zip','国家级大数据综合试验区设立与就业增长.pdf']
for n in inputs:
 src=Path('C:/Users/ASUS/Downloads')/n;dest=R/'original'/n
 if not dest.exists():shutil.copy2(src,dest)
 assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(dest.read_bytes()).digest()
with zipfile.ZipFile(R/'original'/inputs[0]) as z:
 assert z.testzip() is None
 for inf in z.infolist():
  if inf.is_dir():continue
  try:n=inf.filename.encode('cp437').decode('gb18030')
  except UnicodeError:n=inf.filename
  p=(R/'original/_extracted'/n).resolve();assert p.is_relative_to((R/'original/_extracted').resolve())
  p.parent.mkdir(exist_ok=True,parents=True)
  if not p.exists():p.write_bytes(z.read(inf))
files=[dict(file=str(p.relative_to(R/'original')),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in (R/'original').rglob('*') if p.is_file() and p.name!='manifest.json']
(R/'original/manifest.json').write_text(json.dumps(files,ensure_ascii=False,indent=2),encoding='utf-8')
E=R/'original/_extracted';do=next(E.rglob('*.do'));s=do.read_bytes().decode('utf-8-sig').replace('\r\n','\n').replace('\r','\n');(R/'logs/author_program.txt').write_text(s,encoding='utf-8')
for p in E.rglob('*.dta'):
 n='firm.dta' if 'Firmdata' in p.name else 'city.dta' if 'Ctiydata' in p.name else 'ml.dta'
 shutil.copy2(p,R/'work'/n)
pdf=PdfReader(R/'original'/inputs[1]);texts=[]
if not (R/'logs/paper_text.txt').exists():
 texts=[p.extract_text() or '' for p in pdf.pages]
 (R/'logs/paper_text.txt').write_text('\n'.join(f'--- PAGE {i+1} ---\n'+t for i,t in enumerate(texts)),encoding='utf-8',errors='replace')
ap=next(E.rglob('附录.pdf'));p=PdfReader(ap);(R/'logs/appendix_text.txt').write_text('\n'.join(f'--- PAGE {i+1} ---\n'+(t.extract_text() or '') for i,t in enumerate(p.pages)),encoding='utf-8',errors='replace')
commands=[x.strip() for x in s[:s.index('**图2**')].splitlines() if x.strip().startswith('reghdfe ')]
names=[f'T1_{i}' for i in range(1,5)]+['F1']+[f'T{t}_{i}' for t,k in [(2,5),(3,4),(4,6),(5,5),(6,6)] for i in range(1,k+1)]
assert len(commands)==len(names)==31
out=['clear all','set more off','set processors 1','adopath ++ "../../chain_policy/output/local_ado"','log using "../logs/author_body.log", text replace','global Firm_Control "Lev Age Roa Capital Cash Growth Mshrrat Shrholder1 Share_indep"','global City_Control "Gdpt Popt Secondt Waget Edut Firm_numt Thirdt"','tempname H','postfile `H\' str12 spec str24 term double b se N r2a using "../data/author_results.dta", replace']
for typ in ['firm','city']:
 out += [f'use {typ}, clear','gen long row_id=_n']
 for name,cmd in zip(names,commands):
  if name.startswith('T2_') != (typ=='city'):continue
  terms='d_5 d_4 d_3 d_2 d_1 d0 d1 d2 d3 d4 d5'.split() if name=='F1' else ['Bigdata_Post']+(['TFP'] if name=='T3_2' else ['Market_share'] if name=='T3_4' else [])
  out+=[cmd]
  for term in terms:out += [f'post `H\' ("{name}") ("{term}") (_b[{term}]) (_se[{term}]) (e(N)) (e(r2_a))']
  out += [f'gen byte sample_{name}=e(sample)']
 out += ['keep row_id sample_*',f'export delimited using "../data/{typ}_flags.csv", replace']
out += ['postclose `H\'','use "../data/author_results.dta", clear','export delimited using "../data/author_results.csv", replace','log close']
(R/'work/replicate_body.do').write_text('\n'.join(out),encoding='utf-8')
for p in Path('reference/Replication_cn-main/code/R').glob('*.R'):shutil.copy2(p,R/'project/code/R'/p.name)
(R/'project/run_one.R').write_text('options(warn=1)\nsuppressPackageStartupMessages(library(fixest))\nsetFixest_nthreads(1)\nsource("code/R/run_spec.R")\n',encoding='utf-8')
print('PDF pages',len(pdf.pages),'author models',len(commands))
for typ in ['firm','city']:
 d=pd.read_stata(R/f'work/{typ}.dta',convert_categoricals=False)
 print(typ,'shape',d.shape,'years',d.year.unique().tolist(),'D',d.Bigdata_Post.value_counts().to_dict())
 if typ=='firm':
  for v in ['policy','Policy_year','tyear','event','d_1']:
   print(v,d[v].value_counts(dropna=False).sort_index().to_dict())
 print('first-treated',d[d.Bigdata_Post==1].groupby('Firm' if typ=='firm' else 'city').year.min().value_counts().sort_index().to_dict())
 print('switch-offs',int((d.sort_values(['Firm' if typ=='firm' else 'city','year']).groupby('Firm' if typ=='firm' else 'city').Bigdata_Post.diff()<0).sum()))
