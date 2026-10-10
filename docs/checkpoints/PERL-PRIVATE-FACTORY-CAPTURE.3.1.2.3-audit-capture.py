"""Retain rejected staged candidate, original auditor and actual recovery channels."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
AUDITOR='tests/language-readiness/verify_objectives.py'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
sha=lambda r:hashlib.sha256(r).hexdigest()

def envelope(raw):
    return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}

mode=sys.argv[1]
assert mode in ('before','after')
target=ROOT/(PREFIX+'audit-'+mode+'.json')
assert not target.exists(),'one-shot audit channel capture'
record={'producer_sha256':sha(Path(__file__).read_bytes()),'auditor_sha256':sha((ROOT/AUDITOR).read_bytes()),'proof_sha256':sha((ROOT/PROOF).read_bytes())}
if mode=='before':
    staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=ROOT).decode().splitlines()
    assert AUDITOR not in staged,'retention precedes auditor repair'
    snapshot=ROOT/(PREFIX+'audit-before.py');assert not snapshot.exists()
    snapshot.write_bytes((ROOT/AUDITOR).read_bytes())
    patch=subprocess.check_output(['git','diff','--cached','--binary','--full-index'],cwd=ROOT)
    record['candidate']={'base':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip(),'full_index_binary_diff':envelope(patch)}
args=['bash','tools/run_python_project_data.sh',PROOF]
p=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
record.update(args=args,exit_code=p.returncode,stdout=envelope(p.stdout),stderr=envelope(p.stderr))
target.write_text(json.dumps(record,indent=2)+'\n')
if mode=='before':
    assert p.returncode!=0 and b'unreviewed boundary contract drift: perl/LinkedSpec/ActionIR/Contracts.pm' in p.stderr
else:
    assert p.returncode==0 and not p.stderr
print('Actual historical recovery',mode,'channel retained; exit',p.returncode)
