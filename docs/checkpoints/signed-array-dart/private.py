"""One-shot copied-library private-state observation with exact prefix custody."""
import copy
import json
import subprocess
import sys
import common as c
from oracle import same


def main(label):
    assert label.startswith('private') and label[7:].isdigit()
    authority=json.loads(c.file('capability_conformance/signed_array_selector_contract.json').read_bytes())
    rows=[dict(copy.deepcopy(row),private_kind='read',id='read/'+row['id'])
        for row in authority['read_cases']]
    rows += [dict(copy.deepcopy(row),private_kind='write',id='write/'+row['id'])
        for row in authority['write_cases']]
    rows += [dict(copy.deepcopy(row),private_kind='write',id='extra/'+row['id'])
        for row in json.loads(c.file('tests/signed-array-dart/cases.json').read_bytes())['private_extended']]
    detached=next(copy.deepcopy(row) for row in authority['write_cases']
        if row['id']==authority['detachment_probe']['case_id'])
    detached.update(id='detachment',private_kind='write',detachment=authority['detachment_probe'])
    rows.append(detached)
    fixture=dict(cases=rows,arithmetic=authority['arithmetic_cases'])
    c.save(label+'-cases.json',fixture)
    extras=['tests/signed-array-dart/cases.json',c.PREFIX+label+'-cases.json']
    supplied=c.context(extras)
    c.save(label+'-inputs.json.gz',supplied)
    destination=c.ROOT/'.linkedspec-data/verification'/('signed-dart17-'+label)
    destination.mkdir(exist_ok=False)
    names=subprocess.check_output(['git','ls-files','dart/lib'],cwd=c.ROOT,text=True).splitlines()
    copied={}
    suffix=c.file(c.PREFIX+'private_probe.dart').read_bytes()
    for name in names:
        relative=name.removeprefix('dart/')
        raw=c.file(name).read_bytes()
        target=destination/relative
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_bytes(raw+(b'\n'+suffix if name.endswith('/runtime/interpreter.dart') else b''))
        target.chmod(c.file(name).stat().st_mode & 0o7777)
        actual=target.read_bytes()
        assert actual==raw+(b'\n'+suffix if name.endswith('/runtime/interpreter.dart') else b'')
        copied[relative]=dict(original=name,original_sha256=c.sha(raw),original_bytes=len(raw),
            actual=c.read(target.relative_to(c.ROOT)))
    (destination/'main.dart').write_bytes(c.file(c.PREFIX+'private_main.dart').read_bytes())
    c.save(label+'-copy.json.gz',dict(files=copied,driver=c.read((destination/'main.dart').relative_to(c.ROOT)),
        suffix=c.read(c.PREFIX+'private_probe.dart'),
        scope='Every first-party Dart library is copied byte-for-byte; only the exact separately '
            'retained observer suffix is appended to interpreter.dart. No production exports or '
            'semantics are replaced. Private typed ActionIR and stores complement the separate '
            'real authored public/native/generated matrix; this is not an external API.'))
    executable=(destination/'observe').relative_to(c.ROOT).as_posix()
    build=c.run(['bash','tools/run_dart_project_data.sh','compile','exe',
        '--packages=dart/.dart_tool/package_config.json',
        (destination/'main.dart').relative_to(c.ROOT).as_posix(),'-o',executable])
    c.save(label+'-build.json.gz',build)
    assert build['returncode']==0,c.decode(build['stderr_base64']).decode()
    binary=c.archive(executable,label+'-native')
    c.save(label+'-binary.json',binary)
    run=c.run([executable,c.PREFIX+label+'-cases.json'])
    stable=c.unchanged(supplied['inputs']) and all(
        c.read((destination/name).relative_to(c.ROOT))==record['actual'] for name,record in copied.items())
    stable=stable and c.identity(executable)=={key:binary[key] for key in ('sha256','mode')}
    c.save(label+'-run.json.gz',dict(run=run,inputs_and_copy_and_executable_unchanged=stable))
    assert run['returncode']==0 and stable,c.decode(run['stderr_base64']).decode()
    observed={};arithmetic={}
    for line in c.decode(run['stdout_base64']).decode().splitlines():
        tag,raw=line.split('\t',1);row=json.loads(raw)
        selected={'DART_PRIVATE':observed,'DART_ARITHMETIC':arithmetic}[tag]
        assert row['id'] not in selected
        selected[row['id']]=row
    assert observed.keys()=={row['id'] for row in rows}
    assert arithmetic.keys()=={row['id'] for row in authority['arithmetic_cases']}
    failures=[]
    for row in rows:
        actual=observed[row['id']]
        expected=row.get('expected')
        checks={}
        if row['private_kind']=='read':
            checks.update(value=same(actual.get('ok'),row['expected_result']),
                binding=same(actual['binding'],row['expected_binding']),effects=actual['effects']==[])
        else:
            binding=actual['binding']
            if 'detachment' in row:
                binding=dict(present=True,value=actual['binding_before_detachment'])
                checks['detachment']=same(actual['detachment'],row['detachment']['expected'])
            checks.update(binding=same(binding,expected['binding']),
                effects=same(actual['effects'],expected['effects']))
            if expected['error'] is None:
                checks['value']='ok' in actual and same(actual['ok'],expected['result'])
                checks['no_error']='error' not in actual
            else:
                checks['rejected']='ok' not in actual and 'error' in actual
                diagnostic=actual.get('error',{}).get('diagnostic',{})
                for key,value in expected['error'].items():
                    if key=='source_span':value={k:v for k,v in value.items() if k!='source_id'}
                    checks[key]=same(diagnostic.get('detail' if key=='message' else key),value)
                if expected['error']['code']=='fixture_evaluation_failed':
                    checks['identity']=actual.get('injected_identity') is True
            if row.get('guard'):
                checks['same_identity']=actual['same_identity']==(
                    row['guard']['active_identity']==row['guard']['target_identity'])
                if not actual['same_identity']:
                    checks['outer_restored']=actual['outer_restored'] is True
                    checks['outer_value']=same(actual['outer_value'],row['initial_binding']['value'])
        if not all(checks.values()):failures.append(dict(id=row['id'],checks=checks,actual=actual))
    for row in authority['arithmetic_cases']:
        actual=arithmetic[row['id']];expected=row['expected']
        wanted=expected['resolved_index'] if expected['readable'] else None
        checks=dict(read=same(actual['read'],wanted),writable=('ok' in actual)==expected['writable'])
        if expected['writable']:
            target=list(range(row['length']))
            if expected['resolved_index']==len(target):target.append(99)
            else:target[expected['resolved_index']]=99
            checks['written']=same(actual['ok'],target)
        elif row['index']<0:
            checks['resolved']=same(actual['error']['diagnostic'].get('resolved_index'),expected['resolved_index'])
        if not all(checks.values()):failures.append(dict(id='arithmetic/'+row['id'],checks=checks,actual=actual))
    result=dict(cases=len(rows),arithmetic=len(arithmetic),observed=observed,
        arithmetic_observed=arithmetic,failures=failures)
    c.save(label+'-result.json.gz',result)
    print(json.dumps(dict(cases=len(rows),arithmetic=len(arithmetic),failures=len(failures))),flush=True)
    if failures:print(json.dumps(failures,ensure_ascii=False,indent=2),flush=True)
    assert not failures


if __name__=='__main__':
    assert len(sys.argv)==2
    main(sys.argv[1])
