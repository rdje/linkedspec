"""Recover historical Julia proof without invoking the SDK or used producers."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-concat-open-arity-julia-2026-11-12')
ACTIVATION = '952f8a022c59a478614ba1413e0e36e49e7e14e8'
OWNER = 'julia/src/runtime/Interpreter.jl'
RUNNER = 'julia/test/runtests.jl'
NORMAL = 'julia/test/array_concat_open_arity_result_guard_composition_test.jl'
CASES = 'tests/fixtures/array_concat_open_arity_julia_cases.json'
PROFILE = 'tests/fixtures/array_concat_open_arity_result_guard_julia_profiles.json'
LEGACY = 'tests/fixtures/array_transform_callable_result_guard_julia_profiles.json'
ORDINARY = 'tests/fixtures/array_transform_result_guard_julia_profiles.json'
ROUTES = ('native', 'restored', 'plan', 'fresh')


def wire(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def digest(body):
    return hashlib.sha256(body).hexdigest()


def require(condition, reason):
    assert condition, reason


def read(name):
    path = PurePosixPath(name)
    require(not path.is_absolute() and '..' not in path.parts, 'relative path')
    target = ROOT / path
    require(target.is_file() and not target.is_symlink(), 'retained file')
    return target.read_bytes()


def capsule(path, rows):
    bodies = {}
    with tarfile.open(ROOT / path) as archive:
        for member in archive:
            name = PurePosixPath(member.name)
            require(member.isfile() and not name.is_absolute() and '..' not in name.parts, 'safe capsule')
            require(member.name not in bodies and member.name in rows, 'capsule census')
            body = archive.extractfile(member).read()
            row = rows[member.name]
            require(len(body) == row['bytes'] and digest(body) == row['sha256'], 'capsule bytes')
            require(member.mode & 0o777 == row['mode'], 'capsule full modes')
            bodies[member.name] = body
    require(bodies.keys() == rows.keys(), 'capsule census')
    return bodies


def epoch(phase):
    packets = json.loads(read(BASE / phase / 'custody.json'))
    require([row['tag'] for row in packets] == ['root', 'artifacts'], 'epoch packet census')
    return tuple(capsule(row['archive'], row['files']) for row in packets)


def channel(phase, tag, name):
    return gzip.decompress(read(BASE / phase / (tag + '-' + name + '.log.gz')))


def frames(body, prefix):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(prefix + ' '):
            _, key, raw = line.split(' ', 2)
            require(key not in rows, 'frame census')
            rows[key] = json.loads(raw)
    return rows


def semantic_oracle(cases, cold):
    require(len(cases) == 508 and list(cold) == [row['id'] for row in cases], 'program census')
    require(all(set(row) == set(ROUTES) for row in cold.values()), 'route census')
    require(all(not {'expected', 'role', 'expected_error', 'expected_observation'} & row.keys() for row in cases), 'source-only questions')
    expected = copy.deepcopy(cold)
    supported, compatibility = [], []
    for case in cases:
        key, origin = case['id'], case['origin']
        wanted = None
        if origin == 'shared84':
            if case.get('question') == 'needed-producer-error':
                terminal = re.sub(r'_(hash|terminal)$', '_terminal', key)
                require(all('error' in row for row in cold[terminal].values()), 'needed terminal error')
                wanted = copy.deepcopy(cold[terminal])
                for route in ('plan', 'fresh'):
                    prefix = 'array-concat-open-arity-result-guard/'
                    require(wanted[route]['error_json']['source_identity'] == prefix + terminal + '.spec', 'needed source identity')
                    wanted[route]['error_json']['source_identity'] = prefix + key + '.spec'
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
                    require(tail in ('hash', 'later'), 'authored tail')
                    value = [None, effects]
                wanted = {route: dict(value=copy.deepcopy(value)) for route in ROUTES}
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
                require(question in ('initial-producer-policy', 'invalid-signature'), 'own policy scope')
                continue
            wanted = {route: dict(value=copy.deepcopy(value)) for route in ROUTES}
        if wanted is not None:
            if wire(wanted) != wire(cold[key]):
                require(case.get('tail') in ('hash', 'later', 'composed'), 'own supported terminal')
                supported.append(key)
            expected[key] = wanted
    for form in ('free', 'receiver'):
        for key, terminal in (
            ('own_extra_concat_arrays_' + form, 'own_extra_concat_arrays_' + form + '_terminal_probe'),
            ('ordinary_legacy_extra_concat_arrays_' + form + '_composed', 'ordinary_legacy_extra_concat_arrays_' + form + '_terminal'),
        ):
            require(all(set(row) == {'value'} and isinstance(row['value'][0], list)
                and isinstance(row['value'][1], str) for row in cold[terminal].values()), 'own legacy terminal')
            wanted = {route: dict(value=[None, cold[terminal][route]['value'][1]]) for route in ROUTES}
            require(wire(cold[key]) != wire(wanted), 'own legacy continuation RED')
            compatibility.append(key)
            expected[key] = wanted
    require(len(supported) == 20 and len(compatibility) == 4, 'own role census')
    changed = {key for key in cold if wire(cold[key]) != wire(expected[key])}
    require(changed == set(supported + compatibility), 'preservation classification')
    return expected, sorted(supported), sorted(compatibility)


def compare_records(actual, expected):
    require(wire(actual) == wire(expected), 'complete route records')


def main():
    seal = json.loads(read(BASE / 'sealed-identities.json'))
    for name, row in seal.items():
        body = read(name)
        require(len(body) == row['bytes'] and digest(body) == row['sha256'], 'sealed bytes')
    completed = ('prepare', 'intake', 'inspect-intake', 'freeze', 'before', 'repair', 'after', 'private-old', 'private-fixed', 'direct')
    for tag in completed:
        prefix = BASE / 'launches' / tag
        require(read(prefix / 'exit.txt') == b'0\n', 'completed outer exit')
        require(gzip.decompress(read(prefix / 'stderr.log.gz')) == b'', 'outer stderr')
        images = capsule(prefix / 'inputs.tar.gz', json.loads(read(prefix / 'identities.json')))
        command = json.loads(read(prefix / 'command.json'))
        require(command['cwd'] == '.' and command['argv'][0:2] == ['bash', 'tools/project_data_run.sh'], 'actual wrapper command')
        require(str(BASE / 'run_stage.py') in images, 'outer producer custody')
        executable = next(argument for argument in command['argv'] if argument.startswith(str(BASE) + '/') and argument.endswith('.py'))
        require(executable in images, 'delegated producer custody')
    phases = ('intake', 'before', 'after', 'private-old', 'private-fixed', 'direct')
    epochs = {phase: epoch(phase) for phase in phases}
    first_root = epochs['intake'][0]
    original_sdk_paths = {name for name in first_root if name.startswith(('julia/', 'tests/fixtures/', 'specs/'))}
    new_sdk_paths = {NORMAL, CASES, PROFILE}
    require(not original_sdk_paths & new_sdk_paths, 'new inputs were untracked at intake')
    cases = json.loads(first_root[str(BASE / 'cases.json')])
    cold = frames(channel('intake', 'native', 'stdout'), 'ARRAY_CONCAT_JULIA')
    expected, supported, compatibility = semantic_oracle(cases, cold)
    baseline = json.loads(read(BASE / 'baseline.json'))
    compare_records(baseline['observed'], cold)
    compare_records(baseline['expected'], expected)
    require(baseline['supported_targets'] == supported and baseline['legacy_operand_compatibility'] == compatibility, 'frozen role census')
    require(baseline['preserved'] == 484 and baseline['original_assertion_failures'] == 96, 'frozen finite assertions')
    require(len(baseline['initial_policy_ids']) == 80 and len(baseline['invalid_signature_ids']) == 8, 'own initial/signature census')
    before_images = capsule(BASE / 'repair-run/before.tar.gz', json.loads(read(BASE / 'repair-run/before.json')))
    after_images = capsule(BASE / 'repair-run/after.tar.gz', json.loads(read(BASE / 'repair-run/after.json')))
    old = b'    return helper == "concat_arrays" && count == 2\n'
    new = b'    return helper == "concat_arrays" && count >= 1\n'
    require(before_images[OWNER].count(old) == 1 and after_images[OWNER] == before_images[OWNER].replace(old, new, 1), 'exact one-line owner repair')
    include = b'include("array_transform_callable_result_guard_composition_test.jl")\n'
    addition = b'include("array_concat_open_arity_result_guard_composition_test.jl")\n'
    require(before_images[RUNNER].count(include) == 1 and after_images[RUNNER] == before_images[RUNNER].replace(include, include + addition, 1), 'exact runner include')
    for name, body in before_images.items():
        require(body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT), 'activation input bytes')
    for phase in phases:
        root, artifacts = epochs[phase]
        sdk_paths = {name for name in root if name.startswith(('julia/', 'tests/fixtures/', 'specs/'))}
        require(sdk_paths == original_sdk_paths | (set() if phase == 'intake' else new_sdk_paths), 'complete SDK/input scope')
        for name in original_sdk_paths - {OWNER, RUNNER, LEGACY, ORDINARY}:
            require(root[name] == first_root[name], 'untouched SDK/input bytes')
        tag = 'native' if phase == 'intake' else 'normal'
        prefix = 'ARRAY_CONCAT_JULIA' if phase == 'intake' else 'ARRAY_CONCAT_JULIA_NORMAL'
        actual = frames(channel(phase, tag, 'stdout'), prefix)
        compare_records(actual, cold if phase in ('intake', 'before', 'private-old') else expected)
        require(list(actual) == [row['id'] for row in cases], 'actual frame census')
        require(len(artifacts) == 1016, 'actual product census')
        packet_prefix = str(BASE / phase)
        for key in actual:
            for folder, suffix in (('parsed', '.json'), ('emitted', '.jl')):
                body = artifacts[packet_prefix + '/' + folder + '/' + key + suffix]
                first = epochs['intake'][1][str(BASE / 'intake' / folder / (key + suffix))]
                require(body == first, 'unchanged parsed/emitted products')
        is_old = phase in ('before', 'private-old')
        require(read(BASE / phase / (tag + '-exit.txt')) == (b'1\n' if is_old else b'0\n'), 'actual SDK exit')
        command = json.loads(read(BASE / phase / (tag + '-command.json')))
        require(command['cwd'] == '.' and command['argv'][:2] == ['bash', 'tools/run_julia_project_data.sh'], 'actual SDK command')
        require(command['environment']['JULIA_NUM_THREADS'] == '1' and command['environment']['OPENBLAS_NUM_THREADS'] == '1', 'serial SDK workers')
        if phase != 'intake':
            require(command['environment']['LINKEDSPEC_ARRAY_CONCAT_JULIA_CAPTURE'] == str(BASE / phase), 'actual generated capture path')
        if phase != 'intake':
            pattern = rb'Julia existing concat arity result guards\s*\|\s*1936\s+96\s+2032\s' if is_old else rb'Julia existing concat arity result guards\s*\|\s*2032\s+2032\s'
            require(re.search(pattern, channel(phase, tag, 'stdout')) is not None, 'actual normal assertion summary')
        sdk = BASE / 'control-owner/julia' if phase.startswith('private-') else Path('julia')
        marker = ('ARRAY_CONCAT_JULIA_OWNER ' + str(sdk / 'src/LinkedSpecJulia.jl') + '\n').encode()
        require(marker in channel(phase, tag, 'stdout'), 'loaded SDK path')
        owner_path = str(BASE / 'control-owner' / OWNER) if phase.startswith('private-') else OWNER
        require(root[owner_path] == before_images[OWNER] if phase in ('intake', 'before', 'private-old') else root[owner_path] == after_images[OWNER], 'actual owner input')
        if phase.startswith('private-'):
            require('--compiled-modules=no' in json.loads(read(BASE / phase / 'normal-command.json'))['argv'], 'private cache disabled')
            prefix = str(BASE / 'control-owner') + '/'
            require({name.removeprefix(prefix) for name in root if name.startswith(prefix)} == sdk_paths, 'private SDK scope')
            for name in sdk_paths - {OWNER}:
                require(root[prefix + name] == root[name], 'same-path private SDK/input identity')
        if phase in ('intake', 'after', 'private-fixed', 'direct'):
            # Successful root precompilation is retained if present. Its bytes
            # are not suppressed and do not establish native cache custody.
            errors = channel(phase, tag, 'stderr')
            require(not errors or (phase == 'after' and b'Precompiling' in errors), 'actual successful SDK stderr')
        for command_tag in ('memory', 'version'):
            require(read(BASE / phase / (command_tag + '-exit.txt')) == b'0\n', 'preflight exit')
        require(channel(phase, 'version', 'stdout') == channel('intake', 'version', 'stdout'), 'actual executable version')
        require(root['specs/user_function_definition.spec'] == first_root['specs/user_function_definition.spec'], 'actual grammar input')
        instrument = root[str(BASE / ('observer.jl' if phase == 'intake' else 'capture.py'))]
        require(instrument, 'actual instrument')
    normal = epochs['after'][0][NORMAL]
    require(normal.index(b'write(path, serialized)') < normal.index(b'from_json(SpecFile,') < normal.index(b'compile_spec(parsed)'), 'parsed first-use order')
    require(normal.index(b'write(path, emitted)') < normal.index(b'Base.include_string(host, emitted)'), 'module first-use order')
    require(epochs['after'][0][CASES] == first_root[str(BASE / 'cases.json')], 'normal authored sources')
    profiles = json.loads(epochs['after'][0][PROFILE])
    compare_records({row['id']: row['expected'] for row in profiles}, expected)
    require({row['id']: row['case'] for row in profiles} == {row['id']: row for row in cases}, 'profile source bindings')
    prior_legacy, next_legacy = json.loads(before_images[LEGACY]), json.loads(after_images[LEGACY])
    for prior, current in zip(prior_legacy, next_legacy):
        wanted = copy.deepcopy(prior)
        if current['id'] in compatibility:
            wanted['expected'] = expected[current['id']]
        require(wire(current) == wire(wanted), 'only exact legacy expected transfer')
    prior_ordinary, next_ordinary = json.loads(before_images[ORDINARY]), json.loads(after_images[ORDINARY])
    wanted_ordinary = copy.deepcopy(prior_ordinary)
    for form in ('free', 'receiver'):
        wanted_ordinary['extra_concat_arrays_' + form].update(expected['ordinary_legacy_extra_concat_arrays_' + form + '_composed'])
    compare_records(next_ordinary, wanted_ordinary)
    for phase in ('after', 'private-old', 'private-fixed', 'direct'):
        require(epochs[phase][0][LEGACY] == after_images[LEGACY] and epochs[phase][0][ORDINARY] == after_images[ORDINARY], 'actual transferred profile inputs')
    direct = channel('direct', 'normal', 'stdout')
    for title, assertions in ((b'Julia callable Array-transform result guards', 1248), (b'Julia ordinary Array-transform result guards', 903), (b'Julia callable Array-pipeline result guards', 776)):
        number = str(assertions).encode()
        require(re.search(re.escape(title) + rb'\s*\|\s*' + number + rb'\s+' + number + rb'\s', direct) is not None, 'direct dependent assertions')
    legacy_direct = frames(direct, 'CALLABLE_TRANSFORM_JULIA_NORMAL')
    compare_records(legacy_direct, {row['id']: row['expected'] for row in next_legacy})
    ordinary_direct = frames(direct, 'ARRAY_TRANSFORM_JULIA_NORMAL')
    for key, profile in next_ordinary.items():
        compare_records(ordinary_direct[key], {route: profile[route] for route in ROUTES})
    pipeline_profiles = json.loads(epochs['direct'][0]['tests/fixtures/array_pipeline_callable_result_guard_julia_profiles.json'])
    compare_records(frames(direct, 'CALLABLE_PIPELINE_JULIA_NORMAL'), {row['id']: row['expected'] for row in pipeline_profiles})
    controls = []

    def reject(label, operation, reason):
        try:
            operation()
        except (AssertionError, KeyError) as failure:
            require(reason in str(failure), 'corruption rejection reason:' + label)
        else:
            raise AssertionError('corruption accepted:' + label)
        controls.append(label)

    actual = copy.deepcopy(expected)
    actual['function_1_free_hash']['native']['value'][1] += 'K'
    reject('Hash operand leak', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(expected)
    actual['function_3_free_later']['fresh']['value'][0] = 'ran'
    reject('later body restart', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(expected)
    nested = next(row['id'] for row in cases if row['origin'] == 'questions108' and row.get('question') == 'nested-kinds')
    require(actual[nested]['native']['value'][2] is False, 'Boolean mutation precondition')
    actual[nested]['native']['value'][2] = 0
    reject('Boolean Number collapse', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(expected)
    error_key = next(key for key, row in actual.items() if 'error_json' in row['native'])
    del actual[error_key]['native']['error_json']
    reject('lost public error JSON', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(expected)
    actual[error_key]['fresh']['error_json']['source_identity'] = 'wrong.spec'
    reject('wrong authored error identity', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(expected)
    first_initial = baseline['initial_policy_ids'][0]
    actual[first_initial]['native']['unexpected'] = None
    reject('invented absent field', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(expected)
    del actual['function_1_free_hash']['fresh']
    reject('missing fresh route', lambda: compare_records(actual, expected), 'complete route records')
    actual = copy.deepcopy(cold)
    del actual['ordinary_1_free_terminal']
    reject('missing terminal program', lambda: semantic_oracle(cases, actual), 'program census')
    actual_cases = copy.deepcopy(cases)
    actual_cases[0]['expected'] = None
    reject('peer verdict import', lambda: semantic_oracle(actual_cases, cold), 'source-only questions')
    altered = copy.deepcopy(json.loads(read(BASE / 'repair-run/after.json')))
    altered[OWNER]['mode'] ^= 0o100
    reject('lost archived filesystem mode', lambda: capsule(BASE / 'repair-run/after.tar.gz', altered), 'capsule full modes')
    print(json.dumps(dict(historical_recovery='PASS', programs=508, routes=4, supported=20,
        legacy_compatibility=4, preserved=484, actual_pairs=6 * 508, direct_assertions=4959,
        reason_sensitive_controls=controls, limits='Retained historical inputs/observations only. No SDK/producer replay, current-code freshness, whole-domain or full native/cache/transitive/toolchain/OS closure. Operational size telemetry retains its own disclosed falsification/durability gaps.')))


if __name__ == '__main__':
    main()
