"""One-shot fresh emitted libraries and actual primary CLI captures."""
import json
import sys
import common as c
import oracle

DART=['bash','tools/run_dart_project_data.sh']
FIXTURE='tests/signed-array-dart/cases.json'


def build(label,source):
    executable='.linkedspec-data/verification/signed-dart17-'+label
    assert not (c.ROOT/executable).exists()
    run=c.run(DART+['compile','exe','--packages=dart/.dart_tool/package_config.json',source,'-o',executable])
    c.save(label+'-build.json.gz',run)
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
    artifact=c.archive(executable,label+'-native')
    c.save(label+'-binary.json',artifact)
    return executable,artifact


def emitted(label):
    supplied=c.context([FIXTURE])
    c.save(label+'-inputs.json.gz',supplied)
    executable,artifact=build(label+'-generator',c.PREFIX+'emit.dart')
    directory='.linkedspec-data/verification/signed-dart17-'+label+'-modules'
    run=c.run([executable,FIXTURE,directory])
    assert c.identity(executable)=={key:artifact[key] for key in ('sha256','mode')}
    c.save(label+'-generation.json.gz',run)
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
    modules=[json.loads(line) for line in c.decode(run['stdout_base64']).splitlines()]
    cases=json.loads(c.file(FIXTURE).read_bytes())['cases']
    assert [row['id'] for row in modules]==[row['id'] for row in cases]
    root=c.ROOT/directory
    (root/'observe.dart').write_bytes(c.file(c.PREFIX+'emitted_observe.dart').read_bytes())
    source="import 'dart:convert';\nimport 'dart:io';\nimport 'observe.dart';\n"
    source+=''.join("import '"+row['file']+"' as m"+str(index)+";\n" for index,row in enumerate(modules))
    source+="void main(List<String> args) {\nfinal cases=(jsonDecode(File(args.single).readAsStringSync()) as Map)['cases'] as List;\n"
    for index,row in enumerate(modules):
        source+=f"print('DART_EMITTED\\t${{jsonEncode(observeEmitted(cases[{index}] as Map, m{index}.execute))}}');\n"
    source+='}\n'
    (root/'main.dart').write_text(source)
    paths=sorted(path.relative_to(c.ROOT).as_posix() for path in root.iterdir() if path.is_file())
    packets={path:c.read(path) for path in paths}
    c.save(label+'-module-inputs.json.gz',dict(modules=modules,sources=packets,
        scope='All113 actual freshly emitted libraries, exact driver and observer before AOT compilation/execution. '
            'Generated public wrappers retain their established error and caller-sink exception contract.'))
    child,binary=build(label+'-caller',directory+'/main.dart')
    observed=c.run([child,FIXTURE])
    stable=c.unchanged(supplied['inputs']) and all(c.read(path)==value for path,value in packets.items())
    stable=stable and c.identity(child)=={key:binary[key] for key in ('sha256','mode')}
    c.save(label+'-run.json.gz',dict(run=observed,inputs_modules_and_executables_unchanged=stable))
    assert observed['returncode']==0 and stable,c.decode(observed['stderr_base64']).decode()
    rows=[]
    for line in c.decode(observed['stdout_base64']).decode().splitlines():
        tag,raw=line.split('\t',1);assert tag=='DART_EMITTED';rows.append(json.loads(raw))
    assert [row['id'] for row in rows]==[row['id'] for row in cases]
    failures=[dict(id=case['id'],fields=errors,actual=row)
        for case,row in zip(cases,rows) if (errors:=oracle.check(case,row))]
    c.save(label+'-result.json.gz',dict(modules=len(modules),observations=len(rows),failures=failures,observed=rows))
    print(json.dumps(dict(modules=len(modules),observations=len(rows),failures=len(failures))),flush=True)
    if failures:print(json.dumps(failures[:5],ensure_ascii=False,indent=2),flush=True)
    assert not failures


def cli(label):
    supplied=c.context([FIXTURE,'tools/run_cli_conformance.pl'])
    c.save(label+'-inputs.json.gz',supplied)
    executable,binary=build(label,'dart/bin/linkedspec_dart.dart')
    cases=[row for row in json.loads(c.file(FIXTURE).read_bytes())['cases'] if 'injection' not in row]
    directory=c.ROOT/'.linkedspec-data/verification'/('signed-dart17-'+label+'-traces')
    directory.mkdir(exist_ok=False)
    runs=[];failures=[]
    for index,case in enumerate(cases):
        for tracing in (False,True):
            command=[executable,'--inline-spec',case['source'],'--input','x','--top-rule','Top']
            trace=directory/(str(index)+'.trace')
            if tracing:command+=['--trace','high','--trace-file',trace.relative_to(c.ROOT).as_posix(),
                '--trace-mode','route','--trace-reset']
            run=c.run(command)
            row=dict(id=case['id'],tracing=tracing,run=run)
            if tracing:
                row['trace']=c.read(trace.relative_to(c.ROOT))
                assert c.decode(row['trace']['base64'])
            stdout=c.decode(run['stdout_base64']).decode()
            stderr=c.decode(run['stderr_base64']).decode()
            if 'ok' in case['expected']:
                try:value=json.loads(stdout)
                except json.JSONDecodeError:value={'invalid_json':stdout}
                accepted=run['returncode']==0 and stderr=='' and oracle.same(value,case['expected']['ok'])
            else:
                accepted=run['returncode']==1 and stdout=='' and stderr=='linkedspec: parser invocation failed\n'
            if tracing:
                text=c.decode(row['trace']['base64']).decode()
                accepted=accepted and 'compile:ok' in text and ('invoke:ok' if 'ok' in case['expected'] else 'invoke:error') in text
            row['accepted']=accepted;runs.append(row)
            if not accepted:failures.append(row)
    stable=c.unchanged(supplied['inputs']) and c.identity(executable)=={
        key:binary[key] for key in ('sha256','mode')}
    c.save(label+'-result.json.gz',dict(programs=len(cases),runs=runs,failures=failures,
        inputs_and_executable_unchanged=stable,
        scope='Actual quiet/routed-trace primary CLI values and exact generic invocation-phase failure output. '
            'Caller sink injection cases are excluded because CLI does not expose that embedding hook. '
            'No private-state, embedding-effect, detailed-message or typed-diagnostic CLI claim.'))
    print(json.dumps(dict(programs=len(cases),runs=len(runs),failures=len(failures),stable=stable)),flush=True)
    if failures:print(json.dumps(failures[:3],ensure_ascii=False,indent=2),flush=True)
    assert not failures and stable


if __name__=='__main__':
    assert len(sys.argv)==3
    {'emitted':emitted,'cli':cli}[sys.argv[1]](sys.argv[2])
