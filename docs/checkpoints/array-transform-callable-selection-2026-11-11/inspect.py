"""Assess only the frozen authored expectations; initial policies stay profiles."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
cases = json.loads((HERE / 'cases.json').read_bytes())
rows, inputs = {}, {}
for line in gzip.decompress((HERE / 'intake/observer-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL '):
        _, identifier, value = line.split(' ', 2)
        assert identifier not in rows
        rows[identifier] = json.loads(value)
    elif line.startswith('ARRAY_TRANSFORM_CALLABLE_INPUT '):
        _, identifier, value = line.split(' ', 2)
        assert identifier not in inputs
        inputs[identifier] = json.loads(value)
assert set(rows) == set(inputs) == {case['id'] for case in cases}


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


assessment = {}
for case in cases:
    identifier = case['id']
    row = rows[identifier]
    assert inputs[identifier]['source'] == case['source']
    for field, source_field in (('module_input', 'emitted'), ('handler_input', 'handler')):
        artifact = row[field]
        source = inputs[identifier][source_field]
        if source is None:
            assert artifact is None
        else:
            raw = source.encode()
            assert gzip.decompress(Path(artifact['path']).read_bytes()) == raw
            assert artifact['bytes'] == len(raw) and artifact['sha256'] == hashlib.sha256(raw).hexdigest()
    failures = []
    if case.get('profile_only'):
        classification = 'profile'
    else:
        meta = row['metadata']
        ready = (meta.get('language_agnostic_action_ir_ready') == 1
            and all(meta.get(name) == 0 for name in ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count'))
            and not meta.get('unresolved_helpers'))
        if not ready: failures.append('readiness')
        for route, callable_field in (('native', 'native_callable'), ('fresh', 'loaded')):
            if row.get(callable_field) != 1 or route not in row:
                failures.append(route + ':unavailable')
                continue
            error = row.get(route + '_error')
            if 'expected_error' in case:
                if not error or case['expected_error'] not in wire(error): failures.append(route + ':needed-error')
            else:
                if error: failures.append(route + ':unexpected-error')
                if wire(row[route]) != wire(case['expected']): failures.append(route + ':value')
        classification = 'target' if failures else 'healthy'
    assessment[identifier] = dict(classification=classification, failures=failures)
summary = {name: [identifier for identifier, row in assessment.items() if row['classification'] == name]
           for name in ('target', 'healthy', 'profile')}
summary['readiness_only'] = [identifier for identifier, row in assessment.items() if row['failures'] == ['readiness']]
summary['metadata_fields'] = sorted(next(iter(rows.values()))['metadata'])
assert len(summary['metadata_fields']) == 5 and all(sorted(row['metadata']) == summary['metadata_fields'] for row in rows.values())
assert not (HERE / 'assessment.json').exists()
(HERE / 'observations.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(HERE / 'input-records.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
(HERE / 'assessment.json').write_text(json.dumps(dict(rows=assessment, summary=summary), indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', acquisition_only=True,
    targets=len(summary['target']), healthy=len(summary['healthy']), profiles=len(summary['profile']),
    readiness_only=summary['readiness_only'], target_ids=summary['target']), sort_keys=True))
