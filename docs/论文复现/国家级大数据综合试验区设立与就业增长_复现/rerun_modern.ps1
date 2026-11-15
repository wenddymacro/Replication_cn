param(
 [string]$RscriptPath='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe',
 [string]$RLibrary='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library',
 [int]$Bootstrap=999
)
$ErrorActionPreference='Stop'
$runRoot=Join-Path $env:TEMP ('cie_bigdata_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$runRoot/data","$runRoot/logs","$runRoot/project" -Force | Out-Null
foreach($name in 'code','data','run_one.R','run_queue.R','runtime_info.R'){Copy-Item -LiteralPath "$PSScriptRoot/project/$name" -Destination "$runRoot/project" -Recurse}
foreach($name in 'firm_analysis.csv','city_analysis.csv'){Copy-Item -LiteralPath "$PSScriptRoot/data/$name" -Destination "$runRoot/data/$name"}
$env:R_LIBS_USER=$RLibrary
$env:CIE_RAW=$runRoot.Replace('\','/')
$env:OUT_DIR='output'
$jobs=@()
foreach($q in 1..4){$jobs+=Start-Process -FilePath $RscriptPath -ArgumentList '--vanilla','run_queue.R',"$q","$Bootstrap" -WorkingDirectory "$runRoot/project" -WindowStyle Hidden -RedirectStandardOutput "$runRoot/logs/queue_$q.log" -RedirectStandardError "$runRoot/logs/queue_$q.err" -PassThru}
foreach($job in $jobs){$job.WaitForExit()}
foreach($q in 1..4){
 $s=Import-Csv -LiteralPath "$runRoot/logs/queue_${q}_status.csv"
 $n=if($q -le 2){8}else{7}
 if($s.Count -ne $n -or @($s | Where-Object {$_.rc -ne '0'}).Count){throw "存在运行失败，见 $runRoot/logs"}
}
$sens=Import-Csv -LiteralPath "$runRoot/logs/sensitivity_status.csv"
if($sens.rc -ne '0'){throw '稳定城市补充分析失败'}
Push-Location "$runRoot/project"
try{
 & $RscriptPath --vanilla code/R/analysis.R *> "$runRoot/logs/analysis.log"
 if($LASTEXITCODE){throw '上游汇总失败'}
 & $RscriptPath --vanilla runtime_info.R *> "$runRoot/logs/sessionInfo.log"
 if($LASTEXITCODE){throw '环境信息导出失败'}
}finally{Pop-Location}
Write-Output "重跑完成：30个正文协议设定；静态联合自助=$Bootstrap；结果=$runRoot"
Write-Output '事件路径使用仓库原版解析推断；补充样本独立保存，不混入正式设定计数。'
