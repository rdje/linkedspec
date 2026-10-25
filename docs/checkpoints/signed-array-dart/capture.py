"""One-shot public Dart setup/baseline captures, separate from readonly review."""
import json
import sys
import common as c

DART=['bash','tools/run_dart_project_data.sh']


def setup():
    supplied=c.context()
    c.save('setup-inputs.json.gz',supplied)
    commands=[DART+['--version'],DART+['compile','exe','--help'],
        DART+['--packages=dart/.dart_tool/package_config.json',
              'dart/bin/linkedspec_dart.dart','--help']]
    results=[c.run(command) for command in commands]
    c.save('setup-runs.json.gz',dict(runs=results,inputs_unchanged=c.unchanged(supplied['inputs'])))
    assert all(row['returncode']==0 for row in results)
    for row in results:
        print(c.decode(row['stdout_base64']).decode(),end='')
        print(c.decode(row['stderr_base64']).decode(),end='')


def before():
    cases=[
        dict(id='ordinary-read',body='items=[10,20,30]; return([items[-1],items[-2],items[-3],items[-4],items[0]])',expected=[30,20,10,None,10]),
        dict(id='callable-read',body='cb={|| items=[10,20,30]; return([items[-1],items[-2],items[-3],items[-4],items[0]]) }; return(cb())',expected=[30,20,10,None,10]),
        dict(id='ordinary-write',body='items=[10,20,30]; items[-1]=99; return(items)',expected=[10,20,99]),
        dict(id='callable-write',body='cb={|| items=[10,20,30]; items[-1]=99; return(items) }; return(cb())',expected=[10,20,99]),
        dict(id='positive-control',body='items=[10,20,30]; items[1]=99; return([items[0],items[1],items])',expected=[10,99,[10,99,30]]),
        dict(id='quoted-key-control',body='tree={"-1":7}; tree["-1"]=99; return([tree,tree["-1"]])',expected=[{'-1':99},99]),
        dict(id='missing-read-control',body='empty=[]; return([empty[-1],missing[-1]])',expected=[None,None]),
        dict(id='read-coercion-calibration',body='items=[10,20,30]; return([items[-1.0],items[-1.5],items["-1"],items[true]])',calibration=True),
        dict(id='float-write-calibration',body='items=[10,20,30]; items[-1.0]=99; return(items)',calibration=True),
        dict(id='underflow-calibration',body='items=[10]; items[-2]=99; return(items)',calibration=True),
    ]
    c.save('before-cases.json',dict(version=1,cases=cases,
        scope='Seven independently targeted current-source programs and three backend-coercion/error calibrations. No mismatch credit from calibrations.'))
    execute('before')


def execute(label):
    cases=c.load('before-cases.json')['cases']
    supplied=c.context([c.PREFIX+'before-cases.json'])
    c.save(label+'-inputs.json.gz',dict(context=supplied,producer=c.read(c.PREFIX+'capture.py')))
    executable='.linkedspec-data/verification/signed-dart17-'+label
    assert not (c.ROOT/executable).exists()
    build=c.run(DART+['compile','exe','--packages=dart/.dart_tool/package_config.json',
        c.PREFIX+'probe.dart','-o',executable])
    c.save(label+'-build.json.gz',build)
    assert build['returncode']==0,c.decode(build['stderr_base64']).decode()
    artifact=c.archive(executable,label+'-native')
    c.save(label+'-binary.json',artifact)
    run=c.run([executable,c.PREFIX+'before-cases.json'])
    stable=c.identity(executable)=={key:artifact[key] for key in ('sha256','mode')}
    inputs_stable=c.unchanged(supplied['inputs'])
    c.save(label+'-run.json.gz',dict(run=run,executable_unchanged=stable,inputs_unchanged=inputs_stable))
    assert run['returncode']==0 and stable and inputs_stable
    parsed=[];observed=[];compile_errors=[]
    for line in c.decode(run['stdout_base64']).decode().splitlines():
        tag,raw=line.split('\t',1)
        target={'DART_SIGNED_PARSE':parsed,'DART_SIGNED_RUN':observed,
            'DART_SIGNED_COMPILE_ERROR':compile_errors}[tag]
        target.append(json.loads(raw))
    assert not compile_errors,compile_errors
    assert len(parsed)==len(cases) and len(observed)==len(cases)*3
    targets={row['id']:row for row in cases if 'expected' in row}
    selected=[row for row in observed if row['id'] in targets]
    mismatches=[row for row in selected if 'ok' not in row or row['ok']!=targets[row['id']]['expected']]
    controls=[row for row in selected if row['id'].endswith('control')]
    assert all('ok' in row and row['ok']==targets[row['id']]['expected'] for row in controls)
    if label=='before':
        assert any(row['id']=='ordinary-read' for row in mismatches)
        assert any(row['id']=='ordinary-write' for row in mismatches)
    else:
        assert not mismatches,mismatches
        old={ (row['id'],row['route']):row for row in c.load('before-result.json.gz')['observed'] }
        for row in observed:
            if row['id'] in ['read-coercion-calibration','float-write-calibration']:
                assert row==old[(row['id'],row['route'])],row
            elif row['id']=='underflow-calibration':
                message="nested write segment 0 for binding 'items' cannot select array index -2 at length 1 (resolved index -1)"
                if row['route']=='generated_plan':
                    assert row.get('other_type')=='GeneratedSourceException'
                    assert row.get('other_error')=='Generated Dart parser execution failed: RuntimeInterpreterException: '+message
                else:
                    diagnostic=row['error']['diagnostic']
                    assert row['error']['message']==message
                    assert all(diagnostic.get(key)==value for key,value in dict(
                        code='nested_write_array_underflow',index=-2,length=1,resolved_index=-1).items())
    c.save(label+'-result.json.gz',dict(parsed=parsed,observed=observed,
        targeted=len(selected),mismatches=len(mismatches),controls=len(controls),
        calibration_rows=len(observed)-len(selected)))
    print(json.dumps(dict(programs=len(cases),observations=len(observed),targeted=len(selected),
        mismatches=len(mismatches),controls=len(controls),calibration_rows=len(observed)-len(selected)),sort_keys=True))


if __name__=='__main__':
    assert sys.argv[1:] in (['setup'],['before'],['after1'],['after2'])
    if sys.argv[1:]==['setup']:setup()
    elif sys.argv[1:]==['before']:before()
    else:execute(sys.argv[1])
