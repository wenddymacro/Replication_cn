Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs
and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);
se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage
alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).

| estimator | sample | comparisons | papers | corr | corr_paper_w | flip | flip_paper_w | sig_flip | se_ratio_mean | se_ratio_median | with_boot_cov | screen_twfe_only | neg_abs_mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| csa | main:pass_screen | 1 | 1 | NA | NA | 0.00 | 0.00 | 0.000 | 1.579 | 1.579 | 1 | 0 | 0.134 |
| bjs | main:pass_screen | 1 | 1 | NA | NA | 0.00 | 0.00 | 0.000 | 1.320 | 1.320 | 1 | 0 | 0.134 |
| csa | main:all | 1 | 1 | NA | NA | 0.00 | 0.00 | 0.000 | 1.579 | 1.579 | 1 | 0 | 0.134 |
| bjs | main:all | 1 | 1 | NA | NA | 0.00 | 0.00 | 0.000 | 1.320 | 1.320 | 1 | 0 | 0.134 |
| csa | controls:pass_screen | 8 | 1 | -0.842 | -0.842 | 0.250 | 0.250 | 0.125 | 1.991 | 2.217 | 0 | 8 | 0.153 |
| bjs | controls:pass_screen | 8 | 1 | -0.491 | -0.491 | 0.00 | 0.00 | 0.000 | 1.250 | 1.309 | 8 | 8 | 0.153 |
| csa | controls:all | 8 | 1 | -0.842 | -0.842 | 0.250 | 0.250 | 0.125 | 1.991 | 2.217 | 0 | 8 | 0.153 |
| bjs | controls:all | 8 | 1 | -0.491 | -0.491 | 0.00 | 0.00 | 0.000 | 1.250 | 1.309 | 8 | 8 | 0.153 |
