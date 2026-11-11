"""Freeze qualified supported targets, both actual epochs and reader inputs."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
qualified = json.loads((BASE / 'qualified-cases.json').read_bytes())
shared = ROOT / 'tests/fixtures/array_pipeline_callable_result_guard_cases.json'
perl = ROOT / 'tests/fixtures/array_pipeline_callable_perl_selection_cases.json'
assert not shared.exists() and not perl.exists() and not (BASE / 'sealed-identities.json').exists()
assert len(qualified[:37]) == 37 and all('/[z-a]/' not in row['source'] for row in qualified[:37])
shared.write_text(json.dumps(qualified[:37], indent=2) + '\n')
perl.write_bytes((BASE / 'qualified-cases.json').read_bytes())
observations = {}
for phase in ('intake', 'qualified'):
    rows = {}
    for line in gzip.decompress((BASE / phase / 'observer-stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_CALLABLE_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    observations[phase] = rows
(BASE / 'observations.json').write_text(json.dumps(observations, indent=2, sort_keys=True) + '\n')
rows = {}
for path in sorted([item for item in BASE.rglob('*') if item.is_file()] + [shared, perl]):
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    rows[str(path.relative_to(ROOT))] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'sealed-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Original39/qualified41 and safe shared37 sealed; no production changes')
