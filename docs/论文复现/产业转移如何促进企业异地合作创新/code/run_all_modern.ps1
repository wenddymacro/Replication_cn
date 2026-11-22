param([int]$B = 999)
$ErrorActionPreference = 'Stop'
$paperRoot = Split-Path -Parent $PSScriptRoot
if (-not $env:RSCRIPT_EXE) { $cmd = Get-Command Rscript.exe -ErrorAction SilentlyContinue; if ($cmd) { $env:RSCRIPT_EXE = $cmd.Source } }
if (-not $env:RSCRIPT_EXE -or -not (Test-Path -LiteralPath $env:RSCRIPT_EXE)) { throw 'Set RSCRIPT_EXE to the Rscript.exe path before running.' }
if (-not $env:R_LIBS_USER) { throw 'Set R_LIBS_USER to a library containing data.table, jsonlite, haven, fixest, did, and did2s.' }
$scratch = Join-Path $env:TEMP ('cie202606-modern-' + [guid]::NewGuid().ToString('N'))
$inDir = Join-Path $scratch 'input'
$dataDir = Join-Path $inDir 'industry_transfer'
$codeDir = Join-Path $scratch 'code\R'
$specDir = Join-Path $scratch 'data\specs'
$outDir = Join-Path $scratch 'output'
New-Item -ItemType Directory -Force -Path $inDir,$dataDir,$codeDir,$specDir,(Join-Path $outDir 'logs') | Out-Null
Copy-Item -LiteralPath (Join-Path $paperRoot 'original\package\extracted\戴宏伟+论文附件\数据\回归数据.dta') -Destination (Join-Path $inDir 'regression.dta')
Copy-Item -LiteralPath (Join-Path $paperRoot 'code\prepare_data.R') -Destination (Join-Path $scratch 'prepare_data.R')
Copy-Item -LiteralPath (Join-Path $paperRoot 'code\R\estimators.R'),(Join-Path $paperRoot 'code\R\run_spec.R') -Destination $codeDir
Get-ChildItem -LiteralPath (Join-Path $paperRoot 'data\specs') -Filter '*.json' | Copy-Item -Destination $specDir
Push-Location $scratch
try {
  & $env:RSCRIPT_EXE 'prepare_data.R' 2>&1 | Out-File -LiteralPath (Join-Path $outDir 'prepare_data.log') -Encoding utf8
  if ($LASTEXITCODE -ne 0) { throw 'prepare_data.R failed; see output/prepare_data.log' }
  Copy-Item -LiteralPath (Join-Path $inDir 'analysis_replication.dta') -Destination (Join-Path $dataDir 'analysis_replication.dta')
  $env:CIE_RAW = [System.IO.Path]::GetFullPath($inDir).Replace([char]92, '/')
  $env:OUT_DIR = [System.IO.Path]::GetFullPath($outDir).Replace([char]92, '/')
  $status = [System.Collections.Generic.List[object]]::new()
  foreach ($spec in Get-ChildItem -LiteralPath $specDir -Filter '*.json' | Sort-Object Name) {
    $log = Join-Path $outDir ('logs\' + $spec.BaseName + '.log')
    & $env:RSCRIPT_EXE 'code/R/run_spec.R' ('data/specs/' + $spec.Name) $B 2>&1 | Out-File -LiteralPath $log -Encoding utf8
    $rc = $LASTEXITCODE
    $status.Add([pscustomobject]@{spec_id=$spec.BaseName; exit_code=$rc; log=$log})
  }
  $status | Export-Csv -LiteralPath (Join-Path $outDir 'run_status.csv') -NoTypeInformation -Encoding utf8
  $dest = Join-Path $paperRoot 'output\modern'
  Get-ChildItem -LiteralPath $outDir | Copy-Item -Destination $dest -Recurse -Force
  Write-Output "Scratch: $scratch"
  $status | Format-Table -AutoSize
}
finally { Pop-Location }



