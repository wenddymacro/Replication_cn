"""Flag candidate papers by keyword signals and assign screening tiers (PROTOCOL Section 2).

Inputs:  data/frame/frame.csv, data/text/cie/<paper_id>.txt (if converted), data/packages/manifest.csv (if built)
Outputs: data/hits/keyword_hits.csv  (counts per keyword group and paper)
         data/candidates/candidates.csv (research articles with tier 1-3)
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import DATA, JOURNAL, read_csv, read_text, squash, write_csv  # noqa: E402

# Chinese terms are matched on whitespace-free text; English terms case-insensitively on the same text.
GROUPS = {
    "did": ["双重差分", "倍差法", "差分中的差分", "双差分", "DID", "DiD", "difference-in-difference", "differences-in-difference",
            "diff-in-diff"],
    "staggered": ["多期双重差分", "多时点双重差分", "渐进双重差分", "渐进式双重差分", "交错双重差分", "多期DID", "多时点DID",
                  "渐进DID", "渐进式DID", "交错DID", "交叠DID", "时变DID", "staggered", "分批", "逐步推广", "逐步推开",
                  "事件研究", "eventstudy", "event-study", "平行趋势"],
    "modern": ["Callaway", "Sant'Anna", "SantAnna", "SunandAbraham", "Sun&Abraham", "SunandAbrahm", "Borusyak", "插补估计",
               "did_imputation", "csdid", "deChaisemartin", "did_multiplegt", "Goodman-Bacon", "GoodmanBacon", "培根分解",
               "bacondecomp", "负权重", "异质性处理效应", "异质性稳健", "did2s", "jwdid", "eventstudyinteract", "堆叠双重差分",
               "堆叠DID", "stackedDID", "stackeddifference"],
}
ABSTRACT_SIGNAL = ["双重差分", "倍差", "准自然实验", "自然实验", "试点", "政策冲击", "事件研究", "DID", "外生冲击"]


def count(text, terms):
    out = {}
    low = text.lower()
    for t in terms:
        key = squash(t).lower()
        if re.search(r"[A-Za-z]", key):
            n = low.count(key)
        else:
            n = text.count(key)
        if n:
            out[t] = n
    return out


def main():
    frame = [r for r in read_csv(DATA / "frame" / "frame.csv") if r.get("research", "1") == "1"]
    pkg = {r["paper_id"]: r for r in read_csv(DATA / "packages" / "manifest.csv")}
    text_dir = DATA / "text" / JOURNAL
    hits, cands = [], []
    for r in frame:
        pid = r["paper_id"]
        tp = text_dir / f"{pid}.txt"
        meta = " ".join([r.get("title", ""), r.get("abstract", ""), r.get("keywords", "")])
        full = squash((read_text(tp) if tp.exists() else "") + meta)   # article text plus title/abstract/keywords
        g = {k: count(full, v) for k, v in GROUPS.items()}
        absig = count(squash(meta), ABSTRACT_SIGNAL)
        code_modern = pkg.get(pid, {}).get("modern_commands", "")
        code_event = pkg.get(pid, {}).get("event_time_signal", "") == "1"
        f_did, f_stag, f_mod = bool(g["did"]), bool(g["staggered"]) or code_event, bool(g["modern"]) or bool(code_modern)
        if f_did and (f_stag or f_mod):
            tier = 1
        elif f_did or f_stag or f_mod:
            tier = 2
        elif absig:
            tier = 3
        else:
            tier = ""
        row = {"paper_id": pid, "year": r.get("year"), "issue": r.get("issue"), "title": r.get("title"),
               "has_text": int(tp.exists()), "n_did": sum(g["did"].values()), "n_staggered": sum(g["staggered"].values()),
               "n_modern": sum(g["modern"].values()), "abstract_signal": int(bool(absig)),
               "code_modern": code_modern, "code_event_time": int(code_event), "tier": tier,
               "terms": "; ".join(f"{k}={v}" for d in list(g.values()) + [absig] for k, v in d.items())}
        hits.append(row)
        if tier:
            cands.append(row)
    write_csv(DATA / "hits" / "keyword_hits.csv", hits)
    write_csv(DATA / "candidates" / "candidates.csv", cands)
    by = {t: sum(1 for c in cands if c["tier"] == t) for t in (1, 2, 3)}
    no_text = sum(1 for h in hits if not h["has_text"])
    print(f"{len(frame)} research articles; candidates tier1={by[1]} tier2={by[2]} tier3={by[3]}; "
          f"{no_text} without full text (abstract signal only)")


if __name__ == "__main__":
    main()
