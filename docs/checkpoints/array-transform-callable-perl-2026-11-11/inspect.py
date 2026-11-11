"""Assess frozen shared expectations and retain all own policy questions as data."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
cases = json.loads((HERE / 'cases.json').read_bytes())
rows, inputs = {}, {}
for line in gzip.decompress((HERE / 'intake/observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_PERL '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
    elif line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_INPUT '):
        _, key, value = line.split(' ', 2)
        assert key not in inputs
        inputs[key] = json.loads(value)
assert set(rows) == set(inputs) == {case['id'] for case in cases}


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


shared, groups = {}, {}
pairs = 0
for case in cases:
    key, row = case['id'], rows[case['id']]
    assert inputs[key]['source'] == case['source']
    for field, source_field in (('module_input', 'emitted'), ('handler_input', 'handler')):
        artifact, source = row[field], inputs[key][source_field]
        if source is None:
            assert artifact is None
        else:
            raw = source.encode()
            assert gzip.decompress(Path(artifact['path']).read_bytes()) == raw
            assert len(raw) == artifact['bytes'] and hashlib.sha256(raw).hexdigest() == artifact['sha256']
    pairs += row['module_input'] is not None and row['handler_input'] is not None
    if key.startswith('own_'):
        groups.setdefault(case['question'], []).append(key)
        continue
    failures = []
    if case.get('profile_only'):
        classification = 'profile'
    else:
        meta = row['metadata']
        ready = meta.get('language_agnostic_action_ir_ready') == 1 and all(meta.get(name) == 0 for name in
            ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count')) and not meta.get('unresolved_helpers')
        if not ready: failures.append('readiness')
        for route, usable in (('native', 'native_callable'), ('fresh', 'loaded')):
            if row.get(usable) != 1 or route not in row:
                failures.append(route + ':unavailable')
                continue
            error = row.get(route + '_error')
            if 'expected_error' in case:
                if not error or case['expected_error'] not in wire(error): failures.append(route + ':needed-error')
            else:
                if error: failures.append(route + ':unexpected-error')
                if wire(row[route]) != wire(case['expected']): failures.append(route + ':value')
        classification = 'target' if failures else 'healthy'
    shared[key] = dict(classification=classification, failures=failures)
summary = {name: [key for key, row in shared.items() if row['classification'] == name]
    for name in ('target', 'healthy', 'profile')}
assert not (HERE / 'analysis.json').exists()
(HERE / 'observations.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(HERE / 'input-records.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
(HERE / 'analysis.json').write_text(json.dumps(dict(shared=shared, summary=summary,
    own_question_groups=groups, pairs=pairs), indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', acquisition_only=True, questions=len(cases), actual_source_pairs=pairs,
    shared={name:len(keys) for name,keys in summary.items()},
    own_question_groups={name:len(keys) for name,keys in groups.items()}), sort_keys=True))
