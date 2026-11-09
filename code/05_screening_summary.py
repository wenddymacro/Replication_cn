"""Collect screening records and write the candidate-to-replication funnel (Proserpio 2026, Table 2).

Inputs:  data/frame/frame.csv, data/candidates/candidates.csv, data/packages/manifest.csv,
         data/screening/by_paper/*.json, data/specs/*.json, output/specs/*.csv
Outputs: data/screening/screened.csv, data/screening/near_miss.csv, output/tables/funnel.csv, output/tables/funnel.md
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import DATA, OUTPUT, read_csv, write_csv  # noqa: E402


def main():
    frame = [r for r in read_csv(DATA / "frame" / "frame.csv") if r.get("research", "1") == "1"]
    cands = {r["paper_id"]: r for r in read_csv(DATA / "candidates" / "candidates.csv")}
    pkg = {r["paper_id"]: r for r in read_csv(DATA / "packages" / "manifest.csv")}
    recs = []
    for p in sorted((DATA / "screening" / "by_paper").glob("*.json")):
        r = json.loads(p.read_text(encoding="utf-8"))
        r["candidate"] = int(r["paper_id"] in cands)
        r["tier"] = cands.get(r["paper_id"], {}).get("tier", "")
        recs.append(r)
    flat = []
    for r in recs:
        flat.append({k: (json.dumps(v, ensure_ascii=False) if isinstance(v, (list, dict)) else v)
                     for k, v in r.items() if k not in ("eligible_specs", "near_miss_controls_only_specs", "ineligible_specs",
                                                        "appendix_specs")}
                    | {"n_controls_only_specs": len(r.get("near_miss_controls_only_specs", [])),
                       "n_appendix_specs": len(r.get("appendix_specs", []))})
    write_csv(DATA / "screening" / "screened.csv", flat)
    write_csv(DATA / "screening" / "near_miss.csv",
              [f for f in flat if str(f.get("near_miss")).lower() == "true"])

    specs = list((DATA / "specs").glob("cie*.json"))
    spec_papers = {s.name.split("__")[0] for s in specs}
    out_papers = {s.name.split("__")[0] for s in (OUTPUT / "specs").glob("cie*.csv")}
    elig = [r for r in recs if r.get("eligible_design")]

    def n(rs, cond):
        return sum(1 for r in rs if cond(r))

    rows = [
        ("框架内研究论文", len(frame)),
        ("候选论文（Tier 1-3）", len(cands)),
        ("  其中 Tier 1", n(cands.values(), lambda r: r["tier"] == "1")),
        ("候选中有附件", n(cands, lambda p: p in pkg)),
        ("  附件含数据与代码", n(cands, lambda p: pkg.get(p, {}).get("package_status") == "data_and_code")),
        ("  附件仅含代码", n(cands, lambda p: pkg.get(p, {}).get("package_status") == "code_only")),
        ("已筛选论文", len(recs)),
        ("  其中非候选（召回率检查）", n(recs, lambda r: not r["candidate"])),
        ("交错设计（任一设定）", n(recs, lambda r: r.get("staggered_design"))),
        ("合格交错设计", len(elig)),
        ("  数据为模拟/脱敏", n(elig, lambda r: r.get("package_status") == "synthetic")),
        ("  附件无分析数据", n(elig, lambda r: r.get("package_status") in ("code_only", "empty"))),
        ("  无附件", n(elig, lambda r: r.get("package_status") in ("none", "", None))),
        ("  可用数据", n(elig, lambda r: r.get("package_status") == "data_and_code")),
        ("    已写 spec", n(elig, lambda r: r["paper_id"] in spec_papers)),
        ("    已重估", n(elig, lambda r: r["paper_id"] in out_papers)),
        ("近似合格（near-miss）", n(recs, lambda r: r.get("near_miss"))),
        ("  唯一违反项为随时间变化的控制变量", n(recs, lambda r: r.get("near_miss_controls_only"))),
        ("主样本设定数", len(specs)),
        ("二级样本（带控制变量）设定数", len(list((DATA / "specs_controls").glob("cie*.json")))),
    ]
    write_csv(OUTPUT / "tables" / "funnel.csv", [{"row": a, "cie": b} for a, b in rows])
    md = ["| | 中国工业经济 |", "|---|---:|"] + [f"| {a.replace('  ', '&nbsp;&nbsp;')} | {b} |" for a, b in rows]
    (OUTPUT / "tables" / "funnel.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    print("\n".join(f"{a:<30}{b:>6}" for a, b in rows))


if __name__ == "__main__":
    main()
