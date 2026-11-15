from pathlib import Path
import urllib.request,concurrent.futures,json,hashlib,sys
root=Path(__file__).resolve().parents[1]/'output/local_ado'
packages=sys.argv[1:] or ['ivreg2','ranktest','acreg','event_plot','xtbalance','bacondecomp','csdid','drdid','eventstudyinteract','avar','did_multiplegt','did_multiplegt_old','did_multiplegt_dyn','did_multiplegt_stat']
receipt_file=root/'chain_dependency_receipts.json'
receipts=json.loads(receipt_file.read_text()) if receipt_file.exists() else []
def get(url):
    with urllib.request.urlopen(url,timeout=20) as r:return r.read()
def package(p):
    base='http://fmwww.bc.edu/repec/bocode/'+p[0]+'/'
    try:
        data=get(base+p+'.pkg');(root/(p+'.pkg')).write_bytes(data)
        files=[l.split()[1] for l in data.decode().splitlines() if l.startswith('f ')]
        for f in files:
            d=get(base+f); (root/Path(f).name).write_bytes(d)
            receipts.append(dict(url=base+f,file=Path(f).name,sha256=hashlib.sha256(d).hexdigest()))
        return p,len(files),'OK'
    except Exception as e:return p,str(e)
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
    for result in pool.map(package,packages):print(result,flush=True)
(root/'chain_dependency_receipts.json').write_text(json.dumps(receipts,indent=2),encoding='utf-8')
