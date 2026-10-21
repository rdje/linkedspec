"""Readonly composed review of measured epochs, actual faults and current public behavior."""
import json
import re
import common as c
import custody
import doc_proof as book
import oracle
import review_current
import verify_kinds
import verify_library
import guard_proof


def passed(run):
    assert run['returncode']==0,run['command']


def faults():
    saved=c.load('fault-inputs.json.gz')
    change=c.load('guard-change.json.gz')
    assert saved['sources'][c.SOURCE]==change['before'][c.SOURCE]
    assert c.read(c.SOURCE)['base64']==change['after'][c.SOURCE]
    assert all(c.read(path)==packet for path,packet in saved['sources'].items() if path!=c.SOURCE)
    names=[]
    for task in saved['tasks']:
        path=task['path'];original=saved['sources'][path]
        mutant=c.decode(original['base64']).decode()
        for before,after in task['hunks']:
            assert mutant.count(before)==1
            mutant=mutant.replace(before,after,1)
        observed=c.load('fault-'+task['name']+'-observed.json.gz')
        final=c.load('fault-'+task['name']+'.json.gz')
        assert c.decode(observed['mutant']['base64']).decode()==mutant
        assert observed['mutant']['mode']==original['mode'] and observed['run']==final['run']
        assert final['source_restored'] and final['inputs_restored']
        assert oracle.failures(final['run'],task['plan'])==final['failures']
        assert not oracle.failures(final['restored'],task['plan'])
        row=oracle.rows(final['run'])[task['id']]
        if task['name'] in ('call-dispatch','receiver-dispatch'):
            assert row['native']['runtime_detail']['fields']['code']=='unknown_helper'
        elif task['name']=='empty-sum-identity':assert row['native']['value']==1
        elif task['name']=='terminal-effects':assert row['native']['value']==[None,'rx']
        elif task['name']=='scalar-overload-effects':assert row['native']['value']==[None,'']
        else:assert row['generated']['warnings'] and row['native']['last_error'] is not None
        names.append(task['name'])
    assert c.load('fault-review.json.gz')==dict(result='PASS',faults=names,inputs_restored=True)
    assert len(names)==6
    return names


def historical_kind_controls():
    before=c.load('kind-history-before.json.gz')
    for revision,source in before['sources'].items():
        result=c.load('kind-history-'+revision[:9]+'.json.gz')
        assert result['other_inputs_unchanged'] and result['source']['base64']==source['base64']
        passed(result['run']);assert not c.decode(result['run']['stderr_base64'])
        rows=json.loads(c.decode(result['run']['stdout_base64']))['rows']
        assert len(rows)==8
        expected=['[3]','[1]','[8]','[8]','[4]','[3]','[8]','[10]']
        assert [row['native']['value_json'] for row in rows]==expected
        assert [row['generated']['value_json'] for row in rows]==expected
    assert c.load('kind-history-restoration.json.gz')==dict(source_restored=True,inputs_restored=True)
    library=verify_library.check()
    return dict(exact_catalog_sources=8,controlled_emitter_epochs=3,
        owned_library_inputs=library['installed_inputs'],loaded_owned_modules=library['loaded_owned_modules'],
        limit=library['scope'])


def artifact_checks():
    import publish
    saved=c.load('artifact-inputs.json.gz');run=c.load('artifact-run.json.gz')
    observed=c.load('artifact-fault-observed.json.gz')
    assert c.read(c.PREFIX+'publish.py')==saved['producer']
    assert observed['producer']['base64']==saved['mutant_base64']
    assert observed['producer']['mode']==saved['producer']['mode']
    assert run['initial_inputs_unchanged'] and run['producer_restored']
    assert observed['outcomes']==run['fault'] and run['restored']==run['healthy']
    for name,case in saved['cases'].items():
        assert run['healthy'][name]==dict(rejected=True,reason=case['reason'])
        assert run['fault'][name]==dict(rejected=False,reason='')
        try:publish.validate_inputs(case['declared'],saved['actual'])
        except AssertionError as error:assert str(error)==case['reason']
        else:raise AssertionError('Artifact declaration admitted: '+name)
    assert len(saved['cases'])==3
    return dict(denials=3,validator_fault_admissions=3,restored_denials=3)


