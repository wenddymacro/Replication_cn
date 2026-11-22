"""Joint 999-draw Bayesian bootstrap for TWFE, CSA and BJS estimates.

Draws county-level Dirichlet weights once per replicate and reuses the same
draw for all three estimators, preserving their joint covariance.
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd

root = Path(__file__).resolve().parents[1]
df = pd.read_stata(root / "data/author_original/main/Benchmark.dta", convert_categoricals=False)
df = df.sort_values(["id", "year"]).reset_index(drop=True)
ids, years = np.sort(df.id.unique()), np.sort(df.year.unique())
n, t = len(ids), len(years)
Y = df.KeyTech.to_numpy(float).reshape(n, t)
D = df.DID.to_numpy(float).reshape(n, t)
cohort = np.where(D.sum(axis=1) > 0, np.where(D == 1, np.broadcast_to(years, D.shape), np.inf).min(axis=1), 0)
sd_y = float(df.KeyTech.std(ddof=1))

def weighted_twfe(w):
    W = w[:, None]
    def resid(a):
        row = a.mean(axis=1, keepdims=True)
        col = (W * a).sum(axis=0, keepdims=True) / W.sum()
        grand = float((W * row).sum() / W.sum())
        return a - row - col + grand
    yd, dd = resid(Y), resid(D)
    return float((W * dd * yd).sum() / (W * dd * dd).sum())

def weighted_csa(w, waves=None):
    cells, weights = [], []
    cohorts = [int(c) for c in np.unique(cohort) if c > 0 and (waves is None or c in waves)]
    for g in cohorts:
        tg = cohort == g
        b = np.where(years == g - 1)[0]
        if not len(b):
            continue
        b = b[0]
        for j, year in enumerate(years):
            if year < g:
                continue
            ctl = (cohort == 0) | (cohort > year)
            wt, wc = w[tg], w[ctl]
            if wt.sum() == 0 or wc.sum() == 0:
                continue
            dt = Y[tg, j] - Y[tg, b]
            dc = Y[ctl, j] - Y[ctl, b]
            cells.append(float(np.average(dt, weights=wt) - np.average(dc, weights=wc)))
            weights.append(float(wt.sum()))
    return float(np.average(cells, weights=weights))

def weighted_bjs(w):
    untreated = D == 0
    alpha = np.zeros(n)
    lam = np.zeros(t)
    for it in range(3000):
        old = np.r_[alpha, lam]
        for i in range(n):
            m = untreated[i]
            if m.any():
                alpha[i] = np.mean(Y[i, m] - lam[m])
        for j in range(t):
            m = untreated[:, j]
            if m.any():
                lam[j] = np.average(Y[m, j] - alpha[m], weights=w[m])
        shift = lam.mean()
        lam -= shift
        alpha += shift
        if np.max(np.abs(np.r_[alpha, lam] - old)) < 1e-9:
            break
    pred = alpha[:, None] + lam[None, :]
    return float(np.average((Y - pred)[D == 1], weights=np.broadcast_to(w[:, None], D.shape)[D == 1]))

rng = np.random.default_rng(12345)
draws = np.empty((999, 3), dtype=float)
for b in range(999):
    w = rng.dirichlet(np.ones(n)) * n
    draws[b, :] = [weighted_twfe(w), weighted_csa(w), weighted_bjs(w)]
draws /= sd_y
diff_csa = draws[:, 0] - draws[:, 1]
diff_bjs = draws[:, 0] - draws[:, 2]
point = json.loads((root / "output/modern_points.json").read_text(encoding="utf-8"))
point_signs = np.sign([point["published_TWFE_standardized"],
                       point["CSA_all_DID_implied_cohorts_standardized"],
                       point["BJS_all_DID_implied_cohorts_standardized"]])

def summary(x):
    return {"mean": float(x.mean()), "sd": float(x.std(ddof=1)),
            "ci95_percentile": [float(q) for q in np.quantile(x, [0.025, 0.975])]}

out = {
    "bootstrap": "999 joint Bayesian bootstrap draws; county-level Dirichlet(1) weights; seed 12345",
    "standardization_sd": sd_y,
    "estimator_draws_standardized": {name: summary(draws[:, j]) for j, name in enumerate(["TWFE", "CSA", "BJS"])},
    "joint_covariance_standardized": np.cov(draws, rowvar=False, ddof=1).tolist(),
    "twfe_minus_csa": summary(diff_csa),
    "twfe_minus_bjs": summary(diff_bjs),
    "point_estimate_sign_reversal_twfe_vs_csa": bool(point_signs[0] != point_signs[1]),
    "point_estimate_sign_reversal_twfe_vs_bjs": bool(point_signs[0] != point_signs[2]),
    "bootstrap_sign_disagreement_probability_twfe_vs_csa": float(np.mean(np.sign(draws[:, 0]) != np.sign(draws[:, 1]))),
    "bootstrap_sign_disagreement_probability_twfe_vs_bjs": float(np.mean(np.sign(draws[:, 0]) != np.sign(draws[:, 2]))),
    "twfe_csa_difference_excludes_zero": bool(np.quantile(diff_csa, 0.025) > 0 or np.quantile(diff_csa, 0.975) < 0),
    "twfe_bjs_difference_excludes_zero": bool(np.quantile(diff_bjs, 0.025) > 0 or np.quantile(diff_bjs, 0.975) < 0),
    "standard_error_ratio_twfe_to_csa_bootstrap": float(draws[:, 0].std(ddof=1) / draws[:, 1].std(ddof=1)),
    "standard_error_ratio_twfe_to_bjs_bootstrap": float(draws[:, 0].std(ddof=1) / draws[:, 2].std(ddof=1)),
}
path = root / "output/joint_bootstrap_999.json"
path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(out, ensure_ascii=False, indent=2))
