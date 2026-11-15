from pathlib import Path
import shutil
root=Path(__file__).resolve().parent
p=root/'project/code/R/analysis.R';s=p.read_text(encoding='utf-8')
s=s.replace('cov = if (has_cov) get(paste0("cov_twfe_", m)) else NA_real_,','cov = if (has_cov) get(paste0("cov_twfe_", m)) else NA_real_,\n               boot_sd_twfe = if ("bsd_twfe" %in% names(x)) bsd_twfe else NA_real_,\n               boot_sd_mod = if (paste0("bsd_", m) %in% names(x)) get(paste0("bsd_", m)) else NA_real_,')
start=s.index('  z[, vdiff :=')
end=s.index('  z[, z_diff :=',start)
s=s[:start]+'''  z[, variance_basis := fifelse(!is.na(cov) & is.finite(boot_sd_twfe) & is.finite(boot_sd_mod), "joint_bootstrap_matrix", "analytic_marginals_cov_zero")]
  z[, vdiff := fifelse(variance_basis == "joint_bootstrap_matrix", boot_sd_twfe^2 + boot_sd_mod^2 - 2*cov_used, modern_se^2 + twfe_se^2 - 2*cov_used)]
  if (any(z$vdiff <= 0, na.rm=TRUE)) warning("Non-positive difference variance recorded as NA; no correlation clipping")
  z[vdiff <= 0, vdiff := NA_real_]
'''+s[end:]
s=s.replace('and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);','and a significant difference at 5% (the full joint-bootstrap matrix where available; otherwise analytic SEs with covariance 0);')
s=s.replace('  z <- to_long(x)','  z <- to_long(x)\n  fwrite(z, file.path(OUT, paste0(nm, "_comparisons.csv")))')
(root/'project/code/R/analysis_protocol.R').write_text('# Local correction: use internally coherent joint-bootstrap marginal variances and covariance.\n'+s,encoding='utf-8')
run=Path('C:/Users/ASUS/.codex/visualizations/2026/11/13/01a1d4b0-3fa8-7722-902a-2ed6474425f6/cie-protocol-run/project')
(run/'code/R/analysis_protocol.R').write_text((root/'project/code/R/analysis_protocol.R').read_text(encoding='utf-8'),encoding='utf-8')
backup=run/'output/upstream_summary';backup.mkdir(exist_ok=True)
for rel in ['tables/comparison_summary.csv','tables/comparison_summary.md','specs_main.csv']:
    src=run/'output'/rel
    if src.exists() and not (backup/Path(rel).name).exists():shutil.copy2(src,backup/Path(rel).name)
print('Created corrected analysis, upstream script and outputs retained')
