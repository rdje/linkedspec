"""Bind actual intake, original instruments and finite targets before recovery."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
target = BASE / 'sealed-identities.json'
assert not target.exists(), 'one-shot seal'
assert (BASE / 'intake/exit.txt').read_text() == '0\n'
paths = sorted(p for p in (BASE / 'intake').iterdir() if p.is_file())
paths += [BASE / name for name in ('capture.py', 'observer.pl', 'cases.py', 'cases.json',
          'freeze_targets.py', 'zero-key-profiles.json', 'review.py', 'run_review.py', 'seal.py')]
paths += [Path('tests/fixtures/hash_value_result_guard_cases.json'),
          Path('docs/checkpoints/type-operation-inventory/hash-value-result-guard-composition.md')]
records = {}
for path in paths:
    assert not path.is_symlink() and path.stat().st_dev == Path.cwd().stat().st_dev
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Original32 intake/instruments,28 targets and separate4 profiles sealed')
