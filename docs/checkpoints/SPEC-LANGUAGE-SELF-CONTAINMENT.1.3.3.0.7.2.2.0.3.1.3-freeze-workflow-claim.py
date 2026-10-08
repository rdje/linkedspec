"""Preserve the dated cleanup claim without changing any original measurement."""
from pathlib import Path
import base64
import copy
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
REVISION = '864b1a93934ab7fd4b059b0a7cb9d4b417e33c66'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)

snapshot = json.loads((ROOT/(PREFIX+'workflow-claim-rejected.json')).read_bytes())
assert snapshot['complete'] and len(snapshot['stale_prior_claims']) == 1
target = ROOT/(PREFIX+'workflow-claim-freeze.json')
assert not target.exists(), 'one-shot qualification'
item = snapshot['stale_prior_claims'][0]; path = item['path']
assert path == 'docs/claims/REPO-HYGIENE.11.json'
original = base64.b64decode(item['original_record']['base64'],validate=True)
assert sha(original) == item['original_record']['sha256']
assert (ROOT/path).read_bytes() == original == git('show',REVISION+':'+path)
record = json.loads(original); frozen = copy.deepcopy(record)
durable = record['claims'][0]['durability']
assert durable['mode'] == 'live' and len(durable['inputs']) == 21
for source in durable['inputs']:
    assert sha(git('show',REVISION+':'+source['path'])) == source['sha256'], 'original cleanup input '+source['path']
frozen['claims'][0]['durability'].update(mode='historical',revision=REVISION)
inverse = copy.deepcopy(frozen)
inverse['claims'][0]['durability']['mode'] = 'live'
del inverse['claims'][0]['durability']['revision']
assert inverse == record, 'mode/revision only'
(ROOT/path).write_text(json.dumps(frozen,indent=2)+'\n')
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'path':path,'revision':REVISION,
          'original_sha256':sha(original),'frozen_sha256':sha((ROOT/path).read_bytes()),'original_inputs_verified':21,
          'scope':'Dated cleanup evidence is qualified at its exact owning committed boundary. All21 original artifact inputs and original live record verify from immutable Git; only durability mode/revision changes. No cleanup rerun, input-hash refresh, new runtime/artifact census or original channel replacement. Independent rejected-candidate recovery and inverse controls remain required.'}
target.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
