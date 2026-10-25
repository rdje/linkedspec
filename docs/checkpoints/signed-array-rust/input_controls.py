"""One-shot actual publication input denials, validator bypass and restoration."""
import copy
import json
import re
import common as c
import epoch

PUBLISH=c.PREFIX+'publish.py'
README=c.PREFIX+'README.md'
MANIFEST=c.PREFIX+'artifacts.json'
JOURNAL='.linkedspec-data/verification/signed-rust-input-control-events.jsonl'


def journal(value):
    with (c.ROOT/JOURNAL).open('a') as output:
        output.write(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n')


def restore(path,packet):
    destination=c.ROOT/path
    destination.write_bytes(c.decode(packet['base64']))
    destination.chmod(packet['mode'])
    assert c.read(path)==packet


def run():
    return c.run(['bash','tools/run_python_project_data.sh',PUBLISH])


def main():
    assert not (c.ROOT/JOURNAL).exists()
    original={path:c.read(path) for path in [PUBLISH,README,MANIFEST]}
    supplied=epoch.snapshot(['rust/linkedspec-runtime/tests/signed_array_selector_contract.rs',
        'tests/signed-array-rust/cases.json'])
    code=c.decode(original[PUBLISH]['base64']).decode()
    bypass,count=re.subn(r'(?ms)^def check_inputs\(manifest\):\n.*?(?=^def check\(\):)',
        'def check_inputs(manifest):\n    return None  # deliberate actual validator bypass\n\n\n',code)
    assert count==1 and bypass!=code
    bypass_packet=dict(base64=c.encode(bypass.encode()),sha256=c.sha(bypass.encode()),mode=original[PUBLISH]['mode'])
    journal(dict(kind='inputs',context=supplied,original=original,producer=c.read(c.PREFIX+'input_controls.py'),bypass=bypass_packet))
    baseline=run();journal(dict(kind='baseline',run=baseline));assert baseline['returncode']==0
    cases={}
    for name in ['missing','bytes','mode','required-omission']:
        assert all(c.read(path)==packet for path,packet in original.items())
        if name=='missing':
            (c.ROOT/README).unlink()
        elif name=='bytes':
            (c.ROOT/README).write_bytes(c.decode(original[README]['base64'])+b'\nDeliberate input-byte fault.\n')
        elif name=='mode':
            (c.ROOT/README).chmod(original[README]['mode']^0o100)
        else:
            manifest=json.loads(c.decode(original[MANIFEST]['base64']))
            del manifest['inputs'][README]
            (c.ROOT/MANIFEST).write_text(json.dumps(manifest,sort_keys=True,separators=(',',':'))+'\n')
        mutated={path:c.read(path) if (c.ROOT/path).exists() else None for path in original}
        journal(dict(kind='variant',name=name,sources=mutated))
        try:
            red=run();journal(dict(kind='red',name=name,run=red));assert red['returncode']!=0,name
            restore(PUBLISH,bypass_packet)
            admitted=run();journal(dict(kind='bypass',name=name,run=admitted));assert admitted['returncode']==0,name
            assert c.read(PUBLISH)==bypass_packet
            restore(PUBLISH,original[PUBLISH])
            rejected=run();journal(dict(kind='restored_rejection',name=name,run=rejected));assert rejected['returncode']!=0,name
            cases[name]=dict(mutated=mutated,red=red,bypass=admitted,restored_rejection=rejected)
        finally:
            # Only the known test variants are reverted; preserve an unexpected edit.
            current=c.read(PUBLISH)
            assert current in [original[PUBLISH],bypass_packet],'concurrent publisher edit'
            restore(PUBLISH,original[PUBLISH])
            for path in [README,MANIFEST]:
                actual=c.read(path) if (c.ROOT/path).exists() else None
                assert actual==mutated[path],'concurrent controlled-input edit: '+path
                restore(path,original[path])
        print('Actual input RED/bypass/restored rejection:',name,flush=True)
    healthy=run();journal(dict(kind='healthy',run=healthy));assert healthy['returncode']==0
    assert c.unchanged(supplied['inputs'])
    c.write_new('input-controls.json.gz',dict(context=supplied,original=original,
        producer=c.read(c.PREFIX+'input_controls.py'),actual_bypass=bypass_packet,
        baseline=baseline,cases=cases,healthy=healthy,inputs_restored=True,
        journal=c.read(JOURNAL),
        scope='Four actual physical input denials. A physically discarded validator admits each variant; restoring exact publisher bytes rejects it again. All original input/source bytes and full modes restore, with complete actual channels. The late original-input epoch remains recoverable. No historical runtime producer reruns.'))
    print('All four actual input controls and complete exact restoration PASS.',flush=True)


if __name__=='__main__':main()
