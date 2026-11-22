from pathlib import Path
import shutil,subprocess
R=Path(__file__).resolve().parent
root=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-fta-run')
for n in ['author_results.csv','modern_results_long.csv','placebo.csv']:shutil.copy2(R/'data'/n,root/'data'/n)
shutil.copy2(R/'project/make_figures.R',root/'project/make_figures.R')
exe=root.parent/'cie-r-runtime/bin/Rscript.exe'
with (R/'logs/figures.log').open('w') as f:subprocess.run([str(exe),'--vanilla','make_figures.R'],cwd=root/'project',stdout=f,stderr=subprocess.STDOUT,check=True)
shutil.copytree(root/'project/figures',R/'figures',dirs_exist_ok=True)
print('3 figures generated with base R')
