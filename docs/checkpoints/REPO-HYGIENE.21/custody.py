"""Check accepted12's complete source custody without rerunning old producers."""
import gzip
import json
import subprocess
import common as c

CLAIM = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.12.json'
OLD = 'docs/checkpoints/type-deferred-indexed-writes/'
PACKETS = dict(claim=CLAIM, publication=OLD+'publication4.json',
    manifest=OLD+'manifest4.json.gz', gateway=OLD+'publish4.py')


def validate(value):
    assert value['base'] == c.BASE and value['owner'] == c.OWNER
    actor = c.source(c.PREFIX+'activate.py').read_text()
    assert repr(c.decode(value['controller']['base64']).decode()) in actor
    assert c.sha(c.decode(value['controller']['base64'])) == value['controller']['sha256']
    assert value['status']['returncode'] == 0 and not c.decode(value['status']['stdout_base64'])
    assert value['baseline']['returncode'] == 0 and not c.decode(value['baseline']['stderr_base64']), 'actual clean baseline'
    declared = json.loads(gzip.decompress(c.decode(value['manifest']['base64'])))['inputs']
    assert declared == value['inputs'], 'accepted manifest'
    assert len(value['images']) == len(declared)+3, 'complete image population'
    assert all({key:value['images'][path][key] for key in ('sha256','mode')} == item
        for path,item in declared.items()), 'accepted byte/mode declaration'
    regular = {}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name = row.split(b'\t',1)
            mode,kind,oid = metadata.decode().split()
            if mode in ('100644','100755'):
                regular[name.decode()] = dict(mode=mode,kind=kind,oid=oid)
    assert set(regular) == set(value['images']), 'committed image population'
    assert all(image['git'] == regular[path] for path,image in value['images'].items()), 'committed image identity'
    proof = value['git_verification']
    assert proof['returncode'] == 0 and not c.decode(proof['stderr_base64'])
    assert c.decode(proof['stdout_base64']).decode().splitlines() == [
        value['images'][path]['git']['oid'] for path in sorted(value['images'])]
    for key,path in PACKETS.items():
        packet = value[key]
        raw = c.decode(packet['base64'])
        assert c.sha(raw) == packet['sha256']
        assert value['images'][path]['sha256'] == packet['sha256']
        assert value['images'][path]['mode'] == packet['mode'], 'owned full-mode packet'
        assert subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT) == raw
    original = json.loads(c.decode(value['claim']['base64']))
    assert json.loads(c.decode(value['publication']['base64']))['record'] == original
    for claim in original['claims']:
        assert claim['durability']['mode'] == 'live'
        claim['durability'].update(mode='historical',revision=c.BASE)
    assert json.loads(c.source(CLAIM).read_bytes()) == original
    assert not value['direct_intersections']
    # All live records were enumerated before writes; unrelated records remain exact.
    for path,entry in value['live_claims'].items():
        if path != CLAIM:
            assert c.read(path) == entry['packet']
    return dict(base=c.BASE,physical_inputs=len(declared),images=len(regular),
        actual_clean_readonly=0,mode_revision_only=True)


if __name__ == '__main__':
    import sys
    assert len(sys.argv) in (1,2)
    print(json.dumps(validate(c.load(sys.argv[1] if len(sys.argv)==2 else 'prior12.json.gz')),sort_keys=True))
