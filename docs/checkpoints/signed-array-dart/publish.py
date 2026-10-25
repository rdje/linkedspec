"""Read-only dated Dart17.4 publication; --base is control-stage review only."""
import json
import sys
import common as c
import review

REQUIRED={
    'README.md','publish.py','review.py','oracle.py','common.py','source_faults.py',
    'before-inputs.json.gz','before-run.json.gz','public3-inputs.json.gz','public3-runs.json.gz',
    'private2-copy.json.gz','private2-run.json.gz','emitted1-module-inputs.json.gz','emitted1-run.json.gz',
    'cli2-result.json.gz','component-result.json','source-fault-result.json',
    'admission-unregistered-run.json.gz','history-final-read-inputs.json.gz','history-final-run.json.gz',
    'history-final-result.json.gz','auditor-fault-result.json.gz','book-runs.json.gz',
    'book-after-inputs.json.gz','generated-error-qualification.json.gz','public1-qualification.json.gz',
    'instrument-qualification.json.gz','review-mode-qualification.json.gz','review-private-qualification.json.gz',
}


def guard(manifest):
    for name,expected in manifest.items():
        assert name==name.split('/')[-1] and name not in ('.','..'),'publication basename'
        assert c.identity(c.PREFIX+name)==expected,'publication input identity: '+name


def check(base_only=False):
    manifest=c.load('publication.json')
    assert REQUIRED<=manifest['inputs'].keys(),'required publication input omitted'
    guard(manifest['inputs'])
    result=review.check()
    result['publication_inputs']=len(manifest['inputs'])
    if not base_only:
        custody=c.load('custody.json')
        assert set(manifest['inputs'])|{'publication.json','input-controls.json.gz',
            'input-control-inputs.json.gz','review-run.json.gz'}<=custody['inputs'].keys()
        guard(custody['inputs'])
        controls=c.load('input-controls.json.gz')
        assert controls['inputs_restored'] and len(controls['cases'])==4
        assert controls['healthy']['returncode']==controls['final']['returncode']==0
        assert controls['healthy']['stdout_base64']==controls['final']['stdout_base64']
        for row in controls['cases'].values():
            assert row['red']['returncode']!=0 and row['restored_rejection']['returncode']!=0
            assert row['bypass']['returncode']==0
            assert json.loads(c.decode(row['bypass']['stdout_base64']))=={'discarded_validator':True}
        result.update(custody_inputs=len(custody['inputs']),input_faults=4)
    return result


if __name__=='__main__':
    assert sys.argv[1:] in ([],['--base'])
    print(json.dumps(check(base_only=bool(sys.argv[1:])),sort_keys=True))
