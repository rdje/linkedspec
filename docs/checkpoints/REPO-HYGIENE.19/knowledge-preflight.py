"""Retain the actual before-write Knowledge budget refusal and unchanged cards."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
target=ROOT/(PREFIX+'knowledge-preflight.json');assert not target.exists()
preserved=json.loads((ROOT/(PREFIX+'preservation.json')).read_bytes())
cards=[p for p in preserved['owned_bound_paths'] if p.startswith('docs/knowledge/')]
before={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in cards}
command=['python3',PREFIX+'prepare-knowledge.py']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
assert run.returncode!=0 and b'prewrite Knowledge budget' in run.stderr and b'8388673' in run.stderr
assert before=={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in cards}
record=dict(result='PASS',producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    failed_source_sha256=hashlib.sha256((ROOT/(PREFIX+'prepare-knowledge.py')).read_bytes()).hexdigest(),
    unchanged_cards=before,command=command,returncode=run.returncode,
    stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode(),
    scope='Exact original producer refuses8388673 bytes before any card write under unchanged8388608 cap. All fourteen cards remain unchanged. A distinct concise evidence-header producer follows; no limit or previous source/report is rewritten.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
print('Knowledge preflight PASS: original budget RED;all fourteen cards unchanged')
