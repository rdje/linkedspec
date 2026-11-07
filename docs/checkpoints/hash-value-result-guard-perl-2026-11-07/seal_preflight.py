"""Bind actual preflight graph and unchanged instruments before recovery."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
target = BASE / 'preflight-identities.json'
assert not target.exists(), 'one-shot seal'
paths = []
for phase in ('before', 'seed_before'):
    assert (BASE / phase / 'exit.txt').read_text() == '0\n'
    paths += sorted(p for p in (BASE / phase).iterdir() if p.is_file())
paths += sorted(p for p in BASE.iterdir() if p.suffix in ('.py', '.pl', '.json'))
paths += [Path('tests/fixtures') / name for name in ('hash_value_result_guard_cases.json',
          'hash_value_result_guard_perl_profiles.json', 'hash_helper_source_isolation_perl_cases.json')]
paths += [Path('docs/checkpoints/hash-value-result-selection-2026-11-07') / name for name in ('review.py', 'cases.json')]
records = {}
for path in paths:
    assert not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual preflight graph, source projections/policies and instruments sealed')
