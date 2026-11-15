from pathlib import Path
import urllib.request,hashlib,json
root=Path(__file__).resolve().parents[1]/'output/csdid_legacy'
root.mkdir(exist_ok=True)
base='https://raw.githubusercontent.com/friosavila/csdid_drdid/main/code/'
receipts=[]
for package in ['csdid','drdid']:
    with urllib.request.urlopen(base+package+'.pkg',timeout=30) as r:pkg=r.read()
    (root/(package+'.pkg')).write_bytes(pkg)
    for line in pkg.decode('latin-1').splitlines():
        if not line.lower().startswith('f '):continue
        name=line.split()[1]
        with urllib.request.urlopen(base+name,timeout=30) as r:data=r.read()
        target=root/Path(name).name
        target.write_bytes(data)
        receipts.append(dict(url=base+name,file=target.name,sha256=hashlib.sha256(data).hexdigest()))
    print(package,'downloaded',flush=True)
(root/'receipts.json').write_text(json.dumps(receipts,indent=2),encoding='utf-8')
print((root/'csdid.ado').read_text(encoding='utf-8-sig').splitlines()[0])
