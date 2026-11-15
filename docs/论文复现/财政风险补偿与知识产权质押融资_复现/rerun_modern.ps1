param(
 [string]$RscriptPath='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe',
 [string]$RLibrary='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library',
 [int]$Bootstrap=999
)
$ErrorActionPreference='Stop'
$runRoot=Join-Path $env:TEMP ('cie_fiscal_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$runRoot/data","$runRoot/logs","$runRoot/project" -Force | Out-Null
foreach($name in 'code','data','run_one.R','run_queue.R'){Copy-Item -LiteralPath "$PSScriptRoot/project/$name" -Destination "$runRoot/project" -Recurse}
Copy-Item -LiteralPath "$PSScriptRoot/data/analysis.csv" -Destination "$runRoot/data/analysis.csv"
$env:R_LIBS_USER=$RLibrary
$env:CIE_RAW=$runRoot.Replace('\','/')
$env:OUT_DIR='output'
$jobs=@()
foreach($q in 1..3){$jobs+=Start-Process -FilePath $RscriptPath -ArgumentList '--vanilla','run_queue.R',"$q","$Bootstrap" -WorkingDirectory "$runRoot/project" -WindowStyle Hidden -RedirectStandardOutput "$runRoot/logs/queue_$q.log" -RedirectStandardError "$runRoot/logs/queue_$q.err" -PassThru}
foreach($job in $jobs){$job.WaitForExit()}
foreach($q in 1..3){
 $status=Import-Csv -LiteralPath "$runRoot/logs/queue_${q}_status.csv"
 if(@($status | Where-Object {$_.rc -ne '0'}).Count -or $status.Count -ne 4){throw "设定运行失败，见 $runRoot/logs"}
}
Push-Location "$runRoot/project"
try{& $RscriptPath --vanilla code/R/analysis.R *> "$runRoot/logs/analysis.log";if($LASTEXITCODE){throw "汇总失败，见 $runRoot/logs/analysis.log"}}finally{Pop-Location}
Write-Output "12个正文设定重跑完成，bootstrap=$Bootstrap；输出保存在 $runRoot"
Write-Output '此脚本使用冻结作者回归样本，不覆盖正式结果。'
