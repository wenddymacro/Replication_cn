Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs
and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);
se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage
alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).

| estimator | sample | comparisons | papers | corr | corr_paper_w | flip | flip_paper_w | sig_flip | se_ratio_mean | se_ratio_median | with_boot_cov | screen_twfe_only | neg_abs_mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| csa | main:pass_screen |  2 | 1 | NA | NA | 0 | 0 | 0 | 1.140 | 1.140 |  2 |  0 | 0.006 |
| bjs | main:pass_screen |  2 | 1 | NA | NA | 0 | 0 | 0 | 1.067 | 1.067 |  2 |  0 | 0.006 |
| csa | main:all |  2 | 1 | NA | NA | 0 | 0 | 0 | 1.140 | 1.140 |  2 |  0 | 0.006 |
| bjs | main:all |  2 | 1 | NA | NA | 0 | 0 | 0 | 1.067 | 1.067 |  2 |  0 | 0.006 |
| csa | controls:pass_screen |  8 | 1 | 0.653 | 0.653 | 0 | 0 | 0 | 1.549 | 1.625 |  0 |  8 | 0.006 |
| bjs | controls:pass_screen | 10 | 1 | 0.902 | 0.902 | 0 | 0 | 0 | 1.041 | 1.063 | 10 | 10 | 0.006 |
| csa | controls:all |  8 | 1 | 0.653 | 0.653 | 0 | 0 | 0 | 1.549 | 1.625 |  0 |  8 | 0.006 |
| bjs | controls:all | 10 | 1 | 0.902 | 0.902 | 0 | 0 | 0 | 1.041 | 1.063 | 10 | 10 | 0.006 |
