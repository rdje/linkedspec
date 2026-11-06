"""Freeze independently observed Rust source/arity/error profiles after intake."""
import json
from pathlib import Path
import re

BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
destination = Path('tests/fixtures/hash_view_result_guard_rust_profiles.json')
assert not destination.exists(), 'one-shot independent profile freeze'
cases = json.loads((BASE / 'intake/cases.json').read_bytes())
rows, fresh = {}, {}
for filename, prefix, target in (('native-stdout.log', 'HASH_VIEW_RUST', rows),
                                 ('fresh-stdout.log', 'HASH_VIEW_RUST_FRESH', fresh)):
    for line in (BASE / 'intake' / filename).read_text().splitlines():
        match = re.match('^' + prefix + r' ([a-z0-9_]+) (.*)$', line)
        if match:
            assert match[1] not in target
            target[match[1]] = json.loads(match[2])
assert list(rows) == [case['id'] for case in cases]
assert list(fresh) == list(rows), 'retain any preparation failure; do not silently drop profiles'
profiles = {}
for case in cases:
    identifier = case['id']
    if case.get('profile_only') or case.get('expected_error'):
        assert 'preparation_error' not in rows[identifier]
        profiles[identifier] = dict(source=case['source'], **rows[identifier], fresh=fresh[identifier])
        if case.get('expected_error'):
            for name in ('native', 'restored', 'plan', 'fresh'):
                assert case['expected_error'] in profiles[identifier][name]['error']
destination.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
print('Own Rust source/arity/error profiles frozen from actual four-route observations')
