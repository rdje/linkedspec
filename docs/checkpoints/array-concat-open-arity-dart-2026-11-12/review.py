"""Recover finite own Dart concat proof without executing a runtime or producer."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile
from urllib.parse import unquote, urljoin, urlparse

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ACTIVATION = '1753884257bed7ce0b842bc406c665671403a828'
OWNER = 'dart/lib/src/runtime/interpreter.dart'
PROBE = 'dart/tool/probe_open_arity_array_concat_results.dart'
NORMAL = 'dart/test/array_concat_open_arity_result_guard_composition_test.dart'
PROFILE = 'tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json'
CASES = 'tests/fixtures/array_concat_open_arity_dart_cases.json'
GRAMMAR = 'specs/user_function_definition.spec'
OBS = 'dart/tool/callable_array_transform_observation.dart'
CONTROL = str(REL / 'control-owner') + '/'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def same(left, right):
    return json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))


def require(left, right, reason):
    assert same(left, right), reason


def raw(name):
    return gzip.decompress((BASE / name).read_bytes())


def frames(body, tag):
    rows = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', body.decode(), re.M):
        assert key not in rows, 'duplicate frame'
        rows[key] = json.loads(value)
    return rows


def archive(path, identities):
    bodies = {}
    with tarfile.open(path) as packed:
        assert len(packed.getnames()) == len(identities)
        for member in packed:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in bodies
            body = packed.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archive bytes'
            assert member.mode & 0o777 == row['mode'], 'archive mode'
            bodies[member.name] = body
    assert bodies.keys() == identities.keys(), 'archive census'
    return bodies


def inputs(phase):
    data = {}
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        path = PurePosixPath(packet['archive'])
        assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(REL / phase) + '/')
        assert packet['tag'] not in data
        data[packet['tag']] = archive(ROOT / path, packet['files'])
    return data


def routed(path, body, expected):
    own, = [p for p in json.loads(body)['packages'] if p['name'] == 'linkedspec_dart']
    assert not urlparse(own['rootUri']).scheme, 'relative own routing'
    uri = urlparse(urljoin((ROOT / path).as_uri(), own['rootUri']))
    assert uri.scheme == 'file' and not uri.netloc and Path(unquote(uri.path)).resolve() == (ROOT / expected).resolve(), 'SDK routing'


def routes(phase):
    native = frames(raw(phase + '/native-stdout.log.gz'), 'ARRAY_CONCAT_DART')
    fresh = frames(raw(phase + '/fresh-stdout.log.gz'), 'ARRAY_CONCAT_DART_FRESH')
    assert native.keys() == fresh.keys() and len(native) == 508, 'four-route census'
    return {key: dict(row, fresh=fresh[key]) for key, row in native.items()}


def validate(actual, profiles):
    assert actual.keys() == profiles.keys(), 'result census'
    for key, row in profiles.items():
        require(actual[key], {r: row[r] for r in ROUTES}, 'complete wire result:' + key)


def normal(phase, expected, failures, data):
    body = raw(phase + '/normal-stdout.log.gz')
    require(frames(body, 'ARRAY_CONCAT_DART_NORMAL'), {key: {r: row[r] for r in ROUTES[:-1]} for key, row in expected.items()}, 'normal observations')
    actual_red = {key.decode() for key in re.findall(rb'^\S+ \+\d+ -\d+: (\w+) \[E\]$', body, re.M)}
    assert actual_red == failures, 'exact failed case set'
    suffix = '+484 -24: Some tests failed.' if failures else '+1155: All tests passed!' if phase == 'direct' else '+508: All tests passed!'
    assert suffix.encode() in body and (BASE / phase / 'normal-exit.txt').read_text() == ('1\n' if failures else '0\n')
    assert raw(phase + '/normal-stderr.log.gz') == b''
    prefix = CONTROL if phase.startswith('private-') else ''
    folder = prefix + '.linkedspec-data/scratch/open-arity-concat-dart-normal/' + phase + '/'
    parsed = frames(body, 'ARRAY_CONCAT_DART_NORMAL_INPUT')
    assert parsed.keys() == expected.keys() and set(data['normal-parsed']) == {folder + key + '.json' for key in expected}
    for key, row in parsed.items():
        require(json.loads(data['normal-parsed'][folder + key + '.json']), row, 'normal parsed input')


def main():
    for name, row in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / path).read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert (ROOT / path).stat().st_mode & 0o777 == row['mode']
    phases = ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct')
    data = {phase: inputs(phase) for phase in phases}
    original, candidate = data['intake']['root'], data['after']['root']
    old = subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER], cwd=ROOT)
    assert original[OWNER] == raw('owner-before.dart.gz') == old
    new = candidate[OWNER]
    assert new == raw('owner-after.dart.gz')
    anchor = b"      'concat_arrays' => count == 2,"
    assert old.count(anchor) == 1 and old.replace(anchor, b"      'concat_arrays' => count >= 1,", 1) == new, 'one-line owner delta'
    names = set()
    with subprocess.Popen(['git', 'archive', ACTIVATION, 'dart', 'tests/fixtures', 'specs/spec.spec', GRAMMAR, 'specs/pplugin.spec'], cwd=ROOT, stdout=subprocess.PIPE) as process:
        with tarfile.open(fileobj=process.stdout, mode='r|') as packed:
            for member in packed:
                if member.isfile():
                    assert original[member.name] == packed.extractfile(member).read(), 'activation bytes'
                    row = next(p for p in json.loads((BASE / 'intake/custody.json').read_bytes()) if p['tag'] == 'root')['files'][member.name]
                    assert bool(member.mode & 0o111) == bool(row['mode'] & 0o111), 'Git executable class'
                    names.add(member.name)
        assert process.wait() == 0
    assert names == {name for name in original if name.startswith(('dart/', 'tests/fixtures/', 'specs/')) and name not in (PROBE, 'dart/.dart_tool/package_config.json')}
    legacy_paths = {row['path'] for row in json.loads((BASE / 'legacy-transfers.json').read_bytes())}
    for phase in phases:
        private = phase.startswith('private-'); prefix = CONTROL if private else ''
        root = data[phase]['root']
        for name in names:
            expected = new if name == OWNER and phase not in ('intake', 'before', 'private-old') else original[name]
            if name in legacy_paths and phase in ('private-old', 'private-fixed', 'direct'):
                expected = data['direct']['root'][name]
            assert root[prefix + name] == expected, (phase, name)
        if phase != 'intake':
            for name in (NORMAL, PROFILE, CASES):
                assert root[prefix + name] == candidate[name], 'normal/fixture epoch identity'
        assert root[prefix + PROBE] == original[PROBE] and root[prefix + OBS] == original[OBS]
        config = prefix + 'dart/.dart_tool/package_config.json'
        routed(config, data[phase]['resolved'][config], prefix + 'dart')
        for command in (BASE / phase).glob('*-command.json'):
            tag = command.name.removesuffix('-command.json'); record = json.loads(command.read_bytes())
            expected_exit = '1\n' if phase in ('before', 'private-old') and tag == 'normal' else '0\n'
            assert command.with_name(tag + '-exit.txt').read_text() == expected_exit
            assert command.with_name(tag + '-stderr.log.gz').is_file() and command.with_name(tag + '-stdout.log.gz').is_file()
            assert record['environment'].get('TERM') == 'dumb' and record['environment'].get('NO_COLOR') == '1'
            if tag == 'normal':
                assert '--concurrency=1' in record['argv']
    cases = json.loads(candidate[CASES]); profiles = json.loads(candidate[PROFILE])
    require(cases, json.loads(original[str(REL / 'cases.json')]), 'original source-only cases')
    assert len(cases) == 508 and {case['id'] for case in cases} == profiles.keys()
    before, after = routes('intake'), routes('after'); validate(after, profiles)
    assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
    require(before, assessment['observed'], 'cold assessment inputs')
    red = {key for key, row in profiles.items() if row['role'] != 'preservation'}
    assert len(red) == 24 and sum(row['role'] == 'supported-target' for row in profiles.values()) == 20
    assert red == set(assessment['targets']) | set(assessment['compatibility'])
    for case in cases:
        key = case['id']; require(profiles[key]['case'], case, 'source metadata')
        expected = assessment['targets'].get(key, assessment['compatibility'].get(key, before[key]))
        require(after[key], expected, 'frozen own adjudication')
        assert same(before[key], after[key]) == (key not in red), 'preservation boundary'
    initial = [c['id'] for c in cases if c['origin'] == 'questions108' and c['question'] == 'initial-producer-policy']
    invalid = [c['id'] for c in cases if c['origin'] == 'questions108' and c['question'] == 'invalid-signature']
    assert len(initial) == 80 and len(invalid) == 8 and all(same(before[k], after[k]) for k in initial + invalid)
    for phase in ('intake', 'after'):
        emitted, fresh = data[phase]['emitted'], data[phase]['fresh']
        for name, body in emitted.items():
            assert fresh[name] == body, 'emitted inputs before fresh use'
        config = str(REL / phase / 'fresh/.dart_tool/package_config.json')
        routed(config, fresh[config], 'dart')
        assert raw(phase + '/native-stderr.log.gz') == raw(phase + '/fresh-stderr.log.gz') == b''
        grammar = [json.loads(line.split(' ', 1)[1]) for line in raw(phase + '/native-stdout.log.gz').decode().splitlines() if line.startswith('ARRAY_CONCAT_DART_GRAMMAR ')]
        require(grammar, [dict(path=GRAMMAR, source=original[GRAMMAR].decode())], 'actual grammar')
    for index, case in enumerate(cases):
        for tail in (f'inputs/case_{index}.json', f'lib/case_{index}.dart'):
            assert data['intake']['emitted'][str(REL / 'intake/fresh' / tail)] == data['after']['emitted'][str(REL / 'after/fresh' / tail)], 'parsed/module stability'
    for phase, expected, failures in (('before', before, red), ('private-old', before, red), ('private-fixed', after, set()), ('direct', after, set())):
        normal(phase, expected, failures, data[phase])
        prefix = CONTROL if phase.startswith('private-') else ''
        folder = prefix + '.linkedspec-data/scratch/open-arity-concat-dart-normal/' + phase + '/'
        for index, case in enumerate(cases):
            assert data[phase]['normal-parsed'][folder + case['id'] + '.json'] == data['intake']['emitted'][str(REL / 'intake/fresh/inputs' / f'case_{index}.json')], 'normal/public parsed bytes'
    left = {n: b for n, b in data['private-old']['root'].items() if n.startswith(CONTROL)}
    right = {n: b for n, b in data['private-fixed']['root'].items() if n.startswith(CONTROL)}
    assert left.keys() == right.keys() and left[CONTROL + OWNER] == old and right[CONTROL + OWNER] == new
    assert all(left[n] == right[n] for n in left.keys() - {CONTROL + OWNER}), 'same private SDK path inputs'
    for transfer in json.loads((BASE / 'legacy-transfers.json').read_bytes()):
        path = transfer['path']; original_rows = json.loads(original[path]); current_rows = json.loads(data['direct']['root'][path])
        assert original_rows.keys() == current_rows.keys()
        for key, row in original_rows.items():
            if key in transfer['keys']:
                require({r: current_rows[key][r] for r in ROUTES}, after[transfer['keys'][key]], 'legacy transfer routes')
                require({k: v for k, v in current_rows[key].items() if k not in ROUTES}, {k: v for k, v in row.items() if k not in ROUTES}, 'legacy source/metadata')
            else:
                require(current_rows[key], row, 'other legacy profile')
    for name in (NORMAL, PROFILE, CASES, 'dart/test/array_transform_callable_result_guard_composition_test.dart', 'docs/checkpoints/array-transform-callable-dart-2026-11-12/cases.json', 'docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json', 'docs/checkpoints/array-pipeline-callable-dart-2026-11-11/cases.json'):
        assert name in data['direct']['root'], 'direct fixture closure'
    source = candidate[NORMAL]
    assert source.index(b'target.writeAsStringSync(serialized)') < source.index(b'target.readAsStringSync()') < source.index(b'compileSpec(parsed)') < source.index(b'SpecFile.fromJson(')
    probe = original[PROBE]
    assert probe.index(b'inputFile.writeAsStringSync(serialized)') < probe.index(b'inputFile.readAsStringSync()') < probe.index(b'compileSpec(parsed)') < probe.index(b'SpecFile.fromJson(')
    assert b'error.toJson()' in original[OBS]
    for tag in ('prepare', 'intake', 'inspect-intake', 'freeze-policy', 'format-normal', 'before', 'repair', 'after', 'accept-after', 'private-old', 'private-fixed', 'direct', 'format', 'publication-query', 'review-publication-query'):
        out = BASE / 'launches' / tag
        recovered = archive(out / 'inputs.tar.gz', json.loads((out / 'identities.json').read_bytes()))
        command = json.loads((out / 'command.json').read_bytes())
        producers = [name for name in command['argv'] if name.endswith('.py')]
        assert producers and all(recovered[name] == (ROOT / name).read_bytes() for name in producers), 'actual producer'
        assert (out / 'exit.txt').read_text() == '0\n' and gzip.decompress((out / 'stderr.log.gz').read_bytes()) == b''
    controls = []
    def reject(label, operation, reason):
        try:
            operation()
        except AssertionError as error:
            assert reason in str(error), 'wrong rejection reason:' + label
            controls.append(label)
        else:
            raise AssertionError('ineffective control:' + label)
    reject('original owner result is RED', lambda: validate(before, profiles), 'complete wire result')
    for label, key in (('source effects', 'ordinary_3_free_hash'), ('persistent rejection', 'function_3_receiver_later'), ('source snapshot', 'own80_snapshot_function_free_hash')):
        corrupt = copy.deepcopy(after); corrupt[key]['native']['value'] = ['wrong', 'effects']
        reject(label, lambda: validate(corrupt, profiles), 'complete wire result')
    for key in initial[:1] + invalid[:1]:
        corrupt = copy.deepcopy(after); corrupt[key]['restored'] = {'value': 'changed'}
        reject('preservation:' + key, lambda: validate(corrupt, profiles), 'complete wire result')
    error_key = next(key for key, row in after.items() if 'error_json' in row['fresh'])
    corrupt = copy.deepcopy(after); corrupt[error_key]['fresh']['error_json']['source_identity'] = 'foreign.spec'
    reject('complete generated error source identity', lambda: validate(corrupt, profiles), 'complete wire result')
    corrupt = copy.deepcopy(after); corrupt[error_key]['fresh']['unexpected'] = None
    reject('field absence', lambda: validate(corrupt, profiles), 'complete wire result')
    corrupt = copy.deepcopy(after); corrupt['own80_nested_ordinary_free']['native']['value'][2] = 0
    reject('Boolean versus Number', lambda: validate(corrupt, profiles), 'complete wire result')
    report = dict(historical_recovery='PASS', programs=508, routes=4, supported=20, separate_compatibility=4,
        preserved=484, initial_policies=80, invalid_signatures=8, old_red=24, private_current=508, direct_named_groups=1155,
        parsed_module_pairs=1016, normal_parsed_inputs=2032, corruption_controls=controls,
        limits='Finite public own Dart projections/full available JSON only. Full native/VM/cache/transitive/toolchain/OS4.2/SESSION5 and feature/admission/source/context/discovery23.4 remain open. Normalized emitted source state is not complete lowered typed IR. No SDK replay, performance/population or future freshness claim.')
    print(json.dumps(report, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
