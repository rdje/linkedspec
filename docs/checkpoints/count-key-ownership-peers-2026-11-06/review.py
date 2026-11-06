"""Read-only finite peer Count-to-CountKeys preservation and input recovery."""
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
ACTIVATION = '50e5933f56d57487e912fad37e05b6810096c1ea'
FIXTURE = 'tests/fixtures/key_count_count_source_ownership_cases.json'
SHARED = 'tests/fixtures/key_count_result_guard_cases.json'
ROUTES = {'native', 'restored', 'plan'}
OWNERS = {'rust': 'rust/linkedspec-runtime/src/engine.rs', 'dart': 'dart/lib/src/runtime/interpreter.dart'}
NORMALS = {'rust': 'rust/linkedspec-runtime/tests/key_count_result_guard_composition.rs', 'dart': 'dart/test/key_count_result_guard_composition_test.dart'}


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def raw(path):
    path = ROOT / path
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + '.gz').read_bytes())


def recover(record):
    found = {}
    with tarfile.open(ROOT / record['archive']) as archive:
        for member in archive.getmembers():
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in found
            body = archive.extractfile(member).read()
            item = record['files'][member.name]
            assert digest(body) == item['sha256'] and len(body) == item['bytes']
            assert member.mode & 0o777 == item['mode']
            found[member.name] = body
    assert found.keys() == record['files'].keys()
    return found


def frames(phase, tag, prefix, channel='stdout'):
    rows = {}
    for line in raw(BASE / phase / (tag + '-' + channel + '.log')).decode().splitlines():
        if line.startswith(prefix + ' '):
            _, identifier, body = line.split(' ', 2)
            assert identifier not in rows
            rows[identifier] = json.loads(body)
    return rows


def validate(native, fresh, cases):
    assert list(native) == list(fresh) == [c['id'] for c in cases]
    for case in cases:
        n, f = native[case['id']], fresh[case['id']]
        assert set(n) == ROUTES
        for value in [*n.values(), f]:
            assert same(value, {'value': case['expected']}), 'value/kind/effects'


def module_set(actual, cases, extension):
    assert set(actual) == {c['id'] + extension for c in cases}, 'complete actual module population'


