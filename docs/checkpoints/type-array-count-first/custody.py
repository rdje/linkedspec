"""Recover all supplied epochs from retained whole packets, actual files or accepted Git."""
import gzip
import json
import subprocess
import common as c


def verify():
    prior = c.load('prior.json.gz')
    assert prior['base'] == c.BASE and prior['producer'] == c.read(c.PREFIX+'preserve.py')
    assert len(prior['images']) == len(prior['inputs']) + 3
    assert prior['baseline']['returncode'] == 0 and not c.decode(prior['baseline']['stderr_base64'])
    assert prior['status']['returncode'] == 0 and not c.decode(prior['status']['stdout_base64'])
    manifest = json.loads(gzip.decompress(c.decode(prior['manifest']['base64'])))
    assert manifest['inputs'] == prior['inputs']
    original = json.loads(c.decode(prior['claim']['base64']))
    assert json.loads(c.decode(prior['publication']['base64']))['record_base64'] == prior['claim']['base64']
    for claim in original['claims']:
        claim['durability'].update(mode='historical',revision=c.BASE)
    assert json.loads(c.source('docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json').read_bytes()) == original
    git = {}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,path = row.split(b'\t',1)
            mode,kind,oid = metadata.decode().split()
            git[path.decode()] = dict(mode=mode,kind=kind,oid=oid)
    assert all(item['git'] == git[path] for path,item in prior['images'].items())
    proof = prior['git_verification']
    assert proof['returncode'] == 0 and not c.decode(proof['stderr_base64'])
    assert c.decode(proof['stdout_base64']).decode().splitlines() == [
        prior['images'][path]['git']['oid'] for path in sorted(prior['images'])]
    for path,item in prior['logical_inputs'].items():
        assert c.identity(path) == {key:item[key] for key in ('sha256','mode')}
        assert c.source(path).stat().st_size == item['size']
    packets = {}
    epochs = []

    def walk(value, label):
        if isinstance(value,dict):
            if {'sha256','mode','base64'} <= value.keys():
                raw = c.decode(value['base64'])
                assert c.sha(raw) == value['sha256'],label
                packets[(value['sha256'],value['mode'])] = True
            inputs = value.get('inputs')
            if isinstance(inputs,dict) and inputs and all(
                    isinstance(item,dict) and {'sha256','mode'} <= item.keys() for item in inputs.values()):
                epochs.append((label,inputs))
            for key,item in value.items():
                walk(item,label+'/'+key)
        elif isinstance(value,list):
            for index,item in enumerate(value):
                walk(item,label+'/'+str(index))

    for path in sorted((c.ROOT/c.PREFIX).glob('*.json*')):
        walk(c.load(path.name),path.name)
    epochs.append(('accepted13-images',{path:{key:item[key] for key in ('sha256','mode')}
        for path,item in prior['images'].items()}))
    actual = {}
    historical = {}
    recovered = 0
    for label,inputs in epochs:
        for path,item in inputs.items():
            key = (item['sha256'],item['mode'])
            if key in packets:
                continue
            if path not in actual:
                actual[path] = c.identity(path) if (c.ROOT/path).is_file() else None
            if actual[path] == {name:item[name] for name in ('sha256','mode')}:
                continue
            if path not in historical:
                assert path in git,(label,path,'no retained source or accepted Git')
                raw = subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
                historical[path] = (c.sha(raw),int(git[path]['mode'],8) & 0o7777)
            assert historical[path] == key,(label,path,'unrecoverable source bytes/mode')
            recovered += 1
    return dict(prior_physical=len(prior['inputs']),prior_logical=len(prior['logical_inputs']),
        prior_images=len(prior['images']),epochs=len(epochs),whole_packets=len(packets),
        git_recoveries=recovered)


if __name__ == '__main__':
    print(json.dumps(verify(),sort_keys=True))
