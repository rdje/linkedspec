"""Immutable result-guard recovery; current SDK freshness is a separate boundary."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11')
INTAKE = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
ACTIVATION = '5f22dae8d3a10cd10f4d2ecfbc6d0be9fd71e172'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = '.linkedspec-data/scratch/callable-pipeline-result-perl/owner.pm'
NORMAL = 't/array_pipeline_callable_result_guard_composition.t'
FIXTURE = 'tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def encoded(value):
    # Python equality conflates Boolean false and Number0; JSON does not.
    return json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=True)


def same(a, b):
    assert encoded(a) == encoded(b)


def recover(phase):
    folder = ROOT / BASE / phase
    rows = json.loads((folder / 'input-identities.json').read_bytes())
    needed = {OWNER, PRIVATE, NORMAL, FIXTURE, str(INTAKE / 'classification.json')}
    bodies, seen = {}, set()
    with tarfile.open(folder / 'inputs-before-use.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in seen; seen.add(member.name)
            raw = archive.extractfile(member).read(); row = rows[member.name]
            assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
            assert member.mode & 0o777 == row['mode']
            if member.name in needed:
                bodies[member.name] = raw
    assert seen == rows.keys()
    return bodies, rows


def channel(phase, name, stream):
    return gzip.decompress((ROOT / BASE / phase / (name + '-' + stream + '.log.gz')).read_bytes())


def parsed(raw, tag):
    rows = {}
    pattern = re.compile(re.escape(tag) + r' (\w+) (\{.*\})$')
    for line in raw.decode().splitlines():
        match = pattern.search(line)
        if match:
            key, body = match.groups(); assert key not in rows
            rows[key] = json.loads(body)
    return rows


def normalized(value):
    if isinstance(value, dict):
        return {key: normalized(item) for key, item in value.items()}
    if isinstance(value, list):
        return [normalized(item) for item in value]
    if isinstance(value, str):
        return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value)
    return value


def projection(row):
    return normalized({key: value for key, value in row.items()
        if key not in ('module_input', 'handler_input', 'substitution')})


def metadata(ready, helper=None):
    return dict(language_agnostic_action_ir_ready=ready, raw_perl_dependency_count=0,
        canonical_action_ir_fallback_count=0, unresolved_helper_count=0 if ready else 1,
        unresolved_helpers=[] if ready else [helper])


def accepted(row, value, ready, helper=None):
    assert row['native_callable'] == row['loaded'] == 1
    for field in ('descriptor_error', 'emission_error', 'build_error', 'native_error', 'load_error', 'fresh_error'):
        assert field in row and row[field] is None, field
    assert row.get('build_context_error') is None
    same(row['native'], value); same(row['fresh'], value)
    same(row['metadata'], metadata(ready, helper))
    same(row['warnings'], [])
    if 'host_before' in row:
        same(row['host_after'], row['host_before'])


def command(phase, name, argv):
    record = json.loads((ROOT / BASE / phase / (name + '-command.json')).read_bytes())
    same(record, dict(cwd='.', argv=argv))


def artifacts(phase, observations, inputs, cases):
    assert inputs.keys() == observations.keys() == cases.keys()
    for key, row in observations.items():
        assert inputs[key]['source'] == cases[key]['source']
        for field, body in (('module_input', 'emitted'), ('handler_input', 'handler')):
            record = row[field]; path = PurePosixPath(record['path'])
            assert not path.is_absolute() and '..' not in path.parts
            assert str(path).startswith(str(BASE / phase) + '/')
            raw = gzip.decompress((ROOT / str(path)).read_bytes())
            assert len(raw) == record['bytes'] and digest(raw) == record['sha256']
            assert raw == inputs[key][body].encode()
        if not row['loaded']:
            assert 'fresh' not in row and 'fresh_error' not in row and 'fresh_cursor' not in row


INSERT = b'''  # Reuse the terminal producer for valid function sources. Invalid signatures
  # retain their existing rejection instead of becoming a valid empty Array.
  my $array_pipeline_receiver_signature_valid = 1;
  if (@$calls > 1 && _ordinary_array_pipeline_result_call($calls->[0], 1)
      && ($receiver->{kind} // '') eq 'call') {
   my $definition = _user_function_definition_for_name($deps, $receiver->{name});
   if (ref($definition) eq 'HASH') {
    my $signature = _user_function_call_signature($definition);
    my $args = $receiver->{args} || [];
    $array_pipeline_receiver_signature_valid = ref($signature) eq 'HASH' && ref($args) eq 'ARRAY'
     && @$args >= $signature->{min_arity}
     && (!defined($signature->{max_arity}) || @$args <= $signature->{max_arity});
   }
  }
'''
NEW_GATE = b'     && $array_pipeline_receiver_signature_valid\n'
OLD_GATE = b"     && !(($receiver->{kind} // '') eq 'call'\n       && _user_function_definition_for_name($deps, $receiver->{name}))\n"


def source_delta(old, current):
    assert current.count(INSERT) == 1 and current.count(NEW_GATE) == 1
    assert current.replace(INSERT, b'', 1).replace(NEW_GATE, OLD_GATE, 1) == old


def profile_result(profile, row):
    if profile['role'] == 'result-target':
        accepted(row, profile['expected'], 1)
    else:
        same(projection(row), profile['expected_observation'])


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        # Original first-use bytes survive exactly in the immutable gzip alias.
        raw = (gzip.decompress((ROOT / BASE / 'first-review.py.gz').read_bytes())
            if name == str(BASE / 'review.py') else (ROOT / name).read_bytes())
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
    for name, row in json.loads((ROOT / BASE / 'qualified-identities.json').read_bytes()).items():
        raw = (ROOT / name).read_bytes()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
    phases = ('intake', 'signatures', 'before', 'after', 'private_old', 'private_current', 'direct_qualified')
    recovered = {phase: recover(phase) for phase in phases}
    before, baseline = recovered['before']
    after, current = recovered['after']
    source_delta(before[OWNER], after[OWNER])
    profiles = json.loads(before[FIXTURE])
    cases = {profile['case']['id']: profile['case'] for profile in profiles}
    assert len(profiles) == len(cases) == 188
    targets = {p['case']['id'] for p in profiles if p['role'] in ('result-target', 'needed-error-target')}
    compatibility = {p['case']['id'] for p in profiles if p['role'] == 'compatibility-readiness'}
    preservation = set(cases) - targets - compatibility
    assert len(targets) == 27 and len(compatibility) == 3 and len(preservation) == 158

    # Compare the complete tracked owned source image, without inspecting dependencies.
    sdk = {name for name in baseline if name.startswith(('perl/', 'specs/'))}
    raw = subprocess.check_output(['git', 'archive', ACTIVATION, 'perl', 'specs'], cwd=ROOT)
    seen = set()
    with tarfile.open(fileobj=io.BytesIO(raw)) as archive:
        for member in archive:
            if member.isfile():
                seen.add(member.name)
                assert digest(archive.extractfile(member).read()) == baseline[member.name]['sha256']
    assert seen == sdk
    for phase, (bodies, rows) in recovered.items():
        assert {name for name in rows if name.startswith(('perl/', 'specs/'))} == sdk
        for name in sdk:
            expected = current[name] if name == OWNER and phase in ('after', 'private_old', 'private_current', 'direct_qualified') else baseline[name]
            same(rows[name], expected)

    observations = {}
    inputs_by_phase = {}
    for phase in ('before', 'after', 'private_old', 'private_current'):
        bodies, rows = recovered[phase]
        assert bodies[NORMAL] == before[NORMAL] and bodies[FIXTURE] == before[FIXTURE]
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        assert (ROOT / BASE / phase / 'complete.txt').is_file()
        red = phase in ('before', 'private_old')
        assert (ROOT / BASE / phase / 'run-exit.txt').read_text() == ('30\n' if red else '0\n')
        assert (ROOT / BASE / phase / 'version-exit.txt').read_text() == '0\n'
        assert channel(phase, 'version', 'stderr') == b''
        command(phase, 'version', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'])
        argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
            'LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE=' + str(BASE / phase), 'perl', '-Iperl']
        if phase.startswith('private_'):
            argv += [str(BASE / 'private_runner.pl'), PRIVATE]
        command(phase, 'run', argv + [NORMAL])
        stdout, stderr = channel(phase, 'run', 'stdout'), channel(phase, 'run', 'stderr')
        failed = set(re.findall(r'^not ok \d+ - (\w+)', stdout.decode(), re.M))
        assert failed == (targets | compatibility if red else set())
        assert re.search(rb'^1\.\.188$', stdout, re.M)
        actual = parsed(stderr, 'CALLABLE_PIPELINE_RESULT_ROW')
        inputs = parsed(stderr, 'CALLABLE_PIPELINE_RESULT_INPUT')
        artifacts(phase, actual, inputs, cases)
        observations[phase] = actual; inputs_by_phase[phase] = inputs
        owners = re.findall(rb'^CALLABLE_PIPELINE_RESULT_OWNER (\{.*\})$', stderr, re.M)
        if phase.startswith('private_'):
            expected = before[OWNER] if phase == 'private_old' else after[OWNER]
            assert bodies[PRIVATE] == expected and len(owners) == 1
            same(json.loads(owners[0]), dict(path=PRIVATE, bytes=len(expected), sha256=digest(expected)))
        else:
            assert not owners

    cold_cases_raw = subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(INTAKE / 'cases.json')], cwd=ROOT)
    cold_cases = {case['id']: case for case in json.loads(cold_cases_raw)}
    assert digest(cold_cases_raw) == recovered['intake'][1][str(INTAKE / 'cases.json')]['sha256']
    extra_raw = (ROOT / BASE / 'signature-cases.json').read_bytes()
    extra_cases = {case['id']: case for case in json.loads(extra_raw)}
    assert digest(extra_raw) == recovered['signatures'][1][str(BASE / 'signature-cases.json')]['sha256']
    cold = {}
    for phase, source_cases in (('intake', cold_cases), ('signatures', extra_cases)):
        rows = parsed(channel(phase, 'run', 'stdout'), 'ARRAY_PIPELINE_CALLABLE_PERL_PERL')
        inputs = parsed(channel(phase, 'run', 'stdout'), 'ARRAY_PIPELINE_CALLABLE_PERL_INPUT')
        artifacts(phase, rows, inputs, source_cases)
        assert (ROOT / BASE / phase / 'run-exit.txt').read_text() == '0\n'
        assert channel(phase, 'run', 'stderr') == b''
        observer = 'observer.pl' if phase == 'intake' else 'signature_observer.pl'
        fixture = INTAKE / 'cases.json' if phase == 'intake' else BASE / 'signature-cases.json'
        command(phase, 'run', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
            str(BASE / observer), str(fixture), str(BASE / phase)])
        assert not cold.keys() & rows.keys(); cold.update(rows)
    assert cold.keys() == cases.keys()
    original_roles = json.loads(subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(INTAKE / 'classification.json')], cwd=ROOT))['roles']
    assert sum(role == 'supported-target' for role in original_roles.values()) == 25
    for profile in profiles:
        key = profile['case']['id']; role = profile['role']
        same(projection(observations['before'][key]), projection(cold[key]))
        same(projection(observations['before'][key]), projection(observations['private_old'][key]))
        same(projection(observations['after'][key]), projection(observations['private_current'][key]))
        for phase in ('after', 'private_current'):
            profile_result(profile, observations[phase][key])
        if role == 'preservation':
            same(projection(observations['after'][key]), projection(cold[key]))
        elif role == 'needed-error-target':
            expected = projection(cold[profile['oracle']]); expected['metadata'] = metadata(1)
            same(profile['expected_observation'], expected)
        elif role == 'compatibility-readiness':
            expected = projection(cold[key]); expected['metadata'] = metadata(1)
            same(profile['expected_observation'], expected)
    # Terminal literal normalization, function signatures and fixed helper arity stay exact.
    protected = {key for key in preservation if original_roles.get(key) in
        ('function-signature-fence', 'arity-prerequisite-observation')
        or cases[key].get('question') == 'invalid-signature'}
    assert len(protected) == 28
    for key in protected:
        assert observations['after'][key]['metadata']['language_agnostic_action_ir_ready'] == 0

    direct = {}
    direct_artifacts = set()
    direct_tests = ('array_pipeline_value_contract', 'variadic_user_function_contract',
        'array_pipeline_result_guard_composition', 'array_pipeline_callable_arity')
    direct_sources = ['t/' + name + '.t' for name in direct_tests] + ['t/phase0_regression.t',
        'tests/fixtures/array_pipeline_result_guard_perl_cases.json',
        'tests/fixtures/array_pipeline_callable_arity_perl_cases.json',
        'capability_conformance/callable_signature_contract.json',
        'capability_conformance/outward_descriptor_contract.json']
    for name in direct_sources:
        raw = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
        assert digest(raw) == recovered['direct_qualified'][1][name]['sha256']
    for tag in ('syntax-module', 'syntax-phase0') + direct_tests:
        assert (ROOT / BASE / 'direct_qualified' / (tag + '-exit.txt')).read_text() == '0\n'
        if tag.startswith('syntax-'):
            target = 'perl/LinkedSpec.pm' if tag == 'syntax-module' else 't/phase0_regression.t'
            command('direct_qualified', tag, ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', '-c', target])
            assert b'syntax OK' in channel('direct_qualified', tag, 'stderr')
            continue
        command('direct_qualified', tag, ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
            'LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE=' + str(BASE / 'direct_qualified'), 'perl', '-Iperl',
            str(BASE / 'direct_runner_qualified.pl'), 't/' + tag + '.t'])
        output = channel('direct_qualified', tag, 'stdout')
        plan = re.findall(rb'^1\.\.(\d+)$', output, re.M)
        assert len(plan) == 1 and not re.search(rb'^not ok ', output, re.M)
        direct[tag] = int(plan[0])
        for match in re.findall(rb'^CALLABLE_PIPELINE_RESULT_DIRECT_ARTIFACT (\{.*\})$', channel('direct_qualified', tag, 'stderr'), re.M):
            row = json.loads(match); path = PurePosixPath(row['path'])
            assert str(path).startswith(str(BASE / 'direct_qualified') + '/') and '..' not in path.parts
            assert str(path) not in direct_artifacts; direct_artifacts.add(str(path))
            body = gzip.decompress((ROOT / str(path)).read_bytes())
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
    assert direct_artifacts

    # The first direct run is retained as an instrumentation failure, never PASS.
    _, failed_inputs = recover('direct')
    failure = json.loads((ROOT / BASE / 'direct-failure/failure.json').read_bytes())
    assert failure['outer_exit'] == 1 and failure['complete_direct_PASS'] is False
    changed = str(BASE / 'review.py')
    assert failure['changed_declared_input'] == changed
    for label in ('before', 'after'):
        raw = gzip.decompress((ROOT / BASE / 'direct-failure' / ('review-' + label + '.py.gz')).read_bytes())
        assert digest(raw) == failure[label + '_sha256']
    assert failed_inputs[changed]['sha256'] == failure['before_sha256']
    assert failure['before_sha256'] != failure['after_sha256']
    for name, row in failed_inputs.items():
        if name != changed:
            assert digest((ROOT / name).read_bytes()) == row['sha256'], name
    failed_tags = ('syntax-module', 'syntax-phase0') + direct_tests[:-1]
    assert set(failure['actual_direct_exits']) == {tag + '-exit' for tag in failed_tags}
    for tag in failed_tags:
        assert failure['actual_direct_exits'][tag + '-exit'] == '0'
        assert (ROOT / BASE / 'direct' / (tag + '-exit.txt')).read_text() == '0\n'
    assert not (ROOT / BASE / 'direct/complete.txt').exists()
    assert not (ROOT / BASE / 'direct/array_pipeline_callable_arity-exit.txt').exists()
    assert changed.encode() in gzip.decompress((ROOT / BASE / 'direct-failure/outer-log.gz').read_bytes())

    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective recovery control: ' + name)

    profile = next(p for p in profiles if p['case']['id'] == 'own_source_before_rejection')
    key = profile['case']['id']; good = observations['after'][key]
    reject('actual old producer loss remains RED', lambda: profile_result(profile, observations['before'][key]))
    bad = copy.deepcopy(good); bad['native'] = [None, '']
    reject('source effect lost', lambda: profile_result(profile, bad))
    bad = copy.deepcopy(good); bad['fresh'] = ['ran', 'SW']
    reject('later with executes after rejection', lambda: profile_result(profile, bad))
    bad = copy.deepcopy(good); bad['metadata'] = metadata(0, 'with')
    reject('unready matching value accepted', lambda: profile_result(profile, bad))
    bad = copy.deepcopy(good); del bad['fresh']
    reject('fresh execution omitted', lambda: profile_result(profile, bad))
    needed = next(p for p in profiles if p['case']['id'] == 'needed_source_composed')
    bad = copy.deepcopy(observations['after'][needed['case']['id']]); bad['native_error']['detail'] = 'masked'
    reject('required source error detail erased', lambda: profile_result(needed, bad))
    bad = copy.deepcopy(observations['after'][needed['case']['id']]); bad['fresh_error']['stage'] = 'wrong_stage'
    reject('generated producer provenance changed', lambda: profile_result(needed, bad))
    pattern = next(p for p in profiles if p['case']['id'] == 'own_pattern_source_block_composed')
    bad = copy.deepcopy(observations['after'][pattern['case']['id']]); bad['native'] = [None, 'P']
    reject('computed pattern body executes', lambda: profile_result(pattern, bad))
    invalid = next(p for p in profiles if p['case']['id'] == 'own_function_arity_missing_composed')
    bad = copy.deepcopy(observations['after'][invalid['case']['id']]); bad['metadata'] = metadata(1)
    reject('invalid function signature admitted', lambda: profile_result(invalid, bad))
    reject('Boolean and Number conflated', lambda: same([False], [0]))
    reject('numeric kind changed to text', lambda: same([3], ['3']))
    reject('private image swapped', lambda: same(digest(recovered['private_old'][0][PRIVATE]), digest(after[OWNER])))
    reject('unrelated source changed', lambda: source_delta(before[OWNER], after[OWNER] + b'\n'))
    bad = copy.deepcopy(good); bad['handler_input']['sha256'] = '0' * 64
    reject('actual handler identity changed', lambda: artifacts('after', {key: bad},
        {key: inputs_by_phase['after'][key]}, {key: cases[key]}))
    return dict(recovery='PASS', normal_groups=len(cases), supported_targets=len(targets),
        original_supported_targets=25, added_variadic_targets=2, compatibility_readiness=len(compatibility),
        preserved_projections=len(preservation), actual_source_pairs=sum(map(len, observations.values())) + len(cold),
        first_direct='input-stability failure retained, no complete PASS', selected_direct_assertions=direct, direct_artifacts=len(direct_artifacts), effective_corruptions=controls,
        limits='Signature-valid registered Perl function pipeline sources reuse exact terminal producers. Three legacy pattern readiness movements grant no eager pattern/first-class regex authority.28 malformed helper/function signature projections remain unready. Five metadata fields/full observed errors/channels. Same-process fresh modules; native/cache/transitive/toolchain4.2/SESSION5/shadowing32/context/isolation/registration/full23.4 remain open.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
