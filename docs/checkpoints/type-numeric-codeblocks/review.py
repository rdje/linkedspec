"""Readonly review: recover actual epochs, recheck retained observations, run current proof."""
import json
import re
import subprocess
import sys
from pathlib import Path
import common as c
import doc_final as book
import oracle_final as oracle
import phase0_after
import startup


def objects():
    return {path.name: c.load(path.name) for path in sorted((c.ROOT / c.PREFIX).iterdir())
            if path.is_file() and path.name.endswith(('.json', '.json.gz'))
            and not path.name.startswith('publication')}


def recover_epochs(records):
    """Draft bytes come from packets, never an invented historical Git revision."""
    pool, identities, git_inputs = {}, [], []

    def walk(value):
        if isinstance(value, dict):
            if {'base64', 'sha256', 'mode'} <= value.keys():
                raw = c.decode(value['base64'])
                assert c.sha(raw) == value['sha256']
                assert isinstance(value['mode'], int) and 0 <= value['mode'] <= 0o7777
                pool[(value['sha256'], value['mode'])] = raw
            inputs = value.get('inputs')
            if isinstance(inputs, dict) and inputs and all(isinstance(item, dict)
                    and {'sha256', 'mode'} <= item.keys() for item in inputs.values()):
                identities.extend(inputs.items())
            git_inputs.extend(value.get('git_inputs', []))
            for child in value.values():
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    for value in records.values():
        walk(value)
    current, git, seen = {}, {}, set()
    for path, item in identities:
        key = (path, item['sha256'], item['mode'])
        if key in seen:
            continue
        seen.add(key)
        assert not Path(path).is_absolute() and '..' not in Path(path).parts
        if path not in current:
            current[path] = c.identity(path) if (c.ROOT / path).is_file() else None
        if current[path] == {name: item[name] for name in ('sha256', 'mode')}:
            continue
        if (item['sha256'], item['mode']) in pool:
            continue
        if path not in git:
            git[path] = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.sha(git[path]) == item['sha256'], ('unrecoverable epoch', path, item)
    for item in git_inputs:
        raw = c.decode(item['base64'])
        assert c.sha(raw) == item['sha256']
        assert raw == subprocess.check_output(['git', 'show', item['revision'] + ':' + item['path']], cwd=c.ROOT)
        mode = subprocess.check_output(['git', 'ls-tree', item['revision'], '--', item['path']], cwd=c.ROOT).split()[0]
        assert mode.decode() == item['git_mode']
    return len(seen)


def passed(run, quiet=True):
    assert run['returncode'] == 0, run['command']
    if quiet:
        assert not c.decode(run['stderr_base64']), run['command']


def tap(run):
    passed(run)
    output = c.decode(run['stdout_base64'])
    found = re.search(rb'Files=(\d+), Tests=(\d+),', output)
    assert found and b'Result: PASS' in output
    return tuple(map(int, found.groups()))


