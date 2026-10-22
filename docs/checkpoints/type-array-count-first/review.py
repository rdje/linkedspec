"""Re-derive the bounded selection and continuity proof without source writes."""
import json
import subprocess
import common as c
import custody
import doc_proof as book
import direct as focused
import oracle


def history():
    value = c.load('history-result.json.gz')
    assert value['after_registry'] == c.read('doctrine/readme_stability/routes.jsonl')
    assert value['adr'] == c.read('docs/decisions/0137-finite-selection-history-members.md')
    assert value['after_index'] == c.read('docs/decisions/INDEX.md')
    for surface,item in value['rollovers'].items():
        pressure = c.load(surface+'-pressure.json.gz')
        assert pressure['run']['returncode'] != 0
        assert b'rollover required' in c.decode(pressure['run']['stderr_base64'])
        assert item['applied']['returncode'] == item['checked']['returncode'] == 0
        entry = item['entry']
        root = entry['current_path']
        original = subprocess.check_output(['git','show',c.BASE+':'+root],cwd=c.ROOT)
        assert entry['source_commit'] == c.BASE and entry['source_path'] == root
        assert entry['source_blob'] == subprocess.check_output(['git','rev-parse',c.BASE+':'+root],cwd=c.ROOT).decode().strip()
        assert c.sha(original) == item['combined_original_sha256']
        assert pressure['before']['base64'] == c.encode(original)
        packet,record = item['current'],pressure['record']
        for name in ('history-doc-addendum.json.gz','history-doc-addendum2.json.gz','history-doc-addendum3.json.gz'):
            addendum = c.load(name)['surfaces'][surface]
            assert addendum['before'] == packet and addendum['old_record'] == record
            raw = c.decode(packet['base64'])
            assert raw.count(record.encode()) == 1
            assert c.decode(addendum['after']['base64']) == raw.replace(record.encode(),addendum['new_record'].encode(),1)
            assert packet['mode'] == addendum['after']['mode']
            packet,record = addendum['after'],addendum['new_record']
        assert c.read(root) == packet
        archived = c.source(entry['target_path']).read_bytes()
        assert c.read(entry['target_path']) == item['segment']
        assert archived == b''.join(original.splitlines(keepends=True)[entry['source_start_line']-1:entry['source_end_line']])
        assert c.sha(archived) == entry['sha256'] and len(archived) == entry['byte_count']
        retained = c.source(root).read_bytes().replace(record.encode(),b'',1)
        prefix = original[:-len(archived)]
        separator = c.decode(item['separator_base64'])
        assert retained == prefix.rstrip(b'\n')+b'\n'
        assert separator == prefix[len(retained):]
        assert retained+separator+archived == original
        family = 'changes' if surface == 'change_history' else 'development-notes'
        manifest = 'docs/history/'+family+'/manifest.jsonl'
        assert c.read(manifest) == item['manifest']
        current_rows = c.source(manifest).read_bytes().splitlines(keepends=True)
        old_rows = c.decode(pressure['manifest_before']['base64']).splitlines(keepends=True)
        assert current_rows[2:] == old_rows[1:]
        for path,identity in item['old_members'].items():
            if path != manifest:
                assert c.identity(path) == identity
        old,new = value['old'][surface],value['new'][surface]
        assert new['limits'] == dict(old['limits'],max_files=old['limits']['max_files']+1)
        expected = dict(old['member_limits'])
        expected[manifest] = dict(max_bytes=c.source(manifest).stat().st_size,max_lines=len(current_rows))
        assert new['member_limits'] == expected
    refusal = c.load('history-old-cap.json.gz')['run']
    assert refusal['returncode'] != 0
    expected_errors = set()
    for surface in value['rollovers']:
        old,new = value['old'][surface],value['new'][surface]
        family = 'changes' if surface == 'change_history' else 'development-notes'
        manifest = 'docs/history/'+family+'/manifest.jsonl'
        expected_errors.add(f"[readme-routing] FAIL: surface {surface} exceeds control: files {new['limits']['max_files']}/{old['limits']['max_files']}")
        for name,unit in [('max_lines','lines'),('max_bytes','bytes')]:
            expected_errors.add(f"[readme-routing] FAIL: surface {surface} member exceeds control: {unit} {new['member_limits'][manifest][name]}/{old['member_limits'][manifest][name]}")
    actual_errors = {line for line in c.decode(refusal['stderr_base64']).decode().splitlines()
        if line.startswith('[readme-routing] FAIL: ')}
    assert actual_errors == expected_errors
    old,new = value['old']['decisions']['limits'],value['new']['decisions']['limits']
    lines = c.source('docs/decisions/0137-finite-selection-history-members.md').read_bytes().count(b'\n')+1
    assert new == dict(old,max_files=old['max_files']+1,max_total_lines=old['max_total_lines']+lines)
    return {key:dict(files=item['files'],lines=item['lines'],segment=item['entry']['segment_id'])
        for key,item in value['rollovers'].items()}


