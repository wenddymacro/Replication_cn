from pathlib import Path
import shutil,json,hashlib
R=Path(__file__).resolve().parent
for q in ['work','data','logs','project/code/R','project/data/specs','project/data/specs_controls','project/data/screening/by_paper']:(R/q).mkdir(parents=True,exist_ok=True)
for p in Path('reference/Replication_cn-main/code/R').glob('*.R'):shutil.copy2(p,R/'project/code/R'/p.name)
for p in (R/'original/_extracted').rglob('*.dta'):
 if p.name=='分支机构层面数据.dta':shutil.copy2(p,R/'work/branch.dta')
 if p.name=='银行层面数据.dta':shutil.copy2(p,R/'work/bank.dta')
s=(R/'author_code_readable.txt').read_text(encoding='utf-8')
lines=s[:s.index('use 设立风险补偿基金')].splitlines()
commands=[x.strip() for x in lines if x.strip().startswith('reghdfe ')]
names=[f'T{t}_{j}' for t,k in [(1,8),(2,6),(3,6),(4,4),(5,4)] for j in range(1,k+1)]
assert len(names)==len(commands),(len(names),len(commands))
out=['clear all','set more off','set processors 1','adopath ++ "../../chain_policy/output/local_ado"','log using "../logs/author_body.log", text replace','use branch, clear','gen long row_id=_n','global c_city "City_TotalLoan City_BankHHI City_ST City_Patent City_GDP"','global c_pledgee "Branch_Age"','global c_bank "Bank_Size Bank_ROA Bank_CAR Bank_Nplra"','tempname H','postfile `H\' str16 spec str40 term double b se N r2a using "../data/author_results.dta", replace']
for name,cmd in zip(names,commands):
 if name=='T5_3':out+=['preserve','keep row_id sample_*','export delimited using "../data/sample_flags.csv", replace','restore','use bank, clear']
 out += [cmd]
 terms=['Treat_Ratio'] if name in ['T5_3','T5_4'] else [x for x in cmd.split() if x.startswith('DiD')]
 for term in terms:out+=[f'post `H\' ("{name}") ("{term}") (_b[{term}]) (_se[{term}]) (e(N)) (e(r2_a))']
 if name not in ['T5_3','T5_4']:out+=[f'gen byte sample_{name}=e(sample)']
out+=['postclose `H\'','use "../data/author_results.dta", clear','export delimited using "../data/author_results.csv", replace','log close']
(R/'work/replicate_body.do').write_text('\n'.join(out),encoding='utf-8')
(R/'project/run_one.R').write_text('options(warn=1)\nsuppressPackageStartupMessages(library(fixest))\nsetFixest_nthreads(1)\nsource("code/R/run_spec.R")\n',encoding='utf-8')
print('Prepared',len(commands),'body regressions. Next run Stata work/replicate_body.do')
