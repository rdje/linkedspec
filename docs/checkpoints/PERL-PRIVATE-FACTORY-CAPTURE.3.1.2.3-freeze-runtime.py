"""One-shot preserve committed block-component evidence before book teaching edits."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE='cdc45f9cbddbc53603e885225af2a35688657292'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1.json'
sha=lambda r:hashlib.sha256(r).hexdigest()
blob=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
target=ROOT/(PREFIX+'before-runtime.json');assert not target.exists()
before=blob(CLAIM);assert (ROOT/CLAIM).read_bytes()==before
record=json.loads(before);count=0
for claim in record['claims']:
 d=claim['durability']
 if d.get('mode')=='live':
  for entry in d['inputs']:
   raw=blob(entry['path']);assert sha(raw)==entry['sha256'] and (ROOT/entry['path']).read_bytes()==raw
   count+=1
  d.update(mode='historical',revision=BASE)
assert count==241
target.write_bytes(before)
(ROOT/CLAIM).write_text(json.dumps(record,indent=2)+'\n')
print('Original241 runtime/book inputs preserved at clean cdc45f9cb; no proof field or hash refreshed.')
