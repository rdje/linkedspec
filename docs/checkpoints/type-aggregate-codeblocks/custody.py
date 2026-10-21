"""Recover every measured context from whole packets, immutable artifacts or real accepted Git."""
import json
import subprocess
import common as c


def prior():
    saved=c.load('prior.json.gz')
    assert saved['base']==c.BASE and len(saved['inputs'])==10334
    assert saved['producer']==c.read(c.PREFIX+'preserve.py') and saved['primitives']==c.read(c.PREFIX+'common.py')
    manifest=json.loads(c.decode(saved['manifest']['base64']))
    assert manifest['inputs']=={path:{key:item[key] for key in ('sha256','mode')} for path,item in saved['inputs'].items()}
    assert json.loads(c.decode(saved['publication']['base64']))['record_base64']==saved['claim']['base64']
    assert c.decode(saved['baseline']['status']['base64']).strip()==b'0'
    assert b'10334 closed inputs;34 values/14 diagnostics;4 producer faults' in c.decode(saved['baseline']['log']['base64'])
    activation=json.loads(c.decode(saved['activation']['base64']))
    assert activation['head']==c.BASE and activation['status']==dict(returncode=0,stdout='',stderr='')
    tree={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            tree[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    assert all(item['git']==tree[path] for path,item in saved['inputs'].items())
    assert saved['git_verification']['returncode']==0 and not c.decode(saved['git_verification']['stderr_base64'])
    assert c.decode(saved['git_verification']['stdout_base64']).decode().splitlines()==[
        saved['inputs'][path]['git']['oid'] for path in sorted(saved['inputs'])]
    return len(saved['inputs'])


def epochs():
    names=['baseline-inputs.json.gz','red-final-inputs.json.gz','candidate1-inputs.json.gz',
        'dump-inputs.json.gz','diagnostic-inputs.json.gz','kind-history-before.json.gz',
        'kind-flags-inputs.json.gz','candidate2-inputs.json.gz','fault-inputs.json.gz',
        'accepted-inputs.json.gz','focused1-inputs.json.gz','doc-inputs.json.gz',
        'candidate3-inputs.json.gz','malformed-before-inputs.json.gz','malformed-accepted-inputs.json.gz',
        'library-actual-inputs.json.gz','guard-proof-inputs.json.gz','focused2-inputs.json.gz',
        'artifact-epoch.json.gz','admission/pressure-inputs.json.gz','admission/doc-inputs.json.gz']
    snapshots={name:c.load(name) for name in names}
    snapshots['fault-inputs.json.gz']=snapshots['fault-inputs.json.gz']['context']
    all_paths=set().union(*(set(snapshot['inputs']) for snapshot in snapshots.values()))
    current={path:c.identity(path) for path in sorted(all_paths)}
    git_cache={}
    counts={}
    for name,snapshot in snapshots.items():
        assert snapshot['base']==c.BASE
        for path,item in snapshot['inputs'].items():
            packet=snapshot.get('new_inputs',{}).get(path) or snapshot.get('overrides',{}).get(path)
            if packet is not None:
                assert c.sha(c.decode(packet['base64']))==packet['sha256']==item['sha256'],(name,path)
                assert packet['mode']==item['mode'],(name,path)
            elif current[path]!=item:
                if path not in git_cache:
                    raw=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
                    git_cache[path]=c.sha(raw)
                assert git_cache[path]==item['sha256'],(name,path)
            assert isinstance(item['mode'],int) and 0<=item['mode']<=0o7777
        for artifact in snapshot.get('git_inputs',[]):
            raw=subprocess.check_output(['git','show',artifact['revision']+':'+artifact['path']],cwd=c.ROOT)
            assert raw==c.decode(artifact['base64']) and c.sha(raw)==artifact['sha256']
        counts[name]=len(snapshot['inputs'])
    return counts


if __name__=='__main__':print(json.dumps(dict(prior=prior(),epochs=epochs()),sort_keys=True))
