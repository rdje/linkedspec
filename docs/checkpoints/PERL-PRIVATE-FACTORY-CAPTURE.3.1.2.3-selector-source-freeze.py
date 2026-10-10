"""One-shot preserve the intermediate uncommitted publication and actual reader."""
import base64,gzip,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
sha=lambda r:hashlib.sha256(r).hexdigest()
target=ROOT/(PREFIX+'selector-source-freeze.json');before=ROOT/(PREFIX+'selector-claim-before-source.json')
assert not target.exists() and not before.exists()
raw=(ROOT/CLAIM).read_bytes();record=json.loads(raw);count=0
for c in record['claims']:
 if c['durability']['mode']=='live':
  for r in c['durability']['inputs']:
   assert sha((ROOT/r['path']).read_bytes())==r['sha256'],r['path'];count+=1
assert count==368
reader=(ROOT/(PREFIX+'selector-review.py')).read_bytes()
before.write_bytes(raw)
target.write_text(json.dumps({'claim_sha256':sha(raw),'live_inputs':count,
 'reader':{'encoding':'gzip-base64','bytes':len(reader),'sha256':sha(reader),'data':base64.b64encode(gzip.compress(reader,mtime=0)).decode()},
 'evidence_sha256':sha((ROOT/(PREFIX+'selector-evidence.json')).read_bytes()),
 'producer_sha256':sha(Path(__file__).read_bytes())},indent=2)+'\n')
print('Intermediate368-input publication and original reader/evidence retained exactly.')
