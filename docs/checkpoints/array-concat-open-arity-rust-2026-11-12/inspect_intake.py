"""Recover the independent Rust intake and classify authored Array intents."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ROUTES = ('native', 'restored', 'plan', 'fresh')
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(body, tag):
    rows = {}
    for key, raw in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in rows, 'duplicate frame'
        rows[key] = json.loads(raw)
    return rows


def recover():
    packets = {}
    for packet in json.loads((BASE / 'intake/custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts
        assert str(path).startswith(str(REL / 'intake') + '/')
        tag = path.name.removesuffix('-inputs.tar.gz')
        assert tag not in packets, 'duplicate packet'
        bodies, seen = {}, set()
        with tarfile.open(ROOT / path) as archive:
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts
                assert member.name not in seen, 'duplicate member'
                seen.add(member.name)
                row = packet['files'][member.name]
                body = archive.extractfile(member).read()
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archive bytes'
                assert member.mode & 0o777 == row['mode'], 'archive mode'
                if tag not in ('native-product', 'fresh-product'):
                    bodies[member.name] = body
        assert seen == packet['files'].keys(), 'archive membership'
        packets[tag] = dict(files=packet['files'], bodies=bodies)
    assert set(packets) == {'root', 'native-source', 'native-product', 'fresh-source', 'fresh-product'}
    return packets


def main():
    packets = recover()
    root = packets['root']
    for name, row in root['files'].items():
        if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/')):
            raw = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
            assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'activation source'
    cases = json.loads(root['bodies'][str(REL / 'cases.json')])
    assert cases == json.loads((BASE / 'cases.json').read_bytes())
    assert len(cases) == len({case['id'] for case in cases}) == 504
    assert not any({'expected', 'expected_error', 'expected_observation', 'role'} & case.keys() for case in cases)
    stdout = gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes())
    native = frames(stdout, 'ARRAY_CONCAT_RUST')
    fresh = frames(gzip.decompress((BASE / 'intake/fresh-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_RUST_FRESH')
    parsed = frames(stdout, 'ARRAY_CONCAT_RUST_PARSED_INPUT')
    compiled = frames(stdout, 'ARRAY_CONCAT_RUST_INPUT')
    keys = {case['id'] for case in cases}
    assert native.keys() == fresh.keys() == parsed.keys() == compiled.keys() == keys
    observed = {key: dict(row, fresh=fresh[key]) for key, row in native.items()}
    source = packets['fresh-source']['bodies']
    for key, record in observed.items():
        assert set(record) == set(ROUTES), 'route members'
        assert all(set(route) in ({'value'}, {'error'}) for route in record.values()), 'route shape'
        for folder, field, rows in (('parsed-inputs', 'parsed', parsed), ('inputs', 'compiled', compiled)):
            name = str(REL / 'intake/fresh' / folder / (key + '.json'))
            assert source[name] == rows[key][field].encode(), 'serialized input'
        assert str(REL / 'intake/fresh/src/generated' / (key + '.rs')) in source, 'emitted product'
    for path in (BASE / 'intake').glob('*-command.json'):
        tag = path.name.removesuffix('-command.json')
        record = json.loads(path.read_bytes())
        assert record['cwd'] == '.' and record['environment'] == {'CARGO_BUILD_JOBS': '1', 'RUST_TEST_THREADS': '1'}
        assert (BASE / 'intake' / (tag + '-exit.txt')).read_text() == '0\n'
        for channel in ('stdout', 'stderr'):
            body = gzip.decompress((BASE / 'intake' / (tag + '-' + channel + '.log.gz')).read_bytes())
            if tag in ('native', 'fresh') and channel == 'stderr':
                assert body == b'', 'SDK stderr'
        if tag in ('native', 'fresh'):
            executable = str(REL / 'intake' / (tag + '-exec'))
            assert executable in packets[tag + '-product']['files']
            assert record['argv'][:3] == ['bash', 'tools/project_data_run.sh', executable]
    old = json.loads(root['bodies']['tests/fixtures/array_transform_callable_result_guard_rust_profiles.json'])
    assert len(old) == 312
    for case in cases:
        if case['origin'] == 'legacy312':
            key = case['id']
            assert wire(observed[key]) == wire({route: old[key][route] for route in ROUTES}), 'legacy profile:' + key
            assert all(case[field] == old[key]['case'][field] for field in ('body', 'source', 'input', 'rule'))
    intents, targets, compatibility = {}, {}, {}
    for case in cases:
        key = case['id']
        if case['origin'] == 'shared84':
            if case.get('question') == 'needed-producer-error':
                terminal = re.sub(r'_(hash|terminal)$', '_terminal', key)
                assert all(set(row) == {'error'} for row in observed[terminal].values()), 'own terminal error'
                intent = copy.deepcopy(observed[terminal])
            else:
                values = [] if case['empty'] else ['head', 'tail', 'end'][:case['array_count']]
                order = ('S' if case['source_kind'] == 'function' else '') if case['empty'] else 'STU'[:case['array_count']]
                tail = case['tail']
                value = [values, order] if tail == 'terminal' else [values[-1].upper(), order] if tail == 'compatible' else [len(values), order + 'W'] if tail == 'with_' else [None, order]
                intent = {route: {'value': value} for route in ROUTES}
            intents[key] = intent
        elif case['origin'] == 'questions108':
            question = case['question']
            if question == 'valid-rest-source':
                effects = 'SXTU' if case['signature'] == 'rest_multi' else 'STU'
                value = [['head', 'tail', 'end'], effects] if case['tail'] == 'terminal' else [None, effects]
                intents[key] = {route: {'value': value} for route in ROUTES}
            elif question == 'source-snapshot':
                value = [['head', 'tail', 'end'] if case['tail'] == 'terminal' else None, ['head', 'changed']]
                intents[key] = {route: {'value': value} for route in ROUTES}
            elif question == 'nested-kinds':
                value = ['', '0', False, 0, None, {'k': [1]}, [False, 0], 'tail', 'end']
                intents[key] = {route: {'value': value} for route in ROUTES}
            else:
                assert question in ('initial-producer-policy', 'invalid-signature')
    for key, intent in intents.items():
        if wire(observed[key]) != wire(intent):
            case = next(case for case in cases if case['id'] == key)
            assert case.get('tail') in ('hash', 'later', 'composed'), 'unsupported producer/compatible intent:' + key
            targets[key] = intent
    for form in ('free', 'receiver'):
        key = 'own_extra_concat_arrays_' + form
        terminal = key + '_terminal_probe'
        assert all(wire(row) == wire({'value': [['head', 'tail', 'tail', 1], 'SX']}) for row in observed[terminal].values())
        # These are own legacy scalar-operand policies, not portable Array admission.
        compatibility[key] = {route: {'value': [None, 'SX']} for route in ROUTES}
        assert wire(observed[key]) != wire(compatibility[key])
    result = dict(observed=observed, intents=intents, targets=targets, compatibility=compatibility,
        programs=len(cases), supported_targets=sorted(targets), compatibility_ids=sorted(compatibility),
        preserved=len(cases) - len(targets) - len(compatibility), initial_policies=80, invalid_signatures=8,
        limits='Finite own Rust authored controls; exact published JSON errors/presence/kinds. No peer policies, initial/scalar admission or complete native/cache/toolchain/OS/transitive closure (4.2/SESSION5).')
    (BASE / 'intake-assessment.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key not in ('observed', 'intents', 'targets', 'compatibility')}))


if __name__ == '__main__':
    main()
