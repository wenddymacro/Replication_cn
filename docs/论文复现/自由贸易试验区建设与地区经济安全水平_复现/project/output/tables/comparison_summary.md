Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs
and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);
se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage
alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).

| estimator | sample | comparisons | papers | corr | corr_paper_w | flip | flip_paper_w | sig_flip | se_ratio_mean | se_ratio_median | with_boot_cov | screen_twfe_only | neg_abs_mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| csa | main:pass_screen |  1 | 1 | NA | NA | 0.0 | 0.0 | 0.00000000 | 1.103 | 1.103 |  1 |  0 | 0.0000000 |
| bjs | main:pass_screen |  1 | 1 | NA | NA | 0.0 | 0.0 | 0.00000000 | 1.026 | 1.026 |  1 |  0 | 0.0000000 |
| csa | main:all |  1 | 1 | NA | NA | 0.0 | 0.0 | 0.00000000 | 1.103 | 1.103 |  1 |  0 | 0.0000000 |
| bjs | main:all |  1 | 1 | NA | NA | 0.0 | 0.0 | 0.00000000 | 1.026 | 1.026 |  1 |  0 | 0.0000000 |
| csa | controls:pass_screen | 14 | 1 | 0.687 | 0.687 | 0.500 | 0.500 | 0.071 | 2.131 | 2.152 |  0 | 14 | 0.018 |
| bjs | controls:pass_screen | 14 | 1 | 0.999 | 0.999 | 0.0 | 0.0 | 0.00000000 | 1.235 | 1.204 | 14 | 14 | 0.018 |
| csa | controls:all | 14 | 1 | 0.687 | 0.687 | 0.500 | 0.500 | 0.071 | 2.131 | 2.152 |  0 | 14 | 0.018 |
| bjs | controls:all | 14 | 1 | 0.999 | 0.999 | 0.0 | 0.0 | 0.00000000 | 1.235 | 1.204 | 14 | 14 | 0.018 |
