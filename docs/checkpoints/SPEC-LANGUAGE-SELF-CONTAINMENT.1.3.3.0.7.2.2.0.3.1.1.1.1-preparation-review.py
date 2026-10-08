"""Recover every original rejected claim input using an isolated local index."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-'
BASE = '997f1cb8f32ff4eaa1ba278e124cbaaac1942780'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def decode(value):
    raw = gzip.decompress(base64.b64decode(value['gzip_base64'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256']
    return raw

report = json.loads((ROOT / (PREFIX + 'preparation-initial.json')).read_bytes())
assert report['complete'] and report['revision'] == BASE and report['exit'] != 0
assert report['inputs_before'] == report['inputs_after']
assert b'found 7' in decode(report['stderr']) and not decode(report['stdout'])
assert report['producer_sha256'] == sha((ROOT / (PREFIX + 'preparation.py')).read_bytes())
original = (ROOT / (PREFIX + 'preparation-initial-claim.json')).read_bytes()
assert sha(original) == report['original_claim_sha256']
assert json.loads(original)['claims'][0]['durability']['inputs'] == report['original_bound_inputs']
scratch = ROOT / '.linkedspec-data/scratch/residual-producer-preparation'
scratch.mkdir(parents=True, exist_ok=True)
work = Path(tempfile.mkdtemp(prefix='original-', dir=scratch))
objects = work / 'objects'
objects.mkdir()
env = os.environ.copy()
env.update(GIT_INDEX_FILE=str(work / 'index'), GIT_OBJECT_DIRECTORY=str(objects),
           GIT_ALTERNATE_OBJECT_DIRECTORIES=str((ROOT / '.git/objects').resolve()))
assert work.stat().st_dev == ROOT.stat().st_dev
before_index = sha((ROOT / '.git/index').read_bytes())
subprocess.run(['git', 'read-tree', BASE], cwd=ROOT, env=env, check=True, capture_output=True)
subprocess.run(['git', 'apply', '--cached', '--binary', '-'], cwd=ROOT, env=env,
               input=decode(report['staged_binary_delta']), check=True, capture_output=True)
for entry in report['original_bound_inputs']:
    raw = subprocess.check_output(['git', 'show', ':' + entry['path']], cwd=ROOT, env=env)
    assert sha(raw) == entry['sha256'], entry['path']
raw = subprocess.check_output(['git', 'show', ':docs/claims/' + json.loads(original)['owner'] + '.json'], cwd=ROOT, env=env)
assert raw == original, 'exact initial claim recovered'
assert sha((ROOT / '.git/index').read_bytes()) == before_index, 'real index unchanged'
result = {'complete': True, 'revision': BASE, 'original_bindings_recovered': len(report['original_bound_inputs']),
          'original_claim_exact': True, 'real_index_unchanged': True,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'scope': 'Original unadmitted candidate reconstructed from retained full binary delta over immutable Git base; every original claim input hash preserved. Isolated index/object store stays on the repository volume and is not another Git repository.'}
(ROOT / (PREFIX + 'preparation-verification.json')).write_text(json.dumps(result, indent=2) + '\n')
print('Original unadmitted candidate/input recovery PASS; real index unchanged.')
