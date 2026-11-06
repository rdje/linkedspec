"""Seal actual Perl source counterfactuals, numeric seed controls and normal proof."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path('docs/checkpoints/hash-view-receiver-policy-perl-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot completed evidence seal'
patch = subprocess.check_output(['git', 'diff', '--', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'])
capsule = BASE / 'producer-change.patch.gz'
assert not capsule.exists()
capsule.write_bytes(gzip.compress(patch, mtime=0))
assert gzip.decompress(capsule.read_bytes()) == patch
paths = [capsule]
for phase in ('historical', 'current', 'seed/historical', 'seed/current', 'before', 'after', 'direct'):
    root = BASE / phase
    assert (root / 'exit.txt').is_file()
    paths += sorted(path for path in root.rglob('*') if path.is_file())
paths += [BASE / name for name in ('prepare.py', 'capture.py', 'observer.pl', 'cases.json',
          'prepare_seed.py', 'capture_seed.py', 'seed_observer.pl', 'seed-cases.json',
          'prepare_normal.py', 'capture_test.py', 'review.py', 'seal.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    body = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual historical/current/seed/normal epochs, producers, modules and lossless channels sealed')
