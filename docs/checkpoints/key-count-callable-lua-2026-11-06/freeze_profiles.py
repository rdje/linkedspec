"""Freeze each installed Lua host's own actual source-bound intake profiles."""
import gzip
import json
from pathlib import Path

BASE = Path('docs/checkpoints/key-count-callable-lua-2026-11-06')
cases = json.loads((BASE / 'intake/cases.json').read_bytes())
profile_ids = {'boolean_receiver_profile', 'boolean_terminal_profile',
               'malformed_receiver_profile', 'needed_argument_error'}
profiles = {}
for host in ('puc', 'luajit'):
    observations = {}
    path = BASE / 'intake' / host / 'normal-stdout.log.gz'
    for line in gzip.decompress(path.read_bytes()).decode().splitlines():
        if line.startswith('CALLABLE_KEY_COUNT_LUA '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in observations
            observations[identifier] = json.loads(body)
    assert list(observations) == [c['id'] for c in cases]
    profiles[host] = {}
    for case in cases:
        row = observations[case['id']]
        assert set(row) == {'native', 'restored', 'plan', 'fresh'}
        if case['id'] in profile_ids:
            profiles[host][case['id']] = dict(source=case['source'], **row)
        else:
            assert all(value == {'value': case['expected']} for value in row.values()), (host, case['id'])
    for name in ('boolean_receiver_profile', 'boolean_terminal_profile'):
        assert all(value == {'value': None} for value in observations[name].values())
    assert all('binding_kind_mismatch' in observations['needed_argument_error'][route]['error']
               for route in ('native', 'restored', 'plan', 'fresh'))
output = Path('tests/fixtures/key_count_callable_lua_profiles.json')
assert not output.exists(), 'one-shot actual profile freeze'
output.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
print('Each installed Lua host independently freezes Boolean/arity/error profiles from its own intake')
