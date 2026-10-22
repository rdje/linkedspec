"""Read-only review of source-bound public, fault, permanent and book observations."""
import json
from pathlib import Path
import re
import common as c
import book
import focused
import oracle

def runtime_inputs(packet):
    inputs=packet['context']['inputs']
    for path in c.SOURCES+['perl/LinkedSpec.pm',c.PREFIX+'probe.pl',c.PREFIX+'cases.json']:
        assert inputs[path]==c.identity(path),path
    for path,item in inputs.items():
        if path.startswith(('perl/','specs/')):
            assert c.identity(path)==item,path

def check():
    plan=c.load('cases.json')
    assert c.load('cases.json')==json.loads(c.source('tests/numeric-codeblocks/registered-pipelines.json').read_bytes())
    baseline=c.load('baseline.json.gz')
    red=oracle.failures(baseline['run'],plan)
    report=c.load('baseline-review.json')
    assert report['cases']==len(plan['cases']) and report['failures']==red
    for path in c.SOURCES:
        old=c.run(['git','show',c.BASE+':'+path])
        assert old['returncode']==0
        assert c.sha(c.decode(old['stdout_base64']))==baseline['context']['inputs'][path]['sha256']
    candidate=c.load('candidate3.json.gz')
    assert candidate['inputs_unchanged'] and not candidate['failures']
    assert not oracle.failures(candidate['run'],plan)
    runtime_inputs(candidate)
    observed=json.loads(c.decode(candidate['run']['stdout_base64']))
    for path in c.SOURCES:
        assert Path(observed['inc'][path.removeprefix('perl/')]).resolve()==c.ROOT/path
    assert oracle.failures(c.load('candidate1.json.gz')['run'],plan)
    assert not oracle.failures(c.load('candidate2.json.gz')['run'],plan)
    minimal=c.load('minimal.json.gz')
    assert c.read(c.SOURCES[0])==minimal['after']
    assert not c.load('ablation-result.json')['names']['failures']
    controls=c.load('faults2-result.json')
    assert controls['sources_restored']
    before=c.load('faults2-before.json.gz')
    assert set(controls['faults'])=={task[0] for task in before['tasks']}
    for name,path,old,new,case_id in before['tasks']:
        source=before['sources'][path]
        assert c.read(path)==source
        fault=c.load('fault2-'+name+'.json.gz')
        expected=c.decode(source['base64']).decode().replace(old,new,1).encode()
        assert c.decode(fault['mutant']['base64'])==expected
        assert c.sha(expected)==fault['context']['inputs'][path]['sha256']
        failed=oracle.failures(fault['run'],fault['plan'])
        assert failed==fault['failures'] and set(failed)=={case_id}
        restored=c.load('restore2-'+name+'.json.gz')
        assert restored['sources_restored'] and not restored['failures']
        assert not oracle.failures(restored['run'],restored['plan'])
    supplied=c.load('book-inputs.json.gz')
    assert supplied['producer']==c.read(c.PREFIX+'book.py')
    assert all(c.read(path)==packet for path,packet in supplied['inputs'].items())
    book_run=c.load('book-run.json.gz')
    book.validate(book_run['builds']['healthy'],supplied['plan'])
    try:
        book.validate(book_run['builds']['changed'],supplied['plan'])
    except AssertionError as error:
        assert str(error)=='pipeline anchor'
    else:
        raise AssertionError('changed rendered heading accepted')
    assert book_run['inputs_unchanged']
    final_book=c.load('book2-run.json.gz')
    assert final_book['book_inputs_unchanged']
    assert final_book['plan']==book.examples()==supplied['plan']
    assert not oracle.failures(final_book['run'],final_book['plan'])
    runtime_inputs(final_book)
    direct=c.load('focused-run.json.gz')
    assert direct['producer']==c.read(c.PREFIX+'focused.py') and direct['suites']==focused.SUITES
    assert direct['run']['returncode']==0
    output=c.decode(direct['run']['stdout_base64'])
    match=re.search(rb'Files=(\d+), Tests=(\d+),',output)
    assert match and int(match[1])==len(focused.SUITES) and b'Result: PASS' in output
    direct_inputs=c.load('focused-inputs.json.gz')['inputs']
    for path in focused.SUITES+c.SOURCES+['tests/numeric-codeblocks/registered-pipelines.json']:
        assert c.identity(path)==direct_inputs[path],path
    artifact=c.load('artifact-run.json.gz')
    assert artifact['sources_restored']
    import publish
    actual=c.load('artifact-inputs.json.gz')
    assert artifact['original']==c.read(c.PREFIX+'publish.py')
    signature=b'def validate_inputs(declared, actual):\n'
    assert c.decode(artifact['mutant']['base64'])==c.decode(artifact['original']['base64']).replace(signature,signature+b'    return\n',1)
    for key in ('healthy','restored'):
        run=artifact[key]
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
        results=json.loads(c.decode(run['stdout_base64']))
        assert set(results)==set(actual['cases'])
        assert all(row['rejected'] and row['reason']==actual['reasons'][name] for name,row in results.items())
    assert artifact['fault']['returncode']==0
    assert all(not row['rejected'] for row in json.loads(c.decode(artifact['fault']['stdout_base64'])).values())
    assert publish.controls()==json.loads(c.decode(artifact['restored']['stdout_base64']))
    return dict(cases=len(plan['cases']),accepted_red=len(red),accepted_controls=len(plan['cases'])-len(red),
        faults=controls['faults'],direct_suites=int(match[1]),direct_tap=int(match[2]),
        book_inputs=len(supplied['inputs']),book_examples=len(final_book['plan']['cases']),artifact_denials=len(actual['cases']))

if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
