"""Preserve the complete unpublished staged epoch before repairing book pressure."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import publish

OUT='.linkedspec-data/verification/type-aggregate-first-'


def save(name,value):
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (ROOT/(OUT+name+'.json.gz')).open('xb') as output:output.write(gzip.compress(raw,mtime=0))


def main():
    producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())
    baseline=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py'])
    save('baseline',dict(run=baseline,producer=producer))
    assert baseline['returncode']==0 and not c.decode(baseline['stderr_base64'])
    assert b'10496 closed inputs;214 cases/106 RED;7 faults' in c.decode(baseline['stdout_base64'])
    pressure=c.run(['bash','scripts/check_readme_stability.sh'])
    save('pressure',dict(run=pressure))
    assert pressure['returncode']!=0
    assert b'aggregate lines 50007/50000' in c.decode(pressure['stdout_base64'])+c.decode(pressure['stderr_base64'])
    inputs=publish.current_inputs()
    manifest=c.read(c.PREFIX+'publication-inputs.json.gz')
    assert len(inputs)==10496
    publish.validate_inputs(c.load('publication-inputs.json.gz')['inputs'],inputs)
    base={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            base[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    images={};packets={}
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        if mode not in ('100644','100755'):continue
        path=name.decode();identity=c.identity(path)
        entry=dict(mode=mode,kind='blob',oid=oid)
        images[path]=dict(**identity,git=entry,
            recovery='real accepted base' if base.get(path)==entry else 'retained packet or immutable current input')
        if base.get(path)!=entry and not path.endswith('.gz'):packets[path]=c.read(path)
    assert len(images)==10499
    assert all(images[path]['sha256']==item['sha256'] and images[path]['mode']==item['mode'] for path,item in inputs.items())
    paths=sorted(images)
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(paths)+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[images[path]['git']['oid'] for path in paths]
    assert publish.current_inputs()==inputs
    save('epoch',dict(base=c.BASE,claim=c.read('docs/claims/'+c.OWNER+'.json'),
        publication=c.read(c.PREFIX+'publication.json'),manifest=manifest,inputs=inputs,images=images,
        before=packets,git_verification=verified,baseline=baseline,pressure=pressure,producer=producer,
        scope='Complete first unpublished claim/publication/10496 input identities/full modes and actual '
              'readonly0 precede pressure correction.10499 exact staged images independently match Git '
              'object identities. Every changed/new plain source has whole bytes; unchanged source '
              'recovers from real accepted efad, and immutable gzip artifacts remain directly hash-gated. '
              'Any later changed gzip requires its own before packet. No draft Git revision is invented.'))
    print('First aggregate epoch preserved:10496 inputs/10499 staged images; actual readonly0 and pressure RED')


if __name__=='__main__':main()
