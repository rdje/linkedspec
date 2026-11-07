"""Freeze actual extra policies and route the existing normal to this leaf."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
FIELDS = ('metadata native_callable loaded substitution_error descriptor_error emission_error build_error load_error native fresh native_error fresh_error native_cursor fresh_cursor warnings').split()


def normalize(value):
    if isinstance(value, list):
        return [normalize(v) for v in value]
    if isinstance(value, dict):
        return {k: normalize(v) for k, v in value.items()}
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


rows = {}
for line in gzip.decompress((BASE / 'prefix_intake/stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_PERL '):
        _, identifier, raw = line.split(' ', 2)
        assert identifier not in rows
        rows[identifier] = json.loads(raw)
cases = json.loads((BASE / 'prefix_cases.json').read_text())
assert list(rows) == [c['id'] for c in cases] and len(cases) == 52
profiles = []
for case in cases:
    row = rows[case['id']]
    if case['id'].startswith('prefix_number_'):
        expected = ['extra'] if 'concat_arrays' in case['id'] else []
        assert row.get('native') == row.get('fresh') == expected, 'source78.0 must remain isolated before result edits'
        assert row['native_error'] is row['fresh_error'] is None
    assert row['host_before'] == row['host_after']
    profiles.append(dict(case=case, expected_observation=normalize({k: row[k] for k in FIELDS if k in row})))
fixture = Path('tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json')
assert not fixture.exists()
fixture.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
text = Path('t/array_transform_source_isolation.t').read_text()
text = text.replace('LINKEDSPEC_ARRAY_TRANSFORM_SOURCE_CAPTURE', 'LINKEDSPEC_ARRAY_TRANSFORM_COMPOSITION_CAPTURE').replace('ARRAY_TRANSFORM_SOURCE', 'ARRAY_TRANSFORM_COMPOSITION')
text = text.replace('array-transform-source-perl-2026-11-07', 'array-transform-composition-perl-2026-11-07')
text = text.replace('tests/fixtures/array_transform_source_isolation_perl_cases.json', 'tests/fixtures/array_transform_result_guard_cases.json')
text = text.replace('summary helper_name phase rule_label', 'summary helper_name name phase rule_label')
old = "for my $profile (@{read_json('tests/fixtures/array_transform_result_guard_perl_profiles.json')}) {"
new = "for my $profile (map { @{read_json($_)} } qw(tests/fixtures/array_transform_result_guard_perl_profiles.json tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json)) {"
assert text.count(old) == 1
text = text.replace(old, new)
text = text.replace("        is($json->encode(projection($actual)),", "        is_deeply($actual->{host_after}, $actual->{host_before}, 'localized host Arrays remain unchanged');\n        is($json->encode(projection($actual)),")
Path('t/array_transform_result_guard_composition.t').write_text(text)
print('Own52 prefix/arity profiles frozen; Number3 source isolation holds; new normal37+123+52 ready')
