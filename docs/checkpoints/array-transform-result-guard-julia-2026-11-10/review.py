"""Readonly finite Julia recovery, including explicit direct-test fixture bindings."""
import copy
import difflib
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-result-guard-julia-2026-11-10')
ACTIVATION = '0c4738c4efd575a4c348181c56b5d343b4e3d235'
OWNER = 'julia/src/runtime/Interpreter.jl'
NORMAL = 'julia/test/array_transform_result_guard_composition_test.jl'
FIXTURE = 'tests/fixtures/array_transform_result_guard_julia_cases.json'
PROFILE = 'tests/fixtures/array_transform_result_guard_julia_profiles.json'
COMMON = 'tests/fixtures/array_transform_result_guard_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
PHASES = ('intake', 'before', 'after', 'direct', 'private-inverse', 'private-restored')
RED = {helper + '_' + form + '_hash_guard'
       for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted',
                      'reversed', 'concat_arrays') for form in ('free', 'receiver')}
RED |= {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}
DIRECT_INPUTS = (NORMAL, FIXTURE, PROFILE, COMMON, GRAMMAR,
                'tests/fixtures/with_hash_result_values.spec',
                'tests/fixtures/with_hash_result_values.json',
                'tests/fixtures/hash_value_result_guard_julia_cases.json',
                'tests/fixtures/hash_value_result_guard_julia_profiles.json',
                'tests/fixtures/hash_view_result_guard_julia_cases.json',
                'tests/fixtures/hash_view_result_guard_julia_profiles.json')


def same(a, b):
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def raw(phase, tag='normal', channel='stdout'):
    return gzip.decompress((ROOT / BASE / phase / (tag + '-' + channel + '.log.gz')).read_bytes())


def frames(body, prefix):
    result = {}
    for line in body.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(value)
    return result


def recover(phase, artifact=False):
    stem, name = ('artifact', 'actual-emitted-parsed.tar.gz') if artifact else ('input', 'inputs-before-first-run.tar.gz')
    records = json.loads((ROOT / BASE / phase / (stem + '-identities.json')).read_bytes())
    files = {}
    with tarfile.open(ROOT / BASE / phase / name) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in files
            expected = records[member.name]
            body = archive.extractfile(member).read()
            assert hashlib.sha256(body).hexdigest() == expected['sha256']
            assert len(body) == expected['bytes'] and member.mode & 0o777 == expected['mode']
            files[member.name] = body
    assert files.keys() == records.keys()
    return files


def grammar(body, prefix, expected):
    found = [json.loads(line.split(prefix + ' ', 1)[1])
             for line in body.decode().splitlines() if line.startswith(prefix + ' ')]
    assert found == [dict(path=GRAMMAR, source=expected.decode())]
    marker = b'ARRAY_TRANSFORM_JULIA_INPUT' if prefix == 'ARRAY_TRANSFORM_JULIA_GRAMMAR' else b'ARRAY_TRANSFORM_JULIA_NORMAL '
    assert body.index(prefix.encode()) < body.index(marker)


def direct_inputs(files):
    for name in DIRECT_INPUTS:
        assert name in files and isinstance(files[name], bytes)


def validate(observed, cases, profiles, before=False):
    assert list(observed) == [case['id'] for case in cases]
    for case in cases:
        key = case['id']
        rows = observed[key]
        assert set(rows) == {'native', 'restored', 'plan', 'fresh'}
        for route, actual in rows.items():
            if before and key in RED:
                if key in {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}:
                    value = ['ran', 'KVDW' if key == 'sort_logical_later_with' else 'KVW']
                else:
                    helper = key.rsplit('_', 3)[0]
                    compatible = next(row for row in cases if row['id'] == helper + '_compatible')
                    value = [compatible['expected'][0], 'KV']
                assert same(actual, {'value': value}) and not same(actual, {'value': case['expected']})
            elif key in profiles:
                assert case['source'] == profiles[key]['source'] and case['input'] == profiles[key]['input']
                assert same(actual, profiles[key][route])
            else:
                assert same(actual, {'value': case['expected']})
        assert same(rows['native'], rows['restored']) and same(rows['plan'], rows['fresh'])
        if case.get('expected_error'):
            assert all(case['expected_error'] in row['error'] for row in rows.values())
            assert rows['native']['class'] == 'RuntimeInterpreterException'
            assert rows['plan']['class'] == 'GeneratedSourceException'


