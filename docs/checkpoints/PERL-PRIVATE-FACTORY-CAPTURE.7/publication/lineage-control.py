"""Retain one beyond-hash logical-draft denial and exact restoration."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/publication/'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
target=ROOT/(PREFIX+'lineage-control.json.gz');assert not target.exists()
names=('initial-draft.json.gz','failure.json','repair.json')
originals={n:dict(bytes_base64=encode((ROOT/(PREFIX+n)).read_bytes()),mode=(ROOT/(PREFIX+n)).stat().st_mode&0o7777) for n in names}
def invoke():
    command=['python3',PREFIX+'verify.py'];run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
baseline=invoke();assert baseline['returncode']==0 and not decode(baseline['stderr_base64'])
try:
    raw=gzip.decompress(decode(originals['initial-draft.json.gz']['bytes_base64']))
    value=json.loads(raw)
    for key in ('statement',):
        text=value['claims'][0][key];assert text.startswith('One ')
        value['claims'][0][key]='Neo '+text[4:]
    text=value['claims'][0]['rederive']['result'];assert text.startswith('One ')
    value['claims'][0]['rederive']['result']='Neo '+text[4:]
    changed=(json.dumps(value,indent=2)+'\n').encode();assert len(changed)==len(raw)==138598
    (ROOT/(PREFIX+'initial-draft.json.gz')).write_bytes(gzip.compress(changed,mtime=0))
    for name,key in [('failure.json','retained_draft_sha256'),('repair.json','original_draft_sha256')]:
        record=json.loads(decode(originals[name]['bytes_base64']));record[key]=sha(changed)
        (ROOT/(PREFIX+name)).write_text(json.dumps(record,indent=2)+'\n')
    reached={n:dict(bytes_base64=encode((ROOT/(PREFIX+n)).read_bytes()),mode=(ROOT/(PREFIX+n)).stat().st_mode&0o7777) for n in names}
    rejected=invoke()
    assert rejected['returncode']!=0 and b'byte-exact whole logical draft reconstruction' in decode(rejected['stderr_base64'])
finally:
    for n,value in originals.items():(ROOT/(PREFIX+n)).write_bytes(decode(value['bytes_base64']));(ROOT/(PREFIX+n)).chmod(value['mode'])
restored=invoke();assert restored==baseline
report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),originals=originals,
    changed=reached,baseline=baseline,rejection=rejected,restoration=restored,
    scope='Same-length whole initial draft statement/result forgery coherently updates its immediate failure/repair hashes. Original source and input population remain fixed. Actual pure-source byte reconstruction denies it for the named semantic reason before later historical witness hashes; all full changed bytes/modes/channels and exact restored PASS remain retained. No writer/native observation or original source is refreshed.')
with target.open('xb') as output:output.write(gzip.compress(json.dumps(report,sort_keys=True).encode(),mtime=0))
print('Publication lineage control PASS:coherent same-length draft forgery RED;full bytes/channels;exact restoration')
