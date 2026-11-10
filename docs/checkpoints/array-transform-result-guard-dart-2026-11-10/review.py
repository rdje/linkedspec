"""Readonly recovery of this finite historical Dart outcome, with corruptions."""
import copy
import difflib
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import posixpath
import re
import subprocess
import tarfile
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-result-guard-dart-2026-11-10')
ACTIVATION = '155f5f6444b30319a278a78e53265e4e3adda699'
OWNER = 'dart/lib/src/runtime/interpreter.dart'
PROBE = 'dart/tool/probe_array_transform_results.dart'
NORMAL = 'dart/test/array_transform_result_guard_composition_test.dart'
PROFILE = 'tests/fixtures/array_transform_result_guard_dart_profiles.json'
COMMON = 'tests/fixtures/array_transform_result_guard_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
PHASES = ('intake', 'before', 'after', 'after-intake', 'formatted-intake', 'direct', 'format',
          'private-inverse', 'private-restored')
RED = {helper + '_' + form + '_hash_guard'
       for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted',
                      'reversed', 'concat_arrays') for form in ('free', 'receiver')}
RED |= {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}


def same(a, b):
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def digest(body):
    return hashlib.sha256(body).hexdigest()


def raw(phase, tag, channel='stdout'):
    return gzip.decompress((ROOT / BASE / phase / (tag + '-' + channel + '.log.gz')).read_bytes())


def frames(body, prefix):
    result = {}
    for line in body.decode().splitlines():
        match = re.search(r'\b' + re.escape(prefix) + r' ([a-z0-9_]+) (\{.*)', line)
        if match:
            assert match[1] not in result
            result[match[1]] = json.loads(match[2])
    return result


def recover(phase):
    result = {}
    for row in json.loads((ROOT / BASE / phase / 'custody.json').read_bytes()):
        assert row['tag'] not in result and row['archive'].startswith(str(BASE / phase) + '/')
        files = {}
        with tarfile.open(ROOT / row['archive']) as archive:
            for member in archive:
                path = PurePosixPath(member.name)
                assert member.isfile() and not path.is_absolute() and '..' not in path.parts
                assert member.name not in files
                expected = row['files'][member.name]
                body = archive.extractfile(member).read()
                assert digest(body) == expected['sha256'] and len(body) == expected['bytes']
                assert member.mode & 0o777 == expected['mode']
                files[member.name] = body
        assert files.keys() == row['files'].keys()
        result[row['tag']] = files
    return result


def routing(files, config, expected):
    own = next(p for p in json.loads(files[config])['packages'] if p['name'] == 'linkedspec_dart')
    uri = urlparse(own['rootUri'])
    assert not uri.scheme and not uri.netloc and not uri.path.startswith('/')
    path = posixpath.normpath(str(PurePosixPath(config).parent / unquote(uri.path)))
    assert path == expected and own['packageUri'] == 'lib/'


def grammar(body, prefix, expected):
    found = [json.loads(line.split(prefix + ' ', 1)[1])
             for line in body.decode().splitlines() if prefix + ' ' in line]
    assert found == [dict(path=GRAMMAR, source=expected.decode())]
    assert body.index(prefix.encode()) < body.index(b'ARRAY_TRANSFORM_DART_INPUT' if
        prefix == 'ARRAY_TRANSFORM_DART_GRAMMAR' else b'ARRAY_TRANSFORM_DART_NORMAL ')


def validate(native, fresh, cases, profiles, before=False):
    assert list(native) == list(fresh) == [case['id'] for case in cases]
    for case in cases:
        key = case['id']
        assert set(native[key]) == {'native', 'restored', 'plan'}
        rows = {**native[key], 'fresh': fresh[key]}
        for route, actual in rows.items():
            if before and key in RED:
                if key in {'take_later_with', 'reverse_copy_later_with', 'sort_logical_later_with'}:
                    value = ['ran', 'KVDW' if key == 'sort_logical_later_with' else 'KVW']
                else:
                    helper = key.rsplit('_', 3)[0]
                    compatible = next(row for row in cases if row['id'] == helper + '_compatible')
                    value = [compatible['expected'][0], 'KV']
                assert same(actual, {'value': value})
                assert not same(actual, {'value': case['expected']})
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


