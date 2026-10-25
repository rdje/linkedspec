"""Execute retained compiled tests without an intervening Cargo rebuild."""
import json
import subprocess
import common as c
import epoch
import binary
import book

TEST='rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'
FIXTURE='tests/signed-array-rust/cases.json'
ORDER=['linkedspec_runtime','write_vivification_contract','map_leaves_mutation_contract',
    'scalar_numeric_contract','callable_codeblock_literal_contract','uniform_binding_contract',
    'integration_test','corpus_oracle']


def run_binary(path):
    command=[str(c.source(path)),'--nocapture']
    result=subprocess.run(command,cwd=c.ROOT/'rust/linkedspec-runtime',capture_output=True)
    return dict(command=[path,'--nocapture'],cwd='rust/linkedspec-runtime',
        returncode=result.returncode,stdout_base64=c.encode(result.stdout),stderr_base64=c.encode(result.stderr))


def main():
    prior=c.load('focused-binaries.json.gz')
    assert set(prior)==set(ORDER)
    provisional=c.load('focused-linkedspec_runtime-run.json.gz')
    assert provisional['returncode']==0
    current=c.identity(prior['linkedspec_runtime']['path'])
    assert current!={key:prior['linkedspec_runtime']['artifact'][key] for key in ('sha256','mode')}
    c.write_new('focused-custody-qualification.json.gz',dict(producer=c.read(c.PREFIX+'focused_resume.py'),
        initial_producer=c.read(c.PREFIX+'focused.py'),initial_binary=prior['linkedspec_runtime'],
        after_cargo=current,provisional_run=provisional,
        reason='The no-run batch and subsequent Cargo --lib command are different build invocations. Actual Cargo channels show recompilation and the same test path is replaced. The original driver correctly rejects its stale executable identity before any complete compatibility result. Preserve its188 passing test output as provisional only; do not assign the original archived bytes to that execution. The fresh runner captures actual current bytes immediately before execution, with no intervening Cargo invocation, then checks exact post-run identity.'))
    supplied=epoch.snapshot([TEST,FIXTURE,*book.EXAMPLES])
    books=book.inputs()
    assert books==c.load('alias-book-inputs.json.gz')['updated']
    c.write_new('focused-final-inputs.json.gz',dict(context=supplied,book_inputs=books,
        producer=c.read(c.PREFIX+'focused_resume.py'),
        scope='Actual final direct consumers execute in the Cargo package cwd. Program argv is derived from the current repository root; recorded paths remain root-relative. Initial compiled bytes are reused only after exact current identity confirmation; replaced bytes are freshly archived. No historical SDK reconstruction.'))
    artifacts={}
    for name in ORDER:
        old=prior[name];path=old['path'];before=c.identity(path)
        if before=={key:old['artifact'][key] for key in ('sha256','mode')}:
            artifact=old['artifact'];origin='initial-no-run-exact-current-bytes'
        else:
            artifact=binary.archive(c.source(path),'focused-final-'+name);origin='fresh-current-bytes'
        assert before=={key:artifact[key] for key in ('sha256','mode')}
        artifacts[name]=dict(path=path,artifact=artifact,origin=origin,before_execution=before)
        c.write_new('focused-final-'+name+'-binary.json',artifacts[name])
        run=run_binary(path)
        c.write_new('focused-final-'+name+'-run.json.gz',run)
        after=c.identity(path)
        c.write_new('focused-final-'+name+'-identity.json',dict(before=before,after=after,unchanged=before==after))
        assert before==after,'executed binary changed: '+name
        assert run['returncode']==0,'direct compatibility: '+name
        print('Actual direct compatibility PASS:',name,flush=True)
    c.write_new('focused-final-binaries.json.gz',artifacts)
    build=c.run(['bash','tools/run_cargo_local.sh','build','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p','linkedspec-runtime','--bin','linkedspec-rust'])
    c.write_new('current-cli-build.json.gz',build);assert build['returncode']==0
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
    unchanged=c.unchanged(supplied['inputs']);book_unchanged=book.inputs()==books
    c.write_new('focused-final-checks.json.gz',dict(checks=checks,inputs_unchanged=unchanged,book_inputs_unchanged=book_unchanged))
    assert all(run['returncode']==0 for run in checks.values())
    assert unchanged and book_unchanged
    print('Final eight direct consumers, exact binary identities, four CLI book examples, wrong selector and focused checks PASS.',flush=True)


if __name__=='__main__':main()