def knowledge(run):
    passed(run, quiet=False)
    assert not c.decode(run['stdout_base64'])
    assert c.decode(run['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'


def retained_phase0(run, plan):
    passed(run)
    result = phase0_after.summary(run)
    assert result['passing'] and result['complete_selection']
    assert result['selected'] == result['wanted'] == len(plan['selected']) == 3
    assert result['root_tests'] == plan['ordinary_root_tests'] == 1035
    # Actual historical output retains its original absolute runtime location. The producer
    # checked exact root identity then; relocation must not turn that dated path into project data.
    assert result['loaded_method_lowering'].endswith('/perl/LinkedSpec/ActionIR/MethodLowering.pm')
    return result


def prior(records):
    saved = records['prior.json.gz']
    path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json'
    assert c.decode(saved['claim']['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
    original = json.loads(c.decode(saved['claim']['base64']))
    manifest = json.loads(c.decode(saved['manifest']['base64']))
    publication = json.loads(c.decode(saved['publication']['base64']))
    tree = {}
    for row in subprocess.check_output(['git', 'ls-tree', '-rz', c.BASE], cwd=c.ROOT).split(b'\0'):
        if row:
            metadata, name = row.split(b'\t', 1)
            mode, kind, oid = metadata.decode().split()
            tree[name.decode()] = dict(mode=mode, kind=kind, oid=oid)
    assert publication['record_base64'] == saved['claim']['base64']
    assert manifest['inputs'] == {path: {key: item[key] for key in ('sha256', 'mode')}
                                for path, item in saved['inputs'].items()}
    for name, item in saved['inputs'].items():
        assert item['git'] == tree[name]
        raw = subprocess.check_output(['git', 'cat-file', 'blob', item['git']['oid']], cwd=c.ROOT)
        assert c.sha(raw) == item['sha256']
    assert c.decode(saved['baseline']['status']['base64']).strip() == b'0'
    assert b'2179 closed inputs; 30 GREEN; 19 baseline RED' in c.decode(saved['baseline']['log']['base64'])
    retired, qualified = records['prior-retirement.json.gz'], records['prior-qualification.json.gz']
    assert retired['claim_before'] == saved['claim']
    historical = json.loads(c.decode(retired['claim_after']))
    expected = json.loads(json.dumps(original))
    for claim in expected['claims']:
        claim['durability'].update(mode='historical', revision=c.BASE)
    assert historical == expected
    assert qualified['claim_before']['base64'] == retired['claim_after']
    assert (c.ROOT / path).read_bytes() == c.decode(qualified['claim_after'])
    qualified_record = json.loads(c.decode(qualified['claim_after']))
    for old, new in zip(historical['claims'], qualified_record['claims']):
        assert new['scope'].startswith(old['scope']) and 'not established' in new['scope']
        assert {key: value for key, value in old.items() if key != 'scope'} == {
            key: value for key, value in new.items() if key != 'scope'}
    assert retired['readme_after'] == qualified['readme_before']['base64']
    assert (c.ROOT / 'docs/checkpoints/type-scoped-with/README.md').read_bytes() == c.decode(qualified['readme_after'])
    replay = records['prior-focused-run.json.gz']
    assert replay['inputs_unchanged'] and tap(replay['run']) == (14, 1924)
    assert len(records['prior-focused-inputs.json.gz']['inputs']) == 10000
    fault, control = records['prior-focused-producer-observed.json.gz'], records['prior-focused-controls.json.gz']
    assert fault['run']['returncode'] != 0 and control['inputs_restored']
    raw = c.decode(control['original_probe']['base64'])
    assert c.sha(raw.replace(c.decode(fault['before']), c.decode(fault['after']), 1)) == fault['mutant_sha256']
    passed(control['restored'])
    assert control['missing_input_denied']['observed']  # synthetic omission; distinct from producer fault
    assert records['prior-focused-restoration.json']['restored']
    return len(saved['inputs'])


def runtime(records, fresh):
    epochs = [('red', 'red', 'red', 114), ('effect', 'effect-red', 'effect-red', 16),
              ('stability-red', 'stability-red', 'stability-reviewed', 5),
              ('receiver-red', 'receiver-red', 'receiver-red', 34),
              ('mixed-red', 'mixed-red', 'mixed-red', 9)]
    populations, failures = [], []
    for input_name, run_name, review_name, count in epochs:
        inputs = records[input_name + '-inputs.json']
        result = records[run_name + '-run.json.gz']
        assert result['inputs_unchanged']
        bad = oracle.mismatches(result['run'], inputs['plan'], inputs['inputs'])
        assert bad == records[review_name + ('.json' if review_name == 'stability-reviewed' else '-review.json')]['failures']
        assert len(bad) == count
        populations.extend(case['id'] for case in inputs['plan']['cases'])
        failures.extend(bad)
    assert len(populations) == len(set(populations)) == 318
    assert len(failures) == 178  #169 accepted-source RED plus9 separately observed C1 mixed-chain RED
    for epoch, count in [('candidate1', 298), ('candidate2', 318)]:
        inputs = records[epoch + '-inputs.json']
        result = records[epoch + '-run.json.gz']
        assert result['inputs_unchanged'] and len(inputs['plan']['cases']) == count
        assert not oracle.mismatches(result['run'], inputs['plan'], inputs['inputs'])
    current = records['candidate2-inputs.json']
    assert current['sources'] == {path: c.read(path) for path in current['sources']}
    assert set(populations) == {case['id'] for case in current['plan']['cases']}
    if fresh:
        run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(current['plan']).encode())
        assert not oracle.mismatches(run, current['plan'], current['inputs'])
    return current


def faults(records, current):
    inputs = records['fault-inputs.json.gz']
    assert inputs['sources'] == {path: c.read(path) for path in inputs['sources']}
    cases = {case['id']: case for case in current['plan']['cases']}
    results = {}
    for task in inputs['tasks']:
        name = task['name']
        observed, result = records['fault-' + name + '-observed.json.gz'], records['fault-' + name + '.json.gz']
        expected = {path: c.decode(inputs['sources'][path]['base64']) for path in {item['path'] for item in task['changes']}}
        for item in task['changes']:
            before, after = c.decode(item['before']), c.decode(item['after'])
            assert expected[item['path']].count(before) == 1
            expected[item['path']] = expected[item['path']].replace(before, after, 1)
        assert observed['mutant'] == {path: dict(sha256=c.sha(raw), mode=inputs['sources'][path]['mode'])
                                      for path, raw in expected.items()}
        assert result['run'] == observed['run'] and result['syntax'] == observed['syntax']
        passed(result['syntax'], quiet=False)
        if 'command' in task:
            bad = re.findall(r"Failed test '([^']+)'", c.decode(result['run']['stderr_base64']).decode())
            assert result['run']['returncode'] != 0
            passed(result['restored'])
        else:
            plan = dict(cases=[cases[name] for name in task['cases']])
            bad = oracle.mismatches(result['run'], plan, inputs['inputs'])
            assert not oracle.mismatches(result['restored'], plan, inputs['inputs'])
        assert bad == result['failures'] and set(task['required_red']) <= set(bad)
        assert result['sources_restored'] and result['inputs_restored']
        results[name] = bad
    assert results == records['fault-review.json']['faults'] and len(results) == 13
    full = records['fault-full-restoration.json.gz']
    assert full['inputs_restored'] and not oracle.mismatches(full['run'], current['plan'], inputs['inputs'])
    return {name: len(bad) for name, bad in results.items()}


def consumers(records):
    controls = records['phase0-controls.json.gz']
    plan = records['phase0-before-inputs.json']['plan']
    assert retained_phase0(controls['restored'], plan)['selected'] == 3
    assert len(controls['numeric_observer_failures']) == 21
    assert set(controls['numeric_observer_failures']) <= set(controls['observer_failures'])
    observed = records['phase0-observer-observed.json.gz']
    assert observed['run']['returncode'] != 0
    raw = c.decode(records['phase0-after-inputs.json']['test']['base64'])
    assert c.sha(raw.replace(c.decode(observed['before']), c.decode(observed['after']), 1)) == observed['mutant_sha256']
    missing = phase0_after.summary(controls['missing'])
    assert controls['missing']['returncode'] != 0 and missing['selected'] == 0 and missing['wanted'] == 1
    goldens = records['phase0-golden-run.json.gz']
    values = {}
    for name, run in goldens['runs'].items():
        passed(run)
        values[name] = {row['id']: row['observation'] for row in json.loads(c.decode(run['stdout_base64']))['rows']}
        assert len(values[name]) == 21
    broken = [name for name, value in values['original'].items() if 'error' in value]
    assert len(broken) == 1 and not any('error' in value for value in values['corrected'].values())
    assert all(value == values['corrected'][name] for name, value in values['original'].items() if name not in broken)
    assert len(records['phase0-migration.json.gz']['changes']) == 21
    assert len(records['ast-proposals.json.gz']['changes']) == 4
    passed(records['ast-after-run.json.gz']['run'])
    passed(records['legacy-run.json.gz']['run'])
    legacy = records['legacy-consumer-proposals.json.gz']
    assert all(c.read(path) == packet for path, packet in legacy['historical_inputs'].items())
    final = records['focused-final-run.json.gz']
    inputs = records['focused-final-inputs.json.gz']
    assert final['inputs_unchanged'] and [run['command'] for run in final['runs']] == inputs['commands']
    assert all(run['returncode'] == 0 for run in final['runs'])
    assert tap(final['runs'][6]) == (17, 1962)
    assert retained_phase0(final['runs'][-1], plan)['selected'] == 3
    assert len(inputs['inputs']) == 10006
    # The final runtime/test consumers remain byte-identical; final documentation has its own epoch.
    current_surfaces = {path: item for path, item in inputs['inputs'].items()
                        if path.startswith(('perl/', 't/', 'tests/', 'tools/', 'scripts/', 'contracts/'))}
    assert c.unchanged(current_surfaces)
    migration = records['phase0-migration.json.gz']
    ast = records['ast-proposals.json.gz']
    assert (c.ROOT / 't/phase0_regression.t').read_bytes() == c.decode(migration['after'])
    assert (c.ROOT / 't/actionir_ast_parser.t').read_bytes() == c.decode(ast['after'])
    ordinary = records['test-proposals.json.gz']
    terminal = records['terminal-proposals.json.gz']
    assert ordinary['after'] == terminal['test_before']['base64']
    assert (c.ROOT / 't/scalar_numeric_contract.t').read_bytes() == c.decode(terminal['test_after'])
    expected = {path: c.decode(raw) for path, raw in legacy['after'].items()}
    refinement = records['legacy-refinement.json.gz']
    for path, packet in refinement['before'].items():
        if path in expected:
            assert expected[path] == c.decode(packet['base64'])
        expected[path] = c.decode(refinement['after'][path])
    assert all((c.ROOT / path).read_bytes() == raw for path, raw in expected.items())
    assert c.read('tests/numeric-codeblocks/legacy-consumers.json') == legacy['fixture']


def documentation(records, fresh):
    expected = {}
    for name in ('docs-proposals.json.gz', 'docs-clarity.json.gz', 'overload-docs.json.gz'):
        epoch = records[name]
        for path, packet in epoch['before'].items():
            if path in expected:
                assert expected[path] == c.decode(packet['base64'])
            expected[path] = c.decode(epoch['after'][path])
    assert all((c.ROOT / path).read_bytes() == raw for path, raw in expected.items())
    inputs, result = records['doc-final-inputs.json.gz'], records['doc-final-run.json.gz']
    assert inputs['book'] == book.book_inputs() and inputs['examples'] == book.examples()
    assert result['inputs_unchanged']
    knowledge(result['knowledge'])
    assert not oracle.mismatches(result['examples'], inputs['examples'], inputs['inputs'])
    for name, build in result['builds'].items():
        book.validate(build, inputs['examples'], name == 'changed')
    if fresh:
        knowledge(c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh']))
        run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(inputs['examples']).encode())
        assert not oracle.mismatches(run, inputs['examples'], inputs['inputs'])
        for changed in (False, True):
            book.validate(book.render(inputs['book'], changed), inputs['examples'], changed)
    return len(inputs['book'])


def review(fresh=True):
    records = objects()
    recovered = recover_epochs(records)
    old = prior(records)
    current = runtime(records, fresh)
    actual_faults = faults(records, current)
    consumers(records)
    book_count = documentation(records, fresh)
    intake = records['startup-inputs.json.gz']
    actual = records['startup-run.json.gz']
    assert intake['plan'] == startup.PLAN and actual['inputs_unchanged']
    assert not oracle.mismatches(actual['run'], startup.PLAN, intake['inputs'])
    if fresh:
        run = c.run(['perl', '-Iperl', c.PREFIX + 'startup_probe.pl'], input=json.dumps(startup.PLAN).encode())
        assert not oracle.mismatches(run, startup.PLAN, intake['inputs'])
    return dict(result='PASS', runtime_cases=318, accepted_baseline_red=169, accepted_controls=129,
        additional_c1_cases=20, additional_c1_red=9, faults=actual_faults, retained_suites=17,
        retained_tap=1962, focused_inputs=10006, prior_inputs=old, prior_replay_suites=14,
        prior_replay_tap=1924, prior_replay_inputs=10000, book_inputs=book_count, book_examples=3,
        recoverable_epoch_identities=recovered, exact_startup_intake_cases=2,
        limits='Finite Perl scalar repair. Fresh318/native/generated and book proof;17/1962 and14/1924 '
               'are retained actual executions with separate complete contexts, not fresh suite runs. '
               'Original prior4 context is qualified, not retroactively reconstructed. Draft bytes recover '
               'from packets; accepted unchanged bytes from real203cde315. External core toolchains are '
               'read-only prerequisites. Aggregates7, generated drop6 and startup20/32/35/87.4 remain owned. '
               'Canonical receipt separately admits the exact candidate; no exhaustive/backend/parent claim.')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--retained'])
    print(json.dumps(review(fresh=not sys.argv[1:]), sort_keys=True))