def summary(body, before=False):
    pattern = rb'Julia ordinary Array-transform result guards\s*\|\s*827\s+76\s+903\s' if before else rb'Julia ordinary Array-transform result guards\s*\|\s*903\s+903\s'
    assert re.search(pattern, body)


def equal(a, b):
    assert a == b


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert hashlib.sha256(body).hexdigest() == row['sha256'] and len(body) == row['bytes']
        if name.endswith('.gz'):
            gzip.decompress(body)
    roots = {phase: recover(phase) for phase in PHASES}
    artifacts = {phase: recover(phase, True) for phase in PHASES}
    cases = json.loads(roots['intake'][FIXTURE])
    shared = json.loads(roots['intake'][COMMON])
    authored = json.loads(roots['intake'][str(BASE / 'profile-sources.json')])
    profiles = json.loads(roots['before'][PROFILE])
    assert len(shared) == 37 and len(authored) == 119 and cases == shared + authored
    assert len(cases) == 156 and len(profiles) == 123
    assert {key for key, row in profiles.items() if row['profile_only']} == {row['id'] for row in authored}
    assert sum(bool(row.get('expected_error')) for row in cases) == 19
    assert set(json.loads((ROOT / BASE / 'intake-failures.json').read_bytes())) == RED
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(
            ['git', 'archive', '--format=tar', ACTIVATION, 'julia']))) as archive:
        old = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    grammar_bytes = subprocess.check_output(['git', 'show', ACTIVATION + ':' + GRAMMAR])
    shared_bytes = subprocess.check_output(['git', 'show', ACTIVATION + ':' + COMMON])
    candidate = roots['after'][OWNER]
    operations = difflib.SequenceMatcher(a=old[OWNER].splitlines(keepends=True),
        b=candidate.splitlines(keepends=True), autojunk=False).get_opcodes()
    assert all(tag in ('equal', 'insert') for tag, *_ in operations)
    assert sum(b2 - b1 for tag, _, _, b1, b2 in operations if tag == 'insert') == 70
    expected_runner = old['julia/test/runtests.jl'].replace(
        b'include("hash_value_result_guard_composition_test.jl")\n',
        b'include("hash_value_result_guard_composition_test.jl")\ninclude("array_transform_result_guard_composition_test.jl")\n')
    assert expected_runner.count(b'include("array_transform_result_guard_composition_test.jl")') == 1
    version = raw('intake', 'version')
    assert re.fullmatch(rb'julia version [^\r\n]+\r?\n', version)
    modules = {}
    observed = {}
    for phase in PHASES:
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        root = roots[phase]
        private = phase.startswith('private-')
        before = phase in ('intake', 'before', 'private-inverse')
        assert (ROOT / BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if phase in ('before', 'private-inverse') else '0\n')
        assert (ROOT / BASE / phase / 'version-exit.txt').read_text() == '0\n'
        assert raw(phase, 'version') == version and raw(phase, 'version', 'stderr') == b''
        raw(phase, channel='stderr')
        if not private:
            for name, body in old.items():
                expected = (old[OWNER] if before else candidate) if name == OWNER else (
                    body if before or name != 'julia/test/runtests.jl' else expected_runner)
                assert root[name] == expected
            assert root[GRAMMAR] == grammar_bytes and root[COMMON] == shared_bytes
            assert json.loads(root[FIXTURE]) == cases
            if phase != 'intake':
                assert root[NORMAL] == roots['after'][NORMAL] and json.loads(root[PROFILE]) == profiles
            if phase == 'direct':
                direct_inputs(root)
        else:
            prefix = str(BASE / 'control-owner') + '/'
            assert root[OWNER] == candidate
            for name, body in root.items():
                if name.startswith(prefix):
                    logical = name[len(prefix):]
                    expected = (old[OWNER] if before else candidate) if logical == OWNER else roots['after'][logical]
                    assert body == expected
            command = json.loads((ROOT / BASE / phase / 'normal-command.json').read_bytes())['argv']
            assert '--compiled-modules=no' in command and '--project=' + str(BASE / 'control-owner/julia') in command
        body = raw(phase)
        prefix = 'ARRAY_TRANSFORM_JULIA' if phase == 'intake' else 'ARRAY_TRANSFORM_JULIA_NORMAL'
        grammar(body, prefix + '_GRAMMAR', grammar_bytes)
        values = frames(body, prefix)
        validate(values, cases, profiles, before)
        observed[phase] = values
        if phase != 'intake':
            summary(body, before)
            expected_path = str(BASE / 'control-owner/julia/src/LinkedSpecJulia.jl') if private else 'julia/src/LinkedSpecJulia.jl'
            assert ('ARRAY_TRANSFORM_JULIA_OWNER ' + expected_path + '\n').encode() in body
        supplied = frames(body, 'ARRAY_TRANSFORM_JULIA_INPUT') if phase == 'intake' else None
        pairs = {}
        for case in cases:
            key = case['id']
            emitted = artifacts[phase][str(BASE / phase / 'emitted' / (key + '.jl'))]
            parsed = artifacts[phase][str(BASE / phase / 'parsed' / (key + '.json'))]
            if supplied is not None:
                assert json.loads(parsed) == supplied[key]
            pairs[key] = dict(emitted=emitted, parsed=parsed)
        assert len(artifacts[phase]) == 312
        modules[phase] = pairs
    for phase in PHASES[1:]:
        assert modules[phase] == modules['intake']
    for case in cases:
        if case['id'] not in RED:
            assert same(observed['intake'][case['id']], observed['after'][case['id']])
    assert same(observed['before'], observed['intake'])
    assert same(observed['private-inverse'], observed['intake'])
    assert same(observed['private-restored'], observed['after'])
    assert same(observed['direct'], observed['after'])
    for name, count in ((b'Julia ordinary with results', 15), (b'Julia pure Hash-helper result guards', 510),
                        (b'Julia Hash-view result guards', 184), (b'Julia retained constructor result guards', 116)):
        assert re.search(re.escape(name) + rb'\s*\|\s*' + str(count).encode() + rb'\s+' + str(count).encode() + rb'\s', raw('direct'))
    assert raw('direct', channel='stderr') == raw('private-restored', channel='stderr') == b''
    # After's nonempty stderr is explicitly successful package precompilation,
    # not a suppressed diagnostic or a claim that every SDK channel was empty.
    assert b'1 dependency successfully precompiled' in raw('after', channel='stderr')
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    before, after = observed['intake'], observed['after']
    changed = copy.deepcopy(before); changed['take_free_hash_guard'] = copy.deepcopy(after['take_free_hash_guard'])
    reject('original failure hidden', lambda: validate(changed, cases, profiles, True))
    changed = copy.deepcopy(after); changed['take_receiver_hash_guard']['native'] = {'value': [None, 'KV']}
    reject('consumer operands admitted', lambda: validate(changed, cases, profiles))
    changed = copy.deepcopy(after); changed['sort_logical_later_with']['fresh'] = {'value': ['ran', 'KVDW']}
    reject('later body admitted', lambda: validate(changed, cases, profiles))
    changed = copy.deepcopy(after); changed['needed_slice_count_free']['native'] = {'value': 'masked'}
    reject('needed operand error masked', lambda: validate(changed, cases, profiles))
    changed = copy.deepcopy(after); changed['initial_hash_concat_arrays_free']['native'] = {'value': ['second']}
    reject('source fallback normalized', lambda: validate(changed, cases, profiles))
    changed = copy.deepcopy(after); changed['nested_kinds_and_source']['native']['value'][0][-1] = 0
    reject('Boolean replaced by Number', lambda: validate(changed, cases, profiles))
    changed = copy.deepcopy(after); del changed['extra_sorted_free']
    reject('excluded profile omitted', lambda: validate(changed, cases, profiles))
    changed = copy.deepcopy(modules['after']); changed['take_compatible']['emitted'] += b'\n# drift\n'
    reject('actual module drift', lambda: equal(modules['intake'], changed))
    changed = dict(roots['direct']); del changed['tests/fixtures/with_hash_result_values.spec']
    reject('direct fixture binding omitted', lambda: direct_inputs(changed))
    print(json.dumps(dict(shared=37, own_controls=119, total=156, original_failures=19,
        preserved=137, profiles=123, needed_errors=19, four_routes='PASS', normal_checks=903,
        direct_checks=1728, private_inverse=19, private_restored=156, artifact_pairs=156,
        recovery='PASS', effective_corruptions=controls), indent=2))


if __name__ == '__main__':
    main()
