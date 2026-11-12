"""Recover own Julia source-bound intake and adjudicate authored concat intents."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '952f8a022c59a478614ba1413e0e36e49e7e14e8'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(body, tag):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, raw = line.split(' ', 2)
            assert key not in rows, 'duplicate frame'
            rows[key] = json.loads(raw)
    return rows


def recover():
    packets = {}
    for packet in json.loads((BASE / 'intake/custody.json').read_bytes()):
        name = PurePosixPath(packet['archive'])
        assert not name.is_absolute() and '..' not in name.parts
        assert str(name).startswith(str(BASE / 'intake') + '/') and packet['tag'] not in packets
        bodies = {}
        with tarfile.open(name) as archive:
            assert len(archive.getnames()) == len(packet['files']) and set(archive.getnames()) == packet['files'].keys()
            for member in archive:
                path = PurePosixPath(member.name)
                assert member.isfile() and not path.is_absolute() and '..' not in path.parts
                body = archive.extractfile(member).read()
                row = packet['files'][member.name]
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archive bytes'
                assert member.mode & 0o777 == row['mode'], 'full filesystem mode'
                bodies[member.name] = body
        packets[packet['tag']] = dict(files=packet['files'], bodies=bodies)
    assert set(packets) == {'root', 'artifacts'}
    return packets


def main():
    packets = recover()
    root, artifacts = packets['root']['bodies'], packets['artifacts']['bodies']
    names = set()
    command = ['git', 'archive', ACTIVATION, 'julia', 'tests/fixtures',
        'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec']
    with subprocess.Popen(command, stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as archive:
            for member in archive:
                if member.isfile():
                    raw = archive.extractfile(member).read()
                    row = packets['root']['files'][member.name]
                    assert raw == root[member.name], 'activation source:' + member.name
                    assert bool(member.mode & 0o111) == bool(row['mode'] & 0o111), 'Git executable class'
                    names.add(member.name)
        assert process.wait() == 0
    assert names == {name for name in root if name.startswith(('julia/', 'tests/fixtures/', 'specs/'))}
    cases = json.loads(root[str(BASE / 'cases.json')])
    assert cases == json.loads((BASE / 'cases.json').read_bytes())
    assert len(cases) == len({row['id'] for row in cases}) == 508
    assert all(not {'expected', 'role', 'expected_error', 'expected_observation'} & row.keys() for row in cases)
    stdout = gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes())
    assert b'ARRAY_CONCAT_JULIA_OWNER julia/src/LinkedSpecJulia.jl\n' in stdout
    observed = frames(stdout, 'ARRAY_CONCAT_JULIA')
    parsed = frames(stdout, 'ARRAY_CONCAT_JULIA_INPUT')
    assert list(observed) == list(parsed) == [row['id'] for row in cases]
    assert len(artifacts) == 2 * len(cases)
    for key, row in observed.items():
        assert set(row) == set(ROUTES), 'route census:' + key
        assert all('value' in item or 'error' in item for item in row.values()), 'route shape'
        assert wire(json.loads(artifacts[str(BASE / 'intake/parsed' / (key + '.json'))])) == wire(parsed[key])
        assert artifacts[str(BASE / 'intake/emitted' / (key + '.jl'))], 'actual emitted module'
    grammar, = [line for line in stdout.decode().splitlines() if line.startswith('ARRAY_CONCAT_JULIA_GRAMMAR ')]
    assert json.loads(grammar.split(' ', 1)[1]) == dict(path='specs/user_function_definition.spec',
        source=root['specs/user_function_definition.spec'].decode())
    observer = root[str(BASE / 'observer.jl')]
    assert observer.index(b'write(parsed_path, serialized)') < observer.index(b'from_json(SpecFile,') < observer.index(b'compile_spec(parsed)')
    assert observer.index(b'write(emitted_path, emitted)') < observer.index(b'Base.include_string(host, retained_emitted)')
    for tag in ('native', 'version', 'memory'):
        assert (BASE / 'intake' / (tag + '-exit.txt')).read_text() == '0\n'
    legacy = {row['id']: row['expected'] for row in json.loads(root['tests/fixtures/array_transform_callable_result_guard_julia_profiles.json'])}
    ordinary = json.loads(root['tests/fixtures/array_transform_result_guard_julia_profiles.json'])
    for case in cases:
        key = case['id']
        if case['origin'] == 'legacy312':
            assert wire(observed[key]) == wire(legacy[key]), 'own legacy full observation:' + key
        elif case['origin'] == 'ordinary4' and case['tail'] == 'composed':
            assert wire(observed[key]) == wire({route: ordinary[case['legacy_id']][route] for route in ROUTES}), 'own ordinary baseline'
    intents, targets, compatibility = {}, {}, {}
    for case in cases:
        key, origin = case['id'], case['origin']
        if origin == 'shared84':
            if case.get('question') == 'needed-producer-error':
                terminal = re.sub(r'_(hash|terminal)$', '_terminal', key)
                assert all('error' in row for row in observed[terminal].values()), 'own needed terminal error'
                expected = copy.deepcopy(observed[terminal])
                for route in ('plan', 'fresh'):
                    identity = 'array-concat-open-arity-result-guard/'
                    assert expected[route]['error_json']['source_identity'] == identity + terminal + '.spec'
                    expected[route]['error_json']['source_identity'] = identity + key + '.spec'
                intents[key] = expected
            else:
                values = [] if case['empty'] else ['head', 'tail', 'end'][:case['array_count']]
                effects = ('S' if case['source_kind'] == 'function' else '') if case['empty'] else 'STU'[:case['array_count']]
                tail = case['tail']
                if tail == 'terminal':
                    value = [values, effects]
                elif tail == 'compatible':
                    value = [values[-1].upper(), effects]
                elif tail == 'with_':
                    value = [len(values), effects + 'W']
                else:
                    assert tail in ('hash', 'later')
                    value = [None, effects]
                intents[key] = {route: dict(value=copy.deepcopy(value)) for route in ROUTES}
        elif origin == 'questions108':
            question = case['question']
            if question == 'valid-rest-source':
                effects = 'SXTU' if case['signature'] == 'rest_multi' else 'STU'
                value = [['head', 'tail', 'end'], effects] if case['tail'] == 'terminal' else [None, effects]
            elif question == 'source-snapshot':
                value = [['head', 'tail', 'end'] if case['tail'] == 'terminal' else None, ['head', 'changed']]
            elif question == 'nested-kinds':
                value = ['', '0', False, 0, None, {'k': [1]}, [False, 0], 'tail', 'end']
            else:
                assert question in ('initial-producer-policy', 'invalid-signature')
                continue
            intents[key] = {route: dict(value=copy.deepcopy(value)) for route in ROUTES}
    for key, expected in intents.items():
        if wire(observed[key]) != wire(expected):
            case = next(row for row in cases if row['id'] == key)
            assert case.get('tail') in ('hash', 'later', 'composed'), 'unsupported terminal/compatible intent:' + key
            targets[key] = expected
    for form in ('free', 'receiver'):
        pairs = [
            ('own_extra_concat_arrays_' + form, 'own_extra_concat_arrays_' + form + '_terminal_probe'),
            ('ordinary_legacy_extra_concat_arrays_' + form + '_composed', 'ordinary_legacy_extra_concat_arrays_' + form + '_terminal'),
        ]
        for key, terminal in pairs:
            assert all(set(row) == {'value'} and isinstance(row['value'][0], list)
                and isinstance(row['value'][1], str) for row in observed[terminal].values()), 'own terminal Array policy'
            expected = {route: dict(value=[None, observed[terminal][route]['value'][1]]) for route in ROUTES}
            if wire(observed[key]) != wire(expected):
                compatibility[key] = expected
    result = dict(observed=observed, intents=intents, targets=targets, compatibility=compatibility,
        programs=len(cases), supported_targets=sorted(targets), compatibility_ids=sorted(compatibility),
        preserved=len(cases) - len(targets) - len(compatibility),
        initial_policy_ids=[row['id'] for row in cases if row['origin'] == 'questions108' and row.get('question') == 'initial-producer-policy'],
        invalid_signature_ids=[row['id'] for row in cases if row['origin'] == 'questions108' and row.get('question') == 'invalid-signature'],
        stderr_bytes={tag: len(gzip.decompress((BASE / 'intake' / (tag + '-stderr.log.gz')).read_bytes())) for tag in ('native', 'version', 'memory')},
        limits='Own Julia source-scoped authored controls; complete available class/error/error_json and field absence. Plan/fresh source identities follow their authored source. No peer verdict or scalar-input authority; full native/cache/transitive/toolchain/OS closure4.2/SESSION5 remains open.')
    target = BASE / 'intake-assessment.json'
    assert not target.exists()
    target.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key not in ('observed', 'intents', 'targets', 'compatibility')}))


if __name__ == '__main__':
    main()
