param([string]$Project = (Split-Path $PSScriptRoot -Parent))

$original = Import-Csv (Join-Path $Project 'output/原文数值对照.csv')
$rows = foreach ($column in $original) {
    $path = Join-Path $Project "output/$($column.spec_id).csv"
    if (!(Test-Path -LiteralPath $path)) { continue }
    $row = Import-Csv -LiteralPath $path
    if ([int]$row.n -ne [int]$column.published_n) {
        throw "Sample size mismatch for $($column.spec_id)"
    }
    $row | Add-Member -NotePropertyName twfe_raw -NotePropertyValue ([double]$row.twfe * [double]$row.y_sd)
    foreach ($method in @('csa','bjs')) {
        $difference = [double]$row.$method - [double]$row.twfe
        $covariance = $row."cov_twfe_$method"
        $differenceSe = $null
        $pValue = $null
        if ($covariance -and $row."bsd_$method") {
            $variance = [double]$row.bsd_twfe * [double]$row.bsd_twfe +
                [double]$row."bsd_$method" * [double]$row."bsd_$method" - 2 * [double]$covariance
            if ($variance -gt 0) {
                $differenceSe = [math]::Sqrt($variance)
                # Two-sided normal p-value from a standard normal CDF approximation.
                $z = [math]::Abs($difference / $differenceSe)
                $t = 1 / (1 + 0.2316419 * $z)
                $pValue = 2 * [math]::Exp(-$z * $z / 2) / [math]::Sqrt(2 * [math]::PI) *
                    $t * (0.319381530 + $t * (-0.356563782 + $t * (1.781477937 + $t * (-1.821255978 + $t * 1.330274429))))
            }
        }
        $row | Add-Member -NotePropertyName "diff_${method}_twfe" -NotePropertyValue $difference
        $row | Add-Member -NotePropertyName "diff_${method}_se" -NotePropertyValue $differenceSe
        $row | Add-Member -NotePropertyName "diff_${method}_p" -NotePropertyValue $pValue
    }
    $row
}
if (@($rows).Count -ne 24) { throw 'Expected 24 platform specifications' }
$rows | Export-Csv (Join-Path $Project 'output/现代DID汇总.csv') -Encoding utf8BOM -NoTypeInformation
