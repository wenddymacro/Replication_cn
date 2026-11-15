$ErrorActionPreference='Stop'
$root='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-jurisdiction-run'
$R='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe'
$env:R_LIBS_USER='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library'
$env:CIE_RAW=$root
$env:OUT_DIR='output'
Copy-Item -LiteralPath "$PSScriptRoot/project/diagnose_sample.R" -Destination "$root/project/diagnose_sample.R" -Force
Copy-Item -LiteralPath "$PSScriptRoot/project/export_comparisons.R" -Destination "$root/project/export_comparisons.R" -Force
Push-Location "$root/project"
try{
 & $R --vanilla export_comparisons.R *> "$root/logs/analysis.log"
 if($LASTEXITCODE){throw '上游原版汇总失败'}
 & $R --vanilla diagnose_sample.R *> "$root/logs/sample_diagnosis.log"
 if($LASTEXITCODE){throw '样本诊断失败'}
 & $R --vanilla runtime_info.R *> "$root/logs/sessionInfo.log"
 if($LASTEXITCODE){throw '环境导出失败'}
}finally{Pop-Location}
Write-Output '原版汇总、样本核对与运行环境已导出。'
