"""Seal completed actual Hash-view normal/profile/control evidence and producers."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot completed evidence seal'
patch = subprocess.check_output(['git', 'diff', '--', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'])
capsule = BASE / 'producer-change.patch.gz'
assert not capsule.exists()
capsule.write_bytes(gzip.compress(patch, mtime=0))
assert gzip.decompress(capsule.read_bytes()) == patch
paths = [capsule]
for phase in ('before', 'after', 'direct', 'direct-qualified', 'profile-before', 'profile-after'):
    root = BASE / phase
    assert (root / 'exit.txt').is_file()
    paths += sorted(path for path in root.rglob('*') if path.is_file())
assert (BASE / 'causal-control-exit.txt').read_text() == '0\n'
paths += sorted(path for path in (BASE / 'guard-control').rglob('*') if path.is_file())
assert (BASE / 'policy-control-exit.txt').read_text() == '0\n'
paths += sorted(path for path in (BASE / 'policy-control').rglob('*') if path.is_file())
paths += [BASE / name for name in ('prepare.py', 'capture.py', 'observe_profiles.pl', 'profiles.json',
          'freeze_profiles.py', 'frozen-profiles.json', 'prepare_control.py', 'observe_control.pl',
          'causal_control.py', 'causal-control-result.log', 'causal-control-stderr.log',
          'causal-control-exit.txt', 'policy-control-result.log', 'policy-control-stderr.log',
          'policy-control-exit.txt', 'prepare_qualified.py', 'capture_qualified.py', 'review.py', 'seal.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    body = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual normal/profile/control epochs, producers, input archives and modules sealed')