def main():
    records = json.loads((BASE / 'raw-identities.json').read_text())
    for path, item in records.items():
        capsule = (ROOT / item['capsule']).read_bytes()
        body = gzip.decompress(capsule)
        assert digest(capsule) == item['capsule_sha256']
        assert digest(body) == item['sha256'] and len(body) == item['bytes']
        assert body == raw(Path(path))
    custody = {}
    for language in OWNERS:
        for mode in ('probe', 'normal'):
            phase = language + '-' + mode
            declared = json.loads((BASE / phase / 'custody.json').read_text())
            custody[phase] = {Path(r['archive']).name.split('-before-first-run')[0]: recover(r) for r in declared}
            root = custody[phase]['root']
            assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
            assert root[OWNERS[language]] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNERS[language]]), 'runtime source unchanged'
            assert root[FIXTURE] == (ROOT / FIXTURE).read_bytes()
            assert root[SHARED] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + SHARED])
            writer = str(BASE / ('capture_' + language + '.py'))
            assert root[writer] == (ROOT / writer).read_bytes()
            for path in (BASE / phase).glob('*-exit.txt'):
                assert path.read_text() == '0\n'
    cases = json.loads(custody['rust-probe']['root'][FIXTURE])
    assert len(cases) == 3 and all(custody[p]['root'][FIXTURE] == custody['rust-probe']['root'][FIXTURE] for p in custody)
    observations, modules = {}, {}
    for language in OWNERS:
        phase = language + '-probe'
        c = custody[phase]
        n = frames(phase, 'native', 'KEY_COUNT_' + language.upper())
        f = frames(phase, 'fresh', 'KEY_COUNT_' + language.upper() + '_FRESH')
        validate(n, f, cases)
        observations[language] = n, f
        data = frames(phase, 'native', 'KEY_COUNT_' + language.upper() + '_INPUT')
        assert list(data) == [row['id'] for row in cases]
        modules[language] = {}
        if language == 'rust':
            assert json.loads(c['native'][str(BASE / phase / 'cases.json')]) == cases
            assert c['native'][str(BASE / phase / 'native/src/main.rs')] == c['root'][str(BASE / 'observer.rs')]
            for row in cases:
                name = row['id']
                body = c['fresh'][str(BASE / phase / 'fresh/inputs' / (name + '.json'))]
                assert body.decode() == data[name]['compiled']
                modules[language][name + '.rs'] = c['fresh'][str(BASE / phase / 'fresh/src/generated' / (name + '.rs'))]
        else:
            assert json.loads(c['root'][str(BASE / phase / 'cases.json')]) == cases
            probe = 'dart/tool/probe_key_count_result_guards.dart'
            assert c['root'][probe] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + probe])
            for index, row in enumerate(cases):
                body = c['fresh'][str(BASE / phase / 'fresh/inputs' / f'case_{index}.json')]
                assert same(json.loads(body), data[row['id']])
                modules[language][row['id'] + '.dart'] = c['fresh'][str(BASE / phase / 'fresh/lib' / f'case_{index}.dart')]
        module_set(modules[language], cases, '.rs' if language == 'rust' else '.dart')
        normal = custody[language + '-normal']['root'][NORMALS[language]]
        original = custody[phase]['root'][NORMALS[language]]
        assert original == subprocess.check_output(['git', 'show', ACTIVATION + ':' + NORMALS[language]])
        if language == 'rust':
            addition = b'    let ownership: Vec<Value> = serde_json::from_str(include_str!(\n        "../../../tests/fixtures/key_count_count_source_ownership_cases.json"\n    ))\n    .unwrap();\n    cases.extend(ownership);\n'
            names = b'    count_to_keys,\n    count_to_keys_effects,\n    initial_keys_controls,\n'
            assert normal.count(addition) == normal.count(names) == 1
            assert normal.replace(b'let mut cases: Vec<Value>', b'let cases: Vec<Value>', 1).replace(addition, b'').replace(names, b'') == original
        else:
            addition = b"    'tests/fixtures/key_count_count_source_ownership_cases.json',\n"
            assert normal.count(addition) == 1 and normal.replace(addition, b'') == original
        all_cases = json.loads(custody[phase]['root'][SHARED]) + cases
        domain = json.loads(custody[language + '-normal']['root']['tests/fixtures/key_count_result_guard_' + language + '_domain.json'])
        if language == 'rust':
            actual = frames('rust-normal', 'normal', 'KEY_COUNT_GUARD_ACTUAL', 'stderr')
            output = raw(BASE / 'rust-normal/normal-stdout.log').decode()
            tests = re.findall(r'^test (\w+) \.\.\. (ok|FAILED)$', output, re.M)
            assert len(tests) == 25 and all(state == 'ok' for _, state in tests)
            assert {name for name, _ in tests} == {r['id'] for r in all_cases}
            assert not re.search(r'^warning: `linkedspec-(?:core|runtime)`.*generated', raw(BASE / 'rust-normal/normal-stderr.log').decode(), re.M)
        else:
            actual = frames('dart-normal', 'normal', 'KEY_COUNT_GUARD_DART_VALUE')
            errors = frames('dart-normal', 'normal', 'KEY_COUNT_GUARD_DART_ERROR')
            assert not actual.keys() & errors.keys()
            actual.update(errors)
            assert 'All tests passed!' in raw(BASE / 'dart-normal/normal-stdout.log').decode()
        assert set(actual) == {r['id'] for r in all_cases}
        for row in all_cases:
            values = actual[row['id']]
            if language == 'dart':
                assert set(values) == ROUTES
                values = list(values.values())
            else:
                assert len(values) == 3
            for value in values:
                if row.get('expected_error'):
                    assert row['expected_error'] in value['Err' if language == 'rust' else 'error']
                else:
                    expected = domain['expected'] if row['id'] == 'source_domain' else row['expected']
                    assert same(value, {'Ok' if language == 'rust' else 'ok': expected}), 'maintained normal value/kind'
    assert all(same(r, d) for r, d in zip(observations['rust'], observations['dart']))
    for tag in ('rust-format', 'dart-format'):
        assert (BASE / (tag + '-exit.txt')).read_text() == '0\n'
        assert raw(BASE / (tag + '-stderr.log')) == b''
        command = json.loads((BASE / (tag + '-command.json')).read_text())
        for language in NORMALS:
            path = NORMALS[language]
            assert digest(custody[language + '-normal']['root'][path]) == command['inputs'][path]
    rejected = []
    for control in ('missing-row', 'Count-zero-restored', 'with-effect-restored', 'false-as-number', 'missing-module'):
        native, fresh = copy.deepcopy(observations['rust'])
        try:
            if control == 'missing-row':
                native.pop('count_to_keys')
            elif control == 'Count-zero-restored':
                native['count_to_keys']['native']['value'][0] = 0
            elif control == 'with-effect-restored':
                native['count_to_keys_effects']['native']['value'] = ['ran', 'W']
            elif control == 'false-as-number':
                native['initial_keys_controls']['native']['value'][0] = False
            else:
                altered = dict(modules['rust']); altered.pop('count_to_keys.rs')
                module_set(altered, cases, '.rs')
            validate(native, fresh, cases)
        except (AssertionError, KeyError):
            rejected.append(control)
        else:
            raise AssertionError('ineffective control ' + control)
    print(json.dumps(dict(result='PASS', new_controls_per_backend='3PASS/four routes', maintained_normal_per_backend='25PASS/native-restored-plan', runtime_changes=0, peer_defects_demonstrated=0, rejected_controls=rejected, limits='Finite authored controls; emitted execution covers new3. Runtime source byte-identical; full native/transitive custody, general isolation, callable and full admission remain separate.'), sort_keys=True))


if __name__ == '__main__':
    main()
