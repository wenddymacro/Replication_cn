Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs
and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);
se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage
alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).

| estimator | sample | comparisons | papers | corr | corr_paper_w | flip | flip_paper_w | sig_flip | se_ratio_mean | se_ratio_median | with_boot_cov | screen_twfe_only | neg_abs_mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bjs | controls:pass_screen | 17 | 1 | 0.202 | 0.202 | 0.471 | 0.471 | 0.059 | 2.367 | 1.883 | 15 | 17 | 0.221 |
| bjs | controls:all | 17 | 1 | 0.202 | 0.202 | 0.471 | 0.471 | 0.059 | 2.367 | 1.883 | 15 | 17 | 0.221 |
