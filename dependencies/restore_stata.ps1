param(
    [Parameter(Mandatory=$true)][string]$ArchivePath
)
$ErrorActionPreference = 'Stop'
# Restore exact archived bytes only inside this independent repository.
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$branch = git -C $root branch --show-current
if ($LASTEXITCODE -ne 0 -or $branch -ne 'weixiao-work') { throw 'Expected independent weixiao-work checkout.' }
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'migration-manifest.json') -Raw | ConvertFrom-Json
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ArchivePath).Path)
try {
    # Validate ALL archive entries and destinations before writing any file.
    $writes = @()
    foreach ($group in $manifest.files) {
        foreach ($dirId in $group.directories) {
            $relative = $manifest.directories[$dirId] + '/' + $group.name
            $dest = [IO.Path]::GetFullPath((Join-Path $root $relative))
            if (!$dest.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe destination.' }
            $entry = $zip.GetEntry($relative)
            if (!$entry -or $entry.Length -ne $group.bytes) { throw "Archive member missing or wrong size: $relative" }
            $stream = $entry.Open()
            $hasher = [Security.Cryptography.SHA256]::Create()
            try { $actual = [BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-', '') }
            finally { $stream.Dispose(); $hasher.Dispose() }
            if ($actual -ne $group.sha256) { throw "Archive checksum mismatch: $relative" }
            if (Test-Path -LiteralPath $dest) {
                if ((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -ne $group.sha256) { throw "Existing file differs; refusing overwrite: $relative" }
            } else { $writes += [pscustomobject]@{entry=$entry;dest=$dest} }
        }
    }
    foreach ($item in $writes) {
        New-Item -ItemType Directory -Path (Split-Path $item.dest) -Force | Out-Null
        # false explicitly forbids replacing an existing file.
        [IO.Compression.ZipFileExtensions]::ExtractToFile($item.entry, $item.dest, $false)
    }
    Write-Output "Restored $($writes.Count) missing dependency files; existing files were not replaced."
} finally { $zip.Dispose() }
