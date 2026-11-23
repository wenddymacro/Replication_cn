import csv
from pathlib import Path
import re
import sys

project = Path(sys.argv[1])
models = []
for line in (project / "source" / "程序.do").read_text(encoding="utf-8-sig").splitlines():
    if line.startswith("use 数据"):
        data = int(re.search(r"数据([12])", line)[1])
    if line.startswith("global"):
        controls = line.split('"')[1]
    if line.startswith("***"):
        section = re.search(r"(附表|附图|表)(\d+)", line)
        if section:
            label = dict(附表="A", 附图="F", 表="T")[section[1]] + section[2]
            index = 0
    if not line.startswith("reghdfe"):
        continue
    index += 1
    lhs, rhs, criterion, fixed, cluster = re.match(
        r"reghdfe\s+(\w+)\s+(.*?)(?:\s+if\s+([^,]+))?\s*,a\(([^)]+)\)\s*cl\((\w+)\)",
        line,
    ).groups()
    terms = []
    reported = []
    for token in rhs.strip().split():
        if token == "$con":
            terms.extend(controls.split())
            continue
        term = token.replace("c.", "")
        if "##" in term:
            left, right = term.split("##")
            terms.extend((left, right, f"{left}:{right}"))
            reported.extend((left, right, f"{left}:{right}"))
        elif "#" in term:
            generated = term.replace("#", ":")
            terms.append(generated)
            if not generated.endswith(":year"):
                reported.append(generated)
        else:
            terms.append(term)
            if term not in controls.split():
                reported.append(term)
    fixed = " + ".join(x.replace("#", "^") for x in fixed.split())
    models.append(dict(spec=f"{label}_{index}", data=data, y=lhs, rhs=" + ".join(terms),
                       target=" ".join(reported), subset=criterion or "", fixed=fixed, cluster=cluster))
with (project / "code" / "models.csv").open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=models[0].keys())
    writer.writeheader()
    writer.writerows(models)
print(len(models), "author regression commands registered")
