"""Review retained epochs and rederive bounded public behavior on current exact sources."""
import json
import re
import common as c
import custody
import doc_proof as book
import malformed
import oracle

def passed(run):
    assert run['returncode']==0,run['command']

def check(fresh=True):
    plan=c.load('cases3.json');assert len(plan['cases'])==85
    current=c.load('candidate4-run.json.gz')
    assert current['inputs_unchanged'] and not current['failures'] and not oracle.failures(current['run'],plan)
    accepted=c.load('accepted-observed.json.gz')
    failures=oracle.failures(accepted['run'],plan)
    assert failures==accepted['failures'] and len(failures)==41
    assert c.load('accepted-restoration.json')==dict(source_restored=True,inputs_restored=True)
    accepted_inputs=c.load('accepted-inputs.json.gz')
    assert accepted['loaded_source']==accepted_inputs['accepted']
    assert accepted['loaded_path']==c.SOURCE
    guard=c.load('argument-guard-change.json.gz');faults=c.load('fault-inputs.json.gz')
    assert faults['source']==guard['before'][c.SOURCE]
    assert accepted_inputs['current']==guard['before'][c.SOURCE]
    assert c.read(c.SOURCE)['base64']==guard['after'][c.SOURCE]
    assert c.decode(guard['after'][c.SOURCE]).decode()==c.decode(guard['before'][c.SOURCE]['base64']).decode().replace(guard['old'],guard['new'],1)
    names=[]
    for name,case_id,before,after in faults['tasks']:
        observed=c.load('fault-'+name+'-observed.json.gz');restored=c.load('fault-'+name+'.json.gz')
        text=c.decode(faults['source']['base64']).decode();assert text.count(before)==1
        assert c.decode(observed['mutant']['base64']).decode()==text.replace(before,after,1)
        assert observed['mutant']['mode']==faults['source']['mode']
        assert observed['failures']==oracle.failures(observed['run'],observed['plan'])
        assert len(observed['failures'])==1 and observed['plan']['cases'][0]['id']==case_id
        assert restored['source_restored'] and not oracle.failures(restored['restored'],observed['plan'])
        names.append(name)
    assert c.load('fault-result.json')==dict(faults=names,inputs_restored=True) and len(names)==6
    old=c.load('malformed-before.json.gz');new=c.load('malformed-after.json.gz')
    assert not malformed.typed(old['run']) and malformed.typed(new['run'])
    assert old['sources'][c.SOURCE]==guard['before'][c.SOURCE]
    assert new['sources'][c.SOURCE]==c.read(c.SOURCE)
    final_fault=c.load('guard-fault-run.json.gz');observed=c.load('guard-fault-observed.json.gz')
    assert observed['run']==final_fault['red'] and observed['source']==guard['before'][c.SOURCE]
    assert malformed.typed(final_fault['healthy']) and not malformed.typed(final_fault['red'])
    assert malformed.typed(final_fault['restored']) and final_fault['source_restored']
    names.append('malformed-argument-guard')
    migration=c.load('permanent-migration.json.gz')
    assert migration['after']==c.read('t/scalar_numeric_contract.t') and migration['cases']==85
    assert migration['fixture']==c.read('tests/numeric-codeblocks/pipelines.json')
    assert c.read('t/callable_codeblock_literal_contract.t')['base64']==guard['after']['t/callable_codeblock_literal_contract.t']
    earlier=c.load('focused1-run.json.gz')
    assert earlier['inputs_unchanged'] and earlier['tests']['returncode']==1
    assert b"Failed test 'aggregate7/deferred/chain'" in c.decode(earlier['tests']['stderr_base64'])
    assert b'Files=14, Tests=1948,' in c.decode(earlier['tests']['stdout_base64'])
    advanced=c.load('existing-expectation-change.json.gz')
    assert advanced['advanced']==['aggregate7/deferred/chain'] and advanced['after']==c.read(advanced['path'])
    original=json.loads(c.decode(advanced['before']['base64']))
    repaired=json.loads(c.decode(advanced['after']['base64']))
    expected=json.loads(json.dumps(original))
    chosen=next(case for case in expected['cases'] if case['id']=='aggregate7/deferred/chain')
    assert chosen.pop('error')==dict(code='unknown_helper',name='sorted')
    chosen['expected']=4
    assert repaired==expected
    focused=c.load('focused2-run.json.gz');assert focused['inputs_unchanged']
    for key in ('history','tests','scanner'):passed(focused[key])
    history=json.loads(c.decode(focused['history']['stdout_base64']))
    assert history['audit_controls']['governance_mutations_rejected']==650
    assert history['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(focused['tests']['stdout_base64']))
    assert match and int(match[1])==14 and b'Result: PASS' in c.decode(focused['tests']['stdout_base64'])
    marker=b'# RECEIVER_COPY_OBSERVATIONS '
    stderr=c.decode(focused['tests']['stderr_base64'])
    assert stderr.startswith(marker) and len(stderr.splitlines())==1
    diagnostic=json.loads(stderr[len(marker):])
    assert diagnostic['live_error'] is None and diagnostic['live']==diagnostic['standalone']
    assert diagnostic['live_identity']==diagnostic['standalone_identity'] and set(diagnostic['live_identity'].values())=={1}
    kinds=c.load('kind-investigation2.json.gz')
    assert all(c.read(p)==packet for p,packet in kinds['inputs'].items() if p!=c.SOURCE)
    assert kinds['inputs'][c.SOURCE]==guard['before'][c.SOURCE]
    passed(kinds['run']);rows=json.loads(c.decode(kinds['run']['stdout_base64']))['rows'];assert len(rows)==16
    for row in rows:
        assert not row['warnings']
        if row['id'].endswith('/sort'):
            assert row['value']==[1,10,2] and row['cloned_value']==['1','10','2']
            assert all(item['pOK']==item['iOK']==1 for item in row['flags'])
            assert all(item['pOK']==1 and item['iOK']==0 for item in row['cloned_flags'])
        if row['id'].endswith('/control'):
            assert row['value']==[1,10,2] and row['cloned_value']==[1,10,2]
            assert all(item['pOK']==0 and item['iOK']==1 for item in row['flags'])
        if row['id'].endswith('/index'):
            assert row['value'] is None
            if row['route']=='native':assert row['runtime_error']['detail']['code']=='nested_write_kind_conflict'
            else:assert not row['completed']
    doc=c.load('doc2-run.json.gz');inputs=c.load('doc2-inputs.json.gz')
    assert doc['inputs_unchanged'] and c.unchanged(inputs['book'])
    assert inputs['plan']==book.examples() and not oracle.failures(doc['public'],inputs['plan'])
    passed(doc['knowledge']);book.validate(doc['builds']['healthy'],inputs['plan'])
    try:book.validate(doc['builds']['changed'],inputs['plan'])
    except AssertionError as error:assert str(error)=='Missing pipeline heading anchor'
    else:raise AssertionError('Displaced book anchor admitted')
    import publish
    artifacts=c.load('artifact4-inputs.json.gz');runs=c.load('artifact4-run.json.gz')
    assert artifacts['producer']==c.read(c.PREFIX+'publish.py') and runs['producer_restored']
    for run in (runs['healthy'],runs['fault'],runs['restored']):passed(run)
    good=json.loads(c.decode(runs['healthy']['stdout_base64']));bad=json.loads(c.decode(runs['fault']['stdout_base64']))
    assert good==publish.controls('artifact4-inputs.json.gz') and good==json.loads(c.decode(runs['restored']['stdout_base64']))
    assert len(good)==3 and all(item['rejected'] for item in good.values()) and all(not item['rejected'] for item in bad.values())
    mutant=c.load('artifact4-observed.json.gz')
    assert mutant['run']==runs['fault']
    assert c.decode(mutant['producer']['base64'])==c.decode(artifacts['producer']['base64']).replace(b'def validate_inputs(declared,actual):\n',b'def validate_inputs(declared,actual):\n    return\n',1)
    followup=c.load('followup-confirmation.json.gz')
    assert followup['inputs_unchanged'] and followup['source']==c.read(c.SOURCE)
    assert not oracle.failures(followup['run'],followup['plan'])
    sources=custody.verify()
    if fresh:
        run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
        assert not oracle.failures(run,plan)
        public=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(inputs['plan']).encode())
        assert not oracle.failures(public,inputs['plan'])
        book.validate(book.render(inputs['book']),inputs['plan'])
    return dict(cases=85,accepted_red=41,accepted_controls=44,faults=names,
        direct_suites=int(match[1]),direct_tap=int(match[2]),permanent_cases=85,malformed_assertions=75,
        book_inputs=len(inputs['book']),book_examples=3,historical_controls=650,artifacts=3,custody=sources)

if __name__=='__main__':
    import sys
    assert sys.argv[1:] in ([],['--retained'])
    print(json.dumps(check(fresh=not sys.argv[1:]),sort_keys=True))
