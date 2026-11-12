"""Retain the new source and independently check actual remaining eligibility."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
sys.dont_write_bytecode=True
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.32'
TREE='PROJECT-DATA-SSD-ROOTING'
SOURCE=Path('docs/tasks/'+TREE+'.md')
ACTIVATION='9f11029e5af9d6168925f532d4c1911637421af3'
original=SOURCE.read_bytes()
assert original==subprocess.check_output(['git','show',ACTIVATION+':'+str(SOURCE)])
target=BASE/'source-before-preflight.md.gz';assert not target.exists()
target.write_bytes(gzip.compress(original,mtime=0));assert gzip.decompress(target.read_bytes())==original
assert not SOURCE.with_suffix('.index.jsonl').exists()
assert b'  Scope:' not in original and b'  Narrative:' not in original and b'  Narrative epoch:' not in original
helper=BASE/'review.py';records=json.loads((BASE/'template-identities.json').read_bytes())
assert hashlib.sha256(helper.read_bytes()).hexdigest()==records['docs/checkpoints/task-headroom-hygiene-2026-11-12/review.py']['generated_sha256']
spec=importlib.util.spec_from_file_location('rooting_epoch_preflight_oracle',helper)
review=importlib.util.module_from_spec(spec);spec.loader.exec_module(review)
prefix,nodes,tail=review.split_document(original)
eligible=[]
for key,body in nodes.items():
    fields=review.core_fields(body)
    status=fields.get('Status',b'').split(b'`')[1:2]
    if not status or status[0] not in (b'done',b'completed',b'closed',b'superseded'):
        continue
    if b'  Narrative:' in body or b'  Narrative epoch:' in body:
        continue
    pointer=('  Narrative epoch: `'+OWNER+'`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree '+TREE+' --epoch '+OWNER+' --id '+key+'`.\n\n').encode()
    candidate=body.splitlines(keepends=True)[0]+b''.join(fields.values())+pointer
    if len(candidate)<len(body):eligible.append(key)
assert eligible,'No remaining eligible capacity; do not invoke the writer'
result=dict(preflight='PASS',source=str(SOURCE),activation=ACTIVATION,bytes=len(original),sha256=hashlib.sha256(original).hexdigest(),ordered_ids=len(nodes),eligible_closed=sorted(eligible),prefix_bytes=len(prefix),full_tail_bytes=len(tail),scope='Independent original/epoch-pointer and strict shorter-body selection before the fresh qualified operation. Actual migration/query/recovery must still verify the resulting bytes; no SDK or cleanup execution.')
(BASE/'preflight-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(preflight='PASS',ordered_ids=len(nodes),eligible_closed=len(eligible),source_bytes=len(original),tail_bytes=len(tail))))
