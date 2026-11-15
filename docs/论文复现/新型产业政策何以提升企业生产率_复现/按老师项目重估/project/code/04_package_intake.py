"""Inventory replication packages and extract regression commands.

Input:  $CIE_RAW/packages/<paper_id>/  (archives as downloaded from the article page, or loose files)
Output: $CIE_RAW/packages/<paper_id>/_extracted/      extracted archives (zip natively; rar/7z via `7z` or `unar` if installed)
        data/packages/<paper_id>_inventory.json       files by type, data/code flags, software
        data/packages/<paper_id>_regressions.txt      regression and estimator command lines found in the code
        data/packages/manifest.csv                    one row per package

Archives are untrusted: members with absolute paths or '..' are skipped, and nothing in a package is executed.
"""
import re
import shutil
import subprocess
import sys
import zipfile
from collections import Counter
from pathlib import Path, PurePosixPath

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import DATA, RAW, read_text, write_csv, write_json  # noqa: E402

DATA_EXT = {".dta", ".csv", ".xlsx", ".xls", ".rds", ".rdata", ".parquet", ".sav", ".txt", ".mat", ".json", ".feather"}
CODE_EXT = {".do": "Stata", ".ado": "Stata", ".r": "R", ".rmd": "R", ".py": "Python", ".ipynb": "Python", ".m": "MATLAB",
            ".jl": "Julia", ".sas": "SAS"}
ARCHIVE_EXT = {".zip", ".rar", ".7z"}
REG = re.compile(r"^\s*(?:qui(?:etly)?\s*:?\s*|eststo\s*:?\s*|est\s+sto\s*\w*\s*:\s*|xi\s*:\s*|bys(?:ort)?\s+[^:]+:\s*)*"
                 r"(reghdfe|xtreg|areg|reg|regress|ivreghdfe|ppmlhdfe|feols|lm|felm|csdid|did_imputation|did_multiplegt\w*|"
                 r"eventstudyinteract|did2s|jwdid|bacondecomp|sdid|xtdidregress|didregress|att_gt|aggte|PanelOLS)\b", re.I)
MODERN = re.compile(r"\b(csdid|did_imputation|did_multiplegt\w*|eventstudyinteract|did2s|jwdid|bacondecomp|att_gt|"
                    r"didimputation|staggered|hdidregress)\b", re.I)
EVENT = re.compile(r"(\w+\s*-\s*\w*(policy|treat|first|start|adopt|pilot)\w*year)|event_?time|rel_?time|\b(pre|lead|before)_?\d+\b|"
                   r"\b(post|lag|after|current)_?\d+\b|tsset.*\n.*gen\s+\w+\s*=\s*year\s*-", re.I)


def safe_members(names):
    for n in names:
        p = PurePosixPath(n.replace("\\", "/"))
        if p.is_absolute() or ".." in p.parts:
            continue
        yield n


def extract(archive, dest):
    dest.mkdir(parents=True, exist_ok=True)
    ext = archive.suffix.lower()
    if ext == ".zip":
        # names without the UTF-8 flag are decoded as GB18030 (Chinese Windows zip tools); needs Python >= 3.11
        try:
            z = zipfile.ZipFile(archive, metadata_encoding="gb18030")
            z.infolist()
        except (UnicodeDecodeError, TypeError):
            z = zipfile.ZipFile(archive)
        with z:
            for info in z.infolist():
                name = info.filename
                if info.is_dir() or name not in set(safe_members([name])):
                    continue
                target = dest / name
                target.parent.mkdir(parents=True, exist_ok=True)
                with z.open(info) as src, open(target, "wb") as out:
                    shutil.copyfileobj(src, out)
        return "ok"
    tool = shutil.which("7z") or shutil.which("7za") or shutil.which("unar")
    if not tool:
        return "needs 7z or unar"
    cmd = [tool, "x", "-y", f"-o{dest}", str(archive)] if "7z" in tool else [tool, "-q", "-o", str(dest), str(archive)]
    r = subprocess.run(cmd, capture_output=True, text=True)
    bad = [p for p in dest.rglob("*") if not p.resolve().is_relative_to(dest.resolve())]
    return "ok" if r.returncode == 0 and not bad else f"failed: {r.stderr[:200]}"


