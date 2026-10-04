"""Verify the exact immutable consumer-claim freeze and header-only clarifications."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('freeze-review.py')
REVISION = 'c02ce88826f815c201a652d5b29bd3cf044d2740'
claim_path = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1.json'
original = subprocess.check_output(['git','show',REVISION+':'+claim_path],cwd=ROOT)
assert Path(PREFIX+'before-consumer-claim.json').read_bytes() == original
before = json.loads(original)
expected = json.loads(original)
count = 0
for claim in expected['claims']:
    durability = claim['durability']
    assert durability['mode'] == 'live'
    for entry in durability['inputs']:
        blob = subprocess.check_output(['git','show',REVISION+':'+entry['path']],cwd=ROOT)
        assert hashlib.sha256(blob).hexdigest() == entry['sha256'],entry['path']
        count += 1
    durability.update(mode='historical',revision=REVISION)
assert json.loads((ROOT/claim_path).read_bytes()) == expected
for lane in ('0','1'):
    path = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.'+lane+'-prepare.py'
    old = subprocess.check_output(['git','show',REVISION+':'+path],cwd=ROOT).splitlines(keepends=True)
    new = (ROOT/path).read_bytes().splitlines(keepends=True)
    assert old[1:] == new[1:] and new[0] == b'"""Prepare immutable Git inputs plus the explicitly supplied working book overlay."""\n'
result = {'revision':REVISION,'bound_inputs_verified':count,'before_sha256':hashlib.sha256(original).hexdigest(),
          'after_sha256':hashlib.sha256((ROOT/claim_path).read_bytes()).hexdigest(),
          'scope':'Only durability mode/revision changed; original producer bytes are retained at their immutable Git boundaries. Two prepare headers alone now describe the existing working book-overlay branch accurately.',
          'instrument_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
Path(PREFIX+'freeze.json').write_text(json.dumps(result,indent=2)+'\n')
print('Exact historical freeze verified; '+str(count)+' original input hashes; two header-only clarifications')
