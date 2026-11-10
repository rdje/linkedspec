"""Readonly qualification of named fixture bindings, without retrospective credit."""
import copy
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
BASE = Path('docs/checkpoints/dart-direct-input-qualification-2026-11-10')
OUT = BASE / 'qualified'
ACTIVATION = 'daa081db0de3ce0d761f1ee389f7d9a4500bbccb'
STREAMS = {
    'ARRAY_TRANSFORM_DART_NORMAL': ('labelled', 141),
    'HASH_VALUE_DART_NORMAL': ('labelled', 89),
    'HASH_VIEW_DART_NORMAL': ('labelled', 33),
    'WITH_RESULT': ('sequence', 12),
    'CONSTRUCTOR_VALUE': ('labelled', 21),
    'CONSTRUCTOR_ARGUMENT_ERROR': ('json', 1),
    'CONSTRUCTOR_KEY_ERROR': ('json', 1),
    'CONSTRUCTOR_SHAPES': ('json', 1),
    'ARRAY_TRANSFORM_DART_NORMAL_GRAMMAR': ('json', 1),
    'HASH_VALUE_DART_NORMAL_GRAMMAR': ('json', 1),
    'HASH_VIEW_DART_NORMAL_GRAMMAR': ('json', 1),
}


def digest(body):
    return hashlib.sha256(body).hexdigest()


def same(a, b):
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def untar(body):
    files = {}
    with tarfile.open(fileobj=io.BytesIO(body)) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in files
            files[member.name] = (archive.extractfile(member).read(), member.mode & 0o777)
    return files


def recover(tag):
    records = json.loads((ROOT / OUT / (tag + '-identities.json')).read_bytes())
    members = untar((ROOT / OUT / (tag + '-before-first-run.tar.gz')).read_bytes())
    assert members.keys() == records.keys()
    for name, (body, mode) in members.items():
        row = records[name]
        assert digest(body) == row['sha256'] and len(body) == row['bytes'] and mode == row['mode']
    return {name: body for name, (body, _) in members.items()}, records


def required_inputs(spec):
    result = {spec['grammar'], *spec['consumers']}
    result.update(name for paths in spec['consumers'].values() for name in paths)
    return result


def require_bindings(files, spec):
    missing = sorted(required_inputs(spec) - files.keys())
    assert not missing, 'Missing actual bindings: ' + ','.join(missing)


def streams(body):
    result = {}
    for prefix, (style, count) in STREAMS.items():
        values = []
        for line in body.decode().splitlines():
            match = re.search(r'\b' + re.escape(prefix) + r' (.*)$', line)
            if not match:
                continue
            if style in ('labelled', 'sequence'):
                label, value = match[1].split(' ', 1)
                values.append([label, json.loads(value)])
            else:
                values.append(json.loads(match[1]))
        assert len(values) == count, prefix
        if style == 'labelled':
            assert len({row[0] for row in values}) == count
            values = dict(values)
        result[prefix] = values
    assert b'+292: All tests passed!' in body
    assert not re.search(rb'\+\d+ -\d+:', body)
    return result


