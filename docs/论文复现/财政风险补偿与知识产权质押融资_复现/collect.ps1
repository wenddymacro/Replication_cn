$ErrorActionPreference='Stop'
$root='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-fiscal-run'
$R='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe'
foreach($q in 1..3){
 $s=Import-Csv -LiteralPath "$root/logs/queue_${q}_status.csv"
 if($s.Count -ne 4 -or @($s|Where-Object {$_.rc -ne '0'}).Count){throw "queue $q 尚未完整成功"}
}
$env:R_LIBS_USER='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library'
$env:CIE_RAW=$root
$env:OUT_DIR='output'
Push-Location "$root/project"
try{
 & $R --vanilla code/R/analysis.R *> "$root/logs/analysis.log"
 if($LASTEXITCODE){throw '上游汇总程序失败'}
 & $R --vanilla runtime_info.R *> "$root/logs/sessionInfo.log"
 if($LASTEXITCODE){throw '运行环境信息导出失败'}
}finally{Pop-Location}
Write-Output '12个设定与上游原版汇总完成。'