def verify_phase0():
    plan = c.load('phase0-plan.json.gz')['plan']
    summaries = {}
    normalization = c.load('phase0-path-normalization.json.gz')
    draft2 = c.load('draft2.json.gz')
    for stem in ('phase0-accepted','phase0-candidate'):
        run = c.load(stem+'-run.json.gz')
        result = c.load(stem+'-result.json')
        assert run['inputs_unchanged'] and run['plan'] == plan
        marker = b'# FOCUSED_PHASE0_JSON '
        out = c.decode(run['run']['stdout_base64'])
        assert out.count(marker) == 1
        actual = json.loads(out.split(marker)[1].splitlines()[0])
        changed = normalization['summaries'][stem]
        assert changed['before'] == draft2['context']['overrides'][changed['path']]
        assert changed['after'] == c.read(changed['path'])
        original = json.loads(c.decode(changed['before']['base64']))
        assert original['summary'] == actual
        original['summary']['loaded_method_lowering'] = c.SOURCES[1]
        assert original == result and actual['complete_selection']
        assert actual['selected'] == len(plan['selected']) and actual['root_tests'] == plan['ordinary_root_tests']
        assert run['run']['returncode'] == (1 if stem.endswith('accepted') else 0)
        if stem.endswith('accepted'):
            assert set(result['failed']) == {row['number'] for row in plan['selected']}
        else:
            assert not result['failed'] and actual['passing'] and not c.decode(run['run']['stderr_base64'])
        summaries[stem] = actual
    assert summaries['phase0-accepted']['skipped'] == summaries['phase0-candidate']['skipped']
    admission = c.load('phase0-admission.json.gz')
    for path,packet in admission['after'].items():
        assert c.read(path) == packet
    table_path = 'tests/language-readiness/count-first-regression-evolution.json'
    assert c.read(table_path) == admission['table']
    table = json.loads(c.source(table_path).read_bytes())
    before = subprocess.check_output(['git','show',c.BASE+':'+table['source']],cwd=c.ROOT)
    rebuilt = before
    for row in table['hunks']:
        old,new = row['before'].encode(),row['after'].encode()
        assert rebuilt.count(old) == 1 and old != new
        rebuilt = rebuilt.replace(old,new,1)
    assert c.sha(before) == table['before_sha256'] and c.sha(rebuilt) == table['after_sha256']
    assert rebuilt == c.source(table['source']).read_bytes()
    current = c.load('history-final-run.json.gz')
    assert current['inputs_unchanged'] and current['run']['returncode'] == 0
    assert not c.decode(current['run']['stderr_base64'])
    historical = json.loads(c.decode(current['run']['stdout_base64']))
    result = c.load('history-final-result.json')
    assert result['added'] == 3*len(table['hunks']) and result['current'] == result['previous']+result['added']
    assert historical['audit_controls']['governance_mutations_rejected'] == result['current']
    assert historical['healthy_audit_guard'] == dict(original_log_attempts=0,tracked_write_attempts=0)
    assert historical['tracked_inputs'][table_path] == c.identity(table_path)['sha256']
    faults = c.load('history-faults-result.json')
    assert all(faults[key] for key in ('inverse_bypass_rejected','table_byte_change_rejected',
        'actual_hash_bypass_admitted','restored_hash_rejected','sources_restored'))
    values = {}
    for stem in ('healthy','inverse-fault','inverse-restored','table-red','hash-fault','hash-restored','final'):
        run = c.load('history-unit-'+stem+'-run.json.gz')
        assert run['inputs_unchanged'] and not c.decode(run['run']['stderr_base64'])
        value = json.loads(c.decode(run['run']['stdout_base64']))
        assert run['run']['returncode'] == (0 if value['completed'] else 1)
        supplied = c.load('history-unit-'+stem+'-inputs.json.gz')['inputs']
        assert all(identity == supplied[path] for path,identity in value['identities'].items())
        values[stem] = value
    assert values['healthy'] == values['inverse-restored'] == values['final']
    assert values['healthy']['completed'] and values['hash-fault']['completed']
    assert not any(values[key]['completed'] for key in ('inverse-fault','table-red','hash-restored'))
    assert values['table-red']['error'] == values['hash-restored']['error']
    draft = c.load('draft1.json.gz')
    assert draft['inputs_unchanged'] and draft['baseline']['returncode'] == 0
    assert not c.decode(draft['baseline']['stderr_base64'])
    assert c.source(c.PREFIX+'publication.json').read_bytes() == c.decode(draft['packets']['publication']['base64'])
    assert c.source(c.PREFIX+'publication-inputs.json.gz').read_bytes() == c.decode(draft['packets']['manifest']['base64'])
    portable = c.load('phase0-portable-result.json')
    assert portable == c.load('phase0-candidate-result.json')
    portable_run = c.load('phase0-portable-run.json.gz')
    assert portable_run['inputs_unchanged'] and portable_run['plan'] == plan
    assert portable_run['run']['returncode'] == 0 and not c.decode(portable_run['run']['stderr_base64'])
    marker = b'# FOCUSED_PHASE0_JSON '
    out = c.decode(portable_run['run']['stdout_base64'])
    assert out.count(marker) == 1
    observed = json.loads(out.split(marker)[1].splitlines()[0])
    old = json.loads(c.decode(normalization['summaries']['phase0-candidate']['before']['base64']))
    assert observed == old['summary']
    supplied = c.load('phase0-portable-inputs.json.gz')['inputs']
    assert c.identity(c.PREFIX+'phase0.py') == supplied[c.PREFIX+'phase0.py']
    assert draft2['baseline']['returncode'] == 0 and draft2['inputs_unchanged']
    assert not c.decode(draft2['baseline']['stderr_base64']) and draft2['portability']['returncode'] != 0
    for key,name in [('publication','publication2.json'),('manifest','publication2-inputs.json.gz')]:
        assert c.source(c.PREFIX+name).read_bytes() == c.decode(draft2['packets'][key]['base64'])
    assert normalization['producer_before'] == draft2['context']['overrides'][c.PREFIX+'phase0.py']
    assert normalization['producer_after'] == c.read(c.PREFIX+'phase0.py')
    return dict(result,selected=len(plan['selected']),skipped=summaries['phase0-candidate']['skipped'],goldens=len(table['hunks']))


