"""Losslessly seal actual Rust normal/intake inputs, modules and full channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot completed evidence seal'
phases = ('intake', 'receiver-intake', 'normal-before', 'normal-after', 'after-intake', 'direct', 'format')
for phase in phases:
    assert (BASE / phase).is_dir()
patch = subprocess.check_output(['git', 'diff', '--', 'rust/linkedspec-runtime/src/engine.rs'])
capsule = BASE / 'producer-change.patch.gz'
assert not capsule.exists()
capsule.write_bytes(gzip.compress(patch, mtime=0))
assert gzip.decompress(capsule.read_bytes()) == patch
channels = {}
for phase in phases:
    for path in sorted((BASE / phase).rglob('*.log')):
        assert path.is_file() and not path.is_symlink()
        body = path.read_bytes()
        compressed = Path(str(path) + '.gz')
        assert not compressed.exists()
        compressed.write_bytes(gzip.compress(body, mtime=0))
        assert gzip.decompress(compressed.read_bytes()) == path.read_bytes()
        channels[str(path)] = dict(capsule=str(compressed), sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
        path.unlink()
(BASE / 'raw-identities.json').write_text(json.dumps(channels, indent=2, sort_keys=True) + '\n')
paths = [capsule, BASE / 'raw-identities.json']
for phase in phases:
    paths += sorted(path for path in (BASE / phase).rglob('*') if path.is_file())
paths += [BASE / name for name in ('prepare.py', 'capture.py', 'observer.rs', 'profile-sources.json',
          'freeze_profiles.py', 'prepare_receiver.py', 'capture_receiver.py', 'receiver-profile-sources.json',
          'prepare_normal.py', 'capture_test.py', 'prepare_after.py', 'capture_after.py',
          'capture_format.py', 'review.py', 'seal.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    body = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual complete Rust epochs, writers, grammar/source archives, modules and lossless channels sealed')