def check(fresh=True,doc_stem="doc"):
    artifacts=artifact_checks()
    prior=custody.prior();epochs=custody.epochs()
    current=review_current.check()
    assert current==dict(cases=214,failures=[],value_cases=212,diagnostics=2)
    assert c.load('candidate3-review.json.gz')['result']==current
    accepted=c.load('accepted-run.json.gz');assert accepted['inputs_unchanged']
    plan=c.load('cases2.json')
    failed=oracle.failures(accepted['run'],plan)
    retained=c.load('accepted-review.json.gz')
    assert retained==dict(failures=failed,cases=214,sources_restored=True,oracle=c.read(c.PREFIX+'oracle.py'))
    assert len(failed)==106
    before=c.load('accepted-before.json.gz')
    change=c.load('guard-change.json.gz')
    assert before['current'][c.SOURCE]==change['before'][c.SOURCE]
    assert c.read(c.SOURCE)['base64']==change['after'][c.SOURCE]
    assert all(c.read(path)==packet for path,packet in before['current'].items() if path!=c.SOURCE)
    assert c.load('accepted-restoration.json.gz')==dict(sources_restored=True)
    tasks=faults()
    migration=c.load('test-migration.json.gz')
    assert (c.ROOT/migration['path']).read_bytes()==c.decode(migration['after_base64'])
    assert len(migration['converted'])==3 and len(migration['added'])==201
    focused=c.load('focused2-run.json.gz')
    assert focused['inputs_unchanged']
    for key in ('history','tests','scanner'):passed(focused[key])
    stderr=c.decode(focused['tests']['stderr_base64'])
    marker=b'# RECEIVER_COPY_OBSERVATIONS '
    assert stderr.startswith(marker) and stderr.endswith(b'\n') and len(stderr.splitlines())==1
    diagnostic=json.loads(stderr[len(marker):])
    assert diagnostic['live_error'] is None and diagnostic['live']==diagnostic['standalone']
    assert diagnostic['live_identity']==diagnostic['standalone_identity']
    assert set(diagnostic['live_identity'].values())=={1}
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(focused['tests']['stdout_base64']))
    assert match and int(match[1])==14 and b'Result: PASS' in c.decode(focused['tests']['stdout_base64'])
    history=json.loads(c.decode(focused['history']['stdout_base64']))
    assert history['audit_controls']['governance_mutations_rejected']==650
    assert history['restored_inputs']==134 and history['restored_bytes']==84613241 and len(history['controls'])==22
    assert history['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    doc=c.load(doc_stem+'-run.json.gz');inputs=c.load(doc_stem+'-inputs.json.gz')
    assert doc['inputs_unchanged'] and c.unchanged(inputs['book'])
    passed(doc['knowledge']);assert inputs['plan']==book.examples()
    assert not oracle.failures(doc['public'],inputs['plan'])
    book.validate(doc['builds']['healthy'],inputs['plan'])
    try:book.validate(doc['builds']['changed'],inputs['plan'])
    except AssertionError as error:assert str(error)=='Missing aggregate heading anchor'
    else:raise AssertionError('Displaced book anchor admitted')
    assert doc['anchor_control']==dict(rejected=True,message='Missing aggregate heading anchor')
    guard=c.load('guard-proof-run.json.gz')
    assert guard['inputs_unchanged'] and guard['source_restored']
    assert guard_proof.typed(guard['healthy']) and guard_proof.typed(guard['restored'])
    assert not guard_proof.typed(guard['red'])
    kind_guard=c.load('guard-change.json.gz')
    assert c.decode(kind_guard['after'][c.SOURCE])==c.decode(kind_guard['before'][c.SOURCE]['base64']).replace(
        b" for (my $index = 0; $index < @$calls; ++$index) {\n",
        b" for (my $index = 0; $index < @$calls; ++$index) {\n  next unless ref($calls->[$index]) eq 'HASH';\n",1)
    kinds=verify_kinds.check(fresh)
    historical_kinds=historical_kind_controls()
    if fresh:
        public=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
        assert not oracle.failures(public,plan)
        build=book.render(inputs['book']);book.validate(build,inputs['plan'])
    return dict(cases=214,value_cases=212,diagnostics=2,accepted_red=106,accepted_controls=108,
        producer_faults=tasks+['malformed-call-guard'],direct_suites=int(match[1]),direct_tap=int(match[2]),
        permanent_added=201,permanent_advanced=3,malformed_assertions=15,book_inputs=len(inputs['book']),book_examples=3,
        historical_controls=650,historical_inputs=len(history['tracked_inputs']),
        prior_inputs=prior,epochs=epochs,artifacts=artifacts,kinds=kinds,historical_kind_scope=historical_kinds,
        limits='Bounded Perl aggregate availability and complete invalid receiver shapes. Legacy array '
              'decimal/empty/Boolean/selected-term behavior is separate from scalar ADR0029. Source106 '
              'REDs and108 controls use the corrected fixed214 with real accepted execution owners in '
              'explicit current context. Original176 and rejected214/18 oracle discrepancies remain. '
              'Six aggregate faults retain the exact pre-guard epoch; the only final delta skips non-hash '
              'serialized members and has a distinct actual guard-removal fault plus15 permanent assertions. '
              'Current214/final14 suites and canonical admission use that final producer. '
              'Known pipeline9 and internal kind95 failures stay owned; no95 fix, complete inventory, '
              'portable aggregate-input policy or cross-backend admission. Historical650 controls, '
              'archive134/84613241/22 and zero read/write escapes stay unchanged; no inverse needed '
              'because ordinary Phase0 test source is unchanged. Three artifact omission/byte/mode '
              'denials and an actual discarded-validator fault admit3 before exact restoration. '
              'Exact staged canonical receipt governs landing.')


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
