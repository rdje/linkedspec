"""Readonly finite route/input review; never replay acquisition or extract archives."""
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())


def read(path):
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path) + '.gz').read_bytes())


def same(actual, expected):
    if isinstance(actual, bool) or isinstance(expected, bool):
        return type(actual) is type(expected) and actual == expected
    if type(actual) in (int, float) and type(expected) in (int, float):
        return actual == expected
    if type(actual) is not type(expected):
        return False
    if isinstance(actual, list):
        return len(actual) == len(expected) and all(same(a, b) for a, b in zip(actual, expected))
    if isinstance(actual, dict):
        return actual.keys() == expected.keys() and all(same(actual[k], expected[k]) for k in actual)
    return actual == expected


def records(path, prefix):
    result = {}
    for line in read(path).decode().splitlines():
        if line.startswith(prefix):
            name, raw = line[len(prefix):].split(' ', 1)
            assert name not in result, 'duplicate case'
            result[name] = json.loads(raw)
    return result


def matches(row, actual):
    if 'expected_error' in row:
        return set(actual) == {'error'} and row['expected_error'] in actual['error']
    return set(actual) == {'value'} and same(actual['value'], row['expected'])


phases = [sys.argv[1]] if len(sys.argv) > 1 else ['before-qualified', 'after']
for phase in phases:
    directory = BASE / phase
    rows = json.loads(read(directory / 'cases.json'))
    assert len(rows) == 20 and len({r['id'] for r in rows}) == 20
    expected_red = {'free_source_domains', 'receiver_source_domains', 'free_copied_domains'} if phase.startswith('before') else set()
    native = records(directory / 'native-stdout.log', 'COUNT_COPY_RUST ')
    fresh = records(directory / 'fresh-stdout.log', 'COUNT_COPY_RUST_FRESH ')
    normal = records(directory / 'normal-stderr.log', 'COUNT_SOURCE_NORMAL ')
    ids = {row['id'] for row in rows}
    assert set(native) == set(fresh) == set(normal) == ids
    red = {route: set() for route in ('normal0', 'normal1', 'normal2', 'native', 'restored', 'plan', 'fresh')}
    for row in rows:
        name = row['id']
        assert set(native[name]) == {'native', 'restored', 'plan'} and len(normal[name]) == 3
        observations = {**native[name], 'fresh': fresh[name]}
        for index, result in enumerate(normal[name]):
            assert set(result) in ({'Ok'}, {'Err'})
            observations['normal' + str(index)] = {'value': result['Ok']} if 'Ok' in result else {'error': result['Err']}
        for route, actual in observations.items():
            if not matches(row, actual):
                red[route].add(name)
    assert all(names == expected_red for names in red.values()), red
    normal_exit = '101' if expected_red else '0'
    assert read(directory / 'normal-exit.txt').decode().strip() == normal_exit
    for name in ('native', 'fresh'):
        assert read(directory / (name + '-exit.txt')).decode().strip() == '0'
    custody = json.loads(read(directory / 'custody.json'))
    assert len(custody) == 3
    for record in custody:
        with tarfile.open(record['archive']) as archive:
            actual = {}
            for member in archive.getmembers():
                path = PurePosixPath(member.name)
                assert member.isfile() and not path.is_absolute() and '..' not in path.parts
                body = archive.extractfile(member).read()
                actual[member.name] = {'bytes': len(body), 'sha256': hashlib.sha256(body).hexdigest()}
            assert actual == record['files'], 'actual input archive mismatch'
    assert not (directory / 'native').exists() and not (directory / 'fresh').exists()
    print(phase, 'PASS: actual20 root/native/restored/plan/fresh observations; expected REDs', sorted(expected_red), '; exact three first-input archives')
if len(phases) == 2:
    assert read(BASE / 'before-qualified/cases.json') == read(BASE / 'after/cases.json')
    assert same(False, 0) is False and same('0', 0) is False
    print('PASS: authored inputs unchanged; strict Bool/Number/String/null distinctions')
    compat = BASE / 'compat'
    images = json.loads(read(compat / 'inputs.json'))
    with tarfile.open(compat / 'before-first-run.tar.gz') as archive:
        assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                for m in archive.getmembers() if m.isfile()} == images
    for name in ('domain', 'length'):
        assert read(compat / (name + '-exit.txt')).decode().strip() == '0'
        assert 'test result: ok. 1 passed; 0 failed;' in read(compat / (name + '-stdout.log')).decode()
    print('PASS: direct Count diagnostic1/length1; actual compatibility Cargo input archive')

    cleanup = BASE / 'cleanup'
    images = json.loads(read(cleanup / 'inputs.json'))
    with tarfile.open(cleanup / 'before-first-run.tar.gz') as archive:
        assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                for m in archive.getmembers() if m.isfile()} == images
    assert read(cleanup / 'normal-exit.txt').decode().strip() == '0'
    assert 'test result: ok. 20 passed; 0 failed;' in read(cleanup / 'normal-stdout.log').decode()
    assert '(test "count_source_fallback") generated' not in read(cleanup / 'normal-stderr.log').decode()
    print('PASS: final normal20 after import cleanup; no owned test warnings; actual first Cargo inputs')
    initial = BASE / 'before'
    images = json.loads(read(initial / 'initial-project-custody.json'))
    with tarfile.open(initial / 'initial-project-inputs.tar.gz') as archive:
        assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                for m in archive.getmembers() if m.isfile()} == images
    first_root = json.loads(read(BASE / 'before-qualified/custody.json'))[0]['files']
    with tarfile.open(initial / 'root-before-first-run.tar.gz') as archive:
        assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
                for m in archive.getmembers() if m.isfile()} == {k: v['sha256'] for k, v in first_root.items()}
    expected = {name: digest for name, digest in images.items() if '/before/native/' in name}
    expected[str(initial / 'cases.json')] = hashlib.sha256(read(initial / 'cases.json')).hexdigest()
    with tarfile.open(initial / 'native-before-first-run.tar.gz') as archive:
        actual = {}
        for member in archive.getmembers():
            assert member.isfile()
            names = [name for name in expected if member.name.endswith('/' + name)]
            assert len(names) == 1 and names[0] not in actual
            actual[names[0]] = hashlib.sha256(archive.extractfile(member).read()).hexdigest()
        assert actual == expected
    assert not (initial / 'native').exists() and not (initial / 'fresh').exists()
    print('PASS: initial setup evidence/input bodies retained; incorrect old membership gets no behavioral credit')
