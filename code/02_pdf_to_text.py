"""Convert full-text PDFs to text with pdftotext (poppler-utils).

Input:  $CIE_RAW/pdf/<paper_id>.pdf
Output: data/text/cie/<paper_id>.txt  (copyrighted text: git-ignored)
Usage:  python3 code/02_pdf_to_text.py [--force]
"""
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import DATA, JOURNAL, RAW  # noqa: E402


def main():
    force = "--force" in sys.argv
    out_dir = DATA / "text" / JOURNAL
    out_dir.mkdir(parents=True, exist_ok=True)
    pdfs = sorted((RAW / "pdf").glob("*.pdf"))
    done = failed = 0
    for pdf in pdfs:
        out = out_dir / f"{pdf.stem}.txt"
        if out.exists() and not force:
            continue
        r = subprocess.run(["pdftotext", "-layout", "-enc", "UTF-8", str(pdf), str(out)], capture_output=True, text=True)
        if r.returncode != 0 or not out.exists() or out.stat().st_size < 1000:
            failed += 1
            print(f"FAILED or near-empty (scanned PDF? needs OCR): {pdf.name} {r.stderr.strip()[:200]}", file=sys.stderr)
        else:
            done += 1
    print(f"{len(pdfs)} PDFs; converted {done}; failed {failed}; output in {out_dir}")


if __name__ == "__main__":
    main()
