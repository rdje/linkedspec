"""Inspect complete actual preflight channels; never alter a source or verdict."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
raw = gzip.decompress((BASE / 'preflight/stdout.log.gz').read_bytes())
rows = {}
for line in raw.decode().splitlines():
    if line.startswith('ARRAY_PIPELINE_PERL '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
cases = json.loads((BASE / 'cases.json').read_bytes())
assert list(rows) == [case['id'] for case in cases]
assert all(row['host_before'] == row['host_after'] for row in rows.values())


def view(case):
    row = rows[case['id']]
    return {key: row[key] for key in ('native', 'native_error', 'fresh', 'fresh_error',
        'loaded', 'load_error', 'metadata', 'build_error', 'build_context_error', 'warnings') if key in row}


common = []
for case in cases[:36]:
    row = rows[case['id']]
    if case.get('expected_error'):
        valid = all(case['expected_error'] in str(row.get(route + '_error')) for route in ('native', 'fresh'))
    else:
        valid = all(row.get(route + '_error') is None and row.get(route) == case['expected'] for route in ('native', 'fresh'))
    common.append(dict(id=case['id'], passing=valid, observation=view(case)))
summary = dict(actual_programs=len(rows), original_common=common,
    initial={case['id']: view(case) for case in cases if case['id'].startswith('initial_') and '_host_' not in case['id']},
    extra_arity={case['id']: view(case) for case in cases if case['id'].startswith('extra_')},
    prior={case['id']: view(case) for case in cases if case['id'].startswith('prior_')},
    needed_and_patterns={case['id']: view(case) for case in cases if case['id'].startswith(('needed_', 'invalid_pattern'))},
    host={case['id']: view(case) for case in cases if case.get('seed')},
    kinds={case['id']: view(case) for case in cases if case['id'] in ('nested_scalar_kinds', 'numeric_array_source')},
    actual_stdout_sha256=hashlib.sha256(raw).hexdigest())
target = BASE / 'inspection.json'; assert not target.exists()
target.write_text(json.dumps(summary, indent=2) + '\n')
print('common passing', sum(row['passing'] for row in common), 'failing', sum(not row['passing'] for row in common))
for name in ('initial', 'extra_arity', 'prior', 'needed_and_patterns', 'host', 'kinds'):
    for key, row in summary[name].items():
        print(json.dumps(dict(group=name, id=key, **row), sort_keys=True))
