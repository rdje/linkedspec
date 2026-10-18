"""Retain the original before-write publication size refusal and actual channels."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
TARGET=ROOT/'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
before=TARGET.read_bytes()
command=['python3',PREFIX+'publish-over-budget.py','--capture']
result=subprocess.run(command,cwd=ROOT,capture_output=True)
assert result.returncode!=0 and b'(131264, 560)' in result.stderr
assert TARGET.read_bytes()==before
report=dict(result='PASS',command=command,returncode=result.returncode,
    producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    failed_source_sha256=hashlib.sha256((ROOT/(PREFIX+'publish-over-budget.py')).read_bytes()).hexdigest(),
    unchanged_claim_sha256=hashlib.sha256(before).hexdigest(),
    stdout_base64=base64.b64encode(result.stdout).decode(),
    stderr_base64=base64.b64encode(result.stderr).decode(),
    scope='Actual rerun of the original failed publisher with unchanged claim and all560 inputs. The original size refusal precedes any canonical claim write. Final wording is condensed separately under the unchanged131072-byte limit.')
with (ROOT/(PREFIX+'publish-preflight.json')).open('x') as output:
    output.write(json.dumps(report,indent=2)+'\n')
print('Publication preflight PASS: original131264-byte refusal;canonical draft unchanged')
