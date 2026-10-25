"""Read-only re-derivation from retained source, channels and executable bytes."""
import gzip
import json
import subprocess
import types
from pathlib import Path
import common as c
import oracle
import book


def packets(value):
    if isinstance(value,dict):
        if {'base64','sha256','mode'} <= value.keys():
            assert c.sha(c.decode(value['base64']))==value['sha256'],'retained packet digest'
            assert isinstance(value['mode'],int) and 0<=value['mode']<=0o7777,'retained packet mode'
        for item in value.values():packets(item)
    elif isinstance(value,list):
        for item in value:packets(item)


def binary(record):
    packed=[]
    for part in record['parts']:
        raw=c.file(part['path']).read_bytes()
        assert len(raw)==part['bytes'] and c.sha(raw)==part['sha256']
        assert c.identity(part['path'])['mode']==part['mode']
        packed.append(raw)
    raw=gzip.decompress(b''.join(packed))
    assert c.sha(raw)==record['sha256'] and len(raw)==record['bytes'],'whole actual executable'
    assert record['mode'] & 0o111,'actual executable mode'


def git_baseline(context):
    tree=subprocess.check_output(['git','ls-tree','-r','-z',c.BASE,'dart','specs'],cwd=c.ROOT)
    files=[]
    for row in tree.split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.split()
        if kind==b'blob':files.append((name.decode(),int(mode,8)&0o7777))
    queries=''.join(c.BASE+':'+name+'\n' for name,_ in files).encode()
    output=subprocess.check_output(['git','cat-file','--batch'],input=queries,cwd=c.ROOT)
    offset=0
    for name,mode in files:
        end=output.index(b'\n',offset);header=output[offset:end].split();assert header[1]==b'blob'
        length=int(header[2]);raw=output[end+1:end+1+length];offset=end+length+2
        packet=context['sources'][name]
        # Git stores executable class; observed full permissions have their own guards.
        assert c.decode(packet['base64'])==raw and (packet['mode']&0o100)==(mode&0o100),'actual clean baseline '+name
    assert offset==len(output)
    return len(files)


