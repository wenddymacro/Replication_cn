"""Build the search frame from saved CIE issue and article pages (docs/DOWNLOAD.md).

Inputs (local, not in git):
  $CIE_RAW/issues/YYYY_NN.html      table of contents of one issue (/Magazine/GetIssueContentList?Year=..&Issue=..)
  $CIE_RAW/articles/<site_id>.html  article page (/Magazine/Show?id=<site_id>)
  data/frame/frame_manual.csv       optional CNKI-style list: paper_id,year,issue,seq,title,authors,abstract,keywords,site_id,pages
Output:
  data/frame/frame.csv              one row per item; research = 1 for research articles

The site's HTML layout is not documented, so the parser is deliberately loose: it takes every link to
/Magazine/Show?id=N on an issue page (in page order) and, on article pages, the title, the text after
摘要/关键词 labels and every link that looks like a PDF or attachment download.
"""
import html
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import DATA, JOURNAL, NON_RESEARCH, RAW, read_csv, read_text, write_csv  # noqa: E402

SHOW = re.compile(r'href="[^"]*?/Magazine/Show\?id=(\d+)[^"]*"[^>]*>(.*?)</a>', re.S | re.I)
LINK = re.compile(r'href="([^"]+)"[^>]*>(.*?)</a>', re.S | re.I)
DOWNLOAD_HINT = re.compile(r"\.(pdf|zip|rar|7z|gz|dta|do|csv|xlsx?)(\?|$)|download|upload|attach|附件|数据|代码|程序|下载|全文",
                           re.I)


def clean(fragment):
    t = re.sub(r"<script.*?</script>|<style.*?</style>", " ", fragment, flags=re.S | re.I)
    t = re.sub(r"<[^>]+>", " ", t)
    return re.sub(r"\s+", " ", html.unescape(t)).strip()


def parse_issue(path):
    m = re.match(r"(\d{4})_(\d{1,2})", path.stem)
    if not m:
        print(f"skip {path.name}: name must be YYYY_NN.html", file=sys.stderr)
        return []
    year, issue = int(m.group(1)), int(m.group(2))
    rows, seen = [], set()
    for sid, inner in SHOW.findall(read_text(path)):
        title = clean(inner)
        if not title or sid in seen:  # image links repeat the same id without text
            continue
        seen.add(sid)
        rows.append({"paper_id": f"{JOURNAL}{sid}", "site_id": sid, "year": year, "issue": issue,
                     "seq": len(rows) + 1, "title": title})
    return rows


def labelled(text, label, stop):
    m = re.search(r"(?:" + label + r")\s*[:：]?\s*(.+?)(?=" + stop + r"|$)", text, re.S)
    return m.group(1).strip()[:3000] if m else ""


def parse_article(path):
    h = read_text(path)
    text = clean(h)
    title = ""
    for pat in (r'<meta[^>]+name="citation_title"[^>]+content="([^"]+)"', r"<h1[^>]*>(.*?)</h1>",
                r"<h2[^>]*>(.*?)</h2>", r"<title>(.*?)</title>"):
        m = re.search(pat, h, re.S | re.I)
        if m and clean(m.group(1)):
            title = clean(m.group(1))
            break
    stop = r"关键词|关键字|JEL|\[?中图分类号|文献标识码|Abstract|ABSTRACT|基金|作者简介|DOI|下载"
    downloads = []
    for href, inner in LINK.findall(h):
        label = clean(inner)
        if DOWNLOAD_HINT.search(href) or DOWNLOAD_HINT.search(label):
            if href.startswith(("javascript", "#", "mailto")) or "/Admin/" in href:
                continue
            downloads.append(f"{label}|{html.unescape(href)}")
    doi = re.search(r"10\.\d{4,9}/[^\s\"<>，；;]+", text)
    return {
        "site_id": path.stem,
        "title_article": title,
        "abstract": labelled(text, r"摘\s*要", stop),
        "keywords": labelled(text, r"关键词|关键字", r"JEL|中图分类号|文献标识码|Abstract|ABSTRACT|基金|作者简介|DOI|下载"),
        "doi": doi.group(0) if doi else "",
        "downloads": " ;; ".join(dict.fromkeys(downloads)),
    }


def main():
    rows = {}
    for p in sorted((RAW / "issues").glob("*.htm*")):
        for r in parse_issue(p):
            rows[r["paper_id"]] = r
    arts = {p.stem: parse_article(p) for p in sorted((RAW / "articles").glob("*.htm*"))}
    for sid, a in arts.items():
        pid = f"{JOURNAL}{sid}"
        r = rows.setdefault(pid, {"paper_id": pid, "site_id": sid, "year": "", "issue": "", "seq": "", "title": ""})
        r.update({k: v for k, v in a.items() if v})
        if not r.get("title"):
            r["title"] = a["title_article"]
    # optional manual / CNKI list
    for m in read_csv(DATA / "frame" / "frame_manual.csv"):
        key = f"{JOURNAL}{m['site_id']}" if m.get("site_id") else m.get("paper_id")
        if not key:
            key = f"{JOURNAL}{int(m['year'])}{int(m['issue']):02d}{int(m['seq']):02d}"
        r = rows.setdefault(key, {"paper_id": key})
        for k, v in m.items():
            if v and not r.get(k):
                r[k] = v
        r["source_manual"] = 1
    for r in rows.values():
        r["journal"] = JOURNAL
        r["research"] = 0 if NON_RESEARCH.search(r.get("title", "")) else 1
        r["has_article_page"] = int(r.get("site_id", "") in arts)
        r["has_pdf"] = int((RAW / "pdf" / f"{r['paper_id']}.pdf").exists())
        r["has_package_dir"] = int((RAW / "packages" / r["paper_id"]).is_dir())
    out = sorted(rows.values(), key=lambda r: (str(r.get("year", "")), int(r.get("issue") or 0), int(r.get("seq") or 0)))
    fields = ["paper_id", "journal", "site_id", "year", "issue", "seq", "title", "research", "doi", "abstract", "keywords",
              "downloads", "has_article_page", "has_pdf", "has_package_dir", "source_manual"]
    write_csv(DATA / "frame" / "frame.csv", out, fields)
    n_res = sum(r["research"] for r in out)
    print(f"frame: {len(out)} items ({n_res} research) from {len(list((RAW / 'issues').glob('*.htm*')))} issue pages, "
          f"{len(arts)} article pages -> data/frame/frame.csv")


if __name__ == "__main__":
    main()
