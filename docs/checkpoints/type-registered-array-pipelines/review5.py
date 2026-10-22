"""Review final behavior plus conservative closure and whole unpublished custody."""
import json
import common as c
import review2

def check():
    result=review2.check()
    failed=c.load('failed-capture4.json.gz')
    assert failed['status'].strip()=='1'
    assert b'NameError' in c.decode(failed['log']['base64'])
    assert c.read(c.PREFIX+'publish4.py')==failed['original'][c.PREFIX+'publish4.py']
    for path,item in failed['inputs'].items():
        if c.identity(path)==item:
            continue
        assert path in failed['original'],'failed-capture image unavailable: '+path
        packet=failed['original'][path]
        assert c.sha(c.decode(packet['base64']))==item['sha256']
        assert packet['sha256']==item['sha256'] and packet['mode']==item['mode']
    saved=c.load('publication2-preserved.json.gz')
    assert saved['readonly']['returncode']==0 and not c.decode(saved['readonly']['stderr_base64'])
    old=c.load('publication2.json')
    claim='docs/claims/'+c.OWNER+'.json'
    assert c.decode(old['record_base64'])==c.decode(saved['original'][claim]['base64'])
    assert c.read(c.PREFIX+'publication2-inputs.json.gz')==saved['original'][c.PREFIX+'publication2-inputs.json.gz']
    assert c.read(c.PREFIX+'publish2.py')==saved['original'][c.PREFIX+'publish2.py']
    for path,item in saved['inputs'].items():
        if c.identity(path)==item:
            continue
        assert path in saved['original'],'unpreserved original image: '+path
        packet=saved['original'][path]
        assert c.sha(c.decode(packet['base64']))==item['sha256']
        assert packet['sha256']==item['sha256'] and packet['mode']==item['mode']
    import publish5
    actual={p:c.identity(p) for p in publish5.input_paths()}
    publish5.validate_scope(actual)
    for path,packet in saved['required_missing'].items():
        assert path in actual
        assert actual[path]=={key:packet[key] for key in ('sha256','mode')}
        assert actual[path]==c.load('focused2-inputs.json.gz')['inputs'][path]
    scope=c.load('scope5-run.json.gz')
    assert scope['sources_restored'] and c.read(c.PREFIX+'publish5.py')==scope['original']
    raw=c.decode(scope['original']['base64'])
    marker=c.decode(scope['enumeration'])
    omitted=raw.replace(marker,b'    return sorted(set(regular_paths()) - {MANIFEST,PUBLICATION,CLAIM,TARGET})\n',1)
    bypass=omitted.replace(c.decode(scope['scope']),c.decode(scope['scope'])+b'    return\n',1)
    for name,source in [('omitted',omitted),('bypass',bypass),('validator_restored',omitted)]:
        assert c.decode(scope['sources'][name]['base64'])==source
        assert scope['runs'][name]['returncode']==0
    expected=dict(rejected=True,reason='measurement input: '+publish5.TARGET)
    for name in ('omitted','validator_restored'):
        assert json.loads(c.decode(scope['runs'][name]['stdout_base64']))==expected
    assert json.loads(c.decode(scope['runs']['bypass']['stdout_base64']))==dict(rejected=False,reason='')
    for name in ('healthy','restored'):
        assert scope[name]['returncode']==0
        assert json.loads(c.decode(scope[name]['stdout_base64']))==dict(rejected=False,reason='')
    artifact=c.load('artifact5-run.json.gz')
    inputs=c.load('artifact5-inputs.json.gz')
    assert artifact['sources_restored'] and artifact['original']==c.read(c.PREFIX+'publish5.py')
    signature=b'def validate_inputs(declared, actual):\n'
    assert c.decode(artifact['mutant']['base64'])==raw.replace(signature,signature+b'    return\n',1)
    for name in ('healthy','restored'):
        run=artifact[name]
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
        observed=json.loads(c.decode(run['stdout_base64']))
        assert set(observed)==set(inputs['cases'])
        assert all(row['rejected'] and row['reason']==inputs['reasons'][key] for key,row in observed.items())
    assert artifact['fault']['returncode']==0
    assert all(not row['rejected'] for row in json.loads(c.decode(artifact['fault']['stdout_base64'])).values())
    assert publish5.controls()==json.loads(c.decode(artifact['restored']['stdout_base64']))
    result.update(required_fixtures=len(saved['required_missing']),prior_inputs=len(saved['inputs']),
        conservative_inputs=len(actual),scope_omission_control=True,artifact_denials=len(inputs['cases']))
    return result

if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
