import csv
from pathlib import Path
import re
import sys

out = Path(sys.argv[1]) / "output"
with (out / "appendix_tables_A4_A8.csv").open(encoding="utf-8") as file:
    computed = {row["spec_id"]: row for row in csv.DictReader(file) if row["term"] == "Integ"}
with (out / "appendix_A9_psm_R.csv").open(encoding="utf-8") as file:
    computed.update({f"A9_{i}": row for i, row in enumerate(csv.DictReader(file), 1)})
rows = []
for table, page in {4: 3, 5: 4, 6: 5, 7: 6, 8: 7, 9: 9}.items():
    lines = [line.strip() for line in (out / f"appendix-source-{page:02}.txt").read_text(encoding="utf-8").splitlines() if line.strip()]
    start = next(i for i, line in enumerate(lines) if line.startswith("Integ -"))
    n_start = next(i for i, line in enumerate(lines[start:], start) if line.startswith("观测值 "))
    printed = dict(
        coef=re.findall(r"-?\d+\.\d+", lines[start]),
        se=re.findall(r"\d+\.\d+", lines[start+1]),
        n=lines[n_start].replace(",", "").split()[1:],
        r2=lines[n_start+2].split()[1:],
    )
    count = len(printed["coef"])
    assert all(len(values) == count for values in printed.values())
    for index in range(count):
        key = f"A{table}_{index+1}"
        row = {"spec_id": key}
        for field, values in printed.items():
            value = computed[key][field]
            row[field] = value
            row[f"published_{field}"] = values[index]
            row[f"match_{field}"] = int(value) == int(values[index]) if field == "n" else round(float(value), 4) == float(values[index])
        rows.append(row)
assert len(rows) == 20
for row in rows:
    assert all(value for field, value in row.items() if field.startswith("match_")), row
with (out / "附表数值对照.csv").open("w", newline="", encoding="utf-8-sig") as file:
    writer = csv.DictWriter(file, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)
print(f"{len(rows)} appendix columns matched")

source = (out / "appendix-source-02.txt").read_text(encoding="utf-8")
a3 = []
with (out / "appendix_table_A3.csv").open(encoding="utf-8") as file:
    for original in csv.DictReader(file):
        name = original["variable"]
        shown = "Struc" if name == "Str" else name
        match = re.search(rf"\b{shown}\s+([\d,]+)((?:\s+-?\d+\.\d{{4}}){{5}})", source)
        assert match, shown
        printed_values = [match[1].replace(",", ""), *match[2].split()]
        row = {"variable": name}
        for field, value in zip(("N","mean","median","sd","min","max"), printed_values):
            row[field] = original[field]
            row[f"published_{field}"] = value
            row[f"match_{field}"] = round(float(original[field]), 4) == float(value)
        assert all(value for field, value in row.items() if field.startswith("match_")), row
        a3.append(row)
assert len(a3) == 14
with (out / "附表A3数值对照.csv").open("w", newline="", encoding="utf-8-sig") as file:
    writer = csv.DictWriter(file, fieldnames=a3[0].keys())
    writer.writeheader()
    writer.writerows(a3)
print(f"{len(a3)} descriptive-statistic rows matched")
