"""Seal immutable actual epochs; retain mutable SDK/test sources in input archives."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot seal'
paths = []
for phase in ('before', 'after', 'private_inverse', 'private_restored', 'direct'):
    paths += sorted(p for p in (BASE / phase).iterdir() if p.is_file())
paths += sorted(p for p in BASE.iterdir() if p.is_file())
paths += [Path('tests/fixtures') / name for name in ('hash_value_result_guard_cases.json',
          'hash_value_result_guard_perl_cases.json', 'hash_value_result_guard_perl_profiles.json')]
paths += [Path('docs/checkpoints/hash-value-result-selection-2026-11-07') / name for name in ('cases.json', 'review.py')]
paths += [Path('docs/checkpoints/hash-value-result-guard-perl-2026-11-07/review_preflight.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Original/current/private/direct source graph and unchanged producer/tests sealed')
