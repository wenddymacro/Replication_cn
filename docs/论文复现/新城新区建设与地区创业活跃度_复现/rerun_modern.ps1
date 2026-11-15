param(
 [string]$RscriptPath='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe',
 [string]$RLibrary='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library',
 [int]$Bootstrap=999
)
$ErrorActionPreference='Stop'
$runRoot=Join-Path $env:TEMP ('cie_newarea_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$runRoot/data","$runRoot/logs","$runRoot/project" -Force | Out-Null
foreach($name in 'code','data','run_one.R','run_queue.R','runtime_info.R','run_event_reported.R','export_comparisons.R','diagnose_csa_basis.R'){Copy-Item -LiteralPath "$PSScriptRoot/project/$name" -Destination "$runRoot/project" -Recurse}
Copy-Item -LiteralPath "$PSScriptRoot/data/city_analysis.csv" -Destination "$runRoot/data/city_analysis.csv"
$env:R_LIBS_USER=$RLibrary
$env:CIE_RAW=$runRoot.Replace('\','/')
$jobs=@()
foreach($q in 1..4){$jobs+=Start-Process -FilePath $RscriptPath -ArgumentList '--vanilla','run_queue.R',"$q","$Bootstrap" -WorkingDirectory "$runRoot/project" -WindowStyle Hidden -RedirectStandardOutput "$runRoot/logs/queue_$q.log" -RedirectStandardError "$runRoot/logs/queue_$q.err" -PassThru}
foreach($job in $jobs){$job.WaitForExit()}
foreach($q in 1..4){
 $s=Import-Csv -LiteralPath "$runRoot/logs/queue_${q}_status.csv"
 $n=if($q -eq 1){5}else{4}
 if($s.Count -ne $n -or @($s|Where-Object {$_.rc -ne '0'}).Count){throw "有未完成计算：$runRoot/logs"}
}
Push-Location "$runRoot/project"
try{
 foreach($folder in 'output','implementation_output'){
  $env:OUT_DIR=$folder
  & $RscriptPath --vanilla export_comparisons.R *> "$runRoot/logs/analysis_$folder.log"
  if($LASTEXITCODE){throw '上游汇总失败'}
 }
 & $RscriptPath --vanilla diagnose_csa_basis.R *> "$runRoot/logs/csa_basis_diagnosis.log"
 if($LASTEXITCODE){throw '独立CSA诊断失败'}
 & $RscriptPath --vanilla runtime_info.R *> "$runRoot/logs/sessionInfo.log"
 if($LASTEXITCODE){throw '运行环境导出失败'}
}finally{Pop-Location}
Write-Output "17组计算完成，静态联合自助=$Bootstrap；$runRoot"
Write-Output '仅1组为当前规范主设定，另16组为实现对照；CSA基期空间诊断独立，不覆盖原版结果，不代表已经完成规范入池。'
