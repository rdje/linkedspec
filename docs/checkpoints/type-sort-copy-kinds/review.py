"""Re-derive retained claims and current public values without source writes."""
import json
import common as c
import custody
import doc_proof as book
import flags
import focused
import oracle
import transport_review


def check(fresh=True, artifacts=True):
    plan = c.load('cases.json')
    assert c.source('tests/numeric-codeblocks/sort-kinds.json').read_bytes() == c.source(c.PREFIX+'cases.json').read_bytes()
    accepted = c.load('accepted2-run.json.gz')
    observed = c.load(accepted['observation'])
    assert c.identity(c.PREFIX+accepted['observation']) == accepted['observation_identity']
    red = oracle.failures(observed['run'],plan)
    assert red == accepted['failures'] and accepted['inputs_unchanged'] and observed['inputs_unchanged']
    prior = c.load('prior.json.gz')
    for path in c.SOURCES:
        assert c.load('accepted2-inputs.json.gz')['inputs'][path] == {
            key:prior['images'][path][key] for key in ('sha256','mode')}
    candidate = c.load('candidate1-run.json.gz')
    candidate_observation = c.load(candidate['observation'])
    assert c.identity(c.PREFIX+candidate['observation']) == candidate['observation_identity']
    assert candidate['inputs_unchanged'] and candidate_observation['inputs_unchanged']
    assert not candidate['failures'] and not oracle.failures(candidate_observation['run'],plan)
    for path in c.SOURCES:
        assert c.identity(path) == c.load('candidate1-inputs.json.gz')['inputs'][path]
    for stem,summary in (('accepted2',accepted),('candidate1',candidate)):
        inputs = c.load(stem+'-inputs.json.gz')['inputs']
        assert set(summary['loaded_sources']) == {path.removeprefix('perl/')
            for path in c.SOURCES+['perl/LinkedSpec/CodeblockRuntime.pm']}
        for key,item in summary['loaded_sources'].items():
            assert item['path'] == 'perl/'+key
            assert {name:item[name] for name in ('sha256','mode')} == inputs[item['path']]
    transport_review.check()
    implementation = c.load('implementation.json.gz')
    assert implementation['unaffected_inputs_unchanged']
    for path in c.SOURCES:
        assert c.read(path) == implementation['after'][path]
    fault_inputs = c.load('faults-before.json.gz')
    assert all(c.read(path) == packet for path,packet in fault_inputs['sources'].items())
    names = []
    for name,path,before,after,case_id in fault_inputs['tasks']:
        fault = c.load('fault-'+name+'-observed.json.gz')
        restored = c.load('fault-'+name+'-restored.json.gz')
        text = c.decode(fault_inputs['sources'][path]['base64']).decode()
        assert text.count(before) == 1
        assert c.decode(fault['mutant']['base64']).decode() == text.replace(before,after,1)
        assert fault['mutant']['mode'] == fault_inputs['sources'][path]['mode']
        assert fault['inputs_unchanged'] and restored['inputs_unchanged'] and restored['sources_restored']
        assert fault['failures'] == oracle.failures(fault['run'],fault['plan'])
        assert set(fault['failures']) == {case_id}
        assert not oracle.failures(restored['run'],fault['plan'])
        for suffix,run in (('inputs.json.gz',fault),('restored-inputs.json.gz',restored)):
            inputs = c.load('fault-'+name+'-'+suffix)['inputs']
            assert all(item == inputs[owner] for owner,item in run['loaded_sources'].items())
        names.append(name)
    assert c.load('faults-result.json') == dict(faults=names,sources_restored=True)
    admission = c.load('checks-admission.json.gz')
    permanent = c.load('permanent.json.gz')
    assert permanent['after'] == c.read(permanent['path'])
    assert permanent['fixture'] == c.read('tests/numeric-codeblocks/sort-kinds.json')
    assert permanent['cases'] == len(plan['cases'])
    assert admission['after'] == c.read(admission['target']) and admission['proposal_absent']
    assert not (c.ROOT/'t/sorted_value_kinds_perl.t').exists()
    first = c.load('checks-test-run.json.gz')
    second = c.load(admission['run'])
    assert first['inputs_unchanged'] and first['run']['returncode'] == 1
    assert second['inputs_unchanged'] and second['run']['returncode'] == 0
    assert not c.decode(second['run']['stderr_base64'])
    block = c.decode(second['run']['stdout_base64']).split(
        b'# Subtest: sorted scalar kinds survive lexical selection and cloning\n',1)[1]
    assert block.count(b'1..8\n') == admission['cases'] and b'Result: PASS' in block
    flag_result = c.load('flags2-run.json.gz')
    assert flag_result['inputs_unchanged']
    flag_count = flags.validate(flag_result['run'],flag_result['plan'])
    assert not c.load('flags-run.json.gz')['inputs_unchanged']
    for path in c.SOURCES:
        assert c.identity(path) == c.load('flags2-inputs.json.gz')['inputs'][path]
    direct = focused.validate(c.load('focused-run.json.gz'))
    for path in c.SOURCES+['t/uniform_binding_contract.t','t/scalar_numeric_contract.t']:
        assert c.identity(path) == c.load('focused-inputs.json.gz')['inputs'][path]
    docs = c.load('doc-run.json.gz')
    inputs = c.load('doc-inputs.json.gz')
    assert docs['inputs_unchanged'] and c.unchanged(inputs['book'])
    assert inputs['plan'] == book.examples() and not oracle.failures(docs['public'],inputs['plan'])
    book.validate(docs['builds']['healthy'],inputs['plan'])
    try:
        book.validate(docs['builds']['changed'],inputs['plan'])
    except AssertionError as error:
        assert str(error) == 'Missing scalar-kind heading anchor'
    else:
        raise AssertionError('Displaced book heading admitted')
    if artifacts:
        import publish
        artifact = c.load('artifact-inputs.json.gz')
        runs = c.load('artifact-run.json.gz')
        assert artifact['producer'] == c.read(c.PREFIX+'publish.py') and runs['producer_restored']
        for key in ('healthy','fault','restored'):
            assert runs[key]['returncode'] == 0 and not c.decode(runs[key]['stderr_base64'])
        good = json.loads(c.decode(runs['healthy']['stdout_base64']))
        bad = json.loads(c.decode(runs['fault']['stdout_base64']))
        assert good == publish.controls() == json.loads(c.decode(runs['restored']['stdout_base64']))
        assert len(good) == 3 and all(item['rejected'] for item in good.values())
        assert all(not item['rejected'] for item in bad.values())
        fault = c.load('artifact-observed.json.gz')
        assert fault['run'] == runs['fault']
        assert c.decode(fault['producer']['base64']) == c.decode(artifact['producer']['base64']).replace(
            b'def validate_inputs(declared,actual):\n',b'def validate_inputs(declared,actual):\n    return\n',1)
    recovered = custody.verify()
    if fresh:
        current = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
        assert not oracle.failures(current,plan)
        public = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(inputs['plan']).encode())
        assert not oracle.failures(public,inputs['plan'])
        book.validate(book.render(inputs['book']),inputs['plan'])
    return dict(cases=len(plan['cases']),accepted_red=len(red),accepted_controls=len(plan['cases'])-len(red),
        faults=names,direct_suites=direct['suites'],direct_tap=direct['tap'],
        historical_controls=direct['historical_controls'],flag_routes=flag_count,
        scalar_cases=admission['cases'],scalar_assertions=admission['assertions'],
        book_inputs=len(inputs['book']),book_examples=len(inputs['plan']['cases']),custody=recovered)


if __name__ == '__main__':
    import sys
    assert sys.argv[1:] in ([],['--retained'])
    print(json.dumps(check(fresh=not sys.argv[1:]),sort_keys=True))
