"""Readonly review of accepted/candidate epochs, actual faults and current proof."""
import gzip
import json
import re
import subprocess
import common as c
import custody
import doc_proof as book
import focused_review
import oracle


def passed(run,quiet=True):
    assert run['returncode']==0,run['command']
    if quiet:assert not c.decode(run['stderr_base64']),run['command']


def phase0(run,passing):
    output=c.decode(run['stdout_base64'])
    marker=b'# FOCUSED_PHASE0_JSON '
    assert output.count(marker)==1
    value=json.loads(output.split(marker)[1].splitlines()[0])
    assert value['complete_selection'] and value['selected']==value['wanted']==5
    assert value['root_tests']==1035 and value['passing']==passing
    assert (run['returncode']==0)==passing
    assert value['loaded_method_lowering'].endswith('/perl/LinkedSpec/ActionIR/MethodLowering.pm')
    if passing:assert not c.decode(run['stderr_base64'])


def prior():
    saved=c.load('prior.json.gz')
    assert saved['base']==c.BASE and len(saved['inputs'])==10202
    assert saved['producer']==c.read(c.PREFIX+'preserve.py') and saved['primitives']==c.read(c.PREFIX+'common.py')
    manifest=json.loads(c.decode(saved['manifest']['base64']))
    assert manifest['inputs']=={path:{key:item[key] for key in ('sha256','mode')} for path,item in saved['inputs'].items()}
    publication=json.loads(c.decode(saved['publication']['base64']))
    assert publication['record_base64']==saved['claim']['base64']
    assert c.decode(saved['baseline']['status']['base64']).strip()==b'0'
    assert b'10202 closed inputs;318 GREEN;169 accepted RED;13 faults' in c.decode(saved['baseline']['log']['base64'])
    activation=json.loads(c.decode(saved['activation']['base64']))
    assert activation['head']==c.BASE and activation['status']['returncode']==0
    assert activation['status']['stdout']==activation['status']['stderr']==''
    tree={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            tree[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    assert all(item['git']==tree[path] for path,item in saved['inputs'].items())
    passed(saved['git_verification'])
    assert c.decode(saved['git_verification']['stdout_base64']).decode().splitlines()==[
        saved['inputs'][path]['git']['oid'] for path in sorted(saved['inputs'])]
    return len(saved['inputs'])


def source_faults():
    inputs=c.load('source-fault-inputs.json.gz')
    assert inputs['source']==c.read(c.SOURCE)
    raw=c.decode(inputs['source']['base64'])
    for task in inputs['tasks']:
        before,after=c.decode(task['before']),c.decode(task['after'])
        assert raw.count(before)==1
        observed=c.load('fault-'+task['name']+'-observed.json.gz')
        actual=c.load('fault-'+task['name']+'.json.gz')
        assert c.decode(observed['mutant']['base64'])==raw.replace(before,after,1)
        assert observed['mutant']['mode']==inputs['source']['mode']
        assert actual['run']==observed['run'] and actual['source_restored'] and actual['inputs_restored']
        row=oracle.rows(actual['run'])[task['id']]
        if task['name']=='scalar-slice-warning':
            assert not row['generated_fatal']['completed'] and 'Scalar value @__ls_drop{' in row['generated_fatal']['exception']['text']
        elif task['name']=='late-key-read':
            assert row['native']['value']==row['generated']['value']==[{'kind':'node'},'stage']
        elif task['name']=='missing-flat-lowering':
            assert '::flat_array called' in row['native']['last_error']['detail']
        else:
            assert task['name']=='raw-hash-key' and row['native']['last_error']['stage']=='rule_handler_compile'
        assert not oracle.failures(actual['restored'],task['plan'])
        if task['name']=='raw-hash-key':oracle.diagnostics(actual['restored'],c.load('red-run.json.gz')['run'])
    review=c.load('source-fault-review.json.gz')
    assert review==dict(result='PASS',faults=[task['name'] for task in inputs['tasks']],source_restored=True)
    assert len(inputs['tasks'])==4


def history():
    before,after=[c.load(name+'-run.json.gz') for name in ('historical-before','historical-after')]
    for item in (before,after):assert item['inputs_unchanged'];passed(item['run'])
    old,new=[json.loads(c.decode(item['run']['stdout_base64'])) for item in (before,after)]
    assert old['audit_controls']['governance_mutations_rejected']==644
    assert new['audit_controls']['governance_mutations_rejected']==650
    assert len(old['tracked_inputs'])==185 and len(new['tracked_inputs'])==186
    for name,count in old['audit_controls']['governance_mutations_by_source'].items():
        assert new['audit_controls']['governance_mutations_by_source'][name]==count+(6 if name=='t/phase0_regression.t' else 0)
    for result in (old,new):
        assert result['restored_inputs']==134 and result['restored_bytes']==84613241 and len(result['controls'])==22
        assert result['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    assert old['restored_hashes']==new['restored_hashes'] and old['controls']==new['controls']
    implementation=c.load('historical-implementation.json.gz')
    for path,raw in implementation['after'].items():assert (c.ROOT/path).read_bytes()==c.decode(raw)
    table=implementation['table']
    assert (c.ROOT/table['path']).read_bytes()==c.decode(table['base64'])
    assert new['tracked_inputs'][table['path']]==table['sha256']==c.identity(table['path'])['sha256']
    inputs=c.load('historical-fault-inputs.json.gz')
    assert inputs['source']==c.read('tests/language-readiness/verify_objectives.py')
    assert inputs['table']==c.read(table['path'])
    raw=c.decode(inputs['source']['base64'])
    for task in inputs['tasks']:
        before,after=c.decode(task['before']),c.decode(task['after'])
        observed=c.load('historical-fault-'+task['name']+'-observed.json.gz')
        result=c.load('historical-fault-'+task['name']+'.json.gz')
        assert raw.count(before)==1 and c.decode(observed['mutant']['base64'])==raw.replace(before,after,1)
        assert observed['run']==result['run'] and result['run']['returncode']!=0
        assert c.decode(task['reason']) in c.decode(result['run']['stderr_base64'])
        passed(result['restored']);assert result['source_restored'] and result['inputs_restored']
    changed=c.load('historical-table-observed.json.gz')
    assert changed['run']['returncode']!=0 and b'drop inverse table identity mismatch:' in c.decode(changed['run']['stderr_base64'])
    assert json.loads(gzip.decompress(c.decode(changed['changed_base64'])))==json.loads(gzip.decompress(c.decode(table['base64'])))
    review=c.load('historical-fault-review.json.gz')
    assert review['result']=='PASS' and review['inputs_restored'] and review['semantic_table_unchanged']
    passed(review['healthy']);passed(review['table_restored'])
    return dict(previous_controls=644,current_controls=650,new_inverse_fragments=2,new_denials=6,
                restored_inputs=134,restored_bytes=84613241,recovery_controls=22,auditor_faults=2)


def check(fresh=True):
    previous=prior()
    epochs=custody.verify()
    result=oracle.verify()
    assert result['value_cases']==34 and result['diagnostic_controls']==14
    baseline=c.load('red-inputs.json.gz')
    assert c.decode(baseline['source']['base64'])==subprocess.check_output(['git','show',c.BASE+':'+c.SOURCE],cwd=c.ROOT)
    review=c.load('red-review.json.gz')
    assert review['failures']==dict(native=10,generated=28,generated_fatal=28)
    assert c.load('green2-inputs.json.gz')['source']==c.read(c.SOURCE)
    plan=json.loads((c.ROOT/'tests/drop-generated/cases.json').read_bytes())
    assert plan==baseline['plan']==c.load('green2-inputs.json.gz')['plan']
    assert not oracle.failures(c.load('green1-run.json.gz')['run'],plan)
    for row in oracle.rows(c.load('green1-run.json.gz')['run']).values():
        if row['id'].endswith('/hash-key'):assert row['native']['last_error']['stage']=='rule_handler_compile'
    for name,reason in [('review-refinement','diagnostic/call/null-key'),('review-refinement2','diagnostic/array-source'),('review-refinement3','diagnostic/array-source')]:
        failure=c.load(name+'.json.gz')['failed_oracle']
        assert failure['returncode']!=0 and reason.encode() in c.decode(failure['stderr_base64'])
    assert (c.ROOT/(c.PREFIX+'oracle.py')).read_bytes()==c.decode(c.load('review-refinement3.json.gz')['after_base64'])
    source_faults()
    prep=c.load('phase0-before-run.json.gz')
    assert prep['inputs_unchanged'] and prep['run']['returncode']==255
    assert b'Undefined subroutine &LinkedSpec::RuleIR::EmitContext::_lower_method_value_expr' in c.decode(prep['run']['stderr_base64'])
    for name,passing in [('phase0-before2',False),('phase0-after',True)]:
        captured=c.load(name+'-run.json.gz');assert captured['inputs_unchanged'];phase0(captured['run'],passing)
    assert len(re.findall(rb"    #   Failed test '",c.decode(c.load('phase0-before2-run.json.gz')['run']['stderr_base64'])))==5
    migration=c.load('phase0-migration.json.gz')
    assert (c.ROOT/'t/phase0_regression.t').read_bytes()==c.decode(migration['after_base64'])
    historical=history()
    doc_inputs,doc=c.load('doc-inputs.json.gz'),c.load('doc-run.json.gz')
    assert doc['inputs_unchanged'] and c.unchanged(doc_inputs['book'])
    assert doc_inputs['examples']==book.examples()
    assert not oracle.failures(doc['examples'],doc_inputs['examples'])
    passed(doc['knowledge'],False)
    assert c.decode(doc['knowledge']['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
    for name,build in doc['builds'].items():book.validate(build,doc_inputs['examples'],name=='changed')
    focused=c.load('focused-run.json.gz');assert focused['inputs_unchanged']
    assert c.load('focused-review.json.gz')['result']==focused_review.verify()
    passed(focused['scanner'],False)
    match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(focused['tests']['stdout_base64']))
    assert match and int(match[1])==9 and b'Result: PASS' in c.decode(focused['tests']['stdout_base64'])
    for path,item in c.load('focused-inputs.json.gz')['inputs'].items():
        if path.startswith(('perl/','t/','tests/','tools/','conf/','specs/','bin/','capability_conformance/')):
            assert c.identity(path)==item,path
    if fresh:
        public=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
        assert not oracle.failures(public,plan)
        oracle.diagnostics(public,c.load('red-run.json.gz')['run'])
        passed(c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'history_oracle.py','--control']))
    return dict(prior_inputs=previous,epochs=epochs,value_cases=34,diagnostic_controls=14,
        accepted_failures=review['failures'],source_faults=4,history=historical,phase0_roots=5,
        direct_suites=9,direct_assertions=int(match[2]),book_inputs=len(doc_inputs['book']),book_examples=3,
        limits='Bounded Perl drop producer repair: normal/FATAL syntax loading, copied source, evaluated keys, '
               'explicit flat splices and typed shapes. Fixed48 public population; retained accepted/candidate '
               'epochs and current fresh replay. Diagnostic controls preserve underlying source/arity/null '
               'behavior; reference-key coercion has no portable admission. Nine suites are retained actual '
               'executions with complete context; focused Phase0 selects five real roots, not full1035. '
               'Whole accepted numeric publication/10202 inputs and actual clean readonly0 remain separate. '
               'Historical normalization preserves all644 prior controls plus6, archive134/84613241 bytes, '
               '22 recovery denials and zero original-log/tracked-write guard. Rejected shape/selector/oracle '
               'preparations and the exact hash-gated README before-image recovery remain retained. '
               'Canonical receipt separately admits the staged candidate. Aggregate7/inventory and startup '
               'repair owners remain; no full hash-family, backend or parent admission.')


if __name__=='__main__':print(json.dumps(check(fresh=False),sort_keys=True))
