$ErrorActionPreference = 'Stop'
function Compare-Printed($rows, $coefficients, $errors, $sampleSizes, $labels) {
    for ($i=0; $i -lt $rows.Count; $i++) {
        $row=$rows[$i]
        [pscustomobject]@{
            location=$labels[$i]
            outcome=$row.outcome
            published_coef=$coefficients[$i]
            estimated_coef=[double]$row.coef
            published_se=$errors[$i]
            estimated_se=[double]$row.se
            published_n=$sampleSizes[$i]
            estimated_n=[int]$row.n
            matches_printed=([math]::Round([double]$row.coef,4) -eq $coefficients[$i] -and
                [math]::Round([double]$row.se,4) -eq $errors[$i] -and [int]$row.n -eq $sampleSizes[$i])
        }
    }
}
$out=Join-Path $PSScriptRoot 'output'
$table2=@(Import-Csv "$out/table2_city.csv")+@(Import-Csv "$out/table2_pairs.csv")
$r2=Compare-Printed $table2 @(0.0615,1.2028,0.0897,0.0238,0.0013,0.0008,-0.0005,-0.4403,-0.0014) @(0.0209,0.5708,0.0210,0.0127,0.0005,0.0004,0.0002,0.1657,0.0003) @(3151,3151,2745,433628,401016,401016,433628,425847,242365) @('2A1','2A2','2A3','2A4','2A5','2A6','2B1','2B2','2B3')
$r2 | Export-Csv "$out/table2_printed_comparison.csv" -NoTypeInformation
if (Test-Path "$out/table1.csv") {
    $table1=@(Import-Csv "$out/table1.csv")
    $r1=Compare-Printed $table1 @(0.5009,0.3821,0.3814,0.3755,0.1133,0.1264,0.1970,0.2799,0.2342,4.0341) @(0.1712,0.1733,0.1734,0.1727,0.0658,0.0667,0.0726,0.0813,0.1476,0.5621) @(254013,254013,253889,253568,229954,225899,253568,224483,214844,62666) @('1A1','1A2','1A3','1A4','1B1','1B2','1B3','1B4','1B5','1B6')
    $r1 | Export-Csv "$out/table1_printed_comparison.csv" -NoTypeInformation
    $r1 | Format-Table
}
$r2 | Format-Table
