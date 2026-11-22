$ErrorActionPreference='Stop'
$root='C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-fta-run'
if(Test-Path -LiteralPath "$root/project/output"){Copy-Item -LiteralPath "$root/project/output" -Destination "$PSScriptRoot/project" -Recurse -Force}
if(Test-Path -LiteralPath "$root/project/diagnostics"){Copy-Item -LiteralPath "$root/project/diagnostics" -Destination "$PSScriptRoot/project" -Recurse -Force}
Copy-Item -Path "$root/logs/*" -Destination "$PSScriptRoot/logs" -Force
