"""Verify real accepted10 custody without rerunning its historical producer."""
import gzip
import json
import subprocess
import common as c


def validate(value):
    assert value['base'] == c.BASE and value['owner'] == c.OWNER
    assert value['producer'] == c.read(c.PREFIX+'preserve.py'), 'preservation producer'
    assert value['status']['returncode'] == 0 and not c.decode(value['status']['stdout_base64'])
    assert value['baseline']['returncode'] == 0 and not c.decode(value['baseline']['stderr_base64']), 'actual clean baseline'
    declared = json.loads(gzip.decompress(c.decode(value['manifest']['base64'])))['inputs']
    assert declared == value['inputs'], 'accepted manifest'
    assert len(value['images']) == len(declared)+3, 'complete image population'
    assert all({key:value['images'][path][key] for key in ('sha256','mode')} == item for path,item in declared.items())
    git = {}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name = row.split(b'\t',1)
            mode,kind,oid = metadata.decode().split()
            git[name.decode()] = dict(mode=mode,kind=kind,oid=oid)
    regular = {path:entry for path,entry in git.items() if entry['mode'] in ('100644','100755')}
    assert set(regular) == set(value['images']), 'committed image population'
    for path,image in value['images'].items():
        assert image['git'] == regular[path], 'committed image identity'
        assert image['mode'] == int(regular[path]['mode'],8)&0o7777, 'committed full mode'
    proof = value['git_verification']
    assert proof['returncode'] == 0 and not c.decode(proof['stderr_base64'])
    assert c.decode(proof['stdout_base64']).decode().splitlines() == [
        value['images'][path]['git']['oid'] for path in sorted(value['images'])]
    original = json.loads(c.decode(value['claim']['base64']))
    publication = json.loads(c.decode(value['publication']['base64']))
    assert publication['record_base64'] == value['claim']['base64']
    for claim in original['claims']:
        assert claim['durability']['mode'] == 'live'
        claim['durability'].update(mode='historical',revision=c.BASE)
    assert json.loads(c.source('docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json').read_bytes()) == original
    for key,path in [('claim','docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json'),
                     ('publication','docs/checkpoints/type-array-count-first/publication4.json'),
                     ('manifest','docs/checkpoints/type-array-count-first/publication4-inputs.json.gz'),
                     ('gateway','docs/checkpoints/type-array-count-first/publish.py')]:
        raw = subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
        assert raw == c.decode(value[key]['base64']), 'accepted packet bytes'
    for path,item in value['logical_inputs'].items():
        assert c.identity(path) == {key:item[key] for key in ('sha256','mode')}
        assert c.source(path).stat().st_size == item['size']
    return dict(base=c.BASE,physical_inputs=len(declared),images=len(value['images']),
        older_logical_aliases=len(value['logical_inputs']),actual_clean_readonly=0)


if __name__ == '__main__':
    import sys
    assert len(sys.argv) in (1,2)
    print(json.dumps(validate(c.load(sys.argv[1] if len(sys.argv)==2 else 'prior10.json.gz')),sort_keys=True))
