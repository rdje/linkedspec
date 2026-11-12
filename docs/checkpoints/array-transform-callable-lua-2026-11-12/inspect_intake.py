"""Inspect each installed Lua cold epoch; import no peer result or policy."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
cases = json.loads((BASE / 'cases.json').read_bytes())
assert (BASE / 'intake/complete.txt').is_file()
assert len(cases) == 312
routes = ('native', 'restored', 'plan', 'fresh')

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

def archive(path, rows):
    result = {}
    with tarfile.open(path) as stream:
        assert set(stream.getnames()) == rows.keys()
        for member in stream:
            assert member.isfile() and member.name not in result
            assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            body = stream.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    return result

result = {}
for host in ('puc', 'luajit'):
    out = BASE / 'intake' / host
    cold = {}
    stdout = gzip.decompress((out / 'normal-stdout.log.gz').read_bytes())
    for line in stdout.decode().splitlines():
        if line.startswith('CALLABLE_TRANSFORM_LUA '):
            _, key, body = line.split(' ', 2)
            assert key not in cold
            cold[key] = json.loads(body)
    assert list(cold) == [row['id'] for row in cases]
    assert all(set(row) == set(routes) for row in cold.values())
    for tag in ('memory', 'version', 'headers', 'build', 'normal'):
        assert (out / (tag + '-exit.txt')).read_text() == '0\n'
    artifacts = archive(out / 'actual-emitted-parsed.tar.gz', json.loads((out / 'artifact-identities.json').read_bytes()))
    assert len(artifacts) == 624
    for case in cases:
        for name, suffix in (('parsed', '.json'), ('emitted', '.lua')):
            assert str(REL / 'intake' / host / name / (case['id'] + suffix)) in artifacts
    native = archive(out / 'native-before-first-run.tar.gz', json.loads((out / 'native-identities.json').read_bytes()))
    assert len(native) == 3
    targets, healthy, profiles = [], [], []
    for case in cases[:45]:
        key = case['id']
        if 'expected' in case:
            wanted = {route: dict(value=case['expected']) for route in routes}
            (healthy if encoded(cold[key]) == encoded(wanted) else targets).append(key)
        elif 'expected_error' in case:
            assert all(case['expected_error'] in cold[key][route].get('error', '') for route in routes)
            healthy.append(key)
        else:
            profiles.append(key)
    keys = ('initial_number_terminal', 'initial_number_composed', 'initial_null_composed', 'initial_hash_composed',
        'own_initial_number_take_receiver_with', 'own_initial_hash_sorted_receiver_with',
        'own_scalar_bool_receiver', 'own_scalar_bool_receiver_with', 'own_scalar_bool_free_with',
        'own_extra_sorted_free', 'own_extra_sorted_receiver', 'own_signature_variadic_empty_terminal',
        'own_signature_variadic_empty_composed', 'positive_slice_receiver_terminal',
        'positive_concat_arrays_receiver_terminal', 'own_signature_fixed_missing_composed',
        'own_needed_source_take_receiver')
    version = b''.join(gzip.decompress((out / ('version-' + stream + '.log.gz')).read_bytes()) for stream in ('stdout', 'stderr')).decode()
    result[host] = dict(programs=312, routes=4, actual_pairs=312, native_images=3,
        runtime_banner=version, header_versions=gzip.decompress((out / 'headers-stdout.log.gz').read_bytes()).decode(),
        shared_targets=targets, shared_healthy=healthy, shared_profiles=profiles,
        observed=cold, selected_full_records={key: cold[key] for key in keys},
        actual_stderr_bytes={tag: len(gzip.decompress((out / (tag + '-stderr.log.gz')).read_bytes())) for tag in ('memory', 'headers', 'build', 'normal')},
        limits='Own installed-host cold observations only. Targets/compatibility/initial-policy preservation are not frozen; no declared5.4 or full native/transitive admission follows.')
target = BASE / 'intake-assessment.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({host: {key: value for key, value in row.items() if key != 'observed'} for host, row in result.items()}, indent=2, sort_keys=True))
