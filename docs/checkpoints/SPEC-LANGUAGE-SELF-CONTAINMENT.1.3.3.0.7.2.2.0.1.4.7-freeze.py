"""Freeze the committed rollover claim before changing its publication inputs."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('freeze.py')
REVISION = '65304aded7d1a096c701b768b076b29c4eb893b2'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


original = subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT)
expected = json.loads(original)
count = 0
unique = set()
for claim in expected['claims']:
    durability = claim['durability']
    assert durability['mode'] == 'live', 'original live claim boundary'
    for item in durability['inputs']:
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
        assert sha(raw) == item['sha256'], 'original committed input: ' + item['path']
        count += 1
        unique.add(item['path'])
    durability.update(mode='historical', revision=REVISION)
assert json.loads((ROOT / CLAIM).read_bytes()) in (json.loads(original), expected), 'unchanged claim before freeze'
Path(PREFIX + 'before-rollover-claim.json').write_bytes(original)
(ROOT / CLAIM).write_text(json.dumps(expected, indent=2) + '\n')
report = {
    'revision': REVISION, 'bound_inputs': count, 'unique_inputs': len(unique),
    'claims': len(expected['claims']), 'before_sha256': sha(original),
    'after_sha256': sha((ROOT / CLAIM).read_bytes()),
    'instrument_sha256': sha(Path(__file__).read_bytes()),
    'scope': 'Only durability mode/revision change; original claim and input identities remain exact.',
}
Path(PREFIX + 'freeze.json').write_text(json.dumps(report, indent=2) + '\n')
print('Committed rollover claim frozen at65304aded; ' + str(count) + ' original hashes verified')
