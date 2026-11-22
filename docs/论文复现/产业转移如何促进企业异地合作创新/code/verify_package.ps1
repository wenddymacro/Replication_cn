$ErrorActionPreference = 'Stop'
$paperRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $paperRoot 'original'
$manifest = Join-Path $paperRoot 'data\source_manifest.csv'
$rows = foreach ($file in Get-ChildItem -LiteralPath $sourceRoot -File -Recurse) {
  $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
  [pscustomobject]@{path=$file.FullName.Substring($paperRoot.Length+1); bytes=$file.Length; sha256=$hash}
}
$rows | Sort-Object path | Export-Csv -LiteralPath $manifest -NoTypeInformation -Encoding utf8
$zip = Join-Path $sourceRoot 'package\20260709083718538WU_FILE_0.zip'
$entries = [System.IO.Compression.ZipFile]::OpenRead($zip).Entries
[pscustomobject]@{archive=$zip; entries=$entries.Count; nonempty=(@($entries | Where-Object Length -gt 0)).Count; bytes=(Get-Item -LiteralPath $zip).Length} | Format-List
Write-Output "Manifest: $manifest; files: $($rows.Count)"
