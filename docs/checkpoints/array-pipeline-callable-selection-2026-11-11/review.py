"""Readonly recovery of original and qualified callable pipeline selection."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-callable-selection-2026-11-11')
ACTIVATION = '7955c16ca0a98c373dd437284d578e80432b1321'
SHARED = 'tests/fixtures/array_pipeline_callable_result_guard_cases.json'
PERL_CASES = 'tests/fixtures/array_pipeline_callable_perl_selection_cases.json'
HELPERS = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
UNRESOLVED = {name + '_receiver_hash_guard': name for name in HELPERS}
UNRESOLVED.update(trim_later_with='with', uniq_copy_later_with='copy',
    lower_logical_later_with='lowercase_each', needed_source_composed='trim_each',
    needed_delimiter_composed='split_each', initial_number_composed='with',
    initial_null_composed='with', initial_hash_composed='with', invalid_range_receiver_composed='filter_match')
VALUE_FAILURES = {name + '_receiver_hash_guard' for name in HELPERS} | {
    'uniq_copy_later_with', 'lower_logical_later_with', 'needed_source_composed', 'needed_delimiter_composed'}
OMITTED = {'needed_pattern_terminal', 'needed_pattern_composed'}


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
        return a.keys() == b.keys() and all(same(a[key], b[key]) for key in a)
    return a == b


def raw(phase, tag='observer', channel='stdout'):
    return gzip.decompress((ROOT / BASE / phase / (tag + '-' + channel + '.log.gz')).read_bytes())


def frames(body, tag):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


def recover(phase):
    rows = json.loads((ROOT / BASE / phase / 'input-identities.json').read_bytes())
    files = {}
    with tarfile.open(ROOT / BASE / phase / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in files
            body = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
            assert member.mode & 0o777 == row['mode']
            files[member.name] = body
    assert files.keys() == rows.keys()
    return files


def historical(names):
    result = subprocess.run(['git', 'cat-file', '--batch'], cwd=ROOT,
        input=''.join(ACTIVATION + ':' + name + '\n' for name in names).encode(),
        stdout=subprocess.PIPE, check=True)
    position, files = 0, {}
    for name in names:
        end = result.stdout.index(b'\n', position)
        header = result.stdout[position:end].split()
        assert header[1] == b'blob'
        size = int(header[2])
        position = end + 1
        files[name] = result.stdout[position:position + size]
        position += size + 1
    assert position == len(result.stdout)
    return files


def regex_error(row, marker):
    return isinstance(row.get('native_error'), dict) and marker in row['native_error'].get('detail', '') and (
        marker in (row.get('load_error') or '') or marker in (row.get('fresh_error') or {}).get('detail', ''))


def validate(rows, cases, fingerprints, qualified):
    assert list(rows) == [case['id'] for case in cases]
    assert same(rows, fingerprints), 'full observed field retention changed'
    unresolved = dict(UNRESOLVED)
    if not qualified:
        del unresolved['invalid_range_receiver_composed']
        unresolved['needed_pattern_composed'] = 'filter_match'
    bad_values = set()
    for case in cases:
        key, row = case['id'], rows[case['id']]
        assert row['native_callable'] == 1
        assert all(row[field] is None for field in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error'))
        wanted = dict(META)
        if key in unresolved:
            wanted.update(language_agnostic_action_ir_ready=0,
                unresolved_helper_count=1, unresolved_helpers=[unresolved[key]])
        assert row['metadata'] == wanted
        if not qualified and key in OMITTED:
            # Invalid authored eager-pattern expectation is retained, not product RED.
            if key.endswith('_terminal'):
                assert row['loaded'] == 1 and row['native'] == row['fresh'] == []
                assert row['native_error'] is None and row['fresh_error'] is None
            continue
        if case.get('profile_only'):
            assert row['loaded'] == 1 and row['native_error'] is None and row['fresh_error'] is None
            assert row['native'] == row['fresh'] == [[], []]
            continue
        if case.get('expected_regex_error'):
            valid = regex_error(row, case['expected_regex_error'])
        elif case.get('expected_error'):
            valid = row['loaded'] == 1 and all(isinstance(row.get(route + '_error'), dict)
                and case['expected_error'] in row[route + '_error'].get('detail', '') for route in ('native', 'fresh'))
        else:
            valid = row['loaded'] == 1 and all(row.get(route + '_error') is None
                and same(row.get(route), case['expected']) for route in ('native', 'fresh'))
        if not valid:
            bad_values.add(key)
        if key.endswith('_receiver_hash_guard'):
            assert row['loaded'] == 0 and row['native_error']['stage'] == 'rule_handler_compile'
            assert 'fresh' not in row and 'fresh_error' not in row
    assert bad_values == VALUE_FAILURES


def equal(a, b):
    assert a == b


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / path).read_bytes()
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
        if name.endswith('.gz'):
            gzip.decompress(body)
    inputs = {phase: recover(phase) for phase in ('intake', 'qualified')}
    names = sorted(name for name in inputs['intake'] if name.startswith(('perl/', 'specs/')))
    old = historical(names + ['docs/checkpoints/type-operation-inventory/helpers.md'])
    for phase, files in inputs.items():
        assert {name: files[name] for name in names} == {name: old[name] for name in names}
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        for tag in ('version', 'observer'):
            assert (ROOT / BASE / phase / (tag + '-exit.txt')).read_text() == '0\n'
            assert raw(phase, tag, 'stderr') == b''
        command = json.loads((ROOT / BASE / phase / 'observer-command.json').read_bytes())
        observer = 'observer.pl' if phase == 'intake' else 'qualified_observer.pl'
        fixture = 'cases.json' if phase == 'intake' else 'qualified-cases.json'
        assert command == dict(cwd='.', argv=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
            'perl', '-Iperl', str(BASE / observer), str(BASE / fixture), str(BASE / phase)])
    assert raw('intake', 'version') == raw('qualified', 'version')
    original = json.loads(inputs['intake'][str(BASE / 'cases.json')])
    qualified = json.loads(inputs['qualified'][str(BASE / 'qualified-cases.json')])
    assert len(original) == 39 and len(qualified) == 41
    assert qualified[:37] == [case for case in original if case['id'] not in OMITTED]
    assert json.loads((ROOT / SHARED).read_bytes()) == qualified[:37]
    assert json.loads((ROOT / PERL_CASES).read_bytes()) == qualified
    assert all('/[z-a]/' not in case['source'] for case in qualified[:37]), 'unsafe native patterns in shared corpus'
    for case in original + qualified:
        assert case['source'] == 'fn supply(seed) {return(seed)}\n\nValue:: I {' + case['body'] + '}\n'
    fingerprints = json.loads((ROOT / BASE / 'observations.json').read_bytes())
    observations, pairs = {}, {}
    for phase, cases in (('intake', original), ('qualified', qualified)):
        rows = frames(raw(phase), 'ARRAY_PIPELINE_CALLABLE_PERL')
        supplied = frames(raw(phase), 'ARRAY_PIPELINE_CALLABLE_INPUT')
        validate(rows, cases, fingerprints[phase], phase == 'qualified')
        assert list(rows) == list(supplied)
        observations[phase], pairs[phase] = rows, {}
        for case in cases:
            key = case['id']
            assert supplied[key]['source'] == case['source']
            products = []
            for tag, field in (('pm', 'emitted'), ('handler.pl', 'handler')):
                path = str(BASE / phase / (key + '.' + tag + '.gz'))
                body = gzip.decompress((ROOT / path).read_bytes())
                identity = rows[key]['module_input' if tag == 'pm' else 'handler_input']
                assert identity == dict(path=path, sha256=digest(body), bytes=len(body))
                assert body == supplied[key][field].encode()
                products.append(body)
            pairs[phase][key] = products
    for case in qualified[:37]:
        key = case['id']
        expected = copy.deepcopy(observations['intake'][key])
        for tag in ('module_input', 'handler_input'):
            expected[tag]['path'] = expected[tag]['path'].replace('/intake/', '/qualified/')
        assert same(observations['qualified'][key], expected)
        assert pairs['intake'][key] == pairs['qualified'][key]
    pointer = json.loads(inputs['intake'][str(BASE / 'pointer-repair.json')])
    body = old[pointer['path']]
    assert gzip.decompress(inputs['intake'][str(BASE / 'helpers-before.md.gz')]) == body
    assert digest(body) == pointer['before_sha256'] and len(pointer['replacements']) == 2
    for before, after in pointer['replacements']:
        assert body.count(before.encode()) == 1
        body = body.replace(before.encode(), after.encode())
    assert body == inputs['intake'][pointer['path']] == inputs['qualified'][pointer['path']]
    assert digest(body) == pointer['after_sha256']
    owner = inputs['intake']['perl/LinkedSpec/ActionIR/MethodLowering.pm']
    start = owner.index(b'my $ordinary_array_pipeline_result_chain =')
    end = owner.index(b'# Copy and collection results stay together;', start)
    classifier = owner[start:end]
    assert b'_user_function_definition_for_name($deps, $receiver->{name})' in classifier
    assert b'_ordinary_array_pipeline_result_call($calls->[0], 1)' in classifier
    handler = pairs['qualified']['trim_each_receiver_hash_guard'][1]
    assert b'supply([" head "," tail "]).trim_each().set_key({' in handler
    assert b'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with' in pairs['qualified']['trim_later_with'][1]
    assert b'\\{items\\=' in pairs['intake']['needed_pattern_terminal'][1]
    rejected = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(key, field, value):
        changed = copy.deepcopy(observations['qualified'])
        changed[key][field] = value
        validate(changed, qualified, fingerprints['qualified'], True)

    reject('correct value hides unready with', lambda: mutate('trim_later_with', 'metadata', META))
    reject('receiver compile error hidden', lambda: mutate('trim_each_receiver_hash_guard', 'native_error', None))
    reject('invented fresh after failed load', lambda: mutate('trim_each_receiver_hash_guard', 'fresh_error', None))
    reject('consumer effects accepted', lambda: mutate('trim_each_free_hash_guard', 'fresh', [None, 'KV']))
    reject('copy later body hidden', lambda: mutate('uniq_copy_later_with', 'native', [None, '']))
    reject('needed source error masked', lambda: mutate('needed_source_terminal', 'native_error', None))
    wrong = copy.deepcopy(observations['qualified']['needed_source_terminal']['native_error'])
    wrong['owner_stage'] = 'invented_stage'
    reject('full error field lost', lambda: mutate('needed_source_terminal', 'native_error', wrong))
    reject('source evaluated twice', lambda: mutate('source_once', 'native', ['TAIL', 'SS']))
    reject('initial terminal normalized', lambda: mutate('initial_hash_terminal', 'native', [None, None]))
    reject('literal pattern error hidden', lambda: mutate('invalid_range_receiver_terminal', 'load_error', None))
    missing = copy.deepcopy(observations['qualified']); del missing['source_snapshot']
    reject('healthy case omitted', lambda: validate(missing, qualified, fingerprints['qualified'], True))
    reject('actual handler drift', lambda: equal(digest(handler + b'\n'), digest(handler)))
    changed = copy.deepcopy(qualified); changed[0]['expected'] = []
    reject('authored target changed', lambda: validate(observations['qualified'], changed, fingerprints['qualified'], True))
    print(json.dumps(dict(original_programs=39, original_unsupported_pattern_expectations=2,
        qualified_programs=41, shared_safe_programs=37, qualified_targets=16,
        execution_error_failures=11, readiness_only_failures=5, healthy=25,
        original_supported_observations_and_pairs_exact=37, original_artifact_pairs=39,
        qualified_artifact_pairs=41, source_grammar='activation-exact',
        source_qualification='original39 retained; two unsupported eager-pattern expectations replaced only in separate41',
        recovery='PASS', effective_corruptions=rejected,
        limits='Six action-rewriter metadata fields; full observed error/value/warning/absent-field records. Context-free substitution is not a full-source registry oracle. Same-process fresh modules; native/cache/transitive/toolchain custody4.2/SESSION5, shadowing32, source/context/isolation/registration/declared5.4/full23.4 remain separate. Perl41 malformed literals are not the shared safe37 and must not run on unsafe Lua.'), indent=2))


if __name__ == '__main__':
    main()
