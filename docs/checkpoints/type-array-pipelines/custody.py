"""Recover exact measured epochs from whole source packets, immutable data or accepted Git."""
import json
import subprocess
import common as c

def verify():
    saved=c.load('prior.json.gz')
    assert saved['base']==c.BASE and saved['producer']==c.read(c.PREFIX+'preserve.py')
    assert len(saved['inputs'])==10608 and len(saved['logical_inputs'])==3 and len(saved['images'])==10611
    assert saved['baseline']['returncode']==0 and not c.decode(saved['baseline']['stderr_base64'])
    assert saved['status']['returncode']==0 and not c.decode(saved['status']['stdout_base64'])
    manifest=json.loads(__import__('gzip').decompress(c.decode(saved['manifest']['base64'])))
    assert manifest['inputs']==saved['inputs'] and manifest['logical_inputs']==saved['logical_inputs']
    assert json.loads(c.decode(saved['publication']['base64']))['record_base64']==saved['claim']['base64']
    current=json.loads((c.ROOT/'docs/claims/TYPE-REFERENCE-BOOK.1.2.7.json').read_bytes())
    original=json.loads(c.decode(saved['claim']['base64']))
    for item in original['claims']:item['durability'].update(mode='historical',revision=c.BASE)
    assert current==original
    git={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,path=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            git[path.decode()]=dict(mode=mode,kind=kind,oid=oid)
    assert all(item['git']==git[path] for path,item in saved['images'].items())
    assert saved['git_verification']['returncode']==0 and not c.decode(saved['git_verification']['stderr_base64'])
    assert c.decode(saved['git_verification']['stdout_base64']).decode().splitlines()==[saved['images'][p]['git']['oid'] for p in sorted(saved['images'])]
    recovered=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'recover_aggregate.py'])
    assert recovered['returncode']==0
    for path,item in saved['logical_inputs'].items():
        assert c.identity(path)=={key:item[key] for key in ('sha256','mode')}
        assert (c.ROOT/path).stat().st_size==item['size']
    contexts={name:c.load(name) for name in ('candidate1-inputs.json.gz','candidate2-inputs.json.gz',
        'candidate3-inputs.json.gz','candidate4-inputs.json.gz','accepted-inputs.json.gz','fault-inputs.json.gz',
        'focused1-inputs.json.gz','focused2-inputs.json.gz','doc-inputs.json.gz','doc2-inputs.json.gz','followup-inputs.json.gz')}
    first=c.load('report-first.json.gz')
    assert first['producer']==c.read(c.PREFIX+'report-preserve.py')
    assert first['baseline']['returncode']==0 and not c.decode(first['baseline']['stderr_base64'])
    assert b'10716 closed physical inputs;85 values/41 accepted RED/6 restored faults' in c.decode(first['baseline']['stdout_base64'])
    assert len(first['context']['inputs'])==10719
    manifest=json.loads(__import__('gzip').decompress(c.decode(first['manifest']['base64'])))
    assert len(manifest['inputs'])==10716
    assert all(first['context']['inputs'][path]==item for path,item in manifest['inputs'].items())
    publication=json.loads(c.decode(first['publication']['base64']))
    assert publication['record_base64']==first['claim']['base64'] and len(publication['result']['faults'])==7
    assert first['context']['new_inputs'][c.PREFIX+'publish.py']==first['publisher']
    contexts['report-first']=first['context']
    failed=c.load('report-writer-failure.json.gz')
    assert b'FileExistsError' in c.decode(failed['log']['base64'])
    contexts['refused-report-writer']=failed['context']
    second=c.load('reference-first.json.gz')
    assert second['producer']==c.read(c.PREFIX+'reference-preserve.py')
    assert second['baseline']['returncode']==0 and not c.decode(second['baseline']['stderr_base64'])
    assert b'7 restored faults' in c.decode(second['baseline']['stdout_base64'])
    assert c.decode(second['canonical_status']['base64'])==b'143\n'
    manifest=json.loads(__import__('gzip').decompress(c.decode(second['manifest']['base64'])))
    assert len(second['context']['inputs'])==len(manifest['inputs'])+3
    assert all(second['context']['inputs'][path]==item for path,item in manifest['inputs'].items())
    publication=json.loads(c.decode(second['publication']['base64']))
    assert publication['record_base64']==second['claim']['base64'] and len(publication['result']['faults'])==7
    assert c.load('artifact3-inputs.json.gz')['producer']==second['publisher']
    contexts['reference-second']=second['context']
    paths=set(saved['images'])
    for snapshot in contexts.values():paths.update(snapshot['inputs'])
    actual={path:c.identity(path) for path in sorted(paths)}
    cache={}
    def recover(path,item,packet=None):
        if packet is not None:
            assert c.sha(c.decode(packet['base64']))==item['sha256']==packet['sha256'] and packet['mode']==item['mode'],path
        elif actual[path]!=item:
            if path not in cache:
                raw=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
                cache[path]=c.sha(raw)
            assert cache[path]==item['sha256'] and git[path]['mode']==('100755' if item['mode']&0o111 else '100644'),path
    for path,item in saved['images'].items():recover(path,{key:item[key] for key in ('sha256','mode')})
    for name,snapshot in contexts.items():
        assert snapshot['base']==c.BASE
        for path,item in snapshot['inputs'].items():
            packet=snapshot.get('new_inputs',{}).get(path) or snapshot.get('overrides',{}).get(path)
            recover(path,item,packet)
        for item in snapshot.get('git_inputs',[]):
            raw=subprocess.check_output(['git','show',item['revision']+':'+item['path']],cwd=c.ROOT)
            assert raw==c.decode(item['base64']) and c.sha(raw)==item['sha256']
    return dict(prior_physical=10608,prior_logical=3,prior_images=10611,epochs={name:len(snapshot['inputs']) for name,snapshot in contexts.items()})

if __name__=='__main__':print(json.dumps(verify(),sort_keys=True))
