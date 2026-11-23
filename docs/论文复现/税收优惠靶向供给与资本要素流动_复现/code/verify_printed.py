import csv
from pathlib import Path
import sys

root=Path(sys.argv[1])
rows=[]
dof_file=root/"output"/"dof_audit_T7_1.csv"
corrected_ar2=None
if dof_file.exists():
    with dof_file.open(encoding="utf-8") as f:
        corrected_ar2=next(csv.DictReader(f))["adjusted_r2_reghdfe"]
with (root/"code"/"printed.csv").open(encoding="utf-8-sig") as file:
    for record in csv.DictReader(file):
        spec=record["spec"]
        with (root/"output"/f"{spec}.csv").open(encoding="utf-8") as calculated:
            estimates=list(csv.DictReader(calculated))
        coefficients=record["coef"].split()
        errors=record["se"].split()
        assert len(estimates)==len(coefficients)==len(errors), (spec,len(estimates),len(coefficients))
        for estimate, coef, se in zip(estimates,coefficients,errors):
            row=estimate.copy()
            row["ar2_fixest"]=row["ar2"]
            if spec=="T7_1" and corrected_ar2 is not None:
                row["ar2"]=corrected_ar2
            for field, expected in [("coef",coef),("se",se),("n",record["n"]),("ar2",record["ar2"])]:
                got=row[field]
                same=(not got) if expected=="." else (bool(got) and round(float(got),4)==float(expected))
                row["printed_"+field]=expected
                row["match_"+field]=same
            rows.append(row)
dest=root/"output"/"作者回归印刷值核验.csv"
with dest.open("w",encoding="utf-8-sig",newline="") as file:
    writer=csv.DictWriter(file,fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)
for row in rows:
    bad={k:row[k[6:]]+" vs "+row["printed_"+k[6:]] for k in row if k.startswith("match_") and not row[k]}
    if bad: print(row["spec_id"],row["term"],bad)
print("columns",len({row["spec_id"] for row in rows}),"coefficients",len(rows))

