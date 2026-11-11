"""Inspect actual acquired cases without rewriting inputs or observations."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
rows = {}
for line in gzip.decompress((BASE / 'intake/observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_PIPELINE_CALLABLE_PERL '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
cases = json.loads((BASE / 'cases.json').read_bytes())
assert list(rows) == [case['id'] for case in cases]
for case in cases:
    row = rows[case['id']]
    print(json.dumps(dict(id=case['id'], expected=case.get('expected'),
        expected_error=case.get('expected_error'), metadata=row['metadata'],
        native=row.get('native'), native_error=row.get('native_error'),
        loaded=row['loaded'], load_error=row['load_error'], fresh=row.get('fresh'),
        fresh_error=row.get('fresh_error'), warnings=row['warnings']), sort_keys=True))