def private_review():
    inputs=c.load('private2-inputs.json.gz')
    copied=c.load('private2-copy.json.gz')
    production=c.load('public3-inputs.json.gz')['sources']
    suffix=c.decode(copied['suffix']['base64'])
    expected_libraries={path for path in production if path.startswith('dart/lib/')}
    assert {row['original'] for row in copied['files'].values()}==expected_libraries
    for row in copied['files'].values():
        original=c.decode(production[row['original']]['base64'])
        assert row['original_sha256']==c.sha(original) and row['original_bytes']==len(original)
        actual=c.decode(row['actual']['base64'])
        assert actual==original+(b'\n'+suffix if row['original'].endswith('/runtime/interpreter.dart') else b'')
        assert row['actual']['mode']==production[row['original']]['mode']
    fixture=c.load('private2-cases.json')
    assert c.decode(inputs['sources'][c.PREFIX+'private2-cases.json']['base64'])==c.file(c.PREFIX+'private2-cases.json').read_bytes()
    run=c.load('private2-run.json.gz');assert run['inputs_and_copy_and_executable_unchanged']
    assert run['run']['returncode']==0
    observed={};arithmetic={}
    for line in c.decode(run['run']['stdout_base64']).decode().splitlines():
        tag,raw=line.split('\t',1);row=json.loads(raw)
        target={'DART_PRIVATE':observed,'DART_ARITHMETIC':arithmetic}[tag]
        assert row['id'] not in target;target[row['id']]=row
    authority=json.loads(c.decode(inputs['sources']['capability_conformance/signed_array_selector_contract.json']['base64']))
    assert len(observed)==51 and len(arithmetic)==12
    reads={row['id']:row for row in authority['read_cases']}
    writes={row['id']:row for row in authority['write_cases']}
    for row in fixture['cases']:
        actual=observed[row['id']]
        if row['id'].startswith('read/'):
            original=reads[row['id'][5:]]
            assert row['id']=='read/'+original['id']
            assert all(row[key]==value for key,value in original.items() if key!='id')
            assert oracle.same(actual['ok'],original['expected_result'])
            assert oracle.same(actual['binding'],original['expected_binding']) and actual['effects']==[]
            continue
        if row['id'].startswith('write/'):
            original=writes[row['id'][6:]]
            assert row['id']=='write/'+original['id']
            assert all(row[key]==value for key,value in original.items() if key!='id')
        expected=row['expected']
        binding=actual['binding']
        if 'detachment' in row:
            assert row['detachment']==authority['detachment_probe']
            assert oracle.same(actual['detachment'],row['detachment']['expected'])
            binding=dict(present=True,value=actual['binding_before_detachment'])
        assert oracle.same(binding,expected['binding']),row['id']+' private binding'
        assert oracle.same(actual['effects'],expected['effects'])
        if expected['error'] is None:
            assert 'error' not in actual and oracle.same(actual['ok'],expected['result'])
        else:
            assert 'ok' not in actual
            diagnostic=actual['error']['diagnostic']
            for key,value in expected['error'].items():
                if key=='source_span':value={name:item for name,item in value.items() if name!='source_id'}
                assert oracle.same(diagnostic.get('detail' if key=='message' else key),value),(row['id'],key)
            if expected['error']['code']=='fixture_evaluation_failed':assert actual['injected_identity'] is True
        if row.get('guard'):
            same=row['guard']['active_identity']==row['guard']['target_identity']
            assert actual['same_identity'] is same
            if not same:
                assert actual['outer_restored'] is True
                assert oracle.same(actual['outer_value'],row['initial_binding']['value'])
    assert fixture['arithmetic']==authority['arithmetic_cases']
    for row in authority['arithmetic_cases']:
        actual=arithmetic[row['id']];expected=row['expected']
        assert oracle.same(actual['read'],expected['resolved_index'] if expected['readable'] else None)
        assert ('ok' in actual) is expected['writable']
        if expected['writable']:
            wanted=list(range(row['length']));index=expected['resolved_index']
            if index==len(wanted):wanted.append(99)
            else:wanted[index]=99
            assert oracle.same(actual['ok'],wanted)
        elif row['index']<0:
            assert oracle.same(actual['error']['diagnostic']['resolved_index'],expected['resolved_index'])
    return dict(private_cases=len(observed),arithmetic=len(arithmetic),copied_libraries=len(expected_libraries))


