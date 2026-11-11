"""Grade finite authored values/errors and independent full-source readiness."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = json.loads((BASE / 'cases.json').read_bytes())
rows = {}
for line in gzip.decompress((BASE / 'intake/observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_PIPELINE_CALLABLE_PERL '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
assert list(rows) == [case['id'] for case in cases]
expected_meta = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
bad_values, bad_readiness, profiles = [], [], {}
for case in cases:
    key = case['id']
    row = rows[key]
    assert all(row[field] is None for field in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error'))
    assert row['native_callable'] == 1
    if row['metadata'] != expected_meta:
        bad_readiness.append(key)
    if case.get('profile_only'):
        assert row['loaded'] == 1 and row['native_error'] is None and row['fresh_error'] is None
        assert row['native'] == row['fresh']
        profiles[key] = row
        continue
    if case.get('expected_error'):
        valid = row['loaded'] == 1 and all(isinstance(row.get(route + '_error'), dict)
            and case['expected_error'] in row[route + '_error'].get('detail', '') for route in ('native', 'fresh'))
    else:
        valid = row['loaded'] == 1 and all(row.get(route + '_error') is None
            and row.get(route) == case['expected'] for route in ('native', 'fresh'))
    if not valid:
        bad_values.append(key)
targets = sorted(set(bad_values) | set(bad_readiness))
healthy = [case['id'] for case in cases if case['id'] not in targets]
print(json.dumps(dict(cases=len(cases), value_error_targets=bad_values,
    readiness_targets=bad_readiness, targets=targets, healthy=healthy,
    initial_terminal_profiles={key: row['native'] for key, row in profiles.items()},
    details={key: dict(metadata=rows[key]['metadata'], native=rows[key].get('native'),
        native_error=rows[key].get('native_error'), loaded=rows[key]['loaded'],
        fresh=rows[key].get('fresh'), fresh_error=rows[key].get('fresh_error')) for key in targets}), indent=2))
