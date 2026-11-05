"""Readonly Dart Count input/route review, with strict scalar kinds."""
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import sys
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())


def read(path):
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + '.gz').read_bytes())


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if type(a) in (int, float) and type(b) in (int, float):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def records(path, prefix):
    result = {}
    for line in read(path).decode().splitlines():
        if line.startswith(prefix):
            name, value = line[len(prefix):].split(' ', 1)
            assert name not in result
            result[name] = json.loads(value)
    return result


def matches(row, actual):
    if 'expected_error' in row:
        return 'value' not in actual and row['expected_error'] in actual.get('error', '')
    return set(actual) == {'value'} and same(actual['value'], row['expected'])


phases = [sys.argv[1]] if len(sys.argv) > 1 else ['before', 'after']
errors = {}
for phase in phases:
    out = BASE / phase
    rows = json.loads(read(out / 'cases.json'))
    assert len(rows) == 25 and len({r['id'] for r in rows}) == 25
    ids = {row['id'] for row in rows}
    native = records(out / 'native-stdout.log', 'COUNT_COPY_DART ')
    fresh = records(out / 'fresh-stdout.log', 'COUNT_COPY_DART_FRESH ')
    normal = records(out / 'normal-stdout.log', 'COUNT_SOURCE_DART_VALUE ')
    normal_errors = records(out / 'normal-stdout.log', 'COUNT_SOURCE_DART_ERROR ')
    assert not normal.keys() & normal_errors.keys()
    normal.update(normal_errors)
    assert set(native) == set(fresh) == set(normal) == ids
    red = {route: set() for route in ('normal-native', 'normal-restored', 'normal-plan', 'native', 'restored', 'plan', 'fresh')}
    errors[phase] = {}
    for row in rows:
        name = row['id']
        assert set(native[name]) == set(normal[name]) == {'native', 'restored', 'plan'}
        observed = {**native[name], 'fresh': fresh[name]}
        for route, value in normal[name].items():
            observed['normal-' + route] = {'value': value['ok']} if 'ok' in value else value
        for route, value in observed.items():
            if not matches(row, value):
                red[route].add(name)
            if 'expected_error' in row:
                errors[phase][name + '/' + route] = {k: value[k] for k in ('error', 'class')}
    expected = {'receiver_source_domains', 'initial_boolean_count_continuations', 'boolean_count_source_once'} if phase == 'before' else set()
    assert all(names == expected for names in red.values()), red
    for tag in ('root-analysis', 'fresh-analysis', 'native', 'fresh'):
        assert read(out / (tag + '-exit.txt')).decode().strip() == '0', tag
    assert read(out / 'normal-exit.txt').decode().strip() == ('1' if expected else '0')
    custody = json.loads(read(out / 'custody.json'))
    assert len(custody) == 2
    for record in custody:
        with tarfile.open(record['archive']) as archive:
            actual = {}
            for member in archive.getmembers():
                path = PurePosixPath(member.name)
                assert member.isfile() and not path.is_absolute() and '..' not in path.parts
                body = archive.extractfile(member).read()
                actual[member.name] = {'bytes': len(body), 'sha256': hashlib.sha256(body).hexdigest()}
            assert actual == record['files']
    assert not (out / 'fresh').exists()
    print(phase, 'PASS:25 cases/root-native/restored/plan/compiled emission; expected REDs', sorted(expected), '; fatal analysis and actual input archives')
if len(phases) == 2:
    assert read(BASE / 'before/cases.json') == read(BASE / 'after/cases.json')
    assert errors['before'] == errors['after'], 'observed source-error message/class changed'
    assert same(False, 0) is False and same('0', 0) is False
    print('PASS: unchanged authored inputs/error message-class; strict Bool/Number/String/null')
    compat = BASE / 'compat'
    images = json.loads(read(compat / 'inputs.json'))
    with tarfile.open(compat / 'before-first-run.tar.gz') as archive:
        assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                for m in archive.getmembers() if m.isfile()} == images
    for name, total in [('length', 2), ('index', 1)]:
        assert read(compat / (name + '-exit.txt')).decode().strip() == '0'
        assert f'+{total}: All tests passed!' in read(compat / (name + '-stdout.log')).decode()
    fmt = json.loads(read(BASE / 'scoped-format.json'))
    after_inputs = json.loads(read(BASE / 'after/custody.json'))[0]
    assert fmt['sha256'] == after_inputs['files'][fmt['source']]['sha256']
    before_fmt = read(BASE / 'scoped-format-before.txt').decode()
    after_fmt = read(BASE / 'scoped-format-after.txt').decode()
    with tarfile.open(after_inputs['archive']) as archive:
        owner = archive.extractfile(fmt['source']).read().decode()
    start = owner.index('  Object? _evaluateFluentCallsWithValue(')
    end = owner.index('\n  Object? _evaluateFluentCall(', start)
    prefix, suffix = 'class Probe {\n', '\n}\n'
    assert before_fmt == prefix + owner[start:end] + suffix
    assert after_fmt.startswith(prefix) and after_fmt.endswith(suffix)
    assert before_fmt[len(prefix):-len(suffix)].rstrip('\n') == after_fmt[len(prefix):-len(suffix)].rstrip('\n')
    assert not read(BASE / 'scoped-format-stderr.txt')
    print('PASS: direct Count/length2/index1 inputs; owned formatter probe and exact tested runtime identity')
