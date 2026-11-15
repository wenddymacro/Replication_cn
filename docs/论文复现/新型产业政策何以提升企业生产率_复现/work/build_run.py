from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
ado=root/'output/local_ado'
if not (ado/'reghdfe.ado').exists():raise RuntimeError('Bundled local_ado dependencies are missing')
text=(root/'work/author_program.txt').read_text(encoding='utf-8')
lines=[x.strip() for x in text.splitlines() if x.strip()]
logical=[];pending=''
for line in lines:
    if line.endswith('///'):
        pending+=line[:-3]+' ';continue
    logical.append(pending+line);pending=''
text='\n'.join(logical)
# Author explicitly withholds the tax survey microdata. Remove only that preserve/restore block.
text=re.sub(r'preserve\s+use "\./数据/税调数据.dta".*?\brestore', '* SKIPPED: tax survey data not supplied',text,flags=re.S)
# These estimator-specific sections are run separately with their dependencies.
start=text.index('preserve',text.index('附表 6 & 附图 5'))
end=text.index('***',text.index('graph export "./图表/附图6_',start))
(root/'work/modern_source.txt').write_text(text[start:end],encoding='utf-8')
text=text[:start]+'* Modern estimators and Bacon decomposition: separate runner\n'+text[end:]
paths={'./数据/上市公司数据.dta':'../author/listed.dta','./数据/上市公司数据_延长窗口期.dta':'../author/listed_extended.dta','./数据/城市数据.dta':'../author/city.dta'}
for a,b in paths.items():text=text.replace(a,b)
text=text.replace('./图表/','../output/')
out=[];section='initial';idx=0
for line in text.splitlines():
    m=re.search(r'\*\*\*\s*(附表|表)\s*(\d+)',line)
    if m:section=('A' if m[1]=='附表' else 'T')+m[2];idx=0
    if line.startswith(('outreg2 ','bdiff,')):
        out.append('* OMITTED presentation or separate bootstrap: '+line);continue
    if line.startswith(('reghdfe ','ivreghdfe ','acreg ')):
        idx+=1;model=f'{section}_{idx}'
        if "`var'" in line: model+="_`var'"
        if line.startswith('acreg '):
            out.append('* Spatial HAC handled separately: '+line);continue
        out += [f'display "MODEL {model}"','capture noisily '+line,'local rc = _rc',f'file write status "{model} rc=" (`rc\') _n','if `rc\' == 0 {',f'collect_result, model("{model}")','}']
    elif line.startswith('est store '):out.append('capture '+line)
    else:out.append(line)
header=f'''clear all
set more off
set processors 1
set seed 824
capture log close
log using "../output/deterministic.log", text replace
adopath ++ "../output/local_ado"
postfile coef str20 model str100 term double b se N r2 r2_a df using "../output/coefficients.dta", replace
file open status using "../output/model_status.txt", write replace
program define collect_result
syntax, model(string)
matrix bb=e(b)
matrix vv=e(V)
local terms : colnames bb
local j=0
foreach term of local terms {{
local ++j
post coef ("`model'") ("`term'") (bb[1,`j']) (sqrt(vv[`j',`j'])) (e(N)) (e(r2)) (e(r2_a)) (e(df_r))
}}
estimates save "../output/`model'.ster", replace
end
'''
footer='''
postclose coef
file close status
use "../output/coefficients.dta", clear
export delimited using "../output/coefficients.csv", replace
display "REPLICATION_DETERMINISTIC_COMPLETE"
log close
'''
(root/'work/run_deterministic.do').write_text(header+'\n'.join(out)+footer,encoding='utf-8')
print('generated',sum(x.startswith('display "MODEL') for x in out),'models')
