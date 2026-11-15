"""Shared paths and helpers for the pipeline (standard library only)."""
import csv
import json
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUTPUT = ROOT / "output"
# Local, not-in-git directory with saved web pages, PDFs and packages (docs/DOWNLOAD.md)
RAW = Path(os.environ.get("CIE_RAW", "~/cie_raw")).expanduser()
JOURNAL = "cie"

# Items in the table of contents that are not research articles
NON_RESEARCH = re.compile(r"卷首语|征稿|征文|启事|会议综述|研讨会|论坛综述|观点摘要|总目录|目录|编者按|更正|勘误|声明|致谢审稿")


def read_text(path):
    """Read a text file that may be UTF-8 (with or without BOM), GBK or GB18030."""
    raw = Path(path).read_bytes()
    for enc in ("utf-8-sig", "gb18030"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            pass
    return raw.decode("utf-8", errors="replace")


def squash(s):
    """Remove all whitespace: pdftotext often splits Chinese words with spaces or line breaks."""
    return re.sub(r"\s+", "", s or "")


def write_csv(path, rows, fields=None):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = list(rows)
    if fields is None:
        fields = []
        for r in rows:
            for k in r:
                if k not in fields:
                    fields.append(k)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow(r)
    return path


def read_csv(path):
    path = Path(path)
    if not path.exists():
        return []
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def write_json(path, obj):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
