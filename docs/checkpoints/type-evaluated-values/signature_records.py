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
    assert c.unchanged(current_sources)
    path = c.PREFIX + 'README.md'
    assert target[path] == composed['before'][path]
    target[path] = current_sources[path]
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
