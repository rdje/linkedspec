"""Actual missing/byte/mode/required-omission controls and publisher bypass."""
import json
import common as c

TARGET=c.PREFIX+'core-after-complete-run.json.gz'
PUBLISHER=c.PREFIX+'publish.py'


def write(path,packet):
    (c.ROOT/path).write_bytes(c.decode(packet['base64']))
    (c.ROOT/path).chmod(packet['mode'])


def run():
    return c.run(['bash','tools/run_python_project_data.sh',PUBLISHER,'--provisional'])


def main():
    manifest=c.read(c.PREFIX+'publication.json');before=c.read(TARGET);publisher=c.read(PUBLISHER)
    assert c.load('publication.json')['provisional']
    baseline=run();assert baseline['returncode']==0
    source=c.decode(publisher['base64'])
    marker=b'def check(provisional=False):\n'
    assert source.count(marker)==1
    bad=source.replace(marker,marker+b'    return {"bypassed": True}\n',1)
    faulty=dict(base64=c.encode(bad),sha256=c.sha(bad),mode=publisher['mode'])
    lease=c.ROOT/'.linkedspec-data/verification/numeric55-input-lease.json'
    assert not lease.exists()
    lease.write_text(json.dumps(dict(owner=c.OWNER,target=TARGET,before=before,
        publisher=publisher,manifest=manifest),indent=2)+'\n')
    observed={}
    try:
        for name in ['missing','bytes','mode','required-omission']:
            write(TARGET,before);write(PUBLISHER,publisher);write(c.PREFIX+'publication.json',manifest)
            if name in ('missing','required-omission'):(c.ROOT/TARGET).unlink()
            elif name=='bytes':(c.ROOT/TARGET).write_bytes(c.decode(before['base64'])+b'corrupt')
            else:(c.ROOT/TARGET).chmod(before['mode']^0o100)
            altered_manifest=None
            if name=='required-omission':
                altered_manifest=json.loads(c.decode(manifest['base64']))
                del altered_manifest['inputs']['core-after-complete-run.json.gz']
                (c.ROOT/c.PREFIX/'publication.json').write_text(json.dumps(altered_manifest,sort_keys=True,separators=(',',':'))+'\n')
            actual=c.read(TARGET) if (c.ROOT/TARGET).exists() else None
            rejected=run();assert rejected['returncode']!=0
            write(PUBLISHER,faulty)
            admitted=run();assert admitted['returncode']==0
            assert json.loads(c.decode(admitted['stdout_base64']))=={'bypassed':True}
            write(PUBLISHER,publisher)
            again=run();assert again['returncode']!=0
            observed[name]=dict(input=actual,manifest=altered_manifest,rejected=rejected,
                bypass_admitted=admitted,restored_validator_rejected=again)
    finally:
        write(TARGET,before);write(PUBLISHER,publisher);write(c.PREFIX+'publication.json',manifest)
        assert c.read(TARGET)==before and c.read(PUBLISHER)==publisher
        assert c.read(c.PREFIX+'publication.json')==manifest
        lease.unlink()
    restored=run();assert restored['returncode']==0
    assert json.loads(c.decode(restored['stdout_base64']))==json.loads(c.decode(baseline['stdout_base64']))
    c.save('input-controls.json.gz',dict(producer=c.read(c.PREFIX+'input_controls.py'),
        original_input=before,original_manifest=manifest,original_publisher=publisher,
        faulty_publisher=faulty,baseline=baseline,controls=observed,restored=restored,
        scope='Four actual physical input failures, each admitted by an actual '
            'discarded publisher and rejected again after exact source restoration. '
            'The provisional mode omits only this not-yet-created control record; '
            'final sealing adds it and default publication review requires it.'))
    print('Four physical input denials/actual bypasses/exact restoration PASS.')


if __name__=='__main__':main()
