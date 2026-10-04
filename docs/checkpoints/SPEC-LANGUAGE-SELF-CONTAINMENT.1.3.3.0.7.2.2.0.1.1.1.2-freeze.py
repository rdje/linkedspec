"""Freeze the exact prior daily cleanup claim before its bound publication changes."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('freeze.py')
REVISION='aef9e551c7e563985c79c53fcba574ee5df8d509'
path='docs/claims/REPO-HYGIENE.9.json'
original=subprocess.check_output(['git','show',REVISION+':'+path],cwd=ROOT)
Path(PREFIX+'before-cleanup-claim.json').write_bytes(original)
expected=json.loads(original);count=0
for claim in expected['claims']:
    d=claim['durability'];assert d['mode']=='live'
    for e in d['inputs']:
        blob=subprocess.check_output(['git','show',REVISION+':'+e['path']],cwd=ROOT)
        assert hashlib.sha256(blob).hexdigest()==e['sha256'],e['path'];count+=1
    d.update(mode='historical',revision=REVISION)
current=json.loads((ROOT/path).read_bytes())
assert current in (json.loads(original),expected), 'original claim unchanged before freeze'
(ROOT/path).write_text(json.dumps(expected,indent=2)+'\n')
report={'revision':REVISION,'bound_inputs':count,'before_sha256':hashlib.sha256(original).hexdigest(),
        'after_sha256':hashlib.sha256((ROOT/path).read_bytes()).hexdigest(),'instrument_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'scope':'Only durability mode/revision change; every original claim/input identity retained.'}
Path(PREFIX+'freeze.json').write_text(json.dumps(report,indent=2)+'\n')
print('Prior daily cleanup claim frozen at exact activation boundary; '+str(count)+' input hashes verified')
