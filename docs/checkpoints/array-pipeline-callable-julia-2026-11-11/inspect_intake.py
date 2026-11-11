"""Readonly presentation of actual Julia outcomes, with no peer outcome oracle."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
rows = {}
for line in gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('CALLABLE_PIPELINE_JULIA '):
        _, key, body = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(body)
cases = json.loads((BASE / 'cases.json').read_bytes())
assert list(rows) == [row['id'] for row in cases]
assert all(set(row) == {'native', 'restored', 'plan', 'fresh'} for row in rows.values())
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
print('VERSION', gzip.decompress((BASE / 'intake/version-stdout.log.gz').read_bytes()).decode().strip())
print('ALL_PREPARED', len(rows))
for case in shared:
    print('SHARED', case['id'], json.dumps(dict(question=case, actual=rows[case['id']]), sort_keys=True))
groups = {}
for case in cases[len(shared):]:
    groups.setdefault(case['question'], []).append(case)
for question, values in groups.items():
    print('QUESTION', question, len(values))
    for case in values:
        actual = rows[case['id']]
        if question.startswith('initial') or question.startswith('excluded'):
            print('POLICY', case['id'], json.dumps(actual['native'], sort_keys=True))
        else:
            print('FULL', case['id'], json.dumps(actual, sort_keys=True))
