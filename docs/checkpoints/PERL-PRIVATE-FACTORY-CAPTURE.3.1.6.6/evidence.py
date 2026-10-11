"""Actual semantic wording control. Default readonly; --capture is one-shot."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
DIR='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
assert sys.argv[1:] in ([],['--capture'])
sha=lambda raw:hashlib.sha256(raw).hexdigest()
channel=lambda raw:{'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
args=['python3',DIR+'review.py']
def run():
    p=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    return {'args':args,'exit_code':p.returncode,'stdout':channel(p.stdout),'stderr':channel(p.stderr)}
root=ROOT/'DEVELOPMENT_NOTES.md'; original=root.read_bytes()
assert b'ADR0133' in original
mutant=original.replace(b'ADR0133',b'ADR0134',1)
target=ROOT/(DIR+'evidence.json'); reached=ROOT/(DIR+'evidence-reached.json')
if sys.argv[1:]:
    assert not target.exists() and not reached.exists()
    data={'producer_sha256':sha(Path(__file__).read_bytes()),'original_root_sha256':sha(original),'healthy':run(),'mutant':channel(mutant)}
    reached.write_text(json.dumps(data,indent=2)+'\n')
    assert data['healthy']['exit_code']==0 and data['healthy']['stderr']['bytes']==0
    try:
        root.write_bytes(mutant); data['observed']=run(); reached.write_text(json.dumps(data,indent=2)+'\n')
        assert data['observed']['exit_code']!=0 and b'exact chronological wording correction' in base64.b64decode(data['observed']['stderr']['base64'])
    finally: root.write_bytes(original)
    data['restored']=run(); reached.write_text(json.dumps(data,indent=2)+'\n')
    assert data['restored']==data['healthy']
    target.write_text(json.dumps(data,indent=2)+'\n')
data=json.loads(target.read_bytes()); assert json.loads(reached.read_bytes())==data
assert data['producer_sha256']==sha(Path(__file__).read_bytes()) and data['original_root_sha256']==sha(original)
assert data['mutant']==channel(mutant) and data['healthy']==data['restored']==run()
assert data['observed']['args']==args and data['observed']['exit_code']!=0
assert b'exact chronological wording correction' in base64.b64decode(data['observed']['stderr']['base64'])
for observed in (data['healthy'],data['observed'],data['restored']):
    for part in ('stdout','stderr'): assert channel(base64.b64decode(observed[part]['base64'],validate=True))==observed[part]
print('Chronology evidence PASS: unrelated wording actual RED/complete channels/exact restored PASS')
