Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs
and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);
se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage
alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).

| estimator | sample | comparisons | papers | corr | corr_paper_w | flip | flip_paper_w | sig_flip | se_ratio_mean | se_ratio_median | with_boot_cov | screen_twfe_only | neg_abs_mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| csa | main:pass_screen |  1 | 1 | NA | NA | 1.00 | 1.00 | 1 | 1.144 | 1.144 |  1 |  0 | 0.008 |
| bjs | main:pass_screen |  1 | 1 | NA | NA | 0.00 | 0.00 | 0 | 0.974 | 0.974 |  1 |  0 | 0.008 |
| csa | main:all |  1 | 1 | NA | NA | 1.00 | 1.00 | 1 | 1.144 | 1.144 |  1 |  0 | 0.008 |
| bjs | main:all |  1 | 1 | NA | NA | 0.00 | 0.00 | 0 | 0.974 | 0.974 |  1 |  0 | 0.008 |
| csa | controls:pass_screen |  4 | 1 | 0.849 | 0.849 | 0.250 | 0.250 | 0 | 1.969 | 1.910 |  0 |  4 | 0.012 |
| bjs | controls:pass_screen | 20 | 1 | 0.975 | 0.975 | 0.050 | 0.050 | 0 | 1.047 | 1.040 | 20 | 20 | 0.019 |
| csa | controls:all |  4 | 1 | 0.849 | 0.849 | 0.250 | 0.250 | 0 | 1.969 | 1.910 |  0 |  4 | 0.012 |
| bjs | controls:all | 20 | 1 | 0.975 | 0.975 | 0.050 | 0.050 | 0 | 1.047 | 1.040 | 20 | 20 | 0.019 |
