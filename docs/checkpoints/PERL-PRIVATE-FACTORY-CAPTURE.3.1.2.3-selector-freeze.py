"""One-shot retain the uncommitted original four-claim proof before its book repair."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
BASE='cdc45f9cbddbc53603e885225af2a35688657292'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
MODEL='docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
sha=lambda r:hashlib.sha256(r).hexdigest()
target=ROOT/(PREFIX+'selector-freeze.json')
before=ROOT/(PREFIX+'selector-before-claim.json')
assert not target.exists() and not before.exists(),'one-shot pre-repair retention'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()==BASE
raw=(ROOT/CLAIM).read_bytes();record=json.loads(raw);assert len(record['claims'])==4
inputs=[r for c in record['claims'] if c['durability']['mode']=='live' for r in c['durability']['inputs']]
assert len(inputs)==504 and len({r['path'] for r in inputs})==504
for r in inputs:assert sha((ROOT/r['path']).read_bytes())==r['sha256'],'preserve before input writes: '+r['path']
source=subprocess.check_output(['git','show',BASE+':'+MODEL],cwd=ROOT)
assert source==(ROOT/MODEL).read_bytes()
before.write_bytes(raw)
target.write_text(json.dumps({'base':BASE,'claim':CLAIM,'before':before.relative_to(ROOT).as_posix(),
 'original_sha256':sha(raw),'claims':4,'live_inputs':504,'model':MODEL,'model_git_sha256':sha(source),
 'producer_sha256':sha(Path(__file__).read_bytes()),
 'scope':'Exact uncommitted original publication and all504 input identities; original model source is recoverable from clean CDC Git. Existing proof producers/channels stay byte-exact. No committed measurement is refreshed.'},indent=2)+'\n')
print('Original uncommitted four-claim candidate retained; all504 live inputs exact.')
