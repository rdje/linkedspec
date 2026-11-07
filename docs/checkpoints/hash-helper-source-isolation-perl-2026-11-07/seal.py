"""Seal actual immutable source epochs; mutable SDK/test bodies live in archives."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot source proof seal'
paths = []
for phase in ('before', 'after', 'qualified_after', 'private_inverse', 'private_restored', 'qualified_direct'):
    paths += sorted(p for p in (BASE / phase).iterdir() if p.is_file())
paths += sorted(p for p in BASE.iterdir() if p.is_file())
paths += [Path('tests/fixtures') / name for name in ('hash_helper_source_isolation_perl_cases.json',
          'hash_helper_source_isolation_perl_extra_cases.json', 'hash_value_result_guard_perl_profiles.json')]
paths += [Path('docs/checkpoints/hash-value-result-guard-perl-2026-11-07/review_preflight.py'),
          Path('docs/checkpoints/hash-value-result-selection-2026-11-07/review.py')]
records = {}
for path in paths:
    assert not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual original/partial/final/private/direct epochs and readonly producer sealed')
