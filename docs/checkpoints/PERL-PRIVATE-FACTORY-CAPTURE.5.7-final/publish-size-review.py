"""Retain the second publisher's exact source and observed prewrite size refusal."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
source=(ROOT/(PREFIX+'publish.py')).read_bytes()
target=ROOT/'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
before=target.read_bytes()
command=['python3',PREFIX+'publish.py','--capture']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
assert run.returncode!=0 and b'(131243, 563)' in run.stderr
assert target.read_bytes()==before and (ROOT/(PREFIX+'publish.py')).read_bytes()==source
report=dict(result='PASS',command=command,returncode=run.returncode,
    producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    failed_source_base64=base64.b64encode(source).decode(),failed_source_sha256=hashlib.sha256(source).hexdigest(),
    unchanged_claim_sha256=hashlib.sha256(before).hexdigest(),
    stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode(),
    scope='Exact second failed publisher source plus actual rerun channels; canonical draft unchanged. Final prose condensation preserves the unchanged claim byte budget.')
with (ROOT/(PREFIX+'publish-size-review.json')).open('x') as output:
    output.write(json.dumps(report,indent=2)+'\n')
print('Second publication size refusal retained:131243 bytes/563 inputs;draft unchanged')
