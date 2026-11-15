$ErrorActionPreference='Stop'
$root='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-bigdata-run'
$R='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe'
foreach($q in 1..4){
 $s=Import-Csv -LiteralPath "$root/logs/queue_${q}_status.csv"
 $n=if($q -le 2){8}else{7}
 if($s.Count -ne $n -or @($s|Where-Object {$_.rc -ne '0'}).Count){throw "queue $q 尚未完整成功"}
}
$s=Import-Csv -LiteralPath "$root/logs/sensitivity_status.csv"
if($s.rc -ne '0'){throw '补充稳定城市样本失败'}
$env:R_LIBS_USER='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library'
$env:CIE_RAW=$root
$env:OUT_DIR='output'
Copy-Item -LiteralPath "$PSScriptRoot/project/runtime_info.R" -Destination "$root/project/runtime_info.R" -Force
Push-Location "$root/project"
try{
 & $R --vanilla code/R/analysis.R *> "$root/logs/analysis.log"
 if($LASTEXITCODE){throw '上游汇总程序失败'}
 & $R --vanilla runtime_info.R *> "$root/logs/sessionInfo.log"
 if($LASTEXITCODE){throw '运行环境信息导出失败'}
}finally{Pop-Location}
Write-Output '正文30个协议设定及补充样本完成，上游原版汇总已生成。'
