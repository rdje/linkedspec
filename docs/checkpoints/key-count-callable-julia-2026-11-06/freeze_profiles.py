"""Freeze only Julia's actual source-bound nonportable intake profiles."""
import gzip
import json
from pathlib import Path

BASE = Path('docs/checkpoints/key-count-callable-julia-2026-11-06')
cases = json.loads((BASE / 'intake/cases.json').read_text())
observations = {}
for line in gzip.decompress((BASE / 'intake/stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('CALLABLE_KEY_COUNT_JULIA '):
        _, identifier, body = line.split(' ', 2)
        assert identifier not in observations
        observations[identifier] = json.loads(body)
assert list(observations) == [c['id'] for c in cases]
profile_ids = {'boolean_receiver_profile', 'boolean_terminal_profile',
               'malformed_receiver_profile', 'needed_argument_error'}
profiles = {}
for case in cases:
    row = observations[case['id']]
    assert set(row) == {'native', 'restored', 'plan', 'fresh'}
    if case['id'] in profile_ids:
        profiles[case['id']] = dict(source=case['source'], **row)
    else:
        assert all(value == {'value': case['expected']} for value in row.values()), case['id']
for name in ('boolean_receiver_profile', 'boolean_terminal_profile'):
    assert all(value == {'value': None} for key, value in profiles[name].items() if key != 'source')
assert all('binding_kind_mismatch' in profiles['needed_argument_error'][r]['error']
           for r in ('native', 'restored', 'plan', 'fresh'))
output = Path('tests/fixtures/key_count_callable_julia_profiles.json')
assert not output.exists(), 'one-shot actual profile freeze'
output.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
print('Julia source-bound Boolean terminal/composed, arity and error profiles frozen from actual intake')
