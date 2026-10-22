"""Conservatively bind the regular main-repository input superset; default readonly."""
import json
import os
import subprocess
import sys
import common as c
import publish2 as prior

MANIFEST=c.PREFIX+'publication5-inputs.json.gz'
PUBLICATION=c.PREFIX+'publication5.json'
CLAIM=prior.CLAIM
TARGET=sorted(c.load('publication2-preserved.json.gz')['required_missing'])[0]

def regular_paths():
    result=set()
    rows=subprocess.check_output(['git','ls-files','--stage','-z'],cwd=c.ROOT).split(b'\0')
    for row in rows:
        if row:
            metadata,name=row.split(b'\t',1)
            mode,_,stage=metadata.split()
            assert stage==b'0'
            if mode in (b'100644',b'100755'):
                result.add(name.decode())
    for path in subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=c.ROOT).decode().split('\0'):
        if path and not (c.ROOT/path).is_symlink() and (c.ROOT/path).is_file():
            result.add(path)
    return result

def input_paths():
    return sorted(set(regular_paths()) - {MANIFEST,PUBLICATION,CLAIM})

def validate_scope(actual):
    measured=set(c.load('focused2-inputs.json.gz')['inputs'])
    missing=measured-set(actual)
    assert not missing,'measurement input: '+sorted(missing)[0] if missing else ''
    required=c.load('publication2-preserved.json.gz')['required_missing']
    for path,packet in required.items():
        assert path in actual,'required fixture: '+path
        assert actual[path]=={key:packet[key] for key in ('sha256','mode')},'fixture identity: '+path

def validate_inputs(declared, actual):
    return prior.validate_inputs(declared, actual)

def controls():
    supplied=c.load('artifact5-inputs.json.gz')
    result={}
    for name,declared in supplied['cases'].items():
        try:
            validate_inputs(declared,supplied['actual'])
        except AssertionError as error:
            result[name]=dict(rejected=True,reason=str(error))
        else:
            result[name]=dict(rejected=False,reason='')
    return result

def scope_control():
    actual={path:c.identity(path) for path in input_paths()}
    try:
        validate_scope(actual)
    except AssertionError as error:
        return dict(rejected=True,reason=str(error))
    return dict(rejected=False,reason='')

def record(result):
    value=prior.record(result)
    claim=value['claims'][0]
    claim['scope']+=' The current watchset conservatively includes every regular tracked/new nonignored main-repository file, except this claim and its current manifest/publication. It is a superset, not a minimal I/O graph. Gitlinks/symlinks and installed tool/public dependency outputs remain read-only prerequisites. Test-generated temporary inputs are reconstructible from the retained producers and complete source epochs.'
    claim['rederive']['command']='bash tools/run_python_project_data.sh '+c.PREFIX+'publish5.py'
    claim['rederive']['result']+=f" Complete measurement-epoch floor and {result['required_fixtures']} named previously omitted fixtures are gated; whole unpublished714 and actual readonly0 remain preserved."
    claim['falsify']['red_control']+=' An actual input-enumerator omission reproduces the shared watchset defect, rejects against the complete measured epoch/independent named fixture oracle, admits under actual scope-validator bypass, rejects after validator restoration and finishes with exact producer restoration.'
    bindings=[row for row in claim['durability']['inputs'] if row['path']!=prior.MANIFEST]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim['durability']['inputs']=bindings
    return value

def review_result():
    import review5
    return review5.check()

def main():
    if sys.argv[1:]==['--review']:
        print(json.dumps(review_result(),sort_keys=True))
        return
    if sys.argv[1:]==['--controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    if sys.argv[1:]==['--scope-control']:
        print(json.dumps(scope_control(),sort_keys=True))
        return
    assert sys.argv[1:] in ([],['--capture'])
    capture=sys.argv[1:]==['--capture']
    actual={p:c.identity(p) for p in input_paths()}
    validate_scope(actual)
    result=review_result()
    if capture:
        original=c.load('publication2-preserved.json.gz')['original'][CLAIM]
        assert c.read(CLAIM)==original,'original unpublished claim changed'
        c.write_new('publication5-inputs.json.gz',dict(base=c.BASE,inputs=actual,
            scope='Conservative regular main-repository superset, covering the entire measured source-epoch population and independent missing-fixture witnesses. Own claim/current manifest/publication are excluded to avoid self-binding. No minimal dependency-set or other-repository implementation claim.'))
    validate_inputs(c.load('publication5-inputs.json.gz')['inputs'],actual)
    validate_inputs(actual,{p:c.identity(p) for p in input_paths()})
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication5.json',publication)
        pending=c.ROOT/(CLAIM+'.candidate')
        try:
            with pending.open('xb') as stream:stream.write(raw)
            pending.chmod(original['mode'])
            os.replace(pending,c.ROOT/CLAIM)
        finally:
            if pending.exists():pending.unlink()
    else:
        assert c.source(CLAIM).read_bytes()==raw and c.load('publication5.json')==publication
    print('Pipeline11 publication PASS:',len(actual),'conservative inputs;',result['cases'],'cases; complete epoch/fixture closure')

if __name__=='__main__':main()
