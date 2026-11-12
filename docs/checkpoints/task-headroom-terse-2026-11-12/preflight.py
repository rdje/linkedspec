"""Check the chosen immutable task source against the existing epoch vocabulary."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
sys.dont_write_bytecode=True
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
SOURCE=Path('docs/tasks/SPEC-FORMAT-TERSE.md')
ACTIVATION='9f11029e5af9d6168925f532d4c1911637421af3'
original=SOURCE.read_bytes()
assert original==subprocess.check_output(['git','show',ACTIVATION+':'+str(SOURCE)])
target=BASE/'source-before-preflight.md.gz';assert not target.exists()
target.write_bytes(gzip.compress(original,mtime=0))
assert gzip.decompress(target.read_bytes())==original
assert not SOURCE.with_suffix('.index.jsonl').exists()
assert b'  Scope:' not in original and b'  Narrative epoch:' not in original
helper=BASE/'review.py'
rows=json.loads((BASE/'template-identities.json').read_bytes())
expected=rows['docs/checkpoints/task-headroom-hygiene-2026-11-12/review.py']['generated_sha256']
assert hashlib.sha256(helper.read_bytes()).hexdigest()==expected
spec=importlib.util.spec_from_file_location('terse_epoch_preflight_oracle',helper)
review=importlib.util.module_from_spec(spec);spec.loader.exec_module(review)
prefix,nodes,tail=review.split_document(original)
closed=[]
for key,body in nodes.items():
    fields=review.core_fields(body)
    if fields.get('Status',b'').split(b'`')[1:2] and fields['Status'].split(b'`')[1] in (b'done',b'completed',b'closed',b'superseded'):
        closed.append(key)
assert closed and len(nodes)==len(set(nodes))
result=dict(preflight='PASS',source=str(SOURCE),activation=ACTIVATION,bytes=len(original),sha256=hashlib.sha256(original).hexdigest(),ordered_ids=len(nodes),exact_closed=len(closed),prefix_bytes=len(prefix),full_tail_bytes=len(tail),scope='Source/vocabulary readiness only; no mutation, fresh SDK or renewed feature-admission claim. Actual migration independently decides eligible shorter closed bodies.')
(BASE/'preflight-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(result))
