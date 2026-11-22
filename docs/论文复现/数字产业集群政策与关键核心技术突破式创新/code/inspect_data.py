from pathlib import Path
import pandas as pd

root = Path(__file__).resolve().parents[1]
for name in ["Benchmark", "CSDID", "Counterfactual"]:
    p = root / "data" / "author_original" / "main" / f"{name}.dta"
    df = pd.read_stata(p, convert_categoricals=False)
    print(f"\n[{name}] n={len(df)} p={len(df.columns)}")
    print("columns:", ", ".join(df.columns))
    for c in ["id", "year", "Treat", "DID", "reformyear", "KeyTech", "KeyTech_w"]:
        if c in df:
            print(c, "missing", int(df[c].isna().sum()), "unique", df[c].nunique(), "min", df[c].min(), "max", df[c].max())
    if {"id", "year"}.issubset(df.columns):
        print("duplicate id-year:", int(df.duplicated(["id", "year"]).sum()))
    if {"id", "year", "DID"}.issubset(df.columns):
        print("DID first year by id, sample:")
        first = df.loc[df.DID.eq(1)].groupby("id").year.min()
        print(first.value_counts().sort_index().to_dict())
        print("treated IDs:", len(first), "never treated:", df.id.nunique() - len(first))
    if {"id", "year", "reformyear"}.issubset(df.columns):
        print("reformyear distribution:", df.groupby("id").reformyear.first().value_counts(dropna=False).sort_index().to_dict())
    print("years:", sorted(df.year.unique().tolist()) if "year" in df else "")

benchmark = pd.read_stata(root / "data" / "author_original" / "main" / "Benchmark.dta", convert_categoricals=False)
csdata = pd.read_stata(root / "data" / "author_original" / "main" / "CSDID.dta", convert_categoricals=False)
cohort_main = benchmark.loc[benchmark.DID.eq(1)].groupby("id").year.min().rename("main_did_cohort")
cohort_cs = csdata.loc[csdata.reformyear.gt(0)].groupby("id").reformyear.first().rename("csdid_reformyear")
cohorts = pd.concat([cohort_main, cohort_cs], axis=1).fillna(0)
print("\n[Cohort cross-file check]")
print(pd.crosstab(cohorts.main_did_cohort, cohorts.csdid_reformyear, margins=True).to_string())
merged = benchmark.merge(csdata, on=["id", "year"], suffixes=("_main", "_cs"))
print("same panel cells:", len(merged), "KeyTech mismatches:", int((merged.KeyTech_main != merged.KeyTech_cs).sum()),
      "DID mismatches:", int((merged.DID_main != merged.DID_cs).sum()))
print("DID/reformyear consistency in CSDID:", int((merged.DID_cs != (merged.reformyear.gt(0) & merged.year.ge(merged.reformyear))).sum()))
if "pro_id" in benchmark:
    print("Benchmark id to province ids:", benchmark.groupby("id").pro_id.first().nunique(), "unique pro_id values")
