"""Freeze actual selection inputs and source-only questions before readonly review."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
assert not (HERE / 'sealed-identities.json').exists(), 'one-shot seal'
shared = ROOT / 'tests/fixtures/array_transform_callable_result_guard_cases.json'
assert not shared.exists()
shared.write_bytes((HERE / 'qualified-cases.json').read_bytes())
rows = {}
for path in sorted([path for path in HERE.rglob('*') if path.is_file()] + [shared]):
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    rows[path.relative_to(ROOT).as_posix()] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
        mode=path.stat().st_mode & 0o777)
(HERE / 'sealed-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', original44_preserved=True, qualified45_frozen=True,
    native_custody='separately owned4.2/SESSION5', sealed_files=len(rows)), sort_keys=True))
