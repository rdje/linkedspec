"""Inspect own pre-production records and original normal fences, without SDK imports."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-concat-open-arity-selection-2026-11-12')
OUT = BASE / 'intake'
assert (OUT / 'complete.txt').is_file() and not (BASE / 'intake-assessment.json').exists()
cases = json.loads((BASE / 'cases.json').read_bytes())
assert len(cases) == 504


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def normalized(value):
    if isinstance(value, dict):
        return {key: normalized(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalized(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def projection(value):
    return normalized({key: child for key, child in value.items() if key not in ('substitution', 'module_input', 'handler_input')})


def frames(body):
    records, products = {}, {}
    for line in body.decode().splitlines():
        if line.startswith(('ARRAY_CONCAT_PERL ', 'ARRAY_CONCAT_INPUT ')):
            prefix, key, raw = line.split(' ', 2)
            target = records if prefix == 'ARRAY_CONCAT_PERL' else products
            assert key not in target
            target[key] = json.loads(raw)
    return records, products


READY = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])


def value_matches(row, value):
    return row['metadata'] == READY and not row['warnings'] and all(row[flag] == 1 and route in row
        and row[route + '_error'] is None and wire(row[route]) == wire(value)
        for route, flag in (('native', 'native_callable'), ('fresh', 'loaded')))


identities = json.loads((OUT / 'input-identities.json').read_bytes())
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        path = Path(member.name)
        assert member.isfile() and not path.is_absolute() and '..' not in path.parts
        body = archive.extractfile(member).read(); row = identities[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
for tag in ('memory', 'version', 'syntax', 'observer'):
    assert (OUT / (tag + '-exit.txt')).read_text() == '0\n'
    stderr = gzip.decompress((OUT / (tag + '-stderr.log.gz')).read_bytes())
    assert stderr == ((str(BASE / 'observer.pl') + ' syntax OK\n').encode() if tag == 'syntax' else b'')
rows, inputs = frames(gzip.decompress((OUT / 'observer-stdout.log.gz').read_bytes()))
assert list(rows) == list(inputs) == [row['id'] for row in cases]
for case in cases:
    key = case['id']
    assert inputs[key]['source'] == case['source']
    for field, product in (('module_input', 'emitted'), ('handler_input', 'handler')):
        record, source = rows[key][field], inputs[key][product]
        assert record is not None and isinstance(source, str)
        body = source.encode()
        assert len(body) == record['bytes'] and hashlib.sha256(body).hexdigest() == record['sha256']
        assert gzip.decompress(Path(record['path']).read_bytes()) == body
old = json.loads((OLD / 'assessment.json').read_bytes())
for case in cases[:84]:
    key = case['id']
    assert wire(projection(rows[key])) == wire(projection(old['observed'][key])), (key, 'original full observation changed')
    for field in ('module_input', 'handler_input'):
        assert gzip.decompress(Path(rows[key][field]['path']).read_bytes()) == gzip.decompress(Path(old['observed'][key][field]['path']).read_bytes()), (key, field)
profiles = json.loads(Path('tests/fixtures/array_transform_callable_result_guard_perl_cases.json').read_bytes())
assert len(profiles) == 312 and [row['case']['id'] for row in profiles] == [row['id'] for row in cases[84:396]]
for profile in profiles:
    key = profile['case']['id']; actual = rows[key]
    if profile['role'] == 'result-target':
        assert value_matches(actual, profile['expected']), (key, 'legacy target changed before production')
    else:
        assert wire(projection(actual)) == wire(profile['expected_observation']), (key, 'legacy full profile changed before production')
valid_producers, own_targets, snapshot_producers, nested = [], [], [], []
for case in cases[396:]:
    key = case['id']; actual = rows[key]
    if case['question'] == 'valid-rest-source':
        effects = 'SXTU' if case['signature'] == 'rest_multi' else 'STU'
        if case['tail'] == 'terminal':
            assert value_matches(actual, [['head', 'tail', 'end'], effects]), (key, 'producer prerequisite')
            valid_producers.append(key)
        elif not value_matches(actual, [None, effects]):
            own_targets.append(key)
    elif case['question'] == 'source-snapshot':
        desired = [['head', 'tail', 'end'], ['head', 'changed']] if case['tail'] == 'terminal' else [None, ['head', 'changed']]
        if case['tail'] == 'terminal':
            assert value_matches(actual, desired), (key, 'snapshot producer prerequisite')
            snapshot_producers.append(key)
        elif not value_matches(actual, desired):
            own_targets.append(key)
    elif case['question'] == 'nested-kinds':
        desired = ['', '0', False, 0, None, {'k': [1]}, [False, 0], 'tail', 'end']
        assert value_matches(actual, desired), (key, 'nested producer prerequisite')
        nested.append(key)
    elif case['question'] == 'invalid-signature':
        assert actual['metadata']['unresolved_helper_count'] > 0, (key, 'invalid signature unexpectedly admitted')
    else:
        assert case['question'] == 'initial-producer-policy'
assert len(valid_producers) == len(snapshot_producers) == len(nested) == 4
legacy_concat = {profile['case']['id']: dict(role=profile['role'], case=profile['case'], observed=rows[profile['case']['id']])
    for profile in profiles if 'concat_arrays' in profile['case']['body']}
own = {case['id']: rows[case['id']] for case in cases[396:]}
result = dict(programs=504, shared84_full_records_and_pairs_exact=True, legacy312_current_normal_profiles_exact=True,
    actual_module_dump_pairs=504, artifact_files=1008, original_supported_targets=old['contract_differences'],
    valid_rest_producer_controls=valid_producers, snapshot_producer_controls=snapshot_producers, nested_kind_controls=nested,
    additional_supported_targets=own_targets, legacy_concat=legacy_concat, own_observed=own,
    observed=rows, limits='Own pre-production questions only. Full raw channels retain eval serials; only comparison projections normalize those serial tokens/exclude artifact paths and diagnostic-only substitution text. Own initial/invalid policies are profiles, not semantic PASS or input authority. Native dumps follow internal compilation; full4.2/SESSION5 remains open.')
(BASE / 'intake-assessment.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({key: value for key, value in result.items() if key not in ('observed', 'own_observed', 'legacy_concat')}, indent=2))
