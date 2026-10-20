"""Review the separate proposal chain and recoverable focused-source snapshot."""
import gzip
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'


def load(name):
    raw = (c.ROOT / (P + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def current_proposals(inputs, original):
    preserved = load('preservation.json.gz')
    docs = load('docs-proposals-final.json.gz')
    aligned = load('proposals-final.json.gz')
    fixture = load('fixture-proposals.json.gz')
    original_graph = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'graph-inputs.json.gz')).read_bytes()))['inputs']
    target = dict(original['proposals'])
    for path, item in docs['before'].items():
        assert item == target.get(path, preserved['before'].get(path)), path
    target.update(docs['after'])
    for path, item in aligned['before'].items():
        assert item == inputs[path]
    target.update(aligned['after'])
    for path, item in fixture['before'].items():
        assert item == target.get(path, original_graph.get(path)), path
    target.update(fixture['after'])
    assert docs['producer'] == c.read(P + 'docs_final.py')
    assert aligned['producer'] == c.read(P + 'align_final.py')
    assert fixture['producer'] == c.read(P + 'fixture_fix.py')
    admission = json.loads(gzip.decompress(
        (c.ROOT / 'docs/checkpoints/type-values-admission/portable-proposals.json.gz').read_bytes()))
    path = c.PREFIX + 'README.md'
    assert target[path] == admission['before'][path]
    target[path] = admission['after'][path]
    preserved = signature_load('preservation.json.gz')
    first = signature_load('proposals.json.gz')
    assert first['producer'] == c.read(S + 'apply.py')
    assert c.read('t/phase0_regression.t') == first['phase0_after']
    for path, item in first['before'].items():
        expected = target.get(path, inputs.get(path, preserved['before'].get(path)))
        assert item == expected, path
    target.update(first['after'])
    fixed = signature_load('control-fix.json.gz')
    assert fixed['producer'] == c.read(S + 'fix_control.py')
    for path, item in fixed['before'].items():
        assert target[path] == item, path
    target.update(fixed['after'])
    docs = signature_load('docs-proposals.json.gz')
    assert docs['producer'] == c.read(S + 'docs.py')
    for path, item in docs['before'].items():
        assert item == target.get(path, original_graph.get(path)), path
    target.update(docs['after'])
    composed = signature_load('compose-proposals.json.gz')
    assert composed['producer'] == c.read(S + 'compose.py')
    finished = signature_load('finish-proposals.json.gz')
    assert finished['producer'] == c.read(S + 'finish.py')
    for path, item in finished['before'].items():
        assert composed['after'][path] == item, path
    current_sources = dict(composed['after'], **finished['after'])
    polished = signature_load('polish-proposals.json.gz')
    assert polished['producer'] == c.read(S + 'polish.py')
    for path, item in polished['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(polished['after'])
    required_composed = required_load('compose-proposals.json.gz')
    assert required_composed['producer'] == c.read(R + 'compose.py')
    for path, item in required_composed['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(required_composed['after'])
    warning = required_load('warning-proposals.json.gz')
    assert warning['producer'] == c.read(R + 'warning_fix_final.py')
    old_support = required_load('closure.json')['inputs']
    for path, item in warning['before'].items():
        if path in current_sources:
            assert current_sources[path] == item, path
        elif path == 't/lib/LinkedSpecTest/EmittedValues.pm':
            assert required_load('source-fix.json.gz')['after'][path] == item
        else:
            assert all(item[key] == old_support[path][key] for key in ('sha256', 'mode')), path
    current_sources.update(warning['after'])
    selected = selector_load('compose-proposals.json.gz')
    assert selected['producer'] == c.read(Q + 'compose.py')
    for path, item in selected['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(selected['after'])
    finished_selector = selector_load('finish-proposals.json.gz')
    assert finished_selector['producer'] == c.read(Q + 'finish.py')
    for path, item in finished_selector['before'].items():
        if path in current_sources:
            assert current_sources[path] == item, path
        else:
            assert path == Q + 'partition_storage.py'
            assert selector_load('partition-copy.json')['reader'] == item
    current_sources.update(finished_selector['after'])
    formatted_selector = selector_load('format-proposals.json.gz')
    assert formatted_selector['producer'] == c.read(Q + 'format.py')
    for path, item in formatted_selector['before'].items():
        assert current_sources[path] == item, path
    current_sources.update(formatted_selector['after'])
    assert c.unchanged(current_sources)
    path = c.PREFIX + 'README.md'
    assert target[path] == composed['before'][path]
    target[path] = current_sources[path]
    for name, producer in (('proposals.json.gz', 'apply.py'),
                           ('source-fix.json.gz', 'fix_source.py'),
                           ('docs-proposals.json.gz', 'docs.py')):
        change = required_load(name)
        assert change['producer'] == c.read(R + producer)
        for path, item in change['before'].items():
            assert item == target.get(path, inputs.get(path, original_graph.get(path))), path
        target.update(change['after'])
    path = 't/lib/LinkedSpecTest/EmittedValues.pm'
    assert target[path] == warning['before'][path]
    target[path] = warning['after'][path]
    for name, producer in (('proposals.json.gz', 'apply.py'),
                           ('docs-proposals.json.gz', 'docs.py')):
        change = selector_load(name)
        assert change['producer'] == c.read(Q + producer)
        for path, item in change['before'].items():
            assert item == target.get(path, inputs.get(path, original_graph.get(path))), path
        target.update(change['after'])
    assert c.unchanged(target)
    return target


def summary(run):
    output = c.decode(run['stdout_base64'])
    marker = b'# FOCUSED_PHASE0_JSON '
    assert output.count(marker) == 1
    return json.loads(output.split(marker)[1].splitlines()[0])


def focused_result(run, wanted):
    actual = summary(run)
    assert run['returncode'] == 0 and actual['passing'] and actual['complete_selection']
    assert actual['selected'] == actual['wanted'] == 52 and actual['root_tests'] == 1035
    assert actual['skipped'] == 982
    text = c.decode(run['stdout_base64']).decode()
    roots = {int(number): line for line, number in re.findall(r'^(ok (\d+)[^\n]*)$', text, re.M)}
    assert len(roots) == 1035 and not re.search(r'^not ok \d+', text, re.M)
    assert sum(bool(re.search(r'#\s*skip\b', line, re.I)) for line in roots.values()) == 982
    for row in wanted:
        line = roots[row['number']]
        assert line.startswith('ok ' + str(row['number']) + ' - ' + row['name'])
        assert not re.search(r'#\s*skip\b', line, re.I)
    return actual


def verify_focused(fresh):
    snapshot = load('focused-final-inputs.json.gz')
    observed = load('focused-final-run.json.gz')
    record = load('focused-final-review.json')
    raw = (c.ROOT / snapshot['base_capsule']['path']).read_bytes()
    assert c.sha(raw) == snapshot['base_capsule']['sha256']
    supplied = json.loads(gzip.decompress(raw))['inputs']
    supplied.update(snapshot['overrides'])
    assert set(supplied) == set(snapshot['identities'])
    for path, item in supplied.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        assert {key: item[key] for key in ('sha256', 'mode')} == snapshot['identities'][path]
    # Root continuity and the derived map may advance after the frozen observation.
    # Current runtime, test and fixture bytes remain exactly the measured candidate.
    for path, item in supplied.items():
        if path.startswith(('perl/', 't/', 'tests/', 'bin/', 'specs/', 'conf/', 'tablescript/', 'ebnf/', 'capability_conformance/')):
            if path == 'tests/language-readiness/verify_objectives.py':
                # The focused snapshot retains its original auditor. Its later
                # owned source-integrity inverse has independent complete proof.
                assert item == signature_load('proposals.json.gz')['before'][path]
                assert c.read(path) == signature_load('control-fix.json.gz')['after'][path]
            elif path in required_load('proposals.json.gz')['before']:
                first = required_load('proposals.json.gz')
                fixed = required_load('source-fix.json.gz')
                assert item == first['before'][path], path
                assert c.read(path) == fixed['after'].get(path, first['after'][path]), path
            else:
                assert c.read(path) == item, path
    actual = focused_result(observed['run'], snapshot['positive']['selected'])
    relative = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    tail = Path(relative).parts
    assert Path(actual['loaded_method_lowering']).parts[-len(tail):] == tail
    display = dict(actual, loaded_method_lowering=relative)
    assert record['actual'] == display and record['result'] == 'PASS'
    assert observed['inputs_bytes_modes_unchanged'] and len(supplied) == record['inputs']
    denied = summary(observed['missing_selector'])
    assert observed['missing_selector']['returncode'] != 0
    assert not denied['complete_selection'] and denied['selected'] == 0 and denied['wanted'] == 1
    if fresh:
        with tempfile.TemporaryDirectory(prefix='type-values-focused-', dir=os.environ['TMPDIR']) as directory:
            root = Path(directory)
            assert root.stat().st_dev == c.ROOT.stat().st_dev
            for path, item in supplied.items():
                target = root / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(c.decode(item['base64']))
                target.chmod(item['mode'])
            temporary = root / '.linkedspec-data/tmp'
            temporary.mkdir(parents=True)
            environment = dict(os.environ, TMPDIR=str(temporary),
                GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
                GIT_WORK_TREE=str(root), GIT_OPTIONAL_LOCKS='0')
            command = ['perl', '-Iperl', P + 'focused.pl']
            result = subprocess.run(command, cwd=root, env=environment,
                input=json.dumps(snapshot['positive']).encode(), capture_output=True)
            run = dict(command=command, returncode=result.returncode,
                       stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
            repeated = focused_result(run, snapshot['positive']['selected'])
            loaded = Path(repeated['loaded_method_lowering'])
            if not loaded.is_absolute():
                loaded = root / loaded
            assert loaded.resolve() == (root / 'perl/LinkedSpec/ActionIR/MethodLowering.pm').resolve()
            for path, item in supplied.items():
                assert (root / path).read_bytes() == c.decode(item['base64'])
                assert (root / path).stat().st_mode & 0o7777 == item['mode']
    return dict(result='PASS', selected=52, skipped=982, ordinary_root_plan=1035,
        snapshot_inputs=len(supplied), missing_selector_red=True,
        scope='Frozen complete-input focused snapshot; ordinary all1035 is separately canonical admission.')


def verify_supplement(fresh):
    focused = verify_focused(fresh)
    oracle = load('oracle-observed-review.json')
    raw = load('oracle-observed-run.json.gz')['run']
    assert oracle['result'] == 'PASS' and oracle['value_cases'] == 130
    assert raw['returncode'] == 0 and oracle['actual_raw_advisories'] == 2
    rows = json.loads(c.decode(raw['stdout_base64']))['rows']
    assert len(rows) == 130 and all(row['error'] is None for row in rows)
    assert c.decode(raw['stderr_base64']).decode() == ''.join(w for row in rows for w in row['warnings'])
    public = load('warning-routes-run.json.gz')
    assert public['runtime_inputs_unchanged']
    run = public['run']
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    marker = b'\nSOURCE_TYPE_MODEL_JSON '
    assert output.count(marker) == 1 and output.startswith(marker)
    row = json.loads(output.split(marker)[1])['rows'][0]
    assert all(row[route]['ok'] for route in ('descriptor', 'live', 'generated'))
    assert row['live']['value'] == row['generated']['value']['value'] == {'kind': 'node'}
    assert set(row['warning_routes']) == {'generated'} and len(row['warning_routes']['generated']) == 1
    advisory = 'Scalar value @__ls_drop{"debug"} better written as $__ls_drop{"debug"}'
    assert row['warning_routes']['generated'][0].startswith(advisory + ' at (eval ')
    assert not row['generated_fatal']['ok'] and row['generated_fatal']['error'].startswith(advisory)
    assert 'delete @__ls_drop{"debug"}' in row['generated']['value']['source']
    return dict(focused=focused, historical_manual_goldens=130, explicit_compiler_advisories=2,
        public_generated_drop_warning=1, fatal_generated_load='RED; separately owned by .1.2.6')


S = 'docs/checkpoints/type-values-signature/'


def signature_load(name):
    raw = (c.ROOT / (S + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def verify_signature_history(fresh):
    preserved = signature_load('preservation.json.gz')
    first = signature_load('proposals.json.gz')
    fixed = signature_load('control-fix.json.gz')
    assert fixed['before'] == {'tests/language-readiness/verify_objectives.py':
                              first['after']['tests/language-readiness/verify_objectives.py']}
    assert c.unchanged(fixed['after'])
    failed = signature_load('historical-run.json.gz')['run']
    assert failed['returncode'] == 1 and b"KeyError: 'historical'" in c.decode(failed['stderr_base64'])
    original_inputs = signature_load('historical-inputs.json')
    assert original_inputs['current_auditor'] == first['after']['tests/language-readiness/verify_objectives.py']
    assert original_inputs['instrument'] == c.read(S + 'capture.py')
    for path, item in original_inputs['inputs'].items():
        expected = first['after'][path] if path == 'tests/language-readiness/verify_objectives.py' else c.read(path)
        assert all(expected[key] == item[key] for key in ('sha256', 'mode')), path
    plan = signature_load('historical-final-inputs.json')
    observed = signature_load('historical-final-run.json.gz')
    grade = signature_load('historical-final-review.json')
    assert grade['result'] == 'PASS' and grade['input_bytes_modes_unchanged']
    assert observed['producer'] == c.read(S + 'capture_corrected.py')
    assert plan['instrument'] == c.read(S + 'capture_corrected.py')
    for path, item in plan['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    run = observed['run']
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    actual = json.loads(c.decode(run['stdout_base64']))
    assert set(actual['tracked_inputs']) == set(plan['proof_inputs'])
    assert all(actual['tracked_inputs'][path] == plan['inputs'][path]['sha256'] for path in plan['proof_inputs'])
    assert actual['isolated_deterministic_capture']
    assert actual['healthy_audit_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
    assert actual['restored_inputs'] == grade['restored_inputs'] == 134
    assert actual['restored_bytes'] == grade['restored_bytes'] == 84613241
    assert len(actual['controls']) == grade['recovery_controls'] == 22
    assert grade['original_verifier_red'] == first['original_verifier_red'] == 'unreviewed signature-regression drift: t/phase0_regression.t'
    addition = 3 * first['hunks']
    assert grade['fragments'] == first['hunks'] == 70
    assert grade['added_source_denials'] == addition
    isolated_plan = signature_load('baseline-isolated-inputs.json')
    isolated = signature_load('baseline-isolated-run.json.gz')
    command = signature_load('baseline-isolated-command.json')
    assert isolated_plan['producer'] == isolated['producer'] == c.read(S + 'baseline_isolated.py')
    assert command['instrument'] == c.read(S + 'baseline_isolated.py')
    assert command['retention_producer'] == c.read(S + 'finish.py')
    assert command['returncode'] == 0 and c.decode(command['status']['base64']).strip() == b'0'
    assert isolated['result'] == 'PASS' and isolated['calibration']
    assert isolated['healthy_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
    assert isolated['current_inputs_bytes_modes_unchanged'] and isolated['restored_inputs_bytes_modes_unchanged']
    assert isolated['report'] == observed['baseline_report']
    assert isolated['controls'] == observed['baseline_controls']
    assert isolated['restored_inputs'] == 134 and isolated['restored_bytes'] == 84613241
    assert len(isolated_plan['restored']) == 134
    for path, item in isolated_plan['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    assert grade['original_controls'] == observed['baseline_controls']
    assert grade['current_controls'] == actual['audit_controls']
    assert grade['current_controls']['governance_mutations_rejected'] == grade['original_controls']['governance_mutations_rejected'] + addition
    for path, count in grade['original_controls']['governance_mutations_by_source'].items():
        assert grade['current_controls']['governance_mutations_by_source'][path] == count + (addition if path == 't/phase0_regression.t' else 0)
    fault = signature_load('table-final-control.json')
    table = (c.ROOT / 'tests/language-readiness/evaluated-value-regression-evolution.json').read_bytes()
    changed = c.decode(fault['changed_base64'])
    assert changed == table[:-1] + b' ' and table.endswith(b'\n')
    assert json.loads(changed) == json.loads(table) and changed != table
    assert fault['observed_red'] == grade['table_identity_red'] == 'evaluated-value inverse table identity mismatch: t/phase0_regression.t'
    assert fault['producer'] == c.read(S + 'capture_corrected.py')
    if fresh:
        repeated = c.run(['bash', 'tools/run_python_project_data.sh',
            'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'])
        assert repeated['returncode'] == 0 and not c.decode(repeated['stderr_base64'])
        assert json.loads(c.decode(repeated['stdout_base64'])) == actual
        for path, item in plan['inputs'].items():
            assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    return dict(result='PASS', fragments=grade['fragments'], added_denials=addition,
        original_denials=grade['original_controls']['governance_mutations_rejected'],
        current_denials=grade['current_controls']['governance_mutations_rejected'],
        restored_inputs=134, restored_bytes=84613241, recovery_controls=22,
        explicit_proof_inputs=len(plan['proof_inputs']), table_identity_red=True,
        original_baseline_isolated=True, first_control_key_error_retained=True)


R = 'docs/checkpoints/type-values-required/'
sys_path = str(c.ROOT / R)
import sys
sys.path.insert(0, sys_path)
import capsules
required_load = capsules.load


def verify_required(fresh):
    preserved = required_load('preservation.json.gz')
    baseline = required_load('baseline.json')
    assert baseline['returncode'] == 0 and baseline['claim'] == preserved['original_claim']
    original = json.loads(c.decode(preserved['original_claim']['base64']))
    assert len(original['claims'][0]['durability']['inputs']) == 823
    assert preserved['canonical']['returncode'] == 1
    first = required_load('proposals.json.gz')
    assert c.read('perl/LinkedSpec/ActionIR/MethodLowering.pm') == first['current_module']
    failed = required_load('focused-run.json.gz')
    assert failed['run']['returncode'] == 1
    assert len(re.findall(r'^not ok \d+', c.decode(failed['run']['stdout_base64']).decode(), re.M)) == 3
    final = required_load('focused-final-run.json.gz')
    assert final['run']['returncode'] == 0 and final['inputs_bytes_modes_unchanged']
    assert 'Files=12, Tests=5001,' in c.decode(final['run']['stdout_base64']).decode()
    controls = required_load('controls-complete-run.json.gz')
    grade = required_load('controls-complete-review.json')
    plan = required_load('controls-complete-inputs.json.gz')
    assert grade['result'] == 'PASS' and grade['native_inputs'] == 15
    assert controls['producer'] == c.read(R + 'control_capture_complete.py')
    assert controls['main_inputs_bytes_modes_unchanged']
    assert controls['controls']['returncode'] == 0
    assert '1..14' in c.decode(controls['controls']['stdout_base64']).decode()
    assert [row['name'] for row in controls['runs']] == ['healthy', 'mapper-bypass', 'restored']
    assert [row['returncode'] for row in controls['runs']] == [0, 1, 0]
    for row in controls['runs']:
        assert row['supplied_bytes_modes_unchanged']
        text = c.decode(row['stdout_base64']).decode()
        assert 'Files=12, Tests=5001,' in text
        failures = len(re.findall(r'^not ok \d+', text, re.M))
        assert failures == (198 if row['name'] == 'mapper-bypass' else 0)
    assert grade['mapper_bypass_failed_assertions'] == 198
    assert c.sha(c.decode(plan['fault']['base64'])) == plan['fault']['sha256']
    for path, item in plan['inputs'].items():
        assert c.sha(c.decode(item['base64'])) == item['sha256'], path
        assert capsules.read_version(path, item) == item, path
    recovery = required_load('capsule-recovery.json')
    assert recovery['result'] == 'PASS' and len(recovery['rows']) == 2
    for row in recovery['rows']:
        assert capsules.read_version(row['path'], row)['sha256'] == row['sha256']
    closure = required_load('closure-final.json')
    for path, item in closure['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    warning_green = required_load('warning-run.json.gz')
    assert warning_green['producer'] == c.read(R + 'warning_capture_final.py')
    assert warning_green['inputs_bytes_modes_unchanged']
    assert warning_green['run']['returncode'] == 0
    assert not c.decode(warning_green['run']['stderr_base64'])
    assert 'Files=12, Tests=5001,' in c.decode(warning_green['run']['stdout_base64']).decode()
    assert warning_green['syntax']['returncode'] == 0
    assert not c.decode(warning_green['syntax']['stderr_base64'])
    if fresh:
        repeated = c.run(['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
                         'prove', '-v', '-Iperl'] + plan['selected'])
        assert repeated['returncode'] == 0
        assert 'Files=12, Tests=5001,' in c.decode(repeated['stdout_base64']).decode()
        assert not c.decode(repeated['stderr_base64'])
        native = c.run(['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', R + 'controls_final.pl'])
        assert native['returncode'] == 0 and '1..14' in c.decode(native['stdout_base64']).decode()
    return dict(result='PASS', files=12, assertions=5001, native_controls=14,
                mapper_red=198, frozen_native_inputs=15, prior_direct_inputs=823,
                current_stderr_bytes=0, test_stub_warning_repaired=True,
                scope='Original4998 plus3 goldens; full supplied healthy/fault/restored '
                      'execution. First incomplete closure/control and census guard remain '
                      'rejected preparation. New support inputs have a closed hash manifest; '
                      'all823 previous direct bindings remain. No native capture refresh.')


Q = 'docs/checkpoints/type-values-selector/'
sys.path.insert(0, str(c.ROOT / Q))
import partition_storage as storage
storage.install_legacy(c, capsules)
selector_load = storage.load


def verify_selector(fresh):
    saved = selector_load('preservation.json.gz')
    baseline = selector_load('baseline.json')
    assert baseline['claim'] == saved['original_claim']
    assert baseline['run']['returncode'] == 0 and baseline['inputs_bytes_modes_unchanged']
    original = json.loads(c.decode(saved['original_claim']['base64']))
    assert len(original['claims'][0]['durability']['inputs']) == 837
    assert len(c.decode(saved['original_claim']['base64'])) == 130737
    proposal = selector_load('proposals.json.gz')
    assert c.unchanged(proposal['after'])
    grade = selector_load('scanner-review.json')
    observed = selector_load('scanner-run.json.gz')
    assert grade['result'] == 'PASS' and observed['inputs_bytes_modes_unchanged']
    assert observed['producer'] == c.read(Q + 'capture.py')
    for index in (0, 4):
        run = observed['runs'][index]['run']
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
        value = json.loads(c.decode(run['stdout_base64']))
        assert not value['unexpected'] and value['healthy_controls'] == 6 and value['rejection_controls'] == 28
    for row, expected in zip(observed['runs'][1:4], (9, 6, 3)):
        assert row['run']['returncode'] == 1 and not c.decode(row['run']['stderr_base64'])
        assert len(json.loads(c.decode(row['run']['stdout_base64']))['unexpected']) == expected
    assert all(run['returncode'] == 0 for run in observed['public'])
    history = selector_load('history-review.json')
    assert history['result'] == 'PASS' and history['denials'] == 4
    assert history['actual_payload_guard_red'] == 1
    copy = selector_load('partition-copy.json')
    removed = selector_load('partition-removal.json')
    context = selector_load('partition-context.json')
    controls = selector_load('partition-controls-review.json')
    assert copy['result'] == removed['result'] == controls['result'] == 'PASS'
    assert copy['parts'] == 31 and len(copy['originals']) == 2
    assert context['run']['returncode'] == 0 and context['restored']
    assert selector_load('partition-use-context.json')['result'] == 'PASS'
    assert controls['rejected_controls'] == 10 and controls['actual_whole_hash_fault'] == 2
    for row in copy['originals']:
        assert not (c.ROOT / row['path']).exists()
        raw, mode = storage.read_bytes(row['path'])
        assert c.sha(raw) == row['sha256'] and len(raw) == row['size'] and mode == row['mode']
    assert removed['residue_count'] == 0 and removed['removed_bytes'] == 500733803
    closure = selector_load('closure-final.json')
    for path, item in closure['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    # The final closed source inventory precedes fresh global scans. Earlier finite
    # controls retain their original context; no initial global manifest is invented.
    namespace = dict(__file__=str(c.ROOT / 'tools/check_executable_aggregate_selector_sources.py'),
                     __name__='selector_inventory')
    exec(compile(c.decode(c.read('tools/check_executable_aggregate_selector_sources.py')['base64']),
                 'tools/check_executable_aggregate_selector_sources.py', 'exec'), namespace)
    eligible = sorted(path for path in namespace['candidate_files']()
                      if Path(path).suffix not in namespace['EXCLUDED_SUFFIXES']
                      and (c.ROOT / path).is_file())
    assert eligible == closure['scanner_candidates']
    if fresh:
        for command in closure['commands']:
            run = c.run(command)
            assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), run
        for path, item in closure['inputs'].items():
            assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
    return dict(result='PASS', fixtures=3, denials=28, producer_faults=[9, 6, 3],
                original_readonly_inputs=837, original_readonly_bytes=130737,
                partitioned_streams=2, chunks=31, removed_duplicate_bytes=500733803,
                storage_denials=10, whole_hash_producer_red=2,
                historical_metadata_denials=4, historical_metadata_producer_red=1,
                scanner_candidates=len(eligible), closed_inputs=len(closure['inputs']),
                limits='Original837 logical inputs survive. One formerly direct physical '
                       'artifact is replaced by an index and gated chunks. Original '
                       'scanner bytes were explicitly supplied only for retained-use proof; '
                       'current scanner semantics have separate controls and fresh scans.')
