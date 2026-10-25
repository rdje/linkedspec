"""One current build and exact direct execution of eight dependent targets."""
import json
from pathlib import Path
import common as c

TARGETS=['write_vivification_contract','receiver_write_context_contract',
    'scalar_numeric_contract','callable_codeblock_literal_contract',
    'uniform_binding_contract','integration_test','corpus_oracle','signed_array_selector_contract']


def main():
    extras=['rust/linkedspec-core/src/numeric.rs',
        'rust/linkedspec-core/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_bridge_contract.rs']
    extras += [file.relative_to(c.ROOT).as_posix() for file in
        (c.ROOT/'tests/numeric-conversion').glob('*') if file.is_file()]
    supplied=c.context(extras)
    c.save('compatibility-inputs.json.gz',dict(context=supplied,targets=TARGETS))
    args=['bash','tools/run_cargo_local.sh','test','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p','linkedspec-runtime','--no-run','--message-format=json']
    for target in TARGETS:args += ['--test',target]
    build=c.run(args);c.save('compatibility-build.json.gz',build);assert build['returncode']==0
    artifacts={}
    for line in c.decode(build['stdout_base64']).splitlines():
        row=json.loads(line)
        if row.get('reason')=='compiler-artifact' and row.get('executable') and row['target']['name'] in TARGETS:
            target=row['target']['name'];assert target not in artifacts
            file=Path(row['executable']);path=file.relative_to(c.ROOT).as_posix()
            artifacts[target]=dict(path=path,artifact=c.archive(file,'compatibility-'+target))
    assert set(artifacts)==set(TARGETS)
    c.save('compatibility-binaries.json',artifacts)
    runs={};children=[]
    for target in TARGETS:
        item=artifacts[target]
        run=c.run([str(c.ROOT/item['path']),'--nocapture'],cwd=c.ROOT/'rust/linkedspec-runtime')
        stable=c.identity(item['path'])=={key:item['artifact'][key] for key in ('sha256','mode')}
        c.save('compatibility-'+target+'-run.json.gz',dict(run=run,executable_unchanged=stable))
        assert run['returncode']==0 and stable,target
        runs[target]=dict(returncode=run['returncode'],executable_unchanged=stable)
        if target=='signed_array_selector_contract':
            lines=c.decode(run['stdout_base64']).decode().splitlines()
            reports=[json.loads(line.split('SIGNED_ARRAY_EMITTED_EXECUTABLE ',1)[1])
                for line in lines if 'SIGNED_ARRAY_EMITTED_EXECUTABLE ' in line]
            assert len(reports)==1
            report=reports[0];file=c.source(report['path'])
            saved=c.archive(file,'compatibility-signed-child')
            assert saved['sha256']==report['sha256'] and saved['bytes']==report['bytes'] \
                and saved['mode']==report['mode']
            children.append(dict(before_execution_report=report,artifact=saved,
                scope='The unchanged permanent parent hashes the child before direct execution. '
                    'Whole child bytes are retained afterward and match that exact prior '
                    'SHA/size/mode; no second Cargo invocation occurs between them. '
                    'Parent output retains actual module/manifest/lock/build/run channels.'))
        print('Compatibility target PASS:',target,flush=True)
    stable=c.unchanged(supplied['inputs'])
    c.save('compatibility-result.json.gz',dict(runs=runs,children=children,inputs_unchanged=stable))
    assert stable


if __name__=='__main__':
    main()
