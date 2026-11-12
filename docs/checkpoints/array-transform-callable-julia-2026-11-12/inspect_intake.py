"""Inspect actual Julia full wires and archived inputs without a peer oracle."""
import gzip
import hashlib
import json
from pathlib import Path
from collections import Counter
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
cases = json.loads((BASE / 'cases.json').read_bytes())
observed = {}
stdout = gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes())
for line in stdout.decode().splitlines():
    if line.startswith('CALLABLE_TRANSFORM_JULIA '):
        _, key, body = line.split(' ', 2)
        assert key not in observed
        observed[key] = json.loads(body)
assert list(observed) == [row['id'] for row in cases]
routes = ('native', 'restored', 'plan', 'fresh')
assert len(observed) == 312 and all(set(row) == set(routes) for row in observed.values())
for name in ('version', 'native', 'memory'):
    assert (BASE / 'intake' / (name + '-exit.txt')).read_text() == '0\n'
archive_row = next(row for row in json.loads((BASE / 'intake/custody.json').read_bytes()) if row['tag'] == 'artifacts')
with tarfile.open(ROOT / archive_row['archive']) as archive:
    assert set(archive.getnames()) == archive_row['files'].keys()
    assert len(archive_row['files']) == 624
    for member in archive:
        body = archive.extractfile(member).read(); row = archive_row['files'][member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
        assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
    for case in cases:
        assert str(REL / 'intake/parsed' / (case['id'] + '.json')) in archive_row['files']
        assert str(REL / 'intake/emitted' / (case['id'] + '.jl')) in archive_row['files']

def same(left, right):
    return json.dumps(left, sort_keys=True) == json.dumps(right, sort_keys=True)

targets, healthy, profiles = [], [], []
for case in cases[:45]:
    key = case['id']
    if 'expected' in case:
        wanted = {route: dict(value=case['expected']) for route in routes}
        (healthy if same(observed[key], wanted) else targets).append(key)
    elif 'expected_error' in case:
        assert all(case['expected_error'] in observed[key][route].get('error', '') for route in routes)
        healthy.append(key)
    else:
        profiles.append(key)
selected = [row['id'] for row in cases if row['id'] in (
    'initial_number_terminal', 'initial_number_composed', 'initial_null_composed', 'initial_hash_composed',
    'own_initial_number_take_receiver_with', 'own_initial_hash_sorted_receiver_with',
    'own_scalar_bool_receiver', 'own_scalar_bool_receiver_with', 'own_scalar_bool_free_with',
    'own_extra_sorted_free', 'own_extra_sorted_receiver', 'own_signature_variadic_empty_terminal',
    'own_signature_variadic_empty_composed', 'positive_slice_receiver_terminal',
    'positive_concat_arrays_receiver_terminal', 'own_signature_fixed_missing_composed',
    'own_needed_source_take_receiver')]
result = dict(programs=312, routes=4, actual_parsed_module_pairs=312,
    shared_targets=targets, shared_healthy=healthy, shared_profiles=profiles,
    own_question_census=dict(Counter(row['question'] for row in cases[45:])),
    selected_full_records={key: observed[key] for key in selected},
    actual_stderr_bytes={name: len(gzip.decompress((BASE / 'intake' / (name + '-stderr.log.gz')).read_bytes())) for name in ('native', 'version', 'memory')},
    limits='Original Julia observations only; source-only authored questions. Shared intentions are assessed independently. Own targets/policies are not frozen and production is unchanged.')
target = BASE / 'intake-assessment.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, indent=2, sort_keys=True))
