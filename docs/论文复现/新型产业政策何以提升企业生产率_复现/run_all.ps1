param(
    [string]$StataPath = 'D:/Stata/Stata19/StataMP-64.exe',
    [switch]$IncludePermutationTests,
    [switch]$IncludeModernBootstrap
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $StataPath)) { throw '请通过 -StataPath 指定 Stata 可执行文件。' }
$steps = @('run_deterministic.do','run_bacon.do','run_lp.do','run_sa.do','run_cs_legacy.do','run_spatial.do','run_audit.do')
if ($IncludeModernBootstrap) { $steps += 'run_dd.do' }
if ($IncludePermutationTests) {
    foreach ($group in @('g_clus1','g_gc','g_contract','g_clus2','g_mps','g_mayor','g_govpur','g_mstate','g_lpast')) {
        $steps += "run_bootstrap_$group.do"
    }
}
foreach ($step in $steps) {
    Write-Output "正在运行 $step"
    $stataRun = Start-Process -FilePath $StataPath -ArgumentList '/e','do',$step -WorkingDirectory (Join-Path $PSScriptRoot 'work') -WindowStyle Hidden -PassThru
    $stataRun.WaitForExit()
    $doText = Get-Content -LiteralPath (Join-Path $PSScriptRoot "work/$step") -Raw
    $marker = [regex]::Match($doText, 'display "(COMPLETE_[^"]+|REPLICATION_DETERMINISTIC_COMPLETE)"').Groups[1].Value
    $logRelative = [regex]::Match($doText, 'log using "([^"]+)"').Groups[1].Value
    $logPath = Join-Path (Join-Path $PSScriptRoot 'work') $logRelative
    if (-not (Test-Path -LiteralPath $logPath)) { throw "日志未生成：$step" }
    $logText = Get-Content -LiteralPath $logPath -Raw
    if ($marker -and -not $logText.Contains("`r`n$marker`r`n")) { throw "该步骤未正常结束，请检查 $logPath" }
}
Write-Output 'Stata 步骤完成。论文数值对照由 work/verify_results.py、verify_appendix.py、describe_data.py 生成。'
Write-Output '四方法动态效应图可直接重跑 work/run_modern_plot.do；图中矩阵来自本次已保存的估计结果。'
