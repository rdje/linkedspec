"""Recover own Dart intake and adjudicate source-scoped Array result intents."""
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
ACTIVATION = '1753884257bed7ce0b842bc406c665671403a828'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def frames(body, tag):
    result, bodies = {}, {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in result, 'duplicate frame'
        result[key] = json.loads(value); bodies[key] = value.encode()
    return result, bodies


def recover():
    packets = {}
    for packet in json.loads((BASE / 'intake/custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL / 'intake') + '/')
        assert packet['tag'] not in packets
        bodies = {}
        with tarfile.open(ROOT / path) as archive:
            assert len(archive.getnames()) == len(packet['files']) and set(archive.getnames()) == packet['files'].keys()
            for member in archive:
                name = PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in bodies
                raw = archive.extractfile(member).read(); row = packet['files'][member.name]
                assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], 'archive bytes'
                assert member.mode & 0o777 == row['mode'], 'full filesystem mode'
                bodies[member.name] = raw
        packets[packet['tag']] = dict(files=packet['files'], bodies=bodies)
    assert set(packets) == {'root', 'resolved', 'native', 'emitted', 'fresh'}
    return packets


def main():
    packets = recover(); root = packets['root']
    names = set()
    command = ['git', 'archive', ACTIVATION, 'dart', 'tests/fixtures', 'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec']
    with subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as archive:
            for member in archive:
                if not member.isfile():
                    continue
                raw = archive.extractfile(member).read(); row = root['files'][member.name]
                assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], 'activation source'
                assert bool(member.mode & 0o111) == bool(row['mode'] & 0o111), 'Git executable class'
                names.add(member.name)
        assert process.wait() == 0
    expected_names = {name for name in root['files'] if name.startswith(('dart/', 'tests/fixtures/', 'specs/'))
        and name not in ('dart/.dart_tool/package_config.json', 'dart/tool/probe_open_arity_array_concat_results.dart')}
    assert names == expected_names, 'activation census'
    cases = json.loads(root['bodies'][str(REL / 'cases.json')])
    assert wire(cases) == wire(json.loads((BASE / 'cases.json').read_bytes()))
    assert len(cases) == len({case['id'] for case in cases}) == 508
    assert not any({'expected', 'expected_error', 'expected_observation', 'role'} & case.keys() for case in cases)
    native_stdout = gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes())
    native, _ = frames(native_stdout, 'ARRAY_CONCAT_DART')
    fresh, _ = frames(gzip.decompress((BASE / 'intake/fresh-stdout.log.gz').read_bytes()), 'ARRAY_CONCAT_DART_FRESH')
    parsed, parsed_bytes = frames(native_stdout, 'ARRAY_CONCAT_DART_INPUT')
    keys = {case['id'] for case in cases}
    assert native.keys() == fresh.keys() == parsed.keys() == keys, 'frame census'
    observed = {key: dict(row, fresh=fresh[key]) for key, row in native.items()}
    for index, case in enumerate(cases):
        key = case['id']; row = observed[key]
        assert set(row) == set(ROUTES), 'full route set'
        assert all('value' in item or 'error' in item for item in row.values()), 'route shape'
        name = str(REL / 'intake/fresh/inputs' / ('case_' + str(index) + '.json'))
        assert packets['emitted']['bodies'][name] == packets['fresh']['bodies'][name] == parsed_bytes[key], 'actual parsed input'
        module = str(REL / 'intake/fresh/lib' / ('case_' + str(index) + '.dart'))
        assert packets['emitted']['bodies'][module] == packets['fresh']['bodies'][module], 'actual module'
    probe = root['bodies']['dart/tool/probe_open_arity_array_concat_results.dart']
    assert probe.index(b'inputFile.writeAsStringSync(serialized)') < probe.index(b'compileSpec(parsed)') < probe.index(b'SpecFile.fromJson('), 'parsed before use'
    grammar, = [line for line in native_stdout.decode().splitlines() if line.startswith('ARRAY_CONCAT_DART_GRAMMAR ')]
    grammar = json.loads(grammar.split(' ', 1)[1])
    assert grammar == dict(path='specs/user_function_definition.spec', source=root['bodies']['specs/user_function_definition.spec'].decode())
    for path in (BASE / 'intake').glob('*-command.json'):
        tag = path.name.removesuffix('-command.json'); command = json.loads(path.read_bytes())
        assert command['environment'] == dict(TERM='dumb', NO_COLOR='1')
        assert path.with_name(tag + '-exit.txt').read_text() == '0\n'
        if tag in ('native', 'fresh'):
            assert gzip.decompress(path.with_name(tag + '-stderr.log.gz').read_bytes()) == b'', 'SDK stderr'
    old = json.loads(root['bodies']['tests/fixtures/array_transform_callable_result_guard_dart_profiles.json'])
    ordinary = json.loads(root['bodies']['tests/fixtures/array_transform_result_guard_dart_profiles.json'])
    for case in cases:
        key = case['id']
        if case['origin'] == 'legacy312':
            assert wire(observed[key]) == wire({route: old[key][route] for route in ROUTES}), 'own legacy full observation:' + key
            for field in ('source', 'input', 'rule'):
                assert case[field] == old[key]['case'][field], 'own legacy source'
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
                # Bind the public generated error's authored source identity;
                # every other error field and its absence remains compared.
                identity = 'array-concat-open-arity-result-guard/'
                assert expected['fresh']['error_json']['source_identity'] == identity + terminal + '.spec'
                expected['fresh']['error_json']['source_identity'] = identity + key + '.spec'
                intents[key] = expected
            else:
                values = [] if case['empty'] else ['head', 'tail', 'end'][:case['array_count']]
                effects = ('S' if case['source_kind'] == 'function' else '') if case['empty'] else 'STU'[:case['array_count']]
                tail = case['tail']
                value = [values, effects] if tail == 'terminal' else [values[-1].upper(), effects] if tail == 'compatible' else [len(values), effects + 'W'] if tail == 'with_' else [None, effects]
                intents[key] = {route: {'value': value} for route in ROUTES}
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
            intents[key] = {route: {'value': value} for route in ROUTES}
    for key, expected in intents.items():
        if wire(observed[key]) != wire(expected):
            case = next(case for case in cases if case['id'] == key)
            assert case.get('tail') in ('hash', 'later', 'composed'), 'unsupported terminal/compatible intent:' + key
            targets[key] = expected
    for form in ('free', 'receiver'):
        for key, terminal in (
            ('own_extra_concat_arrays_' + form, 'own_extra_concat_arrays_' + form + '_terminal_probe'),
            ('ordinary_legacy_extra_concat_arrays_' + form + '_composed', 'ordinary_legacy_extra_concat_arrays_' + form + '_terminal'),
        ):
            assert all(set(row) == {'value'} and isinstance(row['value'][0], list) and isinstance(row['value'][1], str)
                for row in observed[terminal].values()), 'own terminal Array policy'
            expected = {route: {'value': [None, observed[terminal][route]['value'][1]]} for route in ROUTES}
            if wire(observed[key]) != wire(expected):
                compatibility[key] = expected
    result = dict(observed=observed, intents=intents, targets=targets, compatibility=compatibility,
        programs=508, supported_targets=sorted(targets), compatibility_ids=sorted(compatibility),
        preserved=508 - len(targets) - len(compatibility), initial_policies=80, invalid_signatures=8,
        limits='Own Dart source-scoped authored controls. Complete observed class/error/error_json/presence is retained; fresh source_identity derives only from its authored case. No peer policy, scalar-input/invalid-signature admission, future freshness or full native/VM/cache/transitive/toolchain/OS closure (4.2/SESSION5).')
    (BASE / 'intake-assessment.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key not in ('observed', 'intents', 'targets', 'compatibility')}))


if __name__ == '__main__':
    main()