def validate_run(command, stdout, stderr, exit_code, expected_command, expected_streams):
    assert command == expected_command and exit_code == '0\n' and stderr == b''
    assert same(streams(stdout), expected_streams)


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert digest(body) == row['sha256'] and len(body) == row['bytes']
        if name.endswith('.gz'):
            gzip.decompress(body)
    spec = json.loads((ROOT / BASE / 'inputs.json').read_bytes())
    original = Path(spec['original_packet'])
    assert spec['original_revision'] == '0c4738c4efd575a4c348181c56b5d343b4e3d235'
    assert (ROOT / OUT / 'activation.txt').read_text().strip() == ACTIVATION
    old_archive = subprocess.check_output(['git', 'archive', '--format=tar', spec['original_revision'], str(original)])
    with tarfile.open(fileobj=io.BytesIO(old_archive)) as archive:
        old = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    for name, body in old.items():
        current = (ROOT / name).read_bytes()
        if name == str(original / 'REVIEW.md'):
            assert current.startswith(body)
        else:
            assert current == body
    for name, row in json.loads(old[str(original / 'sealed-identities.json')]).items():
        assert digest(old[name]) == row['sha256'] and len(old[name]) == row['bytes']
    custody = json.loads(old[str(original / 'direct/custody.json')])
    original_root = next(row for row in custody if row['tag'] == 'root')
    old_members = untar(old[original_root['archive']])
    assert old_members.keys() == original_root['files'].keys()
    for name, (body, mode) in old_members.items():
        row = original_root['files'][name]
        assert digest(body) == row['sha256'] and len(body) == row['bytes'] and mode == row['mode']
    missing = sorted(required_inputs(spec) - old_members.keys())
    assert missing == sorted(spec['additional_original_omissions']) and len(missing) == 6
    try:
        require_bindings(old_members, spec)
    except AssertionError as error:
        assert str(error) == 'Missing actual bindings: ' + ','.join(missing)
        original_gate = 'RED: six actual original bindings absent'
    else:
        raise AssertionError('Original binding omission no longer distinguished')
    source, records = recover('source')
    resolved, _ = recover('resolved')
    require_bindings(source, spec)
    assert source[str(BASE / 'inputs.json')] == (ROOT / BASE / 'inputs.json').read_bytes()
    for name, (body, mode) in old_members.items():
        if name.startswith('dart/') and name != 'dart/.dart_tool/package_config.json':
            assert source[name] == body and records[name]['mode'] == mode
    for consumer, paths in spec['consumers'].items():
        # Consumer source bodies are the exact original observed tests. Their
        # six previously unbound fixtures are newly captured, not backdated.
        assert source[consumer] == old_members[consumer][0]
        for name in paths:
            assert name in source
    actual_command = json.loads((ROOT / OUT / 'normal-command.json').read_bytes())
    expected_command = json.loads(old[str(original / 'direct/normal-command.json')])
    assert expected_command['argv'] == ['bash', '../tools/run_dart_project_data.sh', 'test',
        '--reporter', 'expanded', '--concurrency=1',
        *[name.removeprefix('dart/') for name in spec['consumers']]]
    baseline = streams(gzip.decompress(old[str(original / 'direct/normal-stdout.log.gz')]))
    stdout = gzip.decompress((ROOT / OUT / 'normal-stdout.log.gz').read_bytes())
    stderr = gzip.decompress((ROOT / OUT / 'normal-stderr.log.gz').read_bytes())
    exit_code = (ROOT / OUT / 'normal-exit.txt').read_text()
    validate_run(actual_command, stdout, stderr, exit_code, expected_command, baseline)
    grammar_source = source[spec['grammar']].decode()
    for prefix in ('ARRAY_TRANSFORM_DART_NORMAL_GRAMMAR', 'HASH_VALUE_DART_NORMAL_GRAMMAR', 'HASH_VIEW_DART_NORMAL_GRAMMAR'):
        assert baseline[prefix] == [dict(path=spec['grammar'], source=grammar_source)]
    resolution = json.loads((ROOT / OUT / 'default-grammar-resolution.json').read_bytes())
    assert resolution == dict(cwd='dart', nearer_candidate='dart/specs/user_function_definition.spec',
        nearer_candidate_exists=False, selected=spec['grammar'], selected_sha256=digest(source[spec['grammar']]))
    config = 'dart/.dart_tool/package_config.json'
    own = next(p for p in json.loads(resolved[config])['packages'] if p['name'] == 'linkedspec_dart')
    uri = urlparse(own['rootUri'])
    assert not uri.scheme and not uri.netloc and not uri.path.startswith('/')
    assert posixpath.normpath(str(PurePosixPath(config).parent / unquote(uri.path))) == 'dart'
    assert own['packageUri'] == 'lib/'
    for tag, args in (('version', ['--version']), ('resolution', ['pub', 'get', '--offline', '--enforce-lockfile'])):
        packet = json.loads((ROOT / OUT / (tag + '-command.json')).read_bytes())
        assert packet['cwd'] == 'dart' and packet['argv'] == ['bash', '../tools/run_dart_project_data.sh', *args]
        assert (ROOT / OUT / (tag + '-exit.txt')).read_text() == '0\n'
        for channel in ('stdout', 'stderr'):
            gzip.decompress((ROOT / OUT / (tag + '-' + channel + '.log.gz')).read_bytes())
    assert gzip.decompress((ROOT / OUT / 'version-stdout.log.gz').read_bytes()).startswith(b'Dart SDK version:')
    preservation = json.loads((ROOT / OUT / 'original-preservation.json').read_bytes())
    assert preservation['original_proof_preserved'] == 'PASS' and preservation['missing'] == missing
    assert preservation['explicit_original_binding'] == 'INCOMPLETE'
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    changed = dict(source); del changed[missing[0]]
    reject('missing older fixture binding', lambda: require_bindings(changed, spec))
    changed = dict(source); del changed[spec['grammar']]
    reject('missing grammar binding', lambda: require_bindings(changed, spec))
    changed = copy.deepcopy(actual_command); changed['argv'].remove('test/with_hash_results_test.dart')
    reject('selected consumer omitted', lambda: validate_run(changed, stdout, stderr, exit_code, expected_command, baseline))
    reject('wrong exit', lambda: validate_run(actual_command, stdout, stderr, '1\n', expected_command, baseline))
    reject('unexpected stderr', lambda: validate_run(actual_command, stdout, b'warning\n', exit_code, expected_command, baseline))
    reject('missing actual stdout', lambda: validate_run(actual_command, b'', stderr, exit_code, expected_command, baseline))
    changed = copy.deepcopy(baseline); changed['ARRAY_TRANSFORM_DART_NORMAL']['take_free_hash_guard']['native'] = {'value': [None, 'KV']}
    reject('changed actual semantic stream', lambda: validate_run(actual_command, stdout, stderr, exit_code, expected_command, changed))
    first = missing[0]
    reject('changed fixture bytes', lambda: equal(digest(source[first] + b'\n'), records[first]['sha256']))
    print(json.dumps(dict(original_fixture_binding=original_gate,
        qualified_fixture_binding='PASS', original_packet_preserved='PASS', runtime_source='unchanged',
        direct_tests=292, command='exact original five-file concurrency1', semantic_streams='all11 exact',
        old_missing_fixture_paths=missing, qualified_epoch=str(OUT), recovery='PASS',
        effective_corruptions=controls,
        limits='No retrospective first-use identity; full native/cache/transitive/toolchain custody remains4.2/SESSION5.'), indent=2))


def equal(a, b):
    assert a == b


if __name__ == '__main__':
    main()
