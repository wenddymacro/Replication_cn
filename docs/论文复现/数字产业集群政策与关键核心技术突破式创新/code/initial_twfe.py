"""Independent numerical check of the author's baseline FE columns.

Uses the official Benchmark.dta and the balanced-panel two-way demeaning
identity. This does not replace the author's Stata/reghdfe run.
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd

root = Path(__file__).resolve().parents[1]
df = pd.read_stata(root / "data/author_original/main/Benchmark.dta", convert_categoricals=False)
df = df.sort_values(["id", "year"]).reset_index(drop=True)
assert len(df) == df.id.nunique() * df.year.nunique()
assert not df.duplicated(["id", "year"]).any()

def demean(v, weights=None):
    """Two-way FE residuals for a complete balanced panel."""
    n, t = df.id.nunique(), df.year.nunique()
    a = np.asarray(v, dtype=float).reshape(n, t)
    if weights is None:
        return (a - a.mean(axis=1, keepdims=True) - a.mean(axis=0, keepdims=True) + a.mean()).ravel()
    w = np.asarray(weights, dtype=float).reshape(n, 1)
    row = a.mean(axis=1, keepdims=True)
    col = (w * a).sum(axis=0, keepdims=True) / w.sum()
    grand = float((w * row).sum() / w.sum())
    return (a - row - col + grand).ravel()

def fit(outcome, terms):
    y = demean(df[outcome].to_numpy())
    X = np.column_stack([demean(df[v].to_numpy()) for v in terms])
    inv = np.linalg.pinv(X.T @ X)
    b = inv @ X.T @ y
    e = y - X @ b
    meat = X.T @ (X * (e * e)[:, None])
    # reghdfe's robust small-sample factor includes the absorbed FE rank.
    absorbed_rank = df.id.nunique() + df.year.nunique() - 1
    df_r = len(y) - len(terms) - absorbed_rank
    cov = inv @ meat @ inv * (len(y) / df_r)
    return {"b": b.tolist(), "se": np.sqrt(np.diag(cov)).tolist(), "N": int(len(y)),
            "r2_within": float(1 - (e @ e) / (y @ y)), "df_r": int(df_r)}

specs = {
    "published_col_1": ("KeyTech", ["DID"]),
    "published_col_2": ("KeyTech", ["DID", "Area", "Pgdp", "Population", "Industrilazion", "Government", "Agglomeration"]),
}
results = {}
for key, (y, x) in specs.items():
    sample = df[y].notna()
    d0 = df.loc[sample].copy()
    # The printed table includes 9,347 rows in col (3); re-estimate on its exact complete-case sample.
    if len(d0) != len(df):
        # Work on the reduced balanced panel only if complete cases preserve the panel grid.
        ids, years = d0.id.nunique(), d0.year.nunique()
        if len(d0) != ids * years:
            d0 = d0.dropna(subset=x)
        assert len(d0) == d0.id.nunique() * d0.year.nunique(), (key, len(d0))
        old = df
        df = d0.reset_index(drop=True)
        results[key] = fit(y, x)
        df = old
    else:
        results[key] = fit(y, x)
results["details"] = {
    "baseline_printed": {"b": 5.2924, "se": 1.1025, "N": 9570},
    "control_printed": {"b": 4.6533, "se": 1.0585, "N": 9570},
    "sd_KeyTech": float(df.KeyTech.std(ddof=1)),
}
out = root / "output/initial_twfe.json"
out.parent.mkdir(exist_ok=True)
out.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(results, ensure_ascii=False, indent=2))