def intake(pdir):
    pid = pdir.name
    ex = pdir / "_extracted"
    status = {}
    for a in sorted(p for p in pdir.iterdir() if p.is_file() and p.suffix.lower() in ARCHIVE_EXT):
        if not (ex / a.stem).exists():
            status[a.name] = extract(a, ex / a.stem)
        else:
            status[a.name] = "already extracted"
    # nested archives one level down
    for a in sorted(p for p in ex.rglob("*") if p.is_file() and p.suffix.lower() in ARCHIVE_EXT) if ex.exists() else []:
        tgt = a.with_suffix("")
        if not tgt.exists():
            status[str(a.relative_to(pdir))] = extract(a, tgt)
    files = [p for p in pdir.rglob("*") if p.is_file() and p.suffix.lower() not in ARCHIVE_EXT]
    ext_count = Counter(p.suffix.lower() for p in files)
    data_files = [p for p in files if p.suffix.lower() in DATA_EXT and p.stat().st_size > 2000]
    code_files = [p for p in files if p.suffix.lower() in CODE_EXT]
    langs = Counter(CODE_EXT[p.suffix.lower()] for p in code_files)
    reg_lines, modern, event_sig = [], set(), False
    for c in code_files:
        txt = read_text(c)
        rel = c.relative_to(pdir)
        for i, line in enumerate(txt.splitlines(), 1):
            s = line.strip()
            if not s or s.startswith(("*", "//", "#")):
                continue
            if REG.search(s):
                reg_lines.append(f"{rel}:{i}: {s[:400]}")
            for m in MODERN.findall(s):
                modern.add(m.lower())
        if EVENT.search(txt):
            event_sig = True
    readme = [str(p.relative_to(pdir)) for p in files if re.search(r"readme|说明|read_me|使用", p.name, re.I)]
    synthetic = any(re.search(r"模拟数据|虚拟数据|随机生成|synthetic|simulated|脱敏|加噪", read_text(p)[:20000], re.I)
                    for p in files if p.suffix.lower() in {".txt", ".md"} and p.stat().st_size < 2_000_000)
    inv = {
        "paper_id": pid, "archives": status, "n_files": len(files), "extensions": dict(ext_count.most_common()),
        "data_files": [f"{p.relative_to(pdir)} ({p.stat().st_size // 1024} KB)" for p in data_files][:200],
        "code_files": [str(p.relative_to(pdir)) for p in code_files][:200], "software": dict(langs), "readme": readme,
        "modern_commands": sorted(modern), "event_time_signal": event_sig, "synthetic_hint": synthetic,
        "n_regression_lines": len(reg_lines),
    }
    out = DATA / "packages"
    write_json(out / f"{pid}_inventory.json", inv)
    (out / f"{pid}_regressions.txt").write_text("\n".join(reg_lines) + "\n", encoding="utf-8")
    if data_files and code_files:
        pstatus = "data_and_code"
    elif code_files:
        pstatus = "code_only"
    elif data_files:
        pstatus = "data_only"
    else:
        pstatus = "empty"
    return {"paper_id": pid, "package_status": pstatus, "n_files": len(files), "n_data": len(data_files),
            "n_code": len(code_files), "software": "+".join(sorted(langs)), "modern_commands": " ".join(sorted(modern)),
            "event_time_signal": int(event_sig), "synthetic_hint": int(synthetic), "n_regression_lines": len(reg_lines),
            "has_readme": int(bool(readme)), "archive_problems": "; ".join(k for k, v in status.items() if not v.startswith(("ok", "already")))}


def main():
    root = RAW / "packages"
    if not root.exists():
        print(f"no packages directory at {root} (see docs/DOWNLOAD.md)")
        return
    rows = [intake(p) for p in sorted(root.iterdir()) if p.is_dir() and not p.name.startswith("_")]
    write_csv(DATA / "packages" / "manifest.csv", rows)
    c = Counter(r["package_status"] for r in rows)
    print(f"{len(rows)} packages: " + ", ".join(f"{k}={v}" for k, v in c.items()) + " -> data/packages/manifest.csv")


if __name__ == "__main__":
    main()
