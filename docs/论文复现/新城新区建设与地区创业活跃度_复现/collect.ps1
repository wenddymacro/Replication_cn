$ErrorActionPreference='Stop'
$root='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-newarea-run'
$R='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe'
foreach($q in 1..4){
 $s=Import-Csv -LiteralPath "$root/logs/queue_${q}_status.csv"
 $n=if($q -eq 1){5}else{4}
 if($s.Count -ne $n -or @($s | Where-Object {$_.rc -ne '0'}).Count){throw "queue $q 不完整，先检查日志"}
}
Copy-Item -LiteralPath "$PSScriptRoot/project/export_comparisons.R" -Destination "$root/project/export_comparisons.R" -Force
$env:R_LIBS_USER='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library'
$env:CIE_RAW=$root
Push-Location "$root/project"
try{
 foreach($folder in 'output','implementation_output'){
  $env:OUT_DIR=$folder
  & $R --vanilla export_comparisons.R *> "$root/logs/analysis_$folder.log"
  if($LASTEXITCODE){throw "上游汇总失败：$folder"}
 }
 & $R --vanilla runtime_info.R *> "$root/logs/sessionInfo.log"
 if($LASTEXITCODE){throw '环境信息导出失败'}
}finally{Pop-Location}
Write-Output '1个规范主设定与16个实现对照分别汇总，未混池。'
