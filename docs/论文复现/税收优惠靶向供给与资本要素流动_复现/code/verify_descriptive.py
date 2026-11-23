import csv
from pathlib import Path
import sys
import re

root=Path(sys.argv[1])
with (root/"output"/"descriptive_A1.csv").open(encoding="utf-8") as f:
    computed=list(csv.DictReader(f))
source=(root/"output"/"附录.txt").read_text(encoding="utf-8")
table=source.split("Panel A：",1)[1].split("===== 3 =====",1)[0]
printed=re.findall(r"(?m)^\S+ (\d+) (-?\d+\.\d{4}) (-?\d+\.\d{4}) (-?\d+\.\d{4}) (-?\d+\.\d{4})$",table)
assert len(computed)==len(printed)==16
for row,expected in zip(computed,printed):
    for field,value in zip(("n","mean","sd","min","max"),expected):
        row["published_"+field]=value
        row["match_"+field]=round(float(row[field]),4)==float(value)
        assert row["match_"+field], (row["panel"],row["variable"],field)
with (root/"output"/"附表1印刷值核验.csv").open("w",encoding="utf-8-sig",newline="") as f:
    writer=csv.DictWriter(f,fieldnames=computed[0].keys())
    writer.writeheader()
    writer.writerows(computed)
