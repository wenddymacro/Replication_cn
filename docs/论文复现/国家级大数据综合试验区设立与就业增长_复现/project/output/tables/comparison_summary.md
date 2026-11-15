Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs
and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);
se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage
alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).

| estimator | sample | comparisons | papers | corr | corr_paper_w | flip | flip_paper_w | sig_flip | se_ratio_mean | se_ratio_median | with_boot_cov | screen_twfe_only | neg_abs_mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| csa | main:pass_screen |  1 | 1 | NA | NA | 0.00000000 | 0.00000000 | 0 | NA | NA |  1 |  0 | 0.001 |
| bjs | main:pass_screen |  1 | 1 | NA | NA | 0.00000000 | 0.00000000 | 0 | 0.926 | 0.926 |  1 |  0 | 0.001 |
| csa | main:all |  1 | 1 | NA | NA | 0.00000000 | 0.00000000 | 0 | NA | NA |  1 |  0 | 0.001 |
| bjs | main:all |  1 | 1 | NA | NA | 0.00000000 | 0.00000000 | 0 | 0.926 | 0.926 |  1 |  0 | 0.001 |
| csa | controls:pass_screen |  5 | 1 | 0.532 | 0.532 | 0.00000000 | 0.00000000 | 0 | 8.989 | 0.993 |  0 |  5 | 0.000000000 |
| bjs | controls:pass_screen | 30 | 1 | 0.875 | 0.875 | 0.033 | 0.033 | 0 | 1.348 | 1.289 | 28 | 30 | 0.067 |
| csa | controls:all |  5 | 1 | 0.532 | 0.532 | 0.00000000 | 0.00000000 | 0 | 8.989 | 0.993 |  0 |  5 | 0.000000000 |
| bjs | controls:all | 30 | 1 | 0.875 | 0.875 | 0.033 | 0.033 | 0 | 1.348 | 1.289 | 28 | 30 | 0.067 |
