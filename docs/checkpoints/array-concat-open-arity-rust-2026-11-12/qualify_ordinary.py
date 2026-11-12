"""Adjudicate exact own ordinary old/current probes before two profile transfers."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ROUTES = ('native', 'restored', 'plan', 'fresh')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(body, tag):
    rows = {}
    for key, raw in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in rows
        rows[key] = json.loads(raw)
    return rows


def recover(phase):
    result = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        tag = Path(packet['archive']).name.removesuffix('-inputs.tar.gz')
        bodies = {}
        with tarfile.open(ROOT / packet['archive']) as archive:
            assert set(archive.getnames()) == packet['files'].keys()
            for member in archive:
                assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
                body = archive.extractfile(member).read(); row = packet['files'][member.name]
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
                if not tag.endswith('-product'):
                    bodies[member.name] = body
        result[tag] = dict(files=packet['files'], bodies=bodies)
    return result


data = {phase: recover(phase) for phase in ('ordinary-old', 'ordinary-fixed')}
observed = {}
for phase in data:
    native = frames(gzip.decompress((BASE / phase / 'native-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_RUST')
    fresh = frames(gzip.decompress((BASE / phase / 'fresh-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_RUST_FRESH')
    assert len(native) == 4 and native.keys() == fresh.keys()
    observed[phase] = {key: dict(row, fresh=fresh[key]) for key, row in native.items()}
    for tag in ('native', 'fresh'):
        assert (BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
        assert gzip.decompress((BASE / phase / (tag + '-stderr.log.gz')).read_bytes()) == b''
original = json.loads(gzip.decompress((BASE / 'ordinary-profile-original.json.gz').read_bytes()))
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    terminal = {route: {'value': [['b', 'a', 'z', 1], 'SX']} for route in ROUTES}
    assert wire(observed['ordinary-old'][key + '_terminal']) == wire(terminal)
    assert wire(observed['ordinary-fixed'][key + '_terminal']) == wire(terminal)
    assert wire(observed['ordinary-old'][key + '_composed']) == wire({route: original[key][route] for route in ROUTES})
    assert wire(observed['ordinary-fixed'][key + '_composed']) == wire({route: {'value': [None, 'SX']} for route in ROUTES})
    for suffix in ('_terminal', '_composed'):
        for folder, extension in (('parsed-inputs', '.json'), ('inputs', '.json'), ('src/generated', '.rs')):
            name = key + suffix + extension
            assert data['ordinary-old']['fresh-source']['bodies'][str(REL / 'ordinary-old/fresh' / folder / name)] == data['ordinary-fixed']['fresh-source']['bodies'][str(REL / 'ordinary-fixed/fresh' / folder / name)]
prefix = str(REL / 'ordinary-qualification-owner') + '/'
old_root, fixed_root = data['ordinary-old']['root'], data['ordinary-fixed']['root']
names = {name for name in old_root['files'] if name.startswith(prefix)}
assert names == {name for name in fixed_root['files'] if name.startswith(prefix)}
owner = prefix + 'rust/linkedspec-runtime/src/engine.rs'
assert old_root['bodies'][owner] == gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes())
assert fixed_root['bodies'][owner] == gzip.decompress((BASE / 'repair-run/owner-after.rs.gz').read_bytes())
for name in names - {owner}:
    assert old_root['files'][name] == fixed_root['files'][name]
path = Path('tests/fixtures/array_transform_result_guard_rust_profiles.json')
assert path.read_bytes() == gzip.decompress((BASE / 'ordinary-profile-original.json.gz').read_bytes())
updated = copy.deepcopy(original)
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    for route in ROUTES:
        updated[key][route] = observed['ordinary-fixed'][key + '_composed'][route]
for key in original.keys() - {'extra_concat_arrays_free', 'extra_concat_arrays_receiver'}:
    assert wire(original[key]) == wire(updated[key])
path.write_text(json.dumps(updated, indent=2, sort_keys=True) + '\n')
(BASE / 'ordinary-qualification.json').write_text(json.dumps(dict(observed=observed, transferred=2,
    source_triple_pairs=4, same_private_path=True,
    scope='Two additional old ordinary profiles outside main504; same original terminal Array/effects, later Hash rejection. No SDK change, supported non-Array admission or native/cache/transitive closure.'), indent=2, sort_keys=True) + '\n')
print('Exact ordinary same-path old/current four-route probes qualify only two legacy expected projections; all other objects/source policies unchanged')
