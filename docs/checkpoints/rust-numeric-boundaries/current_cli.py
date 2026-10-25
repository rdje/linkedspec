"""Fresh primary CLI, exact rendered examples and retained process channels."""
import json
from pathlib import Path
import struct
import common as c
from execute_emitted import matches


def main():
    books=c.load('book6-after-inputs.json.gz')
    assert all(c.read(path)==packet for path,packet in books['inputs'].items())
    fixture=json.loads(c.source('tests/numeric-conversion/programs.json').read_text())
    width=struct.calcsize('P')*8
    cases=[row for row in fixture['cases'] if row['pointer_width'] in (None,width)]
    numbers=json.loads(c.source('tests/numeric-conversion/cases.json').read_text())
    indexed={row['id']:row for row in numbers['cases']}
    def number(name):
        row=indexed[name]
        return {key:row[key] for key in ('json_kind','integer')}|{'binary64':row['bits']}
    book_targets=[{'array':[number('large-positive'),number('large-negative'),number('small-positive')]},
        {'exact':['100000000000000000000',21,{'100000000000000000000':7}]}]
    assert len(books['examples'])==len(book_targets)==2
    for index,(source,target) in enumerate(zip(books['examples'],book_targets)):
        cases.append(dict(id='book/'+str(index+1),source=source+'\n',input='x',expected={'ok':target}))
    baseline=c.load('before-cli-inputs.json.gz')
    text=next(row for row in baseline['cases'] if row['name']=='text-control')
    old=c.load('before-cli-result.json.gz')['observed']['text-control']['rust']
    cases.append(dict(id='text-control/55.2',source=text['source'],input='xhello',
        expected={'ok':{'exact':old}}))
    extras=['rust/linkedspec-core/src/numeric.rs',
        'rust/linkedspec-core/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_bridge_contract.rs',
        'tests/numeric-conversion/cases.json','tests/numeric-conversion/programs.json',
        c.PREFIX+'book6-after-inputs.json.gz',c.PREFIX+'before-cli-inputs.json.gz',
        c.PREFIX+'before-cli-result.json.gz']+list(books['inputs'])
    supplied=c.context(extras)
    c.save('current-cli-inputs.json.gz',dict(context=supplied,cases=cases,
        scope='Selected actual pointer-width population, two exact rendered numeric '
            'examples, and unchanged Rust cat control. CLI failure observations '
            'cover its generic invocation boundary only; exact typed error fields '
            'remain native/generated/emitted observations. No portable spelling admission.'))
    build=c.run(['bash','tools/run_cargo_local.sh','build','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p','linkedspec-runtime','--bin','linkedspec-rust',
        '--message-format=json'])
    c.save('current-cli-build.json.gz',build);assert build['returncode']==0
    files=[]
    for line in c.decode(build['stdout_base64']).splitlines():
        item=json.loads(line)
        if item.get('reason')=='compiler-artifact' and item.get('executable') \
                and item['target']['name']=='linkedspec-rust':files.append(Path(item['executable']))
    assert len(files)==1
    path=files[0].relative_to(c.ROOT).as_posix();artifact=c.archive(files[0],'current-cli')
    c.save('current-cli-binary.json',dict(path=path,artifact=artifact))
    runs=[];failures=[]
    for case in cases:
        channels={level:c.run(['./'+path,'--inline-spec',case['source'],
            '--input',case['input'],'--trace',level]) for level in ('none','low')}
        quiet,trace=channels['none'],channels['low']
        if 'ok' in case['expected']:
            correct=quiet['returncode']==trace['returncode']==0
            actual=json.loads(c.decode(quiet['stdout_base64'])) if quiet['returncode']==0 else None
            correct=correct and matches(actual,case['expected']['ok'])
            correct=correct and not c.decode(quiet['stderr_base64']) and not c.decode(trace['stderr_base64'])
            correct=correct and b'compile:ok' in c.decode(trace['stdout_base64']) \
                and b'invoke:ok' in c.decode(trace['stdout_base64'])
        else:
            actual=None
            message=b'linkedspec: parser invocation failed\n'
            correct=quiet['returncode']==trace['returncode']==1 \
                and not c.decode(quiet['stdout_base64']) \
                and c.decode(quiet['stderr_base64'])==c.decode(trace['stderr_base64'])==message \
                and b'compile:ok' in c.decode(trace['stdout_base64']) \
                and b'invoke:error' in c.decode(trace['stdout_base64'])
        row=dict(id=case['id'],channels=channels,actual=actual,matches=correct)
        runs.append(row)
        if not correct:failures.append(case['id'])
    stable=c.identity(path)=={key:artifact[key] for key in ('sha256','mode')}
    inputs_stable=c.unchanged(supplied['inputs'])
    c.save('current-cli-runs.json.gz',dict(runs=runs,failures=failures,
        executable_unchanged=stable,inputs_unchanged=inputs_stable))
    assert stable and inputs_stable
    print('Current primary CLI:',len(cases),'cases/',len(cases)*2,
        'full channels; mismatches:',len(failures),flush=True)
    assert not failures,failures


if __name__ == '__main__':
    main()