def historical():
    result=c.load('history-final-result.json.gz');run=c.load('history-final-run.json.gz')
    assert run['returncode']==0 and run['producer_inputs_unchanged']
    assert json.loads(c.decode(run['stdout_base64']))==result
    assert not c.decode(run['stderr_base64'])
    assert result['restored_inputs']==134 and result['restored_bytes']==84613241
    assert len(result['controls'])==22 and result['isolated_deterministic_capture']
    assert result['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    inputs=c.load('history-final-read-inputs.json.gz')
    audit=types.ModuleType('retained_dart_signed_auditor')
    audit.__file__=str(c.ROOT/'tests/language-readiness/verify_objectives.py')
    exec(compile(c.decode(inputs['loaded_sources']['tests/language-readiness/verify_objectives.py']['base64']),audit.__file__,'exec'),audit.__dict__)
    def read(path):return c.decode(inputs['files'][path]['base64'])
    updates=result['audit_report']['runtime_source_updates']
    assert len(updates)==3
    for row in updates:
        if row['owner']==c.OWNER:
            assert audit.verify_dart_signed_evolution(row['path'],read(row['path']),row['historical'])==row
        else:
            assert row['owner']=='SESSION-STARTUP-READING.55.1'
            assert audit.verify_rust_numeric_evolution(row['path'],read(row['path']),row['historical'],read=read)==row
    assert result['audit_controls']['runtime_source_mutations_rejected']==9
    assert len(result['audit_controls']['numeric_support_mutations_rejected'])==5
    # Independently decode the actual retained archive and match every observed restored byte stream.
    import io,zipfile
    archive=read(result['archive']['path'])
    assert c.sha(archive)==result['archive']['sha256'] and len(archive)==result['archive']['bytes']
    with zipfile.ZipFile(io.BytesIO(archive)) as source:
        streams=[source.read(row) for row in source.infolist()]
    assert len(streams)==134 and sum(map(len,streams))==84613241
    assert sorted((c.sha(raw),len(raw)) for raw in streams)==sorted(
        (row['sha256'],row['bytes']) for row in inputs['isolated_reads'].values())
    assert sorted(map(c.sha,streams))==sorted(result['audit_report']['retained_log_hashes'].values())
    original=c.load('admission-unregistered-run.json.gz')
    assert original['inputs_unchanged'] and original['run']['returncode']!=0
    assert b'current executable evidence drift: dart/lib/src/runtime/interpreter.dart' in c.decode(original['run']['stderr_base64'])
    for name,reason in [('accepted-rollback',b'current executable evidence drift: dart/lib/src/runtime/interpreter.dart'),
        ('actual-hash-guard-bypass',b'runtime corruption control did not reject')]:
        row=c.load('auditor-'+name+'.json.gz')
        assert row['all_supplied_inputs_unchanged'] and row['run']['returncode']!=0
        assert reason in c.decode(row['run']['stderr_base64'])
    restored=c.load('auditor-restored.json.gz')
    assert restored['run']['returncode']==0 and restored['all_supplied_inputs_unchanged']
    assert json.loads(c.decode(restored['run']['stdout_base64']))==result
    faults=c.load('auditor-fault-result.json.gz')
    assert faults['exact_source_and_mode_restored'] and faults['direct_rejections']==4
    assert faults['actual_bypass_admits_unreviewed_source'] and faults['actual_bypass_rejected_by_driver']
    return dict(historical_streams=134,historical_bytes=84613241,recovery_controls=22,source_denials=9,support_denials=5)


def check():
    for path in sorted((c.ROOT/c.PREFIX).iterdir()):
        if path.name.endswith(('.json','.json.gz')):
            raw=path.read_bytes();packets(json.loads(gzip.decompress(raw) if path.suffix=='.gz' else raw))
    binaries=0
    for path in sorted((c.ROOT/c.PREFIX).glob('*-binary.json')):
        binary(json.loads(path.read_bytes()));binaries+=1
    before=c.load('before-inputs.json.gz')['context']
    baseline_files=git_baseline(before)
    targets={row['id']:row for row in c.load('before-cases.json')['cases'] if 'expected' in row}
    baseline=c.load('before-run.json.gz')
    assert baseline['run']['returncode']==0 and baseline['inputs_unchanged'] and baseline['executable_unchanged']
    observed=[]
    for line in c.decode(baseline['run']['stdout_base64']).decode().splitlines():
        tag,raw=line.split('\t',1)
        if tag=='DART_SIGNED_RUN':observed.append(json.loads(raw))
    selected=[row for row in observed if row['id'] in targets]
    mismatches=[row for row in selected if 'ok' not in row or not oracle.same(row['ok'],targets[row['id']]['expected'])]
    assert len(observed)==30 and len(selected)==21 and len(mismatches)==12
    assert all('ok' in row and oracle.same(row['ok'],targets[row['id']]['expected'])
        for row in selected if row['id'].endswith('control'))
    current=c.load('public3-inputs.json.gz')
    fixture=json.loads(c.decode(current['sources']['tests/signed-array-dart/cases.json']['base64']))
    cases=fixture['cases'];assert len(cases)==113
    raw=c.load('public3-runs.json.gz')
    assert raw['matrix']['returncode']==raw['tests']['returncode']==0
    assert raw['inputs_unchanged'] and raw['executable_unchanged']
    public=oracle.review(c.decode(raw['matrix']['stdout_base64']),cases)
    assert public['failure_count']==0 and public['observations']==452
    source=c.load('source-fault-lease.json.gz')
    assert source['before']==current['sources']['dart/lib/src/runtime/interpreter.dart']
    source_faults=c.load('source-fault-result.json')
    assert source_faults['exact_bytes_and_mode_restored']
    for name,target in source_faults['results'].items():
        run=c.load('source-fault-'+name+'-run.json.gz')
        assert run['run']['returncode']==0 and run['inputs_and_executable_unchanged']
        outcome=oracle.review(c.decode(run['run']['stdout_base64']),cases)
        assert outcome['failure_count']==target['failures'] and outcome['failure_count']>0
        assert set(target['distinguishing'])<={row['id'] for row in outcome['failures']}
    modules=c.load('emitted1-module-inputs.json.gz');run=c.load('emitted1-run.json.gz')
    assert len(modules['modules'])==113 and len(modules['sources'])==115
    assert run['run']['returncode']==0 and run['inputs_modules_and_executables_unchanged']
    emitted=[]
    for line in c.decode(run['run']['stdout_base64']).decode().splitlines():
        tag,raw=line.split('\t',1);assert tag=='DART_EMITTED';emitted.append(json.loads(raw))
    assert [row['id'] for row in emitted]==[row['id'] for row in cases]
    assert all(not oracle.check(case,row) for case,row in zip(cases,emitted))
    cli=c.load('cli2-result.json.gz');assert cli['inputs_and_executable_unchanged']
    selected={row['id']:row for row in cases if 'injection' not in row}
    assert len(selected)==107 and len(cli['runs'])==214
    assert {(row['id'],row['tracing']) for row in cli['runs']}=={
        (identifier,tracing) for identifier in selected for tracing in (False,True)}
    for row in cli['runs']:
        expected=selected[row['id']]['expected'];run=row['run']
        stdout=c.decode(run['stdout_base64']);stderr=c.decode(run['stderr_base64'])
        if 'ok' in expected:
            assert run['returncode']==0 and not stderr and oracle.same(json.loads(stdout),expected['ok'])
        else:assert run['returncode']==1 and not stdout and stderr==b'linkedspec: parser invocation failed\n'
        if row['tracing']:
            trace=c.decode(row['trace']['base64'])
            assert b'compile:ok' in trace and (b'invoke:ok' if 'ok' in expected else b'invoke:error') in trace
    component=c.load('component-result.json')['returncodes']
    assert component['whole-format']==1 and component['whole-analysis']==2
    assert all(code==0 for name,code in component.items() if name not in ('whole-format','whole-analysis'))
    tests=c.load('component-all-tests.json.gz');assert tests['inputs_unchanged']
    assert b'+636: All tests passed!' in c.decode(tests['run']['stdout_base64'])
    for name in component:
        row=c.load('component-'+name+'.json.gz')
        assert row['inputs_unchanged'] and row['run']['returncode']==component[name]
    saved=c.load('book-after-inputs.json.gz');runs=c.load('book-runs.json.gz');legacy,_=book.helpers()
    book.validate(legacy,runs['healthy'],saved['inputs'])
    assert runs['inputs_unchanged'] and len(saved['inputs'])==95 and len(runs['healthy']['outputs'])==90
    assert set(runs['faults'])=={'heading','coercion','example','admission'}
    for name,row in runs['faults'].items():
        supplied=dict(saved['inputs'])|row['changed_inputs']
        assert row['run']['returncode']==0
        try:book.validate(legacy,row['run'],supplied)
        except AssertionError:pass
        else:raise AssertionError('retained book fault admitted: '+name)
    return dict(public_programs=113,public_observations=452,permanent_tests=114,
        baseline_targets=21,baseline_red=12,baseline_controls=9,baseline_git_files=baseline_files,
        source_faults=len(source_faults['results']),emitted_modules=113,cli_programs=107,cli_runs=214,
        package_tests=636,cli_conformance='66x2',corpus=105,
        component_debt='Existing non-writing format1/analysis2; no full component-gate PASS',
        actual_binaries=binaries,book_inputs=95,book_outputs=90,book_denials=4,
        **private_review(),**historical())


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
