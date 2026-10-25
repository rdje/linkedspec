"""Read-only bridge and public process checks, independent of recorded booleans."""
import json
import common as c
import review_numeric as n


def bridge(stem,green):
    supplied=c.load(stem+'-inputs.json.gz')
    fixture=n.source_fixture(supplied,'tests/numeric-conversion/cases.json')
    cases={row['id']:row for row in fixture['cases'] if row['finite']}
    saved=c.load(stem+'-run.json.gz');run=saved['run']
    observed=n.rows(run,'NUMERIC_BRIDGE\t')
    wanted={(name,route) for name in cases for route in ('native','generated_plan')}
    assert len(observed)==len(wanted) and {(row['id'],row['route']) for row in observed}==wanted
    failures=[]
    for row in observed:
        target=cases[row['id']]
        actual=row['ok']['values'][0] if row['error'] is None else None
        expected={'binary64':target['bits'],'json_kind':target['json_kind'],'integer':target['integer']}
        if row['error'] is not None or not n.value(actual,expected):failures.append((row['id'],row['route']))
    assert saved['inputs_unchanged'] and saved['executable_unchanged']
    assert run['returncode']==(0 if green else 101) and (not failures)==green
    return dict(rows=len(observed),mismatches=len(failures))


def cli():
    supplied=c.load('current-cli-inputs.json.gz');saved=c.load('current-cli-runs.json.gz')
    expected={row['id']:row for row in supplied['cases']}
    observed=saved['runs'];assert len(observed)==len(expected)==52
    assert {row['id'] for row in observed}==expected.keys()
    assert saved['inputs_unchanged'] and saved['executable_unchanged']
    rejected=0
    for row in observed:
        target=expected[row['id']]['expected'];a,z=row['channels']['none'],row['channels']['low']
        if 'ok' in target:
            assert a['returncode']==z['returncode']==0
            assert n.value(json.loads(c.decode(a['stdout_base64'])),target['ok'])
            assert not c.decode(a['stderr_base64']) and not c.decode(z['stderr_base64'])
            assert b'compile:ok' in c.decode(z['stdout_base64']) and b'invoke:ok' in c.decode(z['stdout_base64'])
        else:
            rejected+=1
            assert a['returncode']==z['returncode']==1 and not c.decode(a['stdout_base64'])
            assert c.decode(a['stderr_base64'])==c.decode(z['stderr_base64'])==b'linkedspec: parser invocation failed\n'
            assert b'compile:ok' in c.decode(z['stdout_base64']) and b'invoke:error' in c.decode(z['stdout_base64'])
    functions=c.load('function-cli-inputs.json.gz')
    fixture=json.loads(c.decode(functions['fixture']['base64']))
    expected={row['id']:row for row in fixture['cases']}
    saved=c.load('function-cli-runs.json.gz');assert saved['executable_unchanged']
    assert len(saved['runs'])==len(expected)==4
    for row in saved['runs']:
        assert row['run']['returncode']==0 and n.value(json.loads(c.decode(row['run']['stdout_base64'])),expected[row['id']]['expected']['ok'])
    return dict(cases=52,channels=104,invocation_rejections=rejected,function_cases=4)


def check():return dict(bridge=bridge('bridge-after',True),cli=cli())


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
