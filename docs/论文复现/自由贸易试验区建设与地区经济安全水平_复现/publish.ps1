$ErrorActionPreference='Stop'
$source=(Resolve-Path -LiteralPath $PSScriptRoot).Path
$allowed=[IO.Path]::GetFullPath('C:/Users/ASUS/Desktop/论文复现')
$target=[IO.Path]::GetFullPath((Join-Path $allowed '自由贸易试验区建设与地区经济安全水平_复现'))
if(-not $target.StartsWith($allowed+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw '目标路径越界'}
New-Item -ItemType Directory -Path $target -Force | Out-Null
$files=@(Get-ChildItem -LiteralPath $source -Recurse -File | Where-Object {$_.Name -ne 'delivery_manifest.json' -and $_.FullName -notmatch '[\\/]__pycache__[\\/]'})
$records=@()
foreach($f in $files){
 $rel=[IO.Path]::GetRelativePath($source,$f.FullName)
 $dest=[IO.Path]::GetFullPath((Join-Path $target $rel))
 if(-not $dest.StartsWith($target+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw '文件路径越界'}
 New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($dest)) -Force | Out-Null
 Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
 $a=(Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
 $b=(Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
 if($a -ne $b){throw "复制校验失败：$rel"}
 $records+=[pscustomobject]@{file=$rel;bytes=$f.Length;sha256=$a}
}
$manifest=ConvertTo-Json -InputObject $records -Depth 4
Set-Content -LiteralPath (Join-Path $source 'delivery_manifest.json') -Value $manifest -Encoding utf8
Set-Content -LiteralPath (Join-Path $target 'delivery_manifest.json') -Value $manifest -Encoding utf8
Write-Output "已分类归档并逐文件SHA256核验：$($files.Count)个文件；$target"


