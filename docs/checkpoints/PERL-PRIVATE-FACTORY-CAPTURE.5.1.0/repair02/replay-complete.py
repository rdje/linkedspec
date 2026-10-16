"""Supply the original candidate plus its declared supplemental guard producers."""
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
TARGET = ROOT / (PREFIX + 'repair02/replay-complete.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists()
original_raw = (ROOT / (PREFIX + 'repair02/inputs.json.gz')).read_bytes()
original = json.loads(gzip.decompress(original_raw))
record = json.loads((ROOT / (PREFIX + 'repair02/capture.json')).read_bytes())
assert record['capsule_sha256'] == sha(original_raw)
files = {p: base64.b64decode(x['bytes_base64'], validate=True) for p, x in original.items()}
modes = {p: x['mode'] for p, x in original.items()}
assert all(sha(files[p]) == x['sha256'] for p, x in original.items())
validation = json.loads(files[PREFIX + 'validation.json'])
additions = []
for p, identity in validation['sources'].items():
    value = (ROOT / p).read_bytes()
    assert sha(value) == identity
    if p in files:
        assert files[p] == value
    else:
        files[p] = value
        modes[p] = stat.S_IMODE((ROOT / p).stat().st_mode)
        additions.append(p)
p = PREFIX + 'repair02/replay-complete.py'
files[p] = Path(__file__).read_bytes()
modes[p] = stat.S_IMODE(Path(__file__).stat().st_mode)
cap_path = ROOT / (PREFIX + 'repair02/replay-inputs.json.gz')
capsule = {p: {'sha256': sha(value), 'mode': modes[p],
               'bytes_base64': base64.b64encode(value).decode()} for p, value in files.items()}
with cap_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))
with tempfile.TemporaryDirectory(prefix='expansion-complete-census-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == ROOT.stat().st_dev
    for p, value in files.items():
        target = root / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        target.chmod(modes[p])
    command = ['python3', PREFIX + 'review-final.py']
    env = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(root))
    result = subprocess.run(command, cwd=root, env=env, capture_output=True)
    unchanged = all((root / p).read_bytes() == value and
                    stat.S_IMODE((root / p).stat().st_mode) == modes[p] for p, value in files.items())
r = {'producer_sha256': sha(Path(__file__).read_bytes()), 'original_capsule_sha256': sha(original_raw),
     'capsule_sha256': sha(cap_path.read_bytes()), 'added_supplemental_sources': sorted(additions),
     'inputs': {p: {'sha256': sha(value), 'mode': modes[p]} for p, value in files.items()},
     'command': command, 'returncode': result.returncode, 'unchanged': unchanged,
     'stdout_base64': base64.b64encode(result.stdout).decode(),
     'stderr_base64': base64.b64encode(result.stderr).decode(),
     'scope': 'Distinct complete supplied replay, reusing every original first445 byte/mode from the immutable '
              'capsule and adding only the missing declared supplemental guard sources plus this producer. '
              'The first incomplete replay and its original failure remain unchanged. No original capture is refreshed.'}
with TARGET.open('x') as output:
    output.write(json.dumps(r, indent=2) + '\n')
assert result.returncode == 1 and b'AssertionError: exact independent full review' in result.stderr and unchanged
print('Complete original full-review replay:', len(files), 'inputs; actual self-census RED; additions', len(additions))
