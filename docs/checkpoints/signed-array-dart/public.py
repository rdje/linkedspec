"""One-shot whole-input/AOT public matrix and permanent test capture."""
import json
import sys
import common as c
import oracle


def main(label):
    assert label.startswith('public') and label[6:].isdigit(), label
    fixture='tests/signed-array-dart/cases.json'
    extras=[fixture, 'tests/signed-array-dart/observe.dart',
        'dart/test/signed_array_selector_contract_test.dart',
        'examples/negative-array-current-perl.spec',
        'examples/negative-array-current-callable-perl.spec',
        'examples/negative-array-write-perl.spec',
        'examples/negative-array-write-callable-perl.spec']
    supplied=c.context(extras)
    c.save(label+'-inputs.json.gz', supplied)
    executable='.linkedspec-data/verification/signed-dart17-'+label
    assert not (c.ROOT/executable).exists()
    build=c.run(['bash','tools/run_dart_project_data.sh','compile','exe',
        '--packages=dart/.dart_tool/package_config.json',c.PREFIX+'matrix.dart', '-o',executable])
    c.save(label+'-build.json.gz',build)
    assert build['returncode']==0, c.decode(build['stderr_base64']).decode()
    artifact=c.archive(executable,label+'-native')
    c.save(label+'-binary.json',artifact)
    run=c.run([executable,fixture])
    tests=c.run(['bash','../tools/run_dart_project_data.sh','test',
        'test/signed_array_selector_contract_test.dart','--reporter=expanded'],cwd=c.ROOT/'dart')
    stable=c.identity(executable)=={key:artifact[key] for key in ('sha256','mode')}
    inputs_stable=c.unchanged(supplied['inputs'])
    c.save(label+'-runs.json.gz',dict(matrix=run,tests=tests,
        inputs_unchanged=inputs_stable,executable_unchanged=stable))
    assert run['returncode']==0 and stable and inputs_stable
    result=oracle.review(c.decode(run['stdout_base64']), json.loads(c.file(fixture).read_bytes())['cases'])
    c.save(label+'-result.json.gz',result)
    print(json.dumps({key:result[key] for key in ('programs','observations','failure_count')}
        | dict(test_returncode=tests['returncode']),sort_keys=True),flush=True)
    if result['failures']:
        print(json.dumps(result['failures'][:8],ensure_ascii=False,indent=2),flush=True)
    assert not result['failures'] and tests['returncode']==0


if __name__=='__main__':
    assert len(sys.argv)==2
    main(sys.argv[1])
