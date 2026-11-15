$ErrorActionPreference='Stop'
$root='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-fiscal-run'
$R='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-runtime/bin/Rscript.exe'
New-Item -ItemType Directory -Path "$root/data","$root/logs" -Force | Out-Null
Copy-Item -LiteralPath "$PSScriptRoot/project" -Destination $root -Recurse -Force
Copy-Item -LiteralPath "$PSScriptRoot/data/analysis.csv" -Destination "$root/data/analysis.csv" -Force
$env:R_LIBS_USER='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-r-library'
$env:CIE_RAW=$root
$env:OUT_DIR='output'
foreach($q in 1..3){
 $p=Start-Process -FilePath $R -ArgumentList '--vanilla','run_queue.R',"$q",'999' -WorkingDirectory "$root/project" -WindowStyle Hidden -RedirectStandardOutput "$root/logs/queue_$q.log" -RedirectStandardError "$root/logs/queue_$q.err" -PassThru
 Write-Output "queue=$q pid=$($p.Id)"
}
