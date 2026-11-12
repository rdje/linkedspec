"""Recover actual installed-host observations and adjudicate source-scoped intents."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile
import subprocess
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
ACTIVATION = 'fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
ROUTES = ('native', 'restored', 'plan', 'fresh')
def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))
def archive(out, stem='input', name='inputs-before-first-run.tar.gz'):
    metadata = json.loads((out / (stem + '-identities.json')).read_bytes())
    bodies = {}
    with tarfile.open(out / name) as source:
        assert len(source.getnames()) == len(metadata) and set(source.getnames()) == metadata.keys()
        for member in source:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            body = source.extractfile(member).read()
            row = metadata[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            bodies[member.name] = body
    return bodies

def frames(body, tag):
    out = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, raw = line.split(' ', 2)
            assert key not in out
            out[key] = json.loads(raw)
    return out

def main():
    root = archive(BASE / 'intake')
    selected = json.loads(root[str(BASE / 'selected-inputs.json')])
    with subprocess.Popen(['git', 'archive', ACTIVATION, *selected], stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as source:
            names = set()
            for member in source:
                if member.isfile():
                    assert source.extractfile(member).read() == root[member.name], 'activation source:' + member.name
                    names.add(member.name)
            assert names == set(selected)
        assert process.wait() == 0
    cases = json.loads(root[str(BASE / 'cases.json')])
    assert cases == json.loads((BASE / 'cases.json').read_bytes())
    assert len(cases) == len({r['id'] for r in cases}) == 508
    assert all(not {'expected', 'expected_error', 'role', 'expected_observation'} & r.keys() for r in cases)
    legacy = json.loads(root['tests/fixtures/array_transform_callable_result_guard_lua_profiles.json'])
    ordinary = json.loads(root['tests/fixtures/array_transform_result_guard_lua_profiles.json'])
    results = {}
    for host in ('puc', 'luajit'):
        out = BASE / 'intake' / host
        actual = gzip.decompress((out / 'normal-stdout.log.gz').read_bytes())
        observed = frames(actual, 'ARRAY_CONCAT_LUA')
        parsed = frames(actual, 'ARRAY_CONCAT_LUA_INPUT')
        assert list(observed) == list(parsed) == [r['id'] for r in cases]
        artifacts = archive(out, 'artifact', 'actual-emitted-parsed.tar.gz')
        native = archive(out, 'native', 'native-before-first-run.tar.gz')
        assert len(native) == 3 and len(artifacts) == 1016
        assert b'ARRAY_CONCAT_LUA_OWNER @lua/src/linkedspec/interpreter.lua\n' in actual
        for key, row in observed.items():
            assert set(row) == set(ROUTES), 'full route census:' + key
            # Lua nil deliberately leaves an empty object: preserve absence exactly.
            assert all(isinstance(item, dict) for item in row.values()), 'public object shape'
            assert wire(json.loads(artifacts[str(out / 'parsed' / (key + '.json'))])) == wire(parsed[key])
            assert artifacts[str(out / 'emitted' / (key + '.lua'))]
        grammar, = [line for line in actual.decode().splitlines() if line.startswith('ARRAY_CONCAT_LUA_GRAMMAR ')]
        assert json.loads(grammar.split(' ', 1)[1]) == dict(path='specs/user_function_definition.spec', source=root['specs/user_function_definition.spec'].decode())
        for tag in ('normal', 'build', 'headers', 'version', 'memory'):
            assert (out / (tag + '-exit.txt')).read_text() == '0\n'
        for case in cases:
            key = case['id']
            if case['origin'] == 'legacy312':
                assert wire(observed[key]) == wire({r: legacy[host][key][r] for r in ROUTES}), 'own legacy baseline:' + key
            elif case['origin'] == 'ordinary4' and case['tail'] == 'composed':
                assert wire(observed[key]) == wire({r: ordinary[host][case['legacy_id']][r] for r in ROUTES}), 'own ordinary baseline'
        intents = {}
        for case in cases:
            key, origin = case['id'], case['origin']
            if origin == 'shared84':
                if case.get('question') == 'needed-producer-error':
                    terminal = re.sub(r'_(hash|terminal)$', '_terminal', key)
                    assert all('error' in item for item in observed[terminal].values())
                    expected = copy.deepcopy(observed[terminal])
                    for route in ('plan', 'fresh'):
                        prefix = 'array-concat-open-arity-result-guard/'
                        assert expected[route]['error_json']['source_identity'] == prefix + terminal + '.spec'
                        expected[route]['error_json']['source_identity'] = prefix + key + '.spec'
                    intents[key] = expected
                    continue
                values = [] if case['empty'] else ['head', 'tail', 'end'][:case['array_count']]
                effects = ('S' if case['source_kind'] == 'function' else '') if case['empty'] else 'STU'[:case['array_count']]
                tail = case['tail']
                if tail == 'terminal': value = [values, effects]
                elif tail == 'compatible': value = [values[-1].upper(), effects]
                elif tail == 'with_': value = [len(values), effects + 'W']
                else:
                    assert tail in ('hash', 'later')
                    value = [None, effects]
            elif origin == 'questions108':
                question = case['question']
                if question == 'valid-rest-source':
                    effects = 'SXTU' if case['signature'] == 'rest_multi' else 'STU'
                    value = [['head', 'tail', 'end'], effects] if case['tail'] == 'terminal' else [None, effects]
                elif question == 'source-snapshot': value = [['head', 'tail', 'end'] if case['tail'] == 'terminal' else None, ['head', 'changed']]
                elif question == 'nested-kinds': value = ['', '0', False, 0, None, {'k':[1]}, [False,0], 'tail', 'end']
                else:
                    assert question in ('initial-producer-policy', 'invalid-signature')
                    continue
            else: continue
            intents[key] = {r: dict(value=copy.deepcopy(value)) for r in ROUTES}
        targets = {}
        for key, expected in intents.items():
            if wire(observed[key]) != wire(expected):
                case = next(r for r in cases if r['id'] == key)
                assert case.get('tail') in ('hash', 'later', 'composed'), 'unsupported terminal/compatible intent:' + key
                targets[key] = expected
        compatibility = {}
        for form in ('free', 'receiver'):
            for key, terminal in [('own_extra_concat_arrays_' + form, 'own_extra_concat_arrays_' + form + '_terminal_probe'),
                ('ordinary_legacy_extra_concat_arrays_' + form + '_composed', 'ordinary_legacy_extra_concat_arrays_' + form + '_terminal')]:
                assert all(set(r) == {'value'} and isinstance(r['value'][0], list) and isinstance(r['value'][1], str) for r in observed[terminal].values())
                expected = {r: dict(value=[None, observed[terminal][r]['value'][1]]) for r in ROUTES}
                if wire(observed[key]) != wire(expected): compatibility[key] = expected
        results[host] = dict(observed=observed, intents=intents, targets=targets, compatibility=compatibility,
            supported_targets=sorted(targets), compatibility_ids=sorted(compatibility), preserved=508-len(targets)-len(compatibility),
            initial_policy_ids=[r['id'] for r in cases if r['origin']=='questions108' and r.get('question')=='initial-producer-policy'],
            invalid_signature_ids=[r['id'] for r in cases if r['origin']=='questions108' and r.get('question')=='invalid-signature'],
            empty_route_objects=sum(not value for row in observed.values() for value in row.values()),
            stderr_bytes=len(gzip.decompress((out/'normal-stderr.log.gz').read_bytes())))
        print(json.dumps(dict(host=host, targets=len(targets), compatibility=len(compatibility), preserved=results[host]['preserved'], initial=len(results[host]['initial_policy_ids']), invalid=len(results[host]['invalid_signature_ids']), empty_route_objects=results[host]['empty_route_objects'], sdk_stderr_bytes=results[host]['stderr_bytes'])))
    target = BASE / 'intake-assessment.json'
    assert not target.exists()
    target.write_text(json.dumps(results, indent=2, sort_keys=True) + '\n')
if __name__ == '__main__': main()
