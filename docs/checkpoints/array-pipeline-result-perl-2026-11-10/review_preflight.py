"""Readonly original Perl pipeline policies, source reads and error distinctions."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-pipeline-result-perl-2026-11-10')
ACTIVATION = 'e6f5a7fae1e6ad23ef4a4a1a4cefb991c0a58f75'
HELPERS = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
RECEIVERS = {helper + '_receiver_hash_guard' for helper in HELPERS}
FREE = {helper + '_free_hash_guard' for helper in HELPERS}
LATER = {'trim_later_with', 'uniq_copy_later_with', 'lower_logical_later_with'}
RED = RECEIVERS | FREE | LATER
META = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
NATIVE_FIELDS = {'detail', 'handler_source_label', 'handler_variant', 'owner_stage', 'rule_label',
    'spec_name', 'spec_path', 'stage', 'summary', 'top_rule', 'type'}
FRESH_FIELDS = {'code', 'detail', 'handler_family', 'rule_label', 'source_identity', 'stage', 'summary', 'type'}


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


def frames(body, tag):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows


def native_error(error, stage, needle):
    assert isinstance(error, dict) and set(error) == NATIVE_FIELDS
    assert error['type'] == 'runtime_handler' and error['stage'] == stage
    assert error['owner_stage'] == 'runtime_handler:' + stage
    assert error['handler_source_label'] == 'LinkedSpec::generated_handler:Value:<none>'
    assert error['handler_variant'] == '<none>' and error['top_rule'] == error['rule_label'] == 'Value'
    assert error['spec_name'] == error['spec_path'] == '' and needle in error['detail']


def needed(row):
    native_error(row['native_error'], 'rule_handler_eval', 'binding_kind_mismatch')
    error = row['fresh_error']
    assert isinstance(error, dict) and set(error) == FRESH_FIELDS
    assert error['type'] == 'generated_source_error' and error['code'] == 'generated_execution_failed'
    assert error['stage'] == 'execute_generated' and error['handler_family'] == 'default'
    assert error['source_identity'] == 'array-pipeline-selection.spec' and error['rule_label'] == 'Value'
    assert error['detail'] == row['native_error']['detail']
    assert row['loaded'] == 1 and row['load_error'] is None


def value(row, expected):
    assert row['loaded'] == 1 and row['load_error'] is None
    assert row['native_error'] is None and row['fresh_error'] is None
    assert same(row['native'], expected) and same(row['fresh'], expected)


def validate(rows, cases, supplement=False):
    assert list(rows) == [case['id'] for case in cases]
    for case in cases:
        key, row = case['id'], rows[case['id']]
        seed = case.get('seed', 'empty')
        host = dict(main=['MAIN', 'TAIL', 'END'] if seed == 'main' else [],
            outer=['OUTER', 'TAIL', 'END'] if seed == 'outer' else [])
        assert row['host_before'] == row['host_after'] == host
        if key.startswith('invalid_pattern_'):
            assert row['native_callable'] == row['loaded'] == 0
            assert row['metadata'] == {name: None for name in META}
            assert row['module_input'] is None and row['handler_input'] is None
            assert all(name not in row for name in ('native', 'native_error', 'fresh', 'fresh_error'))
            error = row['build_context_error']
            assert isinstance(error, dict) and error['type'] == 'compiler_pipeline'
            assert error['stage'] == 'validate_dsl_syntax' and 'Unclosed rule block' in error['detail']
            assert row['emission_error']['code'] == 'generated_source_emit_failed'
            continue
        assert row['native_callable'] == 1
        assert all(row[field] is None for field in ('substitution_error', 'descriptor_error', 'emission_error', 'build_error'))
        meta = dict(META)
        if key in RECEIVERS:
            meta.update(language_agnostic_action_ir_ready=0, unresolved_helper_count=1,
                unresolved_helpers=[key[:-len('_receiver_hash_guard')]])
        elif key == 'needed_split_delimiter_receiver':
            meta.update(language_agnostic_action_ir_ready=0, unresolved_helper_count=1, unresolved_helpers=['split_each'])
        elif key.startswith('extra_'):
            helper = key[len('extra_'):].rsplit('_', 1)[0]
            meta.update(language_agnostic_action_ir_ready=0, unresolved_helper_count=1,
                unresolved_helpers=['with' if key.endswith('_receiver') else helper])
        elif key == 'invalid_range_receiver_composed':
            meta.update(language_agnostic_action_ir_ready=0, unresolved_helper_count=1, unresolved_helpers=['filter_match'])
        assert same(row['metadata'], meta)
        if key in RECEIVERS or key == 'needed_split_delimiter_receiver':
            assert row['loaded'] == 0 and row['native'] is None
            assert 'fresh' not in row and 'fresh_error' not in row
            native_error(row['native_error'], 'rule_handler_compile', 'syntax error')
            assert isinstance(row['load_error'], str) and 'syntax error' in row['load_error']
        elif key in FREE | LATER:
            native_error(row['native_error'], 'rule_handler_eval', 'Not a HASH reference')
            assert row['loaded'] == 1 and row['load_error'] is None
            error = row['fresh_error']; assert isinstance(error, dict) and set(error) == FRESH_FIELDS
            assert error['stage'] == 'execute_generated' and error['code'] == 'generated_execution_failed'
            assert 'Not a HASH reference' in error['detail']
            assert "ref($__ls_set_key_source) ne '' ? %{$__ls_set_key_source}" in row['substitution']
        elif key.startswith('invalid_range_'):
            native_error(row['native_error'], 'rule_handler_compile', 'Invalid [] range')
            assert row['loaded'] == 0 and 'Invalid [] range' in row['load_error']
            assert 'fresh' not in row and 'fresh_error' not in row
        elif case.get('expected_error'):
            needed(row)
        elif case.get('host_literal'):
            expected = ['MAIN', 'TAIL', 'END'] if seed == 'main' else []
            if seed == 'main' and '_lowercase_each_' in key:
                expected = ['main', 'tail', 'end']
            value(row, expected)
            assert '[@3]' in row['substitution']
        elif case.get('host_computed'):
            value(row, [])
            assert '[@3]' not in row['substitution'] and 'ref($__ls_array_value_source)' in row['substitution']
        elif key.startswith('initial_'):
            value(row, [0, 'W'] if key.endswith('_with') else [])
        elif key.startswith('extra_'):
            value(row, [None, ''] if key.endswith('_receiver') else ['ran', 'KW'])
        elif key.startswith('prior_'):
            value(row, [None, ''])
        elif key == 'nested_scalar_kinds':
            value(row, [[False, None, ''], [False, 0, None, '0', '']])
        elif key == 'numeric_array_source':
            value(row, [[3], [3], [3], [3]])
        else:
            value(row, case['expected'])
        assert row['native_cursor'] == 0
        if row['loaded']:
            assert row['fresh_cursor'] == 0


def recover(phase):
    rows = json.loads((ROOT / BASE / phase / 'input-identities.json').read_bytes())
    inputs = {}
    with tarfile.open(ROOT / BASE / phase / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in inputs
            body = archive.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256'] and member.mode & 0o777 == row['mode']
            inputs[member.name] = body
    assert inputs.keys() == rows.keys()
    return inputs


def historical(paths):
    raw = subprocess.check_output(['git', 'cat-file', '--batch'], cwd=ROOT,
        input=''.join(ACTIVATION + ':' + name + '\n' for name in paths).encode())
    position, result = 0, {}
    for name in paths:
        end = raw.index(b'\n', position); header = raw[position:end].split(); assert header[1] == b'blob'
        size = int(header[2]); position = end + 1; result[name] = raw[position:position + size]; position += size + 1
    assert position == len(raw)
    return result


def equal(a, b):
    assert a == b


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name); assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes(); assert len(body) == row['bytes'] and digest(body) == row['sha256']
        if name.endswith('.gz'):
            gzip.decompress(body)
    acquired = json.loads((ROOT / BASE / 'acquired-profiles.json').read_bytes())
    epochs, cases_by_phase, actual_pairs = {}, {}, {}
    all_inputs = {}
    for phase, fixture in (('preflight', 'cases.json'), ('delimiter_controls', 'delimiter-cases.json')):
        inputs = recover(phase); all_inputs[phase] = inputs
        paths = sorted(name for name in inputs if name.startswith('perl/') or name in (
            'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec'))
        assert {name: inputs[name] for name in paths} == historical(paths)
        body = gzip.decompress((ROOT / BASE / phase / 'stdout.log.gz').read_bytes())
        assert gzip.decompress((ROOT / BASE / phase / 'stderr.log.gz').read_bytes()) == b''
        assert (ROOT / BASE / phase / 'exit.txt').read_text() == '0\n'
        assert (ROOT / BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
        cases = json.loads(inputs[str(BASE / fixture)])
        rows = frames(body, 'ARRAY_PIPELINE_PERL'); supplied = frames(body, 'ARRAY_PIPELINE_INPUT')
        validate(rows, cases, phase == 'delimiter_controls')
        assert list(rows) == list(supplied)
        command = json.loads((ROOT / BASE / phase / 'command.json').read_bytes())
        observer = 'observer.pl' if phase == 'preflight' else 'observer_delimiter.pl'
        assert command == dict(cwd='.', argv=['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(BASE / observer), str(BASE / fixture), str(BASE / phase)])
        actual_pairs[phase] = 0
        for case in cases:
            key = case['id']; assert supplied[key]['source'] == case['source']
            for field, raw_field, suffix in (('module_input', 'emitted', 'pm'), ('handler_input', 'handler', 'handler.pl')):
                record = rows[key][field]
                if record is None:
                    assert supplied[key][raw_field] is None
                    continue
                assert record['path'] == str(BASE / phase / (key + '.' + suffix + '.gz'))
                artifact = gzip.decompress((ROOT / record['path']).read_bytes())
                assert digest(artifact) == record['sha256'] and len(artifact) == record['bytes']
                assert artifact == supplied[key][raw_field].encode()
            actual_pairs[phase] += int(rows[key]['module_input'] is not None and rows[key]['handler_input'] is not None)
            if key in acquired:
                profile = acquired[key]
                assert profile['source'] == case['source'] and profile['input'] == case['input']
                projection = {name: value for name, value in rows[key].items() if name not in {'substitution', 'module_input', 'handler_input'}}
                assert same(projection, profile['observation'])
        epochs[phase], cases_by_phase[phase] = rows, cases
    before, supplement = epochs['preflight'], epochs['delimiter_controls']
    cases = cases_by_phase['preflight']; extra = cases_by_phase['delimiter_controls']
    assert len(cases) == 176 and len(extra) == 8 and len(acquired) == 148
    common = json.loads(all_inputs['preflight']['tests/fixtures/array_pipeline_result_guard_cases.json'])
    assert cases[:36] == common and len(RED) == 17
    assert cases[36:134] == json.loads(all_inputs['preflight'][str(BASE / 'profiles-source.json')])
    assert cases[134:] == json.loads(all_inputs['preflight'][str(BASE / 'host-cases.json')])
    assert actual_pairs == {'preflight': 172, 'delimiter_controls': 8}
    assert all(same(before[key]['native'], [None, '']) for key in ('prior_count', 'prior_key_count', 'prior_length', 'prior_view', 'prior_copy', 'prior_array'))
    assert 'binding_kind_mismatch' in supplement['receiver_needed_delimiter_terminal']['native_error']['detail']
    assert 'binding_kind_mismatch' not in before['needed_split_delimiter_receiver']['native_error']['detail']
    assert 'syntax error' in before['needed_split_delimiter_receiver']['native_error']['detail']
    main_reads = [case for case in cases if case.get('host_literal') and case['seed'] == 'main']
    assert len(main_reads) == 14 and all(before[case['id']]['native'] != [] for case in main_reads)
    for row in acquired.values():
        if row['role'] == 'source-defect':
            assert row['seed'] == 'main'
    assert acquired['needed_split_delimiter_receiver']['role'] == 'composition-error-defect'
    assert {key for key, item in acquired.items() if item['role'] == 'source-defect'} == {case['id'] for case in main_reads}
    assert {key for key, item in acquired.items() if item['role'] == 'composition-error-defect'} == {'needed_split_delimiter_receiver'}
    for role, prefix in (('syntax-exclusion', 'invalid_pattern_'), ('arity-exclusion', 'extra_'), ('regex-compile-policy', 'invalid_range_')):
        assert {key for key, item in acquired.items() if item['role'] == role} == {key for key in acquired if key.startswith(prefix)}
    owner = all_inputs['preflight']['perl/LinkedSpec/ActionIR/MethodLowering.pm']
    shortcut = owner[owner.index(b'my $lower_array_value_source_expr = sub'):owner.index(b'my $lower_array_pipeline_value_expr = sub')]
    assert b"return '[@'.$array_symbol.']';" in shortcut and b'_method_value_is_numeric_literal' not in shortcut
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective corruption: ' + name)

    def mutate(key, field, value):
        changed = copy.deepcopy(before); changed[key][field] = value; validate(changed, cases)

    reject('hidden literal host read', lambda: mutate('initial_number_trim_each_free_host_main', 'native', []))
    reject('host mutation concealed', lambda: mutate('initial_number_trim_each_free_host_main', 'host_after', dict(main=[], outer=[])))
    reject('computed source normalized into host read', lambda: mutate('computed_number_trim_each_free_host_main', 'fresh', ['MAIN']))
    error = copy.deepcopy(before['needed_trim_each_source']['native_error']); del error['handler_source_label']
    reject('public error provenance omitted', lambda: mutate('needed_trim_each_source', 'native_error', error))
    reject('needed error masked', lambda: mutate('needed_trim_each_source', 'fresh_error', None))
    reject('missing receiver error reblessed', lambda: mutate('needed_split_delimiter_receiver', 'native_error', supplement['receiver_needed_delimiter_terminal']['native_error']))
    reject('excluded arity effects normalized', lambda: mutate('extra_trim_each_free', 'native', ['ran', 'SAKW']))
    value_wrong = copy.deepcopy(before['nested_scalar_kinds']['native']); value_wrong[0][0] = 0
    reject('Bool converted to Number', lambda: mutate('nested_scalar_kinds', 'native', value_wrong))
    changed = copy.deepcopy(supplement); changed['invalid_range_free_terminal']['fresh_error'] = None
    reject('invented fresh error after failed load', lambda: validate(changed, extra, True))
    reject('actual artifact drift', lambda: equal(before['source_once']['handler_input']['sha256'], digest(gzip.decompress((ROOT / before['source_once']['handler_input']['path']).read_bytes()) + b'\n')))
    return dict(programs=184, original_common=36, common_failures=17, common_preserved=19,
        acquired_profiles=148, source_reads=14, additional_error_target=1,
        actual_artifact_pairs=actual_pairs, effective_corruptions=controls, recovery='PASS',
        scope='Original acquisition only; source79.0 precedes result79.1.1. Exclusions are not new authority; older whitelist fields stay an explicit projection. Full native/cache/transitive/toolchain/context/isolation/registration/23.4 remain separate.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
