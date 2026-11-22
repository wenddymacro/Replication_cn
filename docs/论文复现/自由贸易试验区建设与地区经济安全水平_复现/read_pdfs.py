from pathlib import Path
import pypdfium2 as pdfium
from pypdf import PdfReader
R=Path(__file__).resolve().parent
for p in [R/'original/自由贸易试验区建设与地区经济安全水平.pdf',R/'original/extracted/附录.pdf']:
 r=PdfReader(p);s='\n'.join(f'\nPAGE {i+1}\n'+(x.extract_text() or '') for i,x in enumerate(r.pages))
 (R/'logs'/f'{p.stem}.txt').write_text(s,encoding='utf-8')
 print(p.name,'pages',len(r.pages),'text',len(s))
 folder=R/'logs'/('body_pages' if p.parent.name=='original' else 'appendix_pages');folder.mkdir(exist_ok=True)
 doc=pdfium.PdfDocument(p)
 for i in range(len(doc)):doc[i].render(scale=1.5).to_pil().save(folder/f'{i+1:02}.png')
