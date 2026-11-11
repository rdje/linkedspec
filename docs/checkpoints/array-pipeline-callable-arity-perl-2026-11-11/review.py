"""Historical readonly recovery; no current SDK execution or freshness assumption."""
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
BASE = Path('docs/checkpoints/array-pipeline-callable-arity-perl-2026-11-11')
INTAKE = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
ACTIVATION = 'd4f430b96bafdf66b85a6d44e5a0c4f9e0d5e7ce'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PRIVATE = '.linkedspec-data/scratch/callable-pipeline-arity-perl/owner.pm'
NORMAL = 't/array_pipeline_callable_arity.t'
FIXTURE = 'tests/fixtures/array_pipeline_callable_arity_perl_cases.json'
REPAIR = '''   # A function receiver supplies the first free-helper operand. Reject a bad
   # initial pipeline signature before legacy folding can manufacture host calls.
   if ($index == 0
       && $method =~ /\\A(?:split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)\\z/o
       && ($call->{source_method} // $method) eq $method
       && ($receiver->{kind} // '') eq 'call'
       && _user_function_definition_for_name($deps, $receiver->{name})) {
    return _actionir_ast_unsupported_helper_expr($method)
     unless defined($ast_aggregate_call_method->($method, 1 + @$aggregate_args));
   }
'''.encode()


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


def projection(value):
    if isinstance(value, dict):
        return {key: projection(item) for key, item in value.items()
                if key not in ('module_input', 'handler_input', 'substitution')}
    if isinstance(value, list):
        return [projection(item) for item in value]
    if isinstance(value, str):
        return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value)
    return value


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