def normal(phase, expected, grammar_bytes, before=False, direct=False):
    assert (ROOT / BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if before else '0\n')
    body = raw(phase, 'normal')
    grammar(body, 'ARRAY_TRANSFORM_DART_NORMAL_GRAMMAR', grammar_bytes)
    found = frames(body, 'ARRAY_TRANSFORM_DART_NORMAL')
    assert same(found, expected)
    failures = set(re.findall(r': ([a-z][a-z0-9_]*) \[E\]', body.decode()))
    assert failures == (RED if before else set())
    suffix = b'+122 -19: Some tests failed.' if before else (
        b'+292: All tests passed!' if direct else b'+141: All tests passed!')
    assert suffix in body


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert digest(body) == row['sha256'] and len(body) == row['bytes']
        if name.endswith('.gz'):
            gzip.decompress(body)
    recovered = {phase: recover(phase) for phase in PHASES}
    roots = {phase: recovered[phase]['root'] for phase in PHASES}
    cases = json.loads(roots['intake'][str(BASE / 'cases.json')])
    shared = json.loads(roots['intake'][COMMON])
    authored = json.loads(roots['intake'][str(BASE / 'profile-sources.json')])
    profiles = json.loads(roots['before'][PROFILE])
    assert len(shared) == 37 and len(authored) == 104 and cases == shared + authored
    assert len(cases) == 141 and len(profiles) == 108
    assert {key for key, row in profiles.items() if row['profile_only']} == {row['id'] for row in authored}
    assert set(json.loads((ROOT / BASE / 'intake-failures.json').read_bytes())) == RED
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(
            ['git', 'archive', '--format=tar', ACTIVATION, 'dart']))) as archive:
        old = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    grammar_bytes = subprocess.check_output(['git', 'show', ACTIVATION + ':' + GRAMMAR])
    shared_bytes = subprocess.check_output(['git', 'show', ACTIVATION + ':' + COMMON])
    candidate = roots['direct'][OWNER]
    before_owner = old[OWNER].decode().splitlines(keepends=True)
    after_owner = candidate.decode().splitlines(keepends=True)
    operations = difflib.SequenceMatcher(a=before_owner, b=after_owner, autojunk=False).get_opcodes()
    assert all(tag in ('equal', 'insert') for tag, *_ in operations)
    assert sum(b2 - b1 for tag, _, _, b1, b2 in operations if tag == 'insert') == 119
    formatting = json.loads((ROOT / BASE / 'formatter-identities.json').read_bytes())
    assert gzip.decompress((ROOT / BASE / formatting['before'][OWNER]['archive']).read_bytes()) == roots['after'][OWNER]
    assert formatting['after'][OWNER] == digest(candidate)
    assert (ROOT / BASE / 'formatter-exit.txt').read_text() == '0\n'
    for phase in PHASES:
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        root = roots[phase]
        for name, body in old.items():
            if name != OWNER and not phase.startswith('private-'):
                assert root[name] == body
        if phase in ('intake', 'before'):
            assert root[OWNER] == old[OWNER]
        elif phase in ('after', 'after-intake'):
            assert root[OWNER] == roots['after'][OWNER]
        else:
            assert root[OWNER] == candidate
        for name, body in ((COMMON, shared_bytes), (GRAMMAR, grammar_bytes)):
            if name in root:
                assert root[name] == body
        for tag in ('version', 'resolution', 'analysis'):
            if tag == 'analysis' and phase == 'format':
                continue
            assert (ROOT / BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
            raw(phase, tag); raw(phase, tag, 'stderr')
    generated = {}
    observations = {}
    for phase in ('intake', 'after-intake', 'formatted-intake'):
        for tag in ('native', 'fresh-resolution', 'fresh-analysis', 'fresh'):
            assert (ROOT / BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
            raw(phase, tag); raw(phase, tag, 'stderr')
        grammar(raw(phase, 'native'), 'ARRAY_TRANSFORM_DART_GRAMMAR', grammar_bytes)
        native = frames(raw(phase, 'native'), 'ARRAY_TRANSFORM_DART')
        fresh = frames(raw(phase, 'fresh'), 'ARRAY_TRANSFORM_DART_FRESH')
        validate(native, fresh, cases, profiles, before=phase == 'intake')
        observations[phase] = (native, fresh)
        emitted, used = recovered[phase]['emitted'], recovered[phase]['fresh']
        supplied = frames(raw(phase, 'native'), 'ARRAY_TRANSFORM_DART_INPUT')
        assert list(supplied) == [row['id'] for row in cases]
        modules = {}
        for index, case in enumerate(cases):
            module = str(BASE / phase / 'fresh/lib' / f'case_{index}.dart')
            parsed = str(BASE / phase / 'fresh/inputs' / f'case_{index}.json')
            assert emitted[module] == used[module] and emitted[parsed] == used[parsed]
            assert json.loads(used[parsed]) == supplied[case['id']]
            assert f'case_{index}.execute' in used[str(BASE / phase / 'fresh/bin/main.dart')].decode()
            modules[case['id']] = dict(module=used[module], parsed=used[parsed])
        assert len([p for p in used if re.search(r'/lib/case_\d+\.dart$', p)]) == 141
        routing(used, str(BASE / phase / 'fresh/.dart_tool/package_config.json'), 'dart')
        generated[phase] = modules
        routing(recovered[phase]['resolved'], 'dart/.dart_tool/package_config.json', 'dart')
    assert generated['intake'] == generated['after-intake'] == generated['formatted-intake']
    before, fresh_before = observations['intake']
    after, fresh_after = observations['formatted-intake']
    assert same(observations['after-intake'], observations['formatted-intake'])
    for case in cases:
        if case['id'] not in RED:
            assert same(before[case['id']], after[case['id']])
            assert same(fresh_before[case['id']], fresh_after[case['id']])
    normal('before', before, grammar_bytes, before=True)
    normal('after', after, grammar_bytes)
    normal('direct', after, grammar_bytes, direct=True)
    prefix = str(BASE / 'control-owner') + '/'
    for phase, expected, inverse in (('private-inverse', before, True), ('private-restored', after, False)):
        root = roots[phase]
        for name, body in root.items():
            if name.startswith(prefix):
                logical = name[len(prefix):]
                expected_body = (old[OWNER] if inverse else candidate) if logical == OWNER else roots['direct'][logical]
                assert body == expected_body
        routing(recovered[phase]['resolved'], prefix + 'dart/.dart_tool/package_config.json', str(BASE / 'control-owner/dart'))
        command = json.loads((ROOT / BASE / phase / 'normal-command.json').read_bytes())
        assert command['cwd'] == str(BASE / 'control-owner/dart')
        normal(phase, expected, grammar_bytes, before=inverse)
    assert (ROOT / BASE / 'format/format-exit.txt').read_text() == '0\n'
    assert b'(0 changed)' in raw('format', 'format') and raw('format', 'format', 'stderr') == b''
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    changed = copy.deepcopy(before); changed['take_free_hash_guard'] = copy.deepcopy(after['take_free_hash_guard'])
    reject('original failure hidden', lambda: validate(changed, fresh_before, cases, profiles, True))
    changed = copy.deepcopy(after); changed['take_receiver_hash_guard']['native'] = {'value': [None, 'KV']}
    reject('consumer operands admitted', lambda: validate(changed, fresh_after, cases, profiles))
    changed = copy.deepcopy(fresh_after); changed['sort_logical_later_with'] = {'value': ['ran', 'KVDW']}
    reject('later body admitted', lambda: validate(after, changed, cases, profiles))
    changed = copy.deepcopy(after); changed['needed_source_error_composed']['native'] = {'value': 'masked'}
    reject('needed error masked', lambda: validate(changed, fresh_after, cases, profiles))
    changed = copy.deepcopy(after); changed['initial_number_concat_arrays_free']['native'] = {'value': ['second']}
    reject('source fallback normalized', lambda: validate(changed, fresh_after, cases, profiles))
    changed = copy.deepcopy(after); changed['nested_kinds_and_source']['native']['value'][0][-1] = 0
    reject('Boolean replaced by Number', lambda: validate(changed, fresh_after, cases, profiles))
    changed = copy.deepcopy(after); del changed['extra_sorted_receiver']
    reject('excluded profile omitted', lambda: validate(changed, fresh_after, cases, profiles))
    changed = copy.deepcopy(generated['formatted-intake']); changed['take_compatible']['module'] += b'\n// drift\n'
    reject('actual module drift', lambda: equal(generated['intake'], changed))
    print(json.dumps(dict(shared=37, own_controls=104, total=141, original_failures=19,
                         preserved=122, profiles=108, four_routes='PASS', direct_tests=292,
                         private_inverse=19, private_restored=141, artifact_pairs=141,
                         recovery='PASS', effective_corruptions=controls), indent=2))


def equal(a, b):
    assert a == b


if __name__ == '__main__':
    main()
