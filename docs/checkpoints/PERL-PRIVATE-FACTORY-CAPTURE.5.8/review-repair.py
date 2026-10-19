"""Retain the original helper-classification failure and exact scoped correction."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'review-repair.json');assert not target.exists()
source=(ROOT/(PREFIX+'review.py')).read_bytes()
command=['python3',PREFIX+'review.py','--capture']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
assert run.returncode!=0 and b'unchanged actual helper/config source' in run.stderr
changed=subprocess.check_output(['git','diff',BASE,'--name-only','--','tools','scripts','capability_conformance','doctrine','knowledge-map/scripts'],cwd=ROOT,text=True).splitlines()
assert changed==['doctrine/readme_stability/routes.jsonl']
old=b"for p in support:assert decode(stage_data['original'][p]['bytes_base64'])==old(p) and (ROOT/p).read_bytes()==old(p),'unchanged actual helper/config source'"
new=b"for p in support:assert decode(stage_data['original'][p]['bytes_base64'])==old(p) and (p==REG or (ROOT/p).read_bytes()==old(p)),'unchanged actual helper/config source'"
assert source.count(old)==1
corrected=source.replace(old,new,1).replace(b"PREFIX+'review.py'",b"PREFIX+'review-final.py'")
needle=b"'book-review.json','review.py'):raw(PREFIX+name)"
replacement=b"'book-review.json','review.py','review-final.py','review-repair.py','review-repair.json'):raw(PREFIX+name)"
assert corrected.count(needle)==1
corrected=corrected.replace(needle,replacement,1)
with (ROOT/(PREFIX+'review-final.py')).open('xb') as output:output.write(corrected)
record=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),original_producer_sha256=sha(source),
    corrected_producer_sha256=sha(corrected),old_base64=encode(old),new_base64=encode(new),
    command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr),
    changed_support=changed,
    scope='Actual original reader rejects the intentionally changed registry because it classifies every parent-owned support path as unchanged. Original source/channels are retained; the exact correction exempts only REG from the unchanged-current helper assertion. Independent exact six-scalar registry reconstruction still governs that file. All original historical helper bytes remain checked. Other edits only identify/bind the new reader and this repair record.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
print('Original reader refusal retained;only intentional registry support exception;final reader written')
