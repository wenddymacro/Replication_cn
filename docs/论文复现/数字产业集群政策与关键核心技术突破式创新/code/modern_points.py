"""Protocol-aligned point estimates for the static, no-control baseline.

Treatment cohorts are derived from Benchmark.dta's published DID indicator.
The separate author CSDID.dta cohort field is audited separately because it
does not agree with this treatment timing for all counties.
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd

root = Path(__file__).resolve().parents[1]
df = pd.read_stata(root / "data/author_original/main/Benchmark.dta", convert_categoricals=False)
df = df.sort_values(["id", "year"]).reset_index(drop=True)
ids = np.sort(df.id.unique())
years = np.sort(df.year.unique())
N, T = len(ids), len(years)
Y = df.KeyTech.to_numpy(float).reshape(N, T)
D = df.DID.to_numpy(float).reshape(N, T)
sd_y = float(df.KeyTech.std(ddof=1))
g = np.where(D.sum(axis=1) > 0, np.where(D == 1, np.broadcast_to(years, D.shape), np.inf).min(axis=1), 0)
cohort_sizes = {str(int(c)): int((g == c).sum()) for c in np.unique(g)}

# Callaway-Sant'Anna-style group-time ATT: base year g-1; never- and not-yet-treated controls.
att_cells = []
for cohort in sorted(int(c) for c in np.unique(g) if c > 0):
    treated = g == cohort
    base_idx = np.where(years == cohort - 1)[0]
    if not len(base_idx):
        continue
    b = base_idx[0]
    for j, year in enumerate(years):
        if year < cohort:
            continue
        control = (g == 0) | (g > year)
        if not treated.any() or not control.any():
            continue
        delta_t = Y[treated, j] - Y[treated, b]
        delta_c = Y[control, j] - Y[control, b]
        att_cells.append({"cohort": cohort, "year": int(year), "att": float(delta_t.mean() - delta_c.mean()),
                          "n_treated": int(treated.sum()), "n_control": int(control.sum())})

def aggregate(cells):
    w = np.array([x["n_treated"] for x in cells], dtype=float)
    a = np.array([x["att"] for x in cells], dtype=float)
    return float(np.average(a, weights=w))

# Each cohort receives total weight proportional to cohort size times its number of post periods.
csa_raw = aggregate(att_cells)

# Sensitivity to the three policy waves described in the paper (2013, 2014, 2017).
policy_cells = [x for x in att_cells if x["cohort"] in (2013, 2014, 2017)]
csa_3wave_raw = aggregate(policy_cells)

# BJS imputation: estimate additive unit and year effects using untreated observations only.
untreated = D == 0
alpha = np.zeros(N)
lam = np.zeros(T)
for it in range(10000):
    old = np.r_[alpha, lam]
    for i in range(N):
        m = untreated[i]
        if m.any():
            alpha[i] = np.mean(Y[i, m] - lam[m])
    for j in range(T):
        m = untreated[:, j]
        if m.any():
            lam[j] = np.mean(Y[m, j] - alpha[m])
    # Set a stable normalization without changing fitted values.
    shift = lam.mean()
    lam -= shift
    alpha += shift
    if np.max(np.abs(np.r_[alpha, lam] - old)) < 1e-10:
        break
if it == 9999:
    raise RuntimeError("BJS fixed-effect imputation did not converge")
y0 = alpha[:, None] + lam[None, :]
bjs_raw = float((Y[D == 1] - y0[D == 1]).mean())

# TWFE coefficient from the exactly matched independent calculation.
twfe = json.loads((root / "output/initial_twfe.json").read_text(encoding="utf-8"))["published_col_1"]["b"][0]
result = {
    "spec": "KeyTech ~ DID + county FE + year FE; full 435-county balanced panel; no time-varying controls",
    "N": int(N*T), "counties": N, "years": [int(years.min()), int(years.max())],
    "treatment_cohort_counts_from_Benchmark_DID": cohort_sizes,
    "published_TWFE_raw": twfe,
    "published_TWFE_standardized": twfe / sd_y,
    "CSA_all_DID_implied_cohorts_raw": csa_raw,
    "CSA_all_DID_implied_cohorts_standardized": csa_raw / sd_y,
    "CSA_2013_2014_2017_waves_raw": csa_3wave_raw,
    "CSA_2013_2014_2017_waves_standardized": csa_3wave_raw / sd_y,
    "BJS_all_DID_implied_cohorts_raw": bjs_raw,
    "BJS_all_DID_implied_cohorts_standardized": bjs_raw / sd_y,
    "SD_KeyTech": sd_y, "BJS_FE_iterations": int(it + 1),
    "CSA_cell_count_all": len(att_cells), "CSA_cell_count_3wave": len(policy_cells),
    "CSA_cells_all": att_cells,
}
out = root / "output/modern_points.json"
out.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({k:v for k,v in result.items() if k != "CSA_cells_all"}, ensure_ascii=False, indent=2))
