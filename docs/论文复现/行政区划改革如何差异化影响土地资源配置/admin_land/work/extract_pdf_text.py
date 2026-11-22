import pdfplumber
from pathlib import Path
import sys
for label, filename in [('paper', sys.argv[1]), ('appendix', sys.argv[2])]:
    path=Path(filename)
    with pdfplumber.open(path) as pdf:
        text='\n'.join(page.extract_text() or '' for page in pdf.pages)
    dest=Path(sys.argv[3])/(label+'.txt')
    dest.write_text(text,encoding='utf-8')
    print(label, 'pages=',len(pdf.pages),'chars=',len(text),'output=',dest)
