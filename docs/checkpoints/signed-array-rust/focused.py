"""Capture final direct-dependent Cargo compatibility, actual binaries and book CLI."""
import json
from pathlib import Path
import common as c
import epoch
import binary
import book

TEST='rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'
FIXTURE='tests/signed-array-rust/cases.json'
SUITES=['write_vivification_contract','map_leaves_mutation_contract','scalar_numeric_contract',
    'callable_codeblock_literal_contract','uniform_binding_contract','integration_test','corpus_oracle']


def main():
    supplied=epoch.snapshot([TEST,FIXTURE,*book.EXAMPLES])
    c.write_new('focused-inputs.json.gz',dict(context=supplied,producer=c.read(c.PREFIX+'focused.py')))
    build_command=['bash','tools/run_cargo_local.sh','test','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p','linkedspec-runtime','--lib']
    for suite in SUITES:build_command+=['--test',suite]
    build=c.run(build_command+['--no-run','--message-format=json'])
    c.write_new('focused-build.json.gz',build);assert build['returncode']==0
    executables={}
    for line in c.decode(build['stdout_base64']).splitlines():
        item=json.loads(line)
        if item.get('reason')=='compiler-artifact' and item.get('executable') and item.get('profile',{}).get('test'):
            name=item['target']['name']
            if name in SUITES or name=='linkedspec_runtime':
                assert name not in executables
                path=Path(item['executable']).relative_to(c.ROOT).as_posix()
                executables[name]=dict(path=path,artifact=binary.archive(c.source(path),'focused-'+name))
    assert set(executables)==set(SUITES)|{'linkedspec_runtime'}
    c.write_new('focused-binaries.json.gz',executables)
    runs={}
    for name,executable in executables.items():
        selector=['--lib'] if name=='linkedspec_runtime' else ['--test',name]
        run=c.run(['bash','tools/run_cargo_local.sh','test','--manifest-path','rust/Cargo.toml',
            '--locked','--offline','-p','linkedspec-runtime',*selector,'--','--nocapture'])
        runs[name]=run;c.write_new('focused-'+name+'-run.json.gz',run)
        assert c.identity(executable['path'])=={key:executable['artifact'][key] for key in ('sha256','mode')}
        assert run['returncode']==0,'compatibility suite: '+name
        print('Compatibility PASS:',name,flush=True)
    cli_build=c.run(['bash','tools/run_cargo_local.sh','build','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p','linkedspec-runtime','--bin','linkedspec-rust'])
    c.write_new('current-cli-build.json.gz',cli_build);assert cli_build['returncode']==0
    cli='rust/target/debug/linkedspec-rust';artifact=binary.archive(c.source(cli),'current-cli')
    rows={}
    for path,expected in book.EXAMPLES.items():
        source=c.decode(c.read(path)['base64']).decode()
        run=c.run([cli,'--inline-spec',source,'--input','x'])
        rows[path]=dict(source=source,expected=expected,run=run)
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
        assert json.loads(c.decode(run['stdout_base64']))==expected
    path='examples/negative-array-write-perl.spec'
    wrong=rows[path]['source'].replace('items[-2]=99','items[-1]=99')
    assert wrong!=rows[path]['source']
    wrong_run=c.run([cli,'--inline-spec',wrong,'--input','x'])
    assert wrong_run['returncode']==0 and not c.decode(wrong_run['stderr_base64'])
    assert json.loads(c.decode(wrong_run['stdout_base64']))!=book.EXAMPLES[path]
    c.write_new('book-cli-runs.json.gz',dict(executable=artifact,rows=rows,wrong=dict(source=wrong,run=wrong_run),
        executable_unchanged=c.identity(cli)=={key:artifact[key] for key in ('sha256','mode')}))
    checks={name:c.run(command) for name,command in {
        'frozen_write':['bash','tools/run_python_project_data.sh','tools/check_write_vivification_contract.py'],
        'signed_target':['bash','tools/run_python_project_data.sh','tools/check_signed_array_selector_contract.py'],
        'format':['bash','tools/run_cargo_local.sh','fmt','--manifest-path','rust/Cargo.toml','-p','linkedspec-core','-p','linkedspec-runtime','--','--check'],
        'book':['bash','tools/run_mdbook_local.sh'],
    }.items()}
    c.write_new('focused-checks.json.gz',dict(checks=checks,inputs_unchanged=c.unchanged(supplied['inputs'])))
    assert all(run['returncode']==0 for run in checks.values())
    assert c.unchanged(supplied['inputs'])
    print('Final direct compatibility, four CLI book examples, actual wrong selector and focused checks PASS.',flush=True)


if __name__=='__main__':main()
