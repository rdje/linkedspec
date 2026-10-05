"""Preserve exact owned raw TAP streams in whitespace-safe encoded capsules."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
ROOT=Path(__file__).resolve().parents[2]
PREFIX=Path(__file__).resolve().relative_to(ROOT).as_posix().removesuffix('wrap-logs.py')
NAMES=['initial-red.log','initial-green.log','green.log']
rows=[]
for name in NAMES:
    source=ROOT/(PREFIX+name)
    target=ROOT/(PREFIX+name+'.json')
    if source.exists():
        raw=source.read_bytes()
        capsule={'original_relative_path':source.relative_to(ROOT).as_posix(),'encoding':'gzip-base64','bytes':len(raw),
                 'sha256':hashlib.sha256(raw).hexdigest(),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode(),
                 'scope':'Exact original combined stdout/stderr stream; no whitespace or evidence bytes rewritten.'}
        target.write_text(json.dumps(capsule,indent=2)+'\n')
    value=json.loads(target.read_bytes())
    value['original_relative_path']=source.relative_to(ROOT).as_posix()
    target.write_text(json.dumps(value,indent=2)+'\n')
    restored=gzip.decompress(base64.b64decode(value['data'],validate=True))
    assert len(restored)==value['bytes'] and hashlib.sha256(restored).hexdigest()==value['sha256']
    if source.exists():assert restored==source.read_bytes()
    rows.append({'path':target.relative_to(ROOT).as_posix(),'bytes':value['bytes'],'sha256':value['sha256'],'exact':True})
report={'complete':True,'streams':rows,'instrument_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'scope':'Copy and verify exact three owned raw logs before their original staging/worktree entries are removed. This packaging retains original evidence bytes and does not change source/test/capture outcomes.'}
(ROOT/(PREFIX+'wrapped-logs.json')).write_text(json.dumps(report,indent=2)+'\n')
print('Three original raw TAP streams preserved and byte-verified')
