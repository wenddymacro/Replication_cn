param(
 [string]$RscriptPath='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe',
 [string]$RLibrary='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library',
 [int]$Bootstrap=999,
 [string]$Destination=''
)
$ErrorActionPreference='Stop'
if(-not(Test-Path -LiteralPath $RscriptPath)){throw '请用 -RscriptPath 指定已安装的 Rscript.exe。'}
$runRoot=Join-Path $env:TEMP ('cie_protocol_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$runRoot/data","$runRoot/logs" -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'project') -Destination "$runRoot/project" -Recurse
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'data/analysis.csv') -Destination "$runRoot/data/analysis.csv"
$env:R_LIBS_USER=$RLibrary
$env:CIE_RAW=$runRoot.Replace('\','/')
$env:BOOT_B="$Bootstrap"
$env:OUT_DIR='output'
$jobs=@()
$jobs+=Start-Process -FilePath $RscriptPath -ArgumentList '--vanilla','run_one.R','data/specs/cie20260904__T1_1.json',"$Bootstrap" -WorkingDirectory "$runRoot/project" -WindowStyle Hidden -RedirectStandardOutput "$runRoot/logs/main.log" -RedirectStandardError "$runRoot/logs/main.err" -PassThru
foreach($group in 1..4){
 $jobs+=Start-Process -FilePath $RscriptPath -ArgumentList '--vanilla','run_queue.R',"$group" -WorkingDirectory "$runRoot/project" -WindowStyle Hidden -RedirectStandardOutput "$runRoot/logs/queue_$group.log" -RedirectStandardError "$runRoot/logs/queue_$group.err" -PassThru
}
foreach($job in $jobs){$job.WaitForExit();if($job.ExitCode -ne 0){throw "运行未正常结束，请检查 $runRoot/logs"}}
foreach($group in 1..4){
 $status=Import-Csv -LiteralPath "$runRoot/logs/queue_${group}_status.csv"
 if(@($status | Where-Object {$_.rc -ne '0'}).Count){throw "存在失败设定，请检查 $runRoot/logs"}
}
$resultFiles=@(Get-ChildItem "$runRoot/project/output/specs","$runRoot/project/output/specs_controls" -Filter 'cie20260904*.csv')
if($resultFiles.Count -ne 21){throw "结果数量错误：$($resultFiles.Count)/21"}
Push-Location "$runRoot/project"
try{& $RscriptPath --vanilla code/R/analysis_protocol.R *> "$runRoot/logs/analysis.log";if($LASTEXITCODE){throw '汇总程序失败'}}finally{Pop-Location}
if(-not $Destination){$Destination=Join-Path $PSScriptRoot 'rerun_results'}
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
Copy-Item -LiteralPath "$runRoot/project/output" -Destination $Destination -Recurse
Copy-Item -LiteralPath "$runRoot/logs" -Destination $Destination -Recurse
Write-Output "21个设定完成；联合自助次数=$Bootstrap；结果：$Destination"
Write-Output '中文报告记录本次999次正式运行；此脚本另存重跑结果，不覆盖冻结报告。'