def source_delta(old, current):
    assert current.count(REPAIR) == 1 and current.replace(REPAIR, b'', 1) == old


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        raw = (ROOT / name).read_bytes()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
    recovered = {phase: recover(phase) for phase in ('before', 'after', 'private_old', 'private_current', 'preservation', 'direct')}
    before, baseline = recovered['before']
    after, current = recovered['after']
    profiles = json.loads(before[FIXTURE])
    cases = {row['case']['id']: row['case'] for row in profiles}
    assert len(cases) == len(profiles) == 125
    targets = {key for key in cases if key.endswith('_receiver') and key.startswith(('arity_', 'own_extra_', 'own_missing_'))}
    assert len(targets) == 18
    source_delta(before[OWNER], after[OWNER])
    # The tracked owned Perl/specs source image is bound to activation Git.
    raw = subprocess.check_output(['git', 'archive', ACTIVATION, 'perl', 'specs'], cwd=ROOT)
    sdk = {name for name in baseline if name.startswith(('perl/', 'specs/'))}
    seen = set()
    with tarfile.open(fileobj=io.BytesIO(raw)) as archive:
        for member in archive:
            if not member.isfile():
                continue
            body = archive.extractfile(member).read(); seen.add(member.name)
            assert digest(body) == baseline[member.name]['sha256']
    assert seen == sdk
    observations = {}
    for phase in ('before', 'after', 'private_old', 'private_current'):
        bodies, rows = recovered[phase]
        assert bodies[NORMAL] == before[NORMAL] and bodies[FIXTURE] == before[FIXTURE]
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        assert (ROOT / BASE / phase / 'complete.txt').is_file()
        expected_code = 18 if phase in ('before', 'private_old') else 0
        assert (ROOT / BASE / phase / 'run-exit.txt').read_text() == str(expected_code) + '\n'
        assert (ROOT / BASE / phase / 'version-exit.txt').read_text() == '0\n'
        assert channel(phase, 'version', 'stderr') == b''
        command(phase, 'version', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'])
        argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
            'LINKEDSPEC_CALLABLE_PIPELINE_ARITY_CAPTURE=' + str(BASE / phase), 'perl', '-Iperl']
        if phase.startswith('private_'):
            argv += [str(BASE / 'private_runner.pl'), PRIVATE]
        command(phase, 'run', argv + [NORMAL])
        stdout, stderr = channel(phase, 'run', 'stdout'), channel(phase, 'run', 'stderr')
        failed = set(re.findall(r'^not ok \d+ - (\w+)', stdout.decode(), re.M))
        assert failed == (targets if expected_code else set())
        assert re.search(rb'^1\.\.125$', stdout, re.M)
        rows_seen = parsed(stderr, 'CALLABLE_PIPELINE_ARITY_ROW')
        inputs = parsed(stderr, 'CALLABLE_PIPELINE_ARITY_INPUT')
        artifacts(phase, rows_seen, inputs, cases)
        observations[phase] = rows_seen
        owners = re.findall(rb'^CALLABLE_PIPELINE_ARITY_OWNER (\{.*\})$', stderr, re.M)
        if phase.startswith('private_'):
            assert len(owners) == 1
            expected = before[OWNER] if phase == 'private_old' else after[OWNER]
            assert bodies[PRIVATE] == expected
            same(json.loads(owners[0]), dict(path=PRIVATE, bytes=len(expected), sha256=digest(expected)))
        else:
            assert not owners
    for phase, (bodies, rows) in recovered.items():
        assert {name for name in rows if name.startswith(('perl/', 'specs/'))} == sdk
        for name in sdk:
            expected = current[name] if phase != 'before' and name == OWNER else baseline[name]
            same(rows[name], expected)
    for profile in profiles:
        key = profile['case']['id']
        for phase in ('after', 'private_current'):
            accepted(observations[phase][key], profile['expected'], profile['ready'], profile.get('helper'))
        same(projection(observations['before'][key]), projection(observations['private_old'][key]))
        same(projection(observations['after'][key]), projection(observations['private_current'][key]))
        if key not in targets:
            same(projection(observations['before'][key]), projection(observations['after'][key]))
    # Nine independently observed terminal free calls are the arity oracle.
    for key in sorted(k for k in targets if k.startswith('arity_')):
        helper = re.fullmatch(r'arity_(?:extra|missing)_(.*)_receiver', key)[1]
        free = observations['before'][key.removesuffix('_receiver') + '_free']
        accepted(free, [None, ''], 0, helper)
        assert observations['before'][key]['metadata']['language_agnostic_action_ir_ready'] == 1
    old_classification = json.loads(before[str(INTAKE / 'classification.json')])
    assert before[str(INTAKE / 'classification.json')] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(INTAKE / 'classification.json')], cwd=ROOT)
    preserved = parsed(channel('preservation', 'run', 'stdout'), 'ARRAY_PIPELINE_CALLABLE_PERL_PERL')
    preserved_inputs = parsed(channel('preservation', 'run', 'stdout'), 'ARRAY_PIPELINE_CALLABLE_PERL_INPUT')
    original_cases = json.loads(subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(INTAKE / 'cases.json')], cwd=ROOT))
    artifacts('preservation', preserved, preserved_inputs, {row['id']: row for row in original_cases})
    assert len(preserved) == 178
    changed = {key for key, role in old_classification['roles'].items() if role == 'arity-prerequisite-observation' and key.endswith('_receiver')}
    assert len(changed) == 9
    assert sum(role == 'supported-target' for role in old_classification['roles'].values()) == 25
    for key, row in preserved.items():
        if key in changed:
            helper = re.fullmatch(r'own_(?:extra|missing)_(.*)_receiver', key)[1]
            accepted(row, [None, ''], 0, helper)
        else:
            same(projection(row), projection(old_classification['observations'][key]))
    assert (ROOT / BASE / 'preservation/run-exit.txt').read_text() == '0\n'
    assert channel('preservation', 'run', 'stderr') == b''
    command('preservation', 'version', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'])
    command('preservation', 'run', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
        str(BASE / 'preservation_observer.pl'), str(INTAKE / 'cases.json'), str(BASE / 'preservation')])
    direct = {}
    direct_artifacts = set()
    for name in ('t/array_pipeline_value_contract.t', 't/variadic_user_function_contract.t', 't/phase0_regression.t',
                 'capability_conformance/callable_signature_contract.json', 'capability_conformance/outward_descriptor_contract.json'):
        raw = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
        assert digest(raw) == recovered['direct'][1][name]['sha256']
    for tag in ('syntax-module', 'syntax-phase0', 'array_pipeline_value_contract', 'variadic_user_function_contract'):
        assert (ROOT / BASE / 'direct' / (tag + '-exit.txt')).read_text() == '0\n'
        output = channel('direct', tag, 'stdout')
        if tag.startswith('syntax-'):
            target = 'perl/LinkedSpec.pm' if tag == 'syntax-module' else 't/phase0_regression.t'
            command('direct', tag, ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', '-c', target])
            assert b'syntax OK' in channel('direct', tag, 'stderr')
            continue
        command('direct', tag, ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
            'LINKEDSPEC_CALLABLE_PIPELINE_ARITY_CAPTURE=' + str(BASE / 'direct'), 'perl', '-Iperl',
            str(BASE / 'direct_runner.pl'), 't/' + tag + '.t'])
        plan = re.findall(rb'^1\.\.(\d+)$', output, re.M)
        assert len(plan) == 1 and not re.search(rb'^not ok ', output, re.M)
        direct[tag] = int(plan[0])
        for match in re.findall(rb'^CALLABLE_PIPELINE_ARITY_DIRECT_ARTIFACT (\{.*\})$', channel('direct', tag, 'stderr'), re.M):
            row = json.loads(match); path = PurePosixPath(row['path'])
            assert str(path).startswith(str(BASE / 'direct') + '/') and '..' not in path.parts
            assert str(path) not in direct_artifacts; direct_artifacts.add(str(path))
            body = gzip.decompress((ROOT / str(path)).read_bytes())
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
    assert direct_artifacts
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)

    key = 'arity_missing_split_each_receiver'
    good = observations['after'][key]
    reject('actual baseline receiver remains RED', lambda: accepted(observations['before'][key], [None, ''], 0, 'split_each'))
    bad = copy.deepcopy(good); bad['metadata']['language_agnostic_action_ir_ready'] = 1
    reject('false readiness hidden', lambda: accepted(bad, [None, ''], 0, 'split_each'))
    bad = copy.deepcopy(good); bad['native_error'] = 'Undefined subroutine __array_value_split_each'
    reject('private helper execution leak', lambda: accepted(bad, [None, ''], 0, 'split_each'))
    bad = copy.deepcopy(good); bad['native'] = [None, 'S']
    reject('source effect executed', lambda: accepted(bad, [None, ''], 0, 'split_each'))
    bad = copy.deepcopy(good); bad['fresh'] = [None, 'W']
    reject('later with effect executed', lambda: accepted(bad, [None, ''], 0, 'split_each'))
    bad = copy.deepcopy(good); del bad['fresh']
    reject('fresh route omitted', lambda: accepted(bad, [None, ''], 0, 'split_each'))
    reject('Boolean and Number conflated', lambda: same([False], [0]))
    reject('Number and text conflated', lambda: same([3], ['3']))
    reject('unrelated source edit', lambda: source_delta(before[OWNER], after[OWNER] + b'\n'))
    reject('private image swapped', lambda: same(digest(recovered['private_old'][0][PRIVATE]), digest(after[OWNER])))
    healthy = next(key for key in preserved if old_classification['roles'][key] == 'supported-target'
                   and preserved[key]['metadata']['language_agnostic_action_ir_ready'] == 0)
    bad = projection(preserved[healthy]); bad['native_error'] = None; bad['metadata'] = metadata(1)
    reject('pending result defect silently normalized', lambda: same(bad, projection(old_classification['observations'][healthy])))
    return dict(recovery='PASS', normal_groups=125, receiver_RED_groups=18, healthy_projections=107,
        original_programs=178, changed_receiver_arities=9, original_other_projections=169,
        actual_normal_and_preservation_pairs=sum(map(len, observations.values())) + len(preserved), selected_direct_assertions=direct,
        direct_artifacts=len(direct_artifacts), effective_corruptions=controls,
        limits='First canonical pipeline call on registered Perl function receivers only. Free terminal rejection is the oracle; malformed free composed records remain unready excluded observations.25 result gaps remain pending. Five metadata fields, complete observed errors/channels/source artifacts; same-process fresh modules. Native/cache/transitive/toolchain4.2/SESSION5/shadowing32/context/isolation/registration/full23.4 remain open.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