def check(fresh=True,artifacts=True):
    plan = c.load('cases.json')
    assert c.source('tests/numeric-codeblocks/count-first.json').read_bytes() == c.source(c.PREFIX+'cases.json').read_bytes()
    accepted = c.load('accepted-run.json.gz')
    original = c.load('accepted-observed.json.gz')
    red = oracle.failures(original['run'],plan)
    assert red == accepted['failures'] and accepted['inputs_unchanged'] and original['inputs_unchanged']
    prior = c.load('prior.json.gz')
    for path in c.SOURCES:
        assert c.load('accepted-inputs.json.gz')['inputs'][path] == {key:prior['images'][path][key] for key in ('sha256','mode')}
    candidate = c.load('candidate1-run.json.gz')
    observed = c.load('candidate1-observed.json.gz')
    assert candidate['inputs_unchanged'] and observed['inputs_unchanged']
    assert not candidate['failures'] and not oracle.failures(observed['run'],plan)
    for path in c.SOURCES:
        assert c.identity(path) == c.load('candidate1-inputs.json.gz')['inputs'][path]
    for stem,summary in [('accepted',accepted),('candidate1',candidate)]:
        inputs = c.load(stem+'-inputs.json.gz')['inputs']
        assert set(summary['loaded_sources']) == set(c.SOURCES+['perl/LinkedSpec.pm'])
        assert all(item == inputs[path] for path,item in summary['loaded_sources'].items())
    implementation = c.load('implementation.json.gz')
    assert all(c.read(path) == packet for path,packet in implementation['after'].items())
    tasks = c.load('faults-before.json.gz')
    result = c.load('faults-result.json')
    assert result['sources_restored'] and result['faults'] == [task[0] for task in tasks['tasks']]
    for name,path,before,after,case_id in tasks['tasks']:
        stem = result['epochs'][name]
        fault = c.load(stem+'-observed.json.gz')
        restored = c.load(stem+'-restored.json.gz')
        text = c.decode(tasks['sources'][path]['base64']).decode()
        assert text.count(before) == 1
        assert c.decode(fault['mutant']['base64']).decode() == text.replace(before,after,1)
        assert fault['mutant']['mode'] == tasks['sources'][path]['mode']
        assert fault['inputs_unchanged'] and restored['inputs_unchanged'] and restored['sources_restored']
        assert fault['failures'] == oracle.failures(fault['run'],fault['plan'])
        assert set(fault['failures']) == {case_id} and not oracle.failures(restored['run'],fault['plan'])
        for suffix,run in [('inputs.json.gz',fault),('restored-inputs.json.gz',restored)]:
            inputs = c.load(stem+'-'+suffix)['inputs']
            assert all(item == inputs[owner] for owner,item in run['loaded_sources'].items())
    permanent = c.load('permanent.json.gz')
    assert permanent['after'] == c.read(permanent['path'])
    assert permanent['fixture'] == c.read('tests/numeric-codeblocks/count-first.json')
    direct = focused.validate(c.load('focused-final.json.gz'))
    for path in c.SOURCES+['t/scalar_numeric_contract.t']:
        assert c.identity(path) == c.load('focused-inputs.json.gz')['inputs'][path]
    docs = c.load('doc5-run.json.gz')
    inputs = c.load('doc5-inputs.json.gz')
    assert docs['inputs_unchanged'] and c.unchanged(inputs['book'])
    assert inputs['plan'] == book.examples() and not oracle.failures(docs['public'],inputs['plan'])
    book.validate(docs['builds']['healthy'],inputs['plan'])
    try:
        book.validate(docs['builds']['changed'],inputs['plan'])
    except AssertionError as error:
        assert str(error) == 'Missing count/first heading anchor'
    else:
        raise AssertionError('Displaced selection heading admitted')
    continuity = history()
    phase0 = verify_phase0()
    import private_review
    private = private_review.check(fresh=fresh)
    if artifacts:
        import publish
        supplied = c.load('artifact4-inputs.json.gz')
        runs = c.load('artifact4-run.json.gz')
        assert supplied['producer'] == c.read(c.PREFIX+'publish.py') and runs['producer_restored']
        for key in ('healthy','fault','restored'):
            assert runs[key]['returncode'] == 0 and not c.decode(runs[key]['stderr_base64'])
        good = json.loads(c.decode(runs['healthy']['stdout_base64']))
        bad = json.loads(c.decode(runs['fault']['stdout_base64']))
        assert good == publish.controls() == json.loads(c.decode(runs['restored']['stdout_base64']))
        assert len(good) == 3 and all(item['rejected'] for item in good.values())
        assert all(not item['rejected'] for item in bad.values())
        changed = c.load('artifact4-observed.json.gz')
        assert changed['run'] == runs['fault']
        assert c.decode(changed['producer']['base64']) == c.decode(supplied['producer']['base64']).replace(
            b'def validate_inputs(declared,actual):\n',b'def validate_inputs(declared,actual):\n    return\n',1)
    repair = c.load('portability-repair.json.gz')
    assert repair['checker'] == c.read('scripts/check_repo_root_path_portability.sh')
    assert repair['green']['returncode'] == 0 and not c.decode(repair['green']['stderr_base64'])
    recovered = custody.verify()
    if fresh:
        portable = c.run(['bash','scripts/check_repo_root_path_portability.sh'])
        assert portable['returncode'] == 0 and not c.decode(portable['stderr_base64'])
        current = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
        assert not oracle.failures(current,plan)
        public = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(inputs['plan']).encode())
        assert not oracle.failures(public,inputs['plan'])
        book.validate(book.render(inputs['book']),inputs['plan'])
    return dict(cases=len(plan['cases']),accepted_red=len(red),accepted_controls=len(plan['cases'])-len(red),
        faults=result['faults'],direct_suites=direct['suites'],direct_tap=direct['tap'],direct_scope=direct['scope'],
        private=private,historical_controls=phase0['current'],phase0=phase0,book_inputs=len(inputs['book']),
        book_examples=len(inputs['plan']['cases']),history=continuity,custody=recovered)


if __name__ == '__main__':
    import sys
    assert sys.argv[1:] in ([],['--retained'])
    print(json.dumps(check(fresh=not sys.argv[1:]),sort_keys=True))
