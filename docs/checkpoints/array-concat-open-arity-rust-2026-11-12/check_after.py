"""Validate every repaired route, then transfer only two own legacy profiles."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
ROUTES = ('native', 'restored', 'plan', 'fresh')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(body, tag):
    result = {}
    for key, value in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in result
        result[key] = json.loads(value)
    return result


def products(phase):
    packets = json.loads((BASE / phase / 'custody.json').read_bytes())
    packet, = [row for row in packets if row['archive'].endswith('/fresh-source-inputs.tar.gz')]
    result = {}
    with tarfile.open(ROOT / packet['archive']) as archive:
        assert set(archive.getnames()) == packet['files'].keys()
        for member in archive:
            body = archive.extractfile(member).read(); row = packet['files'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name.split('/' + phase + '/fresh/', 1)[1]] = body
    return result


native = frames(gzip.decompress((BASE / 'after/native-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_RUST')
fresh = frames(gzip.decompress((BASE / 'after/fresh-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_RUST_FRESH')
assert native.keys() == fresh.keys() and len(native) == 504
observed = {key: dict(row, fresh=fresh[key]) for key, row in native.items()}
profiles = json.loads(Path('tests/fixtures/array_concat_open_arity_result_guard_rust_profiles.json').read_bytes())
assert profiles.keys() == observed.keys()
for key, row in observed.items():
    assert wire(row) == wire({route: profiles[key][route] for route in ROUTES}), 'full repaired observation:' + key
for channel in ('native', 'fresh'):
    assert (BASE / 'after' / (channel + '-exit.txt')).read_text() == '0\n'
    assert gzip.decompress((BASE / 'after' / (channel + '-stderr.log.gz')).read_bytes()) == b''
assert products('intake') == products('after'), 'all generated/parsed/compiled source bytes'
legacy = Path('tests/fixtures/array_transform_callable_result_guard_rust_profiles.json')
before = legacy.read_bytes()
assert before == gzip.decompress((BASE / 'template-4.gz').read_bytes())
(BASE / 'legacy-before-transfer.json.gz').write_bytes(gzip.compress(before, mtime=0))
original = json.loads(before); updated = copy.deepcopy(original)
for key in ('own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'):
    updated[key]['role'] = 'open-arity-operand-compatibility'
    for route in ROUTES:
        updated[key][route] = observed[key][route]
for key in original.keys() - {'own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'}:
    assert wire(original[key]) == wire(updated[key])
legacy.write_text(json.dumps(updated, indent=2, sort_keys=True) + '\n')
(BASE / 'after-validation.json').write_text(json.dumps(dict(programs=504, source_triples=504,
    exact_records=486, supported_targets=16, separate_compatibility=2, legacy_transfers=2,
    before_sha256=hashlib.sha256(before).hexdigest(), after_sha256=hashlib.sha256(legacy.read_bytes()).hexdigest()), indent=2) + '\n')
print('Own504/four routes pass; all504 source triples exact; only two separately qualified legacy profiles transferred')
